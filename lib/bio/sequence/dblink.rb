#
# = bio/sequence/dblink.rb - sequence ID with database name
#
# Copyright::  Copyright (C) 2008
#              Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id: dblink.rb,v 1.1.2.1 2008/06/17 15:44:22 ngoto Exp $
#

require 'bio/sequence'

# Bio::Sequence::DBLink stores IDs with the database name.
# Its main purpose is to store database cross-reference information
# for a sequence entry.
class Bio::Sequence::DBLink

  # creates a new DBLink object
  def initialize(database, primary_id, *secondary_ids)
    @database = database
    @id = primary_id
    @secondary_ids = secondary_ids
  end

  # Database name, or namespace identifier (String).
  attr_reader :database

  # Primary identifier (String)
  attr_reader :id

  # Secondary identifiers (Array of String)
  attr_reader :secondary_ids

  #--
  # class methods
  #++

  # Parses DR line in EMBL entry, and returns a DBLink object.
  def self.parse_embl_DR_line(str)
    str = str.sub(/\.\s*\z/, '')
    str.sub!(/\ADR   /, '')
    self.new(*(str.split(/\s*\;\s*/, 3)))
  end

  # Parses DR line in UniProt entry, and returns a DBLink object.
  def self.parse_uniprot_DR_line(str)
    str = str.sub(/\.\s*\z/, '')
    str.sub!(/\ADR   /, '')
    self.new(*(str.split(/\s*\;\s*/)))
  end

end #class Bio::Sequence::DBLink


