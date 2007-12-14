#
# = bio/db/kegg/genes.rb - KEGG/GENES database class
#
# Copyright::   Copyright (C) 2001, 2002, 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: genes.rb,v 0.26 2007/12/14 16:20:38 k Exp $
#
#
# == KEGG GENES parser
#
# See http://www.genome.jp/kegg/genes.html
#
#
# === Examples
# 
#  require 'bio/io/fetch'
#  entry_string = Bio::Fetch.query('genes', 'b0002')
# 
#  entry = Bio::KEGG::GENES.new(entry_string)
# 
#  # ENTRY
#  p entry.entry       # => Hash
#
#  p entry.entry_id    # => String
#  p entry.division    # => String
#  p entry.organism    # => String
# 
#  # NAME
#  p entry.name        # => String
#  p entry.genes       # => Array
#  p entry.gene        # => String
# 
#  # DEFINITION
#  p entry.definition  # => String
#  p entry.eclinks     # => Array
# 
#  # PATHWAY
#  p entry.pathway     # => String
#  p entry.pathways    # => Array
# 
#  # POSITION
#  p entry.position    # => String
#  p entry.chromosome  # => String
#  p entry.gbposition  # => String
#  p entry.locations   # => Bio::Locations
#
#  # MOTIF
#  p entry.motif       # => Hash of Array
#
#  # DBLINKS
#  p entry.dblinks     # => Hash of Array
# 
#  # CODON_USAGE
#  p entry.codon_usage # => Hash
#  p entry.cu_list     # => Array
# 
#  # AASEQ
#  p entry.aaseq       # => Bio::Sequence::AA
#  p entry.aalen       # => Fixnum
# 
#  # NTSEQ
#  p entry.ntseq       # => Bio::Sequence::NA
#  p entry.naseq       # => Bio::Sequence::NA
#  p entry.ntlen       # => Fixnum
#  p entry.nalen       # => Fixnum
# 

module Bio

  autoload :KEGGDB,    'bio/db'
  autoload :Locations, 'bio/location'
  autoload :Sequence,  'bio/sequence'

class KEGG

class GENES < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end


  def entry
    unless @data['ENTRY']
      hash = Hash.new('')
      if get('ENTRY').length > 30
        e = get('ENTRY')
        hash['id']       = e[12..29].strip
        hash['division'] = e[30..39].strip
        hash['organism'] = e[40..80].strip
      end
      @data['ENTRY'] = hash
    end
    @data['ENTRY']
  end

  def entry_id
    entry['id']
  end

  def division
    entry['division']			# CDS, tRNA etc.
  end

  def organism
    entry['organism']			# H.sapiens etc.
  end

  def name
    field_fetch('NAME')
  end

  def genes
    name.split(', ')
  end

  def gene
    genes.first
  end

  def definition
    field_fetch('DEFINITION')
  end

  def eclinks
    ec_list = definition.slice(/\[EC:(.*?)\]/, 1)
    if ec_list
      ec_list.strip.split(/\s+/)
    else
      []
    end
  end

  def orthologs
    lines_fetch('ORTHOLOGY')
  end

  def pathway
    field_fetch('PATHWAY')
  end

  def pathways
    pathway.scan(/\[PATH:(.*?)\]/).flatten
  end

  def position
    unless @data['POSITION']
      @data['POSITION'] = fetch('POSITION').gsub(/\s/, '')
    end
    @data['POSITION']
  end

  def chromosome
    if position[/:/]
      position.sub(/:.*/, '')
    elsif ! position[/\.\./]
      position
    else
      nil
    end
  end

  def gbposition
    position.sub(/.*?:/, '')
  end

  def locations
    Bio::Locations.new(gbposition)
  end

  def motif
    unless @data['MOTIF']
      hash = {}
      db = nil
      lines_fetch('MOTIF').each do |line|
        if line[/^\S+:/]
          db, str = line.split(/:/)
        else
          str = line
        end
        hash[db] ||= []
        hash[db] += str.strip.split(/\s+/)
      end
      @data['MOTIF'] = hash
    end
    @data['MOTIF']		# Hash of Array of IDs in MOTIF
  end

  def dblinks
    unless @data['DBLINKS']
      hash = {}
      get('DBLINKS').scan(/(\S+):\s*(.*)\n?/).each do |db, str|
        id_array = str.strip.split(/\s+/)
        hash[db] = id_array
      end
      @data['DBLINKS'] = hash
    end
    @data['DBLINKS']		# Hash of Array of IDs in DBLINKS
  end

  def codon_usage(codon = nil)
    unless @data['CODON_USAGE']
      hash = Hash.new
      list = cu_list
      base = %w(t c a g)
      base.each_with_index do |x, i|
        base.each_with_index do |y, j|
          base.each_with_index do |z, k|
            hash["#{x}#{y}#{z}"] = list[i*16 + j*4 + k]
          end
        end
      end
      @data['CODON_USAGE'] = hash
    end
    @data['CODON_USAGE']
  end

  def cu_list
    ary = []
    get('CODON_USAGE').sub(/.*/,'').each_line do |line|	# cut 1st line
      line.chomp.sub(/^.{11}/, '').scan(/..../) do |cu|
        ary.push(cu.to_i)
      end
    end
    return ary
  end

  def aaseq
    unless @data['AASEQ']
      @data['AASEQ'] = Bio::Sequence::AA.new(fetch('AASEQ').gsub(/\d+/, ''))
    end
    @data['AASEQ']
  end

  def aalen
    fetch('AASEQ')[/\d+/].to_i
  end

  def ntseq
    unless @data['NTSEQ']
      @data['NTSEQ'] = Bio::Sequence::NA.new(fetch('NTSEQ').gsub(/\d+/, ''))
    end
    @data['NTSEQ']
  end
  alias naseq ntseq

  def ntlen
    fetch('NTSEQ')[/\d+/].to_i
  end
  alias nalen ntlen

end

end # KEGG
end # Bio



