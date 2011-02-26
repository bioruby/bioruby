#
# = bio/db/kegg/genome.rb - KEGG/GENOME database class
#
# Copyright::  Copyright (C) 2001, 2002, 2007 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/db'
require 'bio/reference'
require 'bio/db/kegg/common'

module Bio
class KEGG

# == Description
#
# Parser for the KEGG GENOME database
#
# == References
#
# * ftp://ftp.genome.jp/pub/kegg/genomes/genome
# * http://www.genome.jp/dbget-bin/www_bfind?genome
# * http://www.genome.jp/kegg/catalog/org_list.html
#
class GENOME < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  include Common::References
  # REFERENCE -- Returns contents of the REFERENCE records as an Array of
  # Bio::Reference objects.
  def references; super; end if false #dummy for RDoc


  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # (private) Returns a tag name of the field as a String.
  # Needed to redefine because of the PLASMID field.
  def tag_get(str)
    if /\APLASMID\s+/ =~ str.to_s then
      'PLASMID'
    else
      super(str)
    end
  end
  private :tag_get

  # (private) Returns a String of the field without a tag name.
  # Needed to redefine because of the PLASMID field.
  def tag_cut(str)
    if /\APLASMID\s+/ =~ str.to_s then
      $'
    else
      super(str)
    end
  end
  private :tag_cut

  # ENTRY -- Returns contents of the ENTRY record as a String.
  def entry_id
    field_fetch('ENTRY')[/\S+/]
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

  # DATA_SOURCE -- Returns contents of the DATA_SOURCE record as a String.
  def data_source
    field_fetch('DATA_SOURCE')
  end

  # ORIGINAL_DB -- Returns contents of the ORIGINAL_DB record as a String.
  def original_db
    #field_fetch('ORIGINAL_DB')
    unless defined?(@original_db)
      @original_db = fetch('ORIGINAL_DB')
    end
    @original_db
  end

  # Returns ORIGINAL_DB record as an Array containing String objects.
  #
  # ---
  # *Arguments*:
  # *Returns*:: Array containing String objects
  def original_databases
    lines_fetch('ORIGINAL_DB')
  end

  # DISEASE -- Returns contents of the COMMENT record as a String.
  def disease
    field_fetch('DISEASE')
  end

  # COMMENT -- Returns contents of the COMMENT record as a String.
  def comment
    field_fetch('COMMENT')
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

  # STATISTICS -- Returns contents of the STATISTICS record as a Hash.
  def statistics
    unless @data['STATISTICS']
      hash = Hash.new(0.0)
      get('STATISTICS').each_line do |line|
        case line
        when /nucleotides:\s+(\d+)/
          hash['num_nuc'] = $1.to_i
        when /protein genes:\s+(\d+)/
          hash['num_gene'] = $1.to_i
        when /RNA genes:\s+(\d+)/
          hash['num_rna'] = $1.to_i
        end
      end
      @data['STATISTICS'] = hash
    end
    @data['STATISTICS']
  end

  # Returns number of nucleotides from the STATISTICS record as a Fixnum.
  def nalen
    statistics['num_nuc']
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

end # GENOME
    
end # KEGG
end # Bio

