#
# = bio/db.rb - common API for database parsers
#
# Copyright::  Copyright (C) 2001, 2002, 2005
#              Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: db.rb,v 0.38 2007/05/08 17:02:13 nakao Exp $
#
# == On-demand parsing and cache
#
# The flatfile parsers (sub classes of the Bio::DB) split the original entry
# into a Hash and store the hash in the @orig instance variable.  To parse
# in detail is delayed until the method is called which requires a further
# parsing of a content of the @orig hash.  Fully parsed data is cached in the
# another hash, @data, separately.
#
# == Guide lines for the developers to create an new database class
#
# --- Bio::DB.new(entry)
#
# The 'new' method should accept the entire entry in one String and
# return the parsed database object.
#
# --- Bio::DB#entry_id
#
# Database classes should implement the following methods if appropriate:
#
# * entry_id
# * definition
#
# Every sub class should define the following constants if appropriate:
#
# * DELIMITER (RS)
#   * entry separator of the flatfile of the database.
#   * RS (= record separator) is an alias for the DELIMITER in short.
#
# * TAGSIZE
#   * length of the tag field in the FORTRAN-like format.
#
#       |<- tag       ->||<- data                           ---->|
#       ENTRY_ID         A12345
#       DEFINITION       Hoge gene of the Pokemonia pikachuae
#
# === Template of the sub class
# 
#   module Bio
#   class Hoge < DB
# 
#     DELIMITER	= RS = "\n//\n"
#     TAGSIZE		= 12		# You can omit this line if not needed
# 
#     def initialize(entry)
#     end
# 
#     def entry_id
#     end
# 
#   end # class Hoge
#   end # module Bio
# 
# === Recommended method names for sub classes
# 
# In general, the method name should be in the singular form when returns
# a Object (including the case when the Object is a String), and should be
# the plural form when returns same Objects in Array.  It depends on the
# database classes that which form of the method name can be use.
# 
# For example, GenBank has several REFERENCE fields in one entry, so define
# Bio::GenBank#references and this method should return an Array of the
# Reference objects.  On the other hand, MEDLINE has one REFERENCE information
# per one entry, so define Bio::MEDLINE#reference method and this should
# return a Reference object.
# 
# The method names used in the sub classes should be taken from the following
# list if appropriate:
# 
# --- entry_id #=> String
# 
# The entry identifier.
# 
# --- definition #=> String
# 
# The description of the entry.
# 
# --- reference	#=> Bio::Reference
# --- references #=> Array of Bio::Reference
# 
# The reference field(s) of the entry.
# 
# --- dblink #=> String
# --- dblinks #=> Array of String
# 
# The link(s) to the other database entry.
# 
# --- naseq #=> Bio::Sequence::NA
# 
# The DNA/RNA sequence of the entry.
# 
# --- nalen #=> Integer
# 
# The length of the DNA/RNA sequence of the entry.
# 
# --- aaseq #=> Bio::Sequence::AA
# 
# The amino acid sequence of the entry.
# 
# --- aalen #=> Integer
# 
# The length of the amino acid sequence of the entry.
# 
# --- seq #=> Bio::Sequence::NA or Bio::Sequence::AA
# 
# Returns an appropriate sequence object.
# 
# --- position #=> String
# 
# The position of the sequence in the entry or in the genome (depends on
# the database).
# 
# --- locations #=> Bio::Locations
# 
# Returns Bio::Locations.new(position).
# 
# --- division #=> String
# 
# The sub division name of the database.
# 
# * Example:
#   * EST, VRL etc. for GenBank
#   * PATTERN, RULE etc. for PROSITE
# 
# --- date #=> String
# 
# The date of the entry.
# Should we use Date (by ParseDate) instead of String?
# 
# --- gene #=> String
# --- genes #=> Array of String
# 
# The name(s) of the gene.
# 
# --- organism #=> String
# 
# The name of the organism.
# 

require 'bio/sequence'
require 'bio/reference'
require 'bio/feature'

module Bio
  
