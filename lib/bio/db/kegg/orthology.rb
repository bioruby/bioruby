#
# = bio/db/kegg/orthology.rb - KEGG ORTHOLOGY database class
#
# Copyright::  Copyright (C) 2003-2007 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2003 Masumi Itoh <m@bioruby.org>
# License::    The Ruby License
#
# $Id: orthology.rb,v 1.9 2007/04/05 15:42:59 k Exp $
#

require 'bio/db'

module Bio
class KEGG

# == Description
#
# KO (KEGG Orthology) entry parser.
#
# == References
#
# * http://www.genome.jp/dbget-bin/get_htext?KO
# * ftp://ftp.genome.jp/pub/kegg/genes/ko
#
class ORTHOLOGY < KEGGDB
  
  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  # Reads a flat file format entry of the KO database.
  def initialize(entry)
    super(entry, TAGSIZE)
  end
  
  # Returns ID of the entry.
  def entry_id
    field_fetch('ENTRY')[/\S+/]
  end

  # Returns NAME field of the entry.
  def name
    field_fetch('NAME')
  end

  # Returns an Array of names in NAME field.
  def names
    name.split(', ')
  end

  # Returns DEFINITION field of the entry.
  def definition
    field_fetch('DEFINITION')
  end

  # Returns CLASS field of the entry.
  def keggclass
    field_fetch('CLASS')
  end

  # Returns an Array of biological classes in CLASS field.
  def keggclasses
    keggclass.gsub(/ \[[^\]]+/, '').split(/\] ?/)
  end

  # Returns an Array of KEGG/PATHWAY ID in CLASS field.
  def pathways
    keggclass.scan(/\[PATH:(.*?)\]/).flatten
  end
  
  # Returns a Hash of Array of a database name and entry IDs in DBLINKS field.
  def dblinks
    unless @data['DBLINKS']
      @data['DBLINKS'] = lines_fetch('DBLINKS')
    end
    @data['DBLINKS']
  end

  # Returns a Hash of Array of the organism ID and entry IDs in GENES field.
  def genes
    unless @data['GENES']
      @data['GENES'] = lines_fetch('GENES')
    end
    @data['GENES']
  end
  
end # ORTHOLOGY
    
end # KEGG
end # Bio



if __FILE__ == $0

  require 'bio/io/fetch'

  flat = Bio::Fetch.query('ko', 'K00001')
  entry = Bio::KEGG::ORTHOLOGY.new(flat)

  p entry.entry_id
  p entry.name
  p entry.names
  p entry.definition
  p entry.keggclass
  p entry.keggclasses
  p entry.pathways
  p entry.dblinks
  p entry.genes

end


