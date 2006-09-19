#
# = bio/db/kegg/genome.rb - KEGG/GENOME database class
#
# Copyright::  Copyright (C) 2001, 2002 Toshiaki Katayama <k@bioruby.org>
# License::    Ruby's
#
# $Id: genome.rb,v 0.15 2006/09/19 05:52:45 k Exp $
#

require 'bio/db'

module Bio
class KEGG

# == Description
#
# Parser for the KEGG GENOME database
#
# == References
#
# * ftp://ftp.genome.jp/pub/kegg/genomes/genome
#
class GENOME < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end


  # ENTRY -- Returns contents of the ENTRY record as a String.
  def entry_id
    field_fetch('ENTRY')
  end
  
  # NAME -- Returns contents of the NAME record as a String.
  def name
    field_fetch('NAME')
  end

  # DEFINITION -- Returns contents of the DEFINITION record as a String.
  def definition
    field_fetch('DEFINITION')
  end
  alias organism definition

  # TAXONOMY -- Returns contents of the TAXONOMY record as a Hash.
  def taxonomy
    unless @data['TAXONOMY']
      taxid, lineage = subtag2array(get('TAXONOMY'))
      taxid   = taxid   ? truncate(tag_cut(taxid))   : ''
      lineage = lineage ? truncate(tag_cut(lineage)) : ''
      @data['TAXONOMY'] = {
        'taxid'	=> taxid,
        'lineage'	=> lineage,
      }
      @data['TAXONOMY'].default = ''
    end
    @data['TAXONOMY']
  end

  # Returns NCBI taxonomy ID from the TAXONOMY record as a String.
  def taxid
    taxonomy['taxid']
  end

  # Returns contents of the TAXONOMY/LINEAGE record as a String.
  def lineage
    taxonomy['lineage']
  end

  # COMMENT -- Returns contents of the COMMENT record as a String.
  def comment
    field_fetch('COMMENT')
  end
  
  # REFERENCE -- Returns contents of the REFERENCE records as an Array of
  # Bio::Reference objects.
  def references
    unless @data['REFERENCE']
      ary = []
      toptag2array(get('REFERENCE')).each do |ref|
        hash = Hash.new('')
        subtag2array(ref).each do |field|
          case tag_get(field)
          when /AUTHORS/
            authors = truncate(tag_cut(field))
            authors = authors.split(', ')
            authors[-1] = authors[-1].split(/\s+and\s+/)
            authors = authors.flatten.map { |a| a.sub(',', ', ') }
            hash['authors']	= authors
          when /TITLE/
            hash['title']	= truncate(tag_cut(field))
          when /JOURNAL/
            journal = truncate(tag_cut(field))
            if journal =~ /(.*) (\d+):(\d+)-(\d+) \((\d+)\) \[UI:(\d+)\]$/
              hash['journal']	= $1
              hash['volume']	= $2
              hash['pages']		= $3
              hash['year']		= $5
              hash['medline']	= $6
            else
              hash['journal'] = journal
            end
          end
        end
        ary.push(Reference.new(hash))
      end
      @data['REFERENCE'] = References.new(ary)
    end
    @data['REFERENCE']
  end

  # CHROMOSOME -- Returns contents of the CHROMOSOME records as an Array
  # of Hash.
  def chromosomes
    unless @data['CHROMOSOME']
      @data['CHROMOSOME'] = []
      toptag2array(get('CHROMOSOME')).each do |chr|
        hash = Hash.new('')
        subtag2array(chr).each do |field|
          hash[tag_get(field)] = truncate(tag_cut(field))
        end
        @data['CHROMOSOME'].push(hash)
      end
    end
    @data['CHROMOSOME']
  end

  # PLASMID -- Returns contents of the PLASMID records as an Array of Hash.
  def plasmids
    unless @data['PLASMID']
      @data['PLASMID'] = []
      toptag2array(get('PLASMID')).each do |chr|
        hash = Hash.new('')
        subtag2array(chr).each do |field|
          hash[tag_get(field)] = truncate(tag_cut(field))
        end
        @data['PLASMID'].push(hash)
      end
    end
    @data['PLASMID']
  end

  # SCAFFOLD -- Returns contents of the SCAFFOLD records as an Array of Hash.
  def scaffolds
    unless @data['SCAFFOLD']
      @data['SCAFFOLD'] = []
      toptag2array(get('SCAFFOLD')).each do |chr|
        hash = Hash.new('')
        subtag2array(chr).each do |field|
          hash[tag_get(field)] = truncate(tag_cut(field))
        end
        @data['SCAFFOLD'].push(hash)
      end
    end
    @data['SCAFFOLD']
  end

  # STATISTICS -- Returns contents of the STATISTICS record as a Hash.
  def statistics
    unless @data['STATISTICS']
      hash = Hash.new(0.0)
      get('STATISTICS').each_line do |line|
        case line
        when /nucleotides:\s+(\d+)/
          hash['nalen'] = $1.to_i
        when /protein genes:\s+(\d+)/
          hash['num_gene'] = $1.to_i
        when /RNA genes:\s+(\d+)/
          hash['num_rna'] = $1.to_i
        when /G\+C content:\s+(\d+.\d+)/
          hash['gc'] = $1.to_f
        end
      end
      @data['STATISTICS'] = hash
    end
    @data['STATISTICS']
  end

  # Returns number of nucleotides from the STATISTICS record as a Fixnum.
  def nalen
    statistics['nalen']
  end
  alias length nalen

  # Returns number of protein genes from the STATISTICS record as a Fixnum.
  def num_gene
    statistics['num_gene']
  end

  # Returns number of rna from the STATISTICS record as a Fixnum.
  def num_rna
    statistics['num_rna']
  end

  # Returns G+C content from the STATISTICS record as a Float.
  def gc
    statistics['gc']
  end

  # GENOMEMAP -- Returns contents of the GENOMEMAP record as a String.
  def genomemap
    field_fetch('GENOMEMAP')
  end

end # GENOME
    
end # KEGG
end # Bio



if __FILE__ == $0

  begin
    require 'pp'
    def p(arg); pp(arg); end
  rescue LoadError
  end

  require 'bio/io/flatfile'

  ff = Bio::FlatFile.new(Bio::KEGG::GENOME, ARGF)

  ff.each do |genome|

    puts "### Tags"
    p genome.tags

    [
      %w( ENTRY entry_id ),
      %w( NAME name ),
      %w( DEFINITION definition ),
      %w( TAXONOMY taxonomy taxid lineage ),
      %w( REFERENCE references ),
      %w( CHROMOSOME chromosomes ),
      %w( PLASMID plasmids ),
      %w( SCAFFOLD plasmids ),
      %w( STATISTICS statistics nalen num_gene num_rna gc ),
      %w( GENOMEMAP genomemap ),
    ].each do |x|
      puts "### " + x.shift
      x.each do |m|
        p genome.send(m)
      end
    end

  end

end