class DB

  def self.open(filename, *mode, &block)
    Bio::FlatFile.open(self, filename, *mode, &block)
  end

  # Returns an entry identifier as a String.  This method must be
  # implemented in every database classes by overriding this method.
  def entry_id
    raise NotImplementedError
  end

  # Returns a list of the top level tags of the entry as an Array of String.
  def tags
    @orig.keys
  end

  # Returns true or false - wether the entry contains the field of the
  # given tag name.
  def exists?(tag)
    @orig.include?(tag)
  end

  # Returns an intact field of the tag as a String.
  def get(tag)
    @orig[tag]
  end

  # Similar to the get method, however, fetch returns the content of the
  # field without its tag and any extra white spaces stripped.
  def fetch(tag, skip = 0)
    field = @orig[tag].split(/\n/, skip + 1).last.to_s
    truncate(field.gsub(/^.{0,#{@tagsize}}/,''))
  end


  private

  # Returns a String with successive white spaces are replaced by one
  # space and stripeed.
  def truncate(str)
    str ||= ""
    return str.gsub(/\s+/, ' ').strip
  end

  # Returns a tag name of the field as a String.
  def tag_get(str)
    str ||= ""
    return str[0,@tagsize].strip
  end

  # Returns a String of the field without a tag name.
  def tag_cut(str)
    str ||= ""
    str[0,@tagsize] = ''
    return str
  end

  # Returns the content of the field as a String like the fetch method.
  # Furthermore, field_fetch stores the result in the @data hash.
  def field_fetch(tag, skip = 0)
    unless @data[tag]
      @data[tag] = fetch(tag, skip)
    end
    return @data[tag]
  end

  # Returns an Array containing each line of the field without a tag.
  # lines_fetch also stores the result in the @data hash.
  def lines_fetch(tag)
    unless @data[tag]
      list = []
      lines = get(tag).split(/\n/)
      lines.each do |line|
        data = tag_cut(line)
        if data[/^\S/]                  # next sub field
          list << data
        else                            # continued sub field
          data.strip!
          if list.last[/\-$/]           # folded
            list[-1] += data
          else
            list[-1] += " #{data}"     # rest of list
          end
        end
      end
      @data[tag] = list
    end
    @data[tag]
  end

end # class DB


# Stores a NCBI style (GenBank, KEGG etc.) entry.
class NCBIDB < DB

  autoload :Common, 'bio/db/genbank/common'

  # The entire entry is passed as a String.  The length of the tag field is
  # passed as an Integer.  Parses the entry roughly by the entry2hash method
  # and returns a database object.
  def initialize(entry, tagsize)
    @tagsize = tagsize
    @orig = entry2hash(entry.strip)	# Hash of the original entry
    @data = {}				# Hash of the parsed entry
  end

  private

  # Splits an entry into an Array of Strings at the level of top tags.
  def toptag2array(str)
    sep = "\001"
    str.gsub(/\n([A-Za-z\/\*])/, "\n#{sep}\\1").split(sep)
  end

  # Splits a field into an Array of Strings at the level of sub tags.
  def subtag2array(str)
    sep = "\001"
    str.gsub(/\n(\s{1,#{@tagsize-1}}\S)/, "\n#{sep}\\1").split(sep)
  end

  # Returns the contents of the entry as a Hash with the top level tags as
  # its keys.
  def entry2hash(entry)
    hash = Hash.new('')

    fields = toptag2array(entry)

    fields.each do |field|
      tag = tag_get(field)
      hash[tag] += field
    end
    return hash
  end

end # class NCBIDB


# Class for KEGG databases. Inherits a NCBIDB class.
class KEGGDB < NCBIDB
end


# Stores an EMBL style (EMBL, TrEMBL, Swiss-Prot etc.) entry.
class EMBLDB < DB

  autoload :Common, 'bio/db/embl/common'

  # The entire entry is passed as a String.  The length of the tag field is
  # passed as an Integer.  Parses the entry roughly by the entry2hash method
  # and returns a database object.
  def initialize(entry, tagsize)
    @tagsize = tagsize
    @orig = entry2hash(entry.strip)	# Hash of the original entry
    @data = {}			# Hash of the parsed entry
  end

  private

  # Returns the contents of the entry as a Hash.
  def entry2hash(entry)
    hash = Hash.new { |h,k| h[k] = '' }
    entry.each_line do |line|
      tag = tag_get(line)
      next if tag == 'XX'
      tag = 'R' if tag =~ /^R./	# Reference lines
      hash[tag].concat line
    end
    return hash
  end

end # class EMBLDB

end # module Bio

