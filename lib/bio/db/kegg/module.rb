#
# = bio/db/kegg/module.rb - KEGG MODULE database class
#
# Copyright::  Copyright (C) 2010 Kozo Nishida <kozo-ni@is.naist.jp>
# Copyright::  Copyright (C) 2010 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#

require 'bio/db'
require 'bio/db/kegg/common'

module Bio
class KEGG

# == Description
#
# Bio::KEGG::MODULE is a parser class for the KEGG MODULE database entry.
#
# == References
#
# * http://www.kegg.jp/kegg-bin/get_htext?ko00002.keg
# * ftp://ftp.genome.jp/pub/kegg/pathway/module
#
class MODULE < KEGGDB

  DELIMITER = RS = "\n///\n"
  TAGSIZE = 12

  #--
  # for a private method strings_as_hash.
  #++
  include Common::StringsAsHash

  # Creates a new Bio::KEGG::MODULE object.
  # ---
  # *Arguments*:
  # * (required) _entry_: (String) single entry as a string
  # *Returns*:: Bio::KEGG::MODULE object
  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # Return the ID, described in the ENTRY line.
  # ---
  # *Returns*:: String
  def entry_id
    field_fetch('ENTRY')[/\S+/]
  end

  # Name of the module, described in the NAME line.
  # ---
  # *Returns*:: String
  def name
    field_fetch('NAME')
  end

  # Definition of the module, described in the DEFINITION line.
  # ---
  # *Returns*:: String
  def definition
    field_fetch('DEFINITION')
  end

  # Name of the KEGG class, described in the CLASS line.
  # ---
  # *Returns*:: String
  def keggclass
    field_fetch('CLASS')
  end

  # Pathways described in the PATHWAY lines.
  # ---
  # *Returns*:: Array containing String
  def pathways_as_strings
    lines_fetch('PATHWAY')
  end

  # Pathways described in the PATHWAY lines.
  # ---
  # *Returns*:: Hash of pathway ID and its definition
  def pathways_as_hash
    unless (defined? @pathways_as_hash) && @pathways_as_hash
      @pathways_as_hash = strings_as_hash(pathways_as_strings)
    end
    @pathways_as_hash
  end
  alias pathways pathways_as_hash


  # Orthologs described in the ORTHOLOGY lines.
  # ---
  # *Returns*:: Array containing String
  def orthologs_as_strings
    lines_fetch('ORTHOLOGY')
  end

  # Orthologs described in the ORTHOLOGY lines.
  # ---
  # *Returns*:: Hash of orthology ID and its definition
  def orthologs_as_hash
    unless (defined? @orthologs_as_hash) && @orthologs_as_hash
      @orthologs_as_hash = strings_as_hash(orthologs_as_strings)
    end
    @orthologs_as_hash
  end
  alias orthologs orthologs_as_hash

  # All KO IDs in the ORTHOLOGY lines.
  # ---
  # *Returns*:: Array of orthology IDs
  def orthologs_as_array
    orthologs_as_hash.keys.map{|x| x.split(/\+|\-|,/)}.flatten.sort.uniq
  end


  # Reactions described in the REACTION lines.
  # ---
  # *Returns*:: Array containing String
  def reactions_as_strings
    lines_fetch('REACTION')
  end

  # Reactions described in the REACTION lines.
  # ---
  # *Returns*:: Hash of reaction ID and its definition
  def reactions_as_hash
    unless (defined? @reactions_as_hash) && @reactions_as_hash
      @reactions_as_hash = strings_as_hash(reactions_as_strings)
    end
    @reactions_as_hash
  end
  alias reactions reactions_as_hash


  # Compounds described in the COMPOUND lines.
  # ---
  # *Returns*:: Array containing String
  def compounds_as_strings
    lines_fetch('COMPOUND')
  end

  # Compounds described in the COMPOUND lines.
  # ---
  # *Returns*:: Hash of compound ID and its definition
  def compounds_as_hash
    unless (defined? @compounds_as_hash) && @compounds_as_hash
      @compounds_as_hash = strings_as_hash(compounds_as_strings)
    end
    @compounds_as_hash
  end
  alias compounds compounds_as_hash

end # MODULE

end # KEGG
end # Bio
