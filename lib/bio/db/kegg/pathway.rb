#
# = bio/db/kegg/pathway.rb - KEGG PATHWAY database class
#
# Copyright::  Copyright (C) 2010 Kozo Nishida <kozo-ni@is.naist.jp>
# Copyright::  Copyright (C) 2010 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/db'
require 'bio/db/kegg/common'

module Bio
class KEGG

# == Description
#
# Bio::KEGG::PATHWAY is a parser class for the KEGG PATHWAY database entry.
#
# == References
#
# * http://www.genome.jp/kegg/pathway.html
# * ftp://ftp.genome.jp/pub/kegg/pathway/pathway
#
class PATHWAY < KEGGDB

  DELIMITER = RS = "\n///\n"
  TAGSIZE = 12

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

  include Common::References
  # REFERENCE -- Returns contents of the REFERENCE records as an Array of
  # Bio::Reference objects.
  # ---
  # *Returns*:: an Array containing Bio::Reference objects
  def references; super; end if false #dummy for RDoc

  include Common::ModulesAsHash
  # Returns MODULE field as a Hash.
  # Each key of the hash is KEGG MODULE ID,
  # and each value is the name of the Pathway Module.
  # ---
  # *Returns*:: Hash
  def modules_as_hash; super; end if false #dummy for RDoc
  alias modules modules_as_hash

  #--
  # for a private method strings_as_hash.
  #++
  include Common::StringsAsHash

  # Creates a new Bio::KEGG::PATHWAY object.
  # ---
  # *Arguments*:
  # * (required) _entry_: (String) single entry as a string
  # *Returns*:: Bio::KEGG::PATHWAY object
  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # Return the ID of the pathway, described in the ENTRY line.
  # ---
  # *Returns*:: String
  def entry_id
    field_fetch('ENTRY')[/\S+/]
  end

  # Name of the pathway, described in the NAME line.
  # ---
  # *Returns*:: String
  def name
    field_fetch('NAME')
  end

  # Description of the pathway, described in the DESCRIPTION line.
  # ---
  # *Returns*:: String
  def description
    field_fetch('DESCRIPTION')
  end
  alias definition description

  # Return the name of the KEGG class, described in the CLASS line.
  # ---
  # *Returns*:: String
  def keggclass
    field_fetch('CLASS')
  end

  # Pathways described in the PATHWAY_MAP lines.
  # ---
  # *Returns*:: Array containing String
  def pathways_as_strings
    lines_fetch('PATHWAY_MAP')
  end

  # Returns MODULE field of the entry.
  # ---
  # *Returns*:: Array containing String objects
  def modules_as_strings
    lines_fetch('MODULE')
  end

  # Disease described in the DISEASE lines.
  # ---
  # *Returns*:: Array containing String
  def diseases_as_strings
    lines_fetch('DISEASE')
  end

  # Diseases described in the DISEASE lines.
  # ---
  # *Returns*:: Hash of disease ID and its definition
  def diseases_as_hash
    unless @diseases_as_hash
      @diseases_as_hash = strings_as_hash(diseases_as_strings)
    end
    @diseases_as_hash
  end
  alias diseases diseases_as_hash

  # Returns an Array of a database name and entry IDs in DBLINKS field.
  # ---
  # *Returns*:: Array containing String
  def dblinks_as_strings
    lines_fetch('DBLINKS')
  end

  # Orthologs described in the ORTHOLOGY lines.
  # ---
  # *Returns*:: Array containing String
  def orthologs_as_strings
    lines_fetch('ORTHOLOGY')
  end

  # Organism described in the ORGANISM line.
  # ---
  # *Returns*:: String
  def organism
    field_fetch('ORGANISM')
  end

  # Genes described in the GENE lines.
  # ---
  # *Returns*:: Array containing String
  def genes_as_strings
    lines_fetch('GENE')
  end

  # Genes described in the GENE lines.
  # ---
  # *Returns*:: Hash of gene ID and its definition
  def genes_as_hash
    unless @genes_as_hash
      @genes_as_hash = strings_as_hash(genes_as_strings)
    end
    @genes_as_hash
  end
  alias genes genes_as_hash

  # Enzymes described in the ENZYME lines.
  # ---
  # *Returns*:: Array containing String
  def enzymes_as_strings
    lines_fetch('ENZYME')
  end
  alias enzymes enzymes_as_strings

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
    unless @reactions_as_hash
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
    unless @compounds_as_hash
      @compounds_as_hash = strings_as_hash(compounds_as_strings)
    end
    @compounds_as_hash
  end
  alias compounds compounds_as_hash

  # Returns REL_PATHWAY field of the entry.
  # ---
  # *Returns*:: Array containing String objects
  def rel_pathways_as_strings
    lines_fetch('REL_PATHWAY')
  end

  # Returns REL_PATHWAY field as a Hash. Each key of the hash is
  # Pathway ID, and each value is the name of the pathway.
  # ---
  # *Returns*:: Hash
  def rel_pathways_as_hash
    unless defined? @rel_pathways_as_hash then
      hash = {}
      rel_pathways_as_strings.each do |line|
        entry_id, name = line.split(/\s+/, 2)
        hash[entry_id] = name
      end
      @rel_pathways_as_hash = hash
    end
    @rel_pathways_as_hash
  end
  alias rel_pathways rel_pathways_as_hash

  # KO pathway described in the KO_PATHWAY line.
  # ---
  # *Returns*:: String
  def ko_pathway
    field_fetch('KO_PATHWAY')
  end

end # PATHWAY

end # KEGG
end # Bio
