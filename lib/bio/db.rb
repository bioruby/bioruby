#
# bio/db.rb - DataBase parser general API
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  $Id: db.rb,v 0.2 2001/06/21 08:15:53 katayama Exp $
#

require 'bio/sequence'
#require 'bio/id'
#require 'bio/taxonomy'

class DB

  ### sub classes should define the following constants if appropriate

  DELIMITER	= RS = ""
  TAGSIZE	= 0


  ### sub classes should define the following methods if appropriate

  # returns ENTRY ID as String
  def id
  end

  # returns DB division (gb -> VRL, ps -> PATTERN etc.) as String
  def division
  end

  # returns date of the ENTRY as String
  def date
  end

  # returns Array of gene names of the ENTRY as String
  def gene
  end

  # returns DEFINITION as String
  def definition
  end

  # returns REFERENCE as String or Array or Reference? : ref.rb
  def reference
  end

  # returns links to other DBs as Array of String or DBlinks? : id.rb
  def dblinks
  end

  # returns organism as String
  def organism
  end

  # returns KEGG organism code (3 letters) as String
  def keggorg
  end

  # returns taxonomy as String or Taxonomy? : taxonomy.rb
  def taxonomy
  end

  # returns Sequence position in the ENTRY or in the GENOME as String
  def position
  end

  # returns Gene Ontology or KEGG map or classification of the ENTRY as ?
  def ontology
  end

  # returns DNA/RNA sequence as NAseq
  def naseq
  end

  # returns DNA/RNA sequence length as integer
  def nalen
  end

  # returns Amino Acid sequence as AAseq
  def aaseq
  end

  # returns Amino Acid sequence length as integer
  def aalen
  end

  # returns Pattern or Profile?
  def pattern
  end
  def profile
  end

  # returns 3D coordinates of the Amino Acid? or Array of the coordinates?
  def coordinates
  end


  ### common methods

  # returns the field of the tag as is
  def get(tag)
    @orig[tag]
  end

  # returns contents of the field without the tag and any extra white spaces
  def fetch(tag)
    str = ''
    get(tag).each_line do |line|
      str += tag_cut(line)
    end
    return truncate(str)
  end


  ### private methods

  private

  # remove extra white spaces
  def truncate(str)
    return str.gsub(/\s+/, ' ').strip
  end

  # returns the tag of the field
  def tag_get(str)
    return str[0,@tagsize].strip
  end

  # remove the tag from the field
  def tag_cut(str)
    str[0,@tagsize-1] = ''
    return str
  end

  # (1) returns contents of the field as String
  def field_fetch(tag)
    unless @data[tag]
      @data[tag] = fetch(tag)
    end
    return @data[tag]
  end

  # split fields into Array of the field by the same tag name
  def toptag_array(field)
    ary = []
    field.each_line do |line|
      if line =~ /^\w/
	ary.push(line)
      else
	ary.last << line
      end
    end
    return ary
  end

  # split a field into Hash by subtag
  def subtag_hash(field)
    hash = Hash.new('')
    sub = ''
    field.each_line do |line|
      tmp = tag_get(line)
      if tmp.length > 0
	sub = tmp
      end
      hash[sub] += truncate(tag_cut(line))
    end
    return hash
  end

  # (2) returns Array of String of the multiple fields (REFERENCE etc.)
  def field_multi(tag)
    unless @data[tag]
      field = get(tag)
      @data[tag] = toptag_array(field)
    end
    return @data[tag]
  end

  # (3) returns Hash of String of the subtag (SOURCE etc.)
  def field_sub(tag)
    unless @data[tag]
      field = get(tag)
      @data[tag] = subtag_hash(field)
    end
    return @data[tag]
  end

  # (2)+(3) returns Array of Hash of String of the multiple fields with subtag
  def field_multi_sub(tag)
    unless @data[tag]
      ary = []
      field = get(tag)
      toptag_array(field).each do |f|
	hash = subtag_hash(f)
	ary.push(hash)
      end
      @data[tag] = ary
    end
    return @data[tag]
  end

end


class NCBIDB < DB

  def initialize(entry, tagsize)
    @tagsize = tagsize
    @orig = entry2hash(entry)			# Hash of the original entry
    @data = {}					# Hash of the parsed entry
  end

  private

  # returns hash of the NCBI style fields (GenBank, KEGG etc.)
  def entry2hash(entry)
    hash = Hash.new('')
    tag = ''
    entry.each_line do |line|
      next if line =~ /^$/			# work around for gb:AARPOB2
      if line =~ /^\w/
	tag = tag_get(line)
      end
      hash[tag] += line
    end
    return hash
  end

end


class KEGGDB < NCBIDB
  require 'bio/data/keggorg'; include KEGGORG
end


class EMBLDB < DB

  def initialize(entry, tagsize)
    @tagsize = tagsize
    @orig = entry2hash(entry)			# Hash of the original entry
    @data = {}					# Hash of the parsed entry
  end

  private

  # returns hash of the EMBL style fields (EMBL, Swiss-Prot etc.)
  def entry2hash(entry)
    hash = Hash.new('')
    tag = oldtag = ''
    entry.each_line do |line|
      next if line =~ /^$/
      tag = tag_get(line)
      if tag != oldtag
	oldtag = tag
      end
      hash[tag] += line
    end
    return hash
  end

end

