#
# = bio/db/kegg/genes.rb - KEGG/GENES database class
#
# Copyright::   Copyright (C) 2001, 2002, 2006, 2010
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id:$
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
#  p entry.names       # => Array
# 
#  # DEFINITION
#  p entry.definition  # => String
#  p entry.eclinks     # => Array
# 
#  # PATHWAY
#  p entry.pathway     # => String
#  p entry.pathways    # => Hash
# 
#  # POSITION
#  p entry.position    # => String
#  p entry.chromosome  # => String
#  p entry.gbposition  # => String
#  p entry.locations   # => Bio::Locations
#
#  # MOTIF
#  p entry.motifs      # => Hash of Array
#
#  # DBLINKS
#  p entry.dblinks     # => Hash of Array
# 
#  # STRUCTURE
#  p entry.structure   # => Array
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

  autoload :Locations, 'bio/location' unless const_defined?(:Locations)
  autoload :Sequence,  'bio/sequence' unless const_defined?(:Sequence)

  require 'bio/db'
  require 'bio/db/kegg/common'

class KEGG

# == Description
#
# KEGG GENES entry parser.
#
# == References
#
# * http://www.genome.jp/kegg/genes.html
#
class GENES < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  include Common::DblinksAsHash
  # Returns a Hash of the DB name and an Array of entry IDs in DBLINKS field.
  def dblinks_as_hash; super; end if false #dummy for RDoc
  alias dblinks dblinks_as_hash

  include Common::PathwaysAsHash
  # Returns a Hash of the pathway ID and name in PATHWAY field.
  def pathways_as_hash; super; end if false #dummy for RDoc
  alias pathways pathways_as_hash

  include Common::OrthologsAsHash
  # Returns a Hash of the orthology ID and definition in ORTHOLOGY field.
  def orthologs_as_hash; super; end if false #dummy for RDoc
  alias orthologs orthologs_as_hash

  include Common::DiseasesAsHash
  # Returns a Hash of the disease ID and its definition
  def diseases_as_hash; super; end if false #dummy for RDoc
  alias diseases diseases_as_hash

  # Creates a new Bio::KEGG::GENES object.
  # ---
  # *Arguments*:
  # * (required) _entry_: (String) single entry as a string
  # *Returns*:: Bio::KEGG::GENES object
  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # Returns the "ENTRY" line content as a Hash.
  # For example, 
  #   {"organism"=>"E.coli", "division"=>"CDS", "id"=>"b0356"}
  #
  # ---
  # *Returns*:: Hash
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

  # ID of the entry, described in the ENTRY line.
  # ---
  # *Returns*:: String
  def entry_id
    entry['id']
  end

  # Division of the entry, described in the ENTRY line.
  # ---
  # *Returns*:: String
  def division
    entry['division']			# CDS, tRNA etc.
  end

  # Organism name of the entry, described in the ENTRY line.
  # ---
  # *Returns*:: String
  def organism
    entry['organism']			# H.sapiens etc.
  end

  # Returns the NAME line.
  # ---
  # *Returns*:: String
  def name
    field_fetch('NAME')
  end

  # Names of the entry as an Array, described in the NAME line.
  #
  # ---
  # *Returns*:: Array containing String
  def names_as_array
    name.split(', ')
  end
  alias names names_as_array

  # The method will be deprecated. Use Bio::KEGG::GENES#names.
  #
  # Names of the entry as an Array, described in the NAME line.
  #
  # ---
  # *Returns*:: Array containing String
  def genes
    names_as_array
  end

  # The method will be deprecated.
  # Use <tt>entry.names.first</tt> instead.
  #
  # Returns the first gene name described in the NAME line.
  # ---
  # *Returns*:: String
  def gene
    genes.first
  end

  # Definition of the entry, described in the DEFINITION line.
  # ---
  # *Returns*:: String
  def definition
    field_fetch('DEFINITION')
  end

  # Enzyme's EC numbers shown in the DEFINITION line.
  # ---
  # *Returns*:: Array containing String
  def eclinks
    unless defined? @eclinks
      ec_list = 
        definition.slice(/\[EC\:([^\]]+)\]/, 1) ||
        definition.slice(/\(EC\:([^\)]+)\)/, 1)
      ary = ec_list ? ec_list.strip.split(/\s+/) : []
      @eclinks = ary
    end
    @eclinks
  end

  # Orthologs described in the ORTHOLOGY lines.
  # ---
  # *Returns*:: Array containing String
  def orthologs_as_strings
    lines_fetch('ORTHOLOGY')
  end

  # Returns the PATHWAY lines as a String.
  # ---
  # *Returns*:: String
  def pathway
    unless defined? @pathway
      @pathway = fetch('PATHWAY')
    end
    @pathway
  end

  # Pathways described in the PATHWAY lines.
  # ---
  # *Returns*:: Array containing String
  def pathways_as_strings
    lines_fetch('PATHWAY')
  end

  # Networks described in the NETWORK lines.
  # ---
  # *Returns*:: Array containing String
  def networks_as_strings
    lines_fetch('NETWORK')
  end

  # Diseases described in the DISEASE lines.
  # ---
  # *Returns*:: Array containing String
  def diseases_as_strings
    lines_fetch('DISEASE')
  end
  
  # Drug targets described in the DRUG_TARGET lines.
  # ---
  # *Returns*:: Array containing String
  def drug_targets_as_strings
    lines_fetch('DRUG_TARGET')
  end

  # Returns CLASS field of the entry.
  def keggclass
    field_fetch('CLASS')
  end

  # Returns an Array of biological classes in CLASS field.
  def keggclasses
    keggclass.gsub(/ \[[^\]]+/, '').split(/\] ?/)
  end

  # The position in the genome described in the POSITION line.
  # ---
  # *Returns*:: String
  def position
    unless @data['POSITION']
      @data['POSITION'] = fetch('POSITION').gsub(/\s/, '')
    end
    @data['POSITION']
  end

  # Chromosome described in the POSITION line.
  # ---
  # *Returns*:: String or nil
  def chromosome
    if position[/:/]
      position.sub(/:.*/, '')
    elsif ! position[/\.\./]
      position
    else
      nil
    end
  end

  # The position in the genome described in the POSITION line
  # as GenBank feature table location formatted string.
  # ---
  # *Returns*:: String
  def gbposition
    position.sub(/.*?:/, '')
  end

  # The position in the genome described in the POSITION line
  # as Bio::Locations object.
  # ---
  # *Returns*:: Bio::Locations object
  def locations
    Bio::Locations.new(gbposition)
  end

  # Motif information described in the MOTIF lines.
  # ---
  # *Returns*:: Strings
  def motifs_as_strings
    lines_fetch('MOTIF')
  end

  # Motif information described in the MOTIF lines.
  # ---
  # *Returns*:: Hash
  def motifs_as_hash
    unless @data['MOTIF']
      hash = {}
      db = nil
      motifs_as_strings.each do |line|
        if line[/^\S+:/]
          db, str = line.split(/:/, 2)
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
  alias motifs motifs_as_hash

  # The specification of the method will be changed in the future.
  # Please use Bio::KEGG::GENES#motifs.
  #
  # Motif information described in the MOTIF lines.
  # ---
  # *Returns*:: Hash
  def motif
    motifs
  end

  # Links to other databases described in the DBLINKS lines.
  # ---
  # *Returns*:: Array containing String objects
  def dblinks_as_strings
    lines_fetch('DBLINKS')
  end

  # Returns structure ID information described in the STRUCTURE lines.
  # ---
  # *Returns*:: Array containing String
  def structure
    unless @data['STRUCTURE']
      @data['STRUCTURE'] = fetch('STRUCTURE').sub(/(PDB: )*/,'').split(/\s+/)
    end
    @data['STRUCTURE'] # ['PDB:1A9X', ...]
  end
  alias structures structure

  # Codon usage data described in the CODON_USAGE lines. (Deprecated: no more exists)
  # ---
  # *Returns*:: Hash
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

  # Codon usage data described in the CODON_USAGE lines as an array.
  # ---
  # *Returns*:: Array
  def cu_list
    ary = []
    get('CODON_USAGE').sub(/.*/,'').each_line do |line|	# cut 1st line
      line.chomp.sub(/^.{11}/, '').scan(/..../) do |cu|
        ary.push(cu.to_i)
      end
    end
    return ary
  end

  # Returns amino acid sequence described in the AASEQ lines.
  # ---
  # *Returns*:: Bio::Sequence::AA object
  def aaseq
    unless @data['AASEQ']
      @data['AASEQ'] = Bio::Sequence::AA.new(fetch('AASEQ').gsub(/\d+/, ''))
    end
    @data['AASEQ']
  end

  # Returns length of the amino acid sequence described in the AASEQ lines.
  # ---
  # *Returns*:: Integer
  def aalen
    fetch('AASEQ')[/\d+/].to_i
  end

  # Returns nucleic acid sequence described in the NTSEQ lines.
  # ---
  # *Returns*:: Bio::Sequence::NA object
  def ntseq
    unless @data['NTSEQ']
      @data['NTSEQ'] = Bio::Sequence::NA.new(fetch('NTSEQ').gsub(/\d+/, ''))
    end
    @data['NTSEQ']
  end
  alias naseq ntseq

  # Returns nucleic acid sequence length.
  # ---
  # *Returns*:: Integer
  def ntlen
    fetch('NTSEQ')[/\d+/].to_i
  end
  alias nalen ntlen

end

end # KEGG
end # Bio



