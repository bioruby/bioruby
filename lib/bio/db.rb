#
# bio/db.rb - DataBase parser general API
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>,
#   Copyright (C) 2001 NAKAO Mitsuteru <n@bioruby.org> (EMBL part)
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: db.rb,v 0.14 2002/06/07 11:29:20 n Exp $
#

require 'bio/id'
require 'bio/sequence'
require 'bio/reference'
require 'bio/data/keggorg'

module Bio

  class DB

    # returns the entry identifier
    def entry_id
      raise NotImplementedError
    end

    # returns tag list of the entry
    def tags
      @orig.keys
    end

    # returns true or faluse - wether the entry contains the field of the tag
    def exists?(tag)
      @orig.include?(tag)
    end

    # returns the field of the tag as is
    def get(tag)
      @orig[tag]
    end

    # returns contents of the field without the tag and any extra white spaces
    def fetch(tag)
      str = ''
      get(tag).each_line do |line|
	str += tag_cut(line)	# IS THIS SLOW TOO?
      end
      return truncate(str)
    end


    ### common private/protected methods

    protected

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

    # returns contents of the field as String
    def field_fetch(tag)
      unless @data[tag]
	@data[tag] = fetch(tag)
      end
      return @data[tag]
    end

  end


  class NCBIDB < DB

    def initialize(entry, tagsize)
      @tagsize = tagsize
      @orig = entry2hash(entry)		# Hash of the original entry
      @data = {}			# Hash of the parsed entry
    end
    attr_accessor :data

    private

    def toptag2array(str)
      sep = "\001"
      str.gsub(/\n(\S)/, "\n#{sep}\\1").split(sep)
    end

    def subtag2array(str)
      sep = "\001"
      str.gsub(/\n(\s{1,#{@tagsize-1}}\S)/, "\n#{sep}\\1").split(sep)
    end

    def entry2hash(entry)
      hash = Hash.new('')

      fields = toptag2array(entry)

      fields.each do |field|
        tag = tag_get(field)
        hash[tag] += field
      end
      return hash
    end

  end


  class KEGGDB < NCBIDB

    def keggorg2organism(korg)
      return KEGGORG[korg][0]
    end

    def keggorg2species(korg)
      return KEGGORG[korg][1]
    end

    def species2keggorg(species)
      KEGGORG.each do |korg, sp|
	if sp[1] =~ /#{species}/
	  return korg
	end
      end
    end

  end


  class EMBLDB < DB
    
    def initialize(entry, tagsize)
      @tagsize = tagsize
      @orig = entry2hash(entry)			# Hash of the original entry
      @data = {}				# Hash of the parsed entry
    end

    # Shared methods in Bio::EMBL and Bio::SPTR

    # AC Line
    # "AC   A12345; B23456;"
    # AC [AC1;]+
    #
    # Accession numbers format:
    # 1       2     3          4          5          6
    # [O,P,Q] [0-9] [A-Z, 0-9] [A-Z, 0-9] [A-Z, 0-9] [0-9]
    #
    # Bio::SPTR#ac  -> Array
    #          #accessions  -> Array
    def ac
      unless @data['AC']
	tmp=Array.new
	a=field_fetch('AC').split(' ')
	a.each do |e|
	  tmp.push(e.sub(/;/,''))
	end
	@data['AC']=tmp
      end
      @data['AC']
    end
    alias accessions ac
    # Bio::SPTR#accession  -> String
    def accession
      @data['AC'][0]
    end


    # OS Line; organism species (>=1)
    # "OS   Trifolium repens (white clover)"
    #
    # OS   Genus species (name).
    # OS   Genus species (name0) (name1).
    # OS   Genus species (name0) (name1).
    # OS   Genus species (name0), G s0 (name0), and G s (name1).
    #
    # Bio::EMBL#os  -> Array w/in Hash
    # [{'name'=>'Human', 'os'=>'Homo sapiens'}, 
    #  {'name'=>'Rat', 'os'=>'Rattus norveticus'}]
    # Bio::STPR#os[0]['name'] => "Human"
    # Bio::STPR#os[0] => {'name'=>"Human", 'os'=>'Homo sapiens'}
    # Bio::STPR#os(0) => "Homo sapiens (Human)"
    #
    # Bio::SPTR#os -> Array w/in Hash
    # Bio::SPTR#os(num) -> String
    def os(num=nil)
      unless @data['OS']
	os=Array.new
	fetch('OS').split(',').each do |tmp|
	  if tmp =~ /([A-Z][a-z]+ [a-zA-Z0-9]+)/
	    org=$1
	    tmp =~ /\((.+)\)/ 
	    os.push({'name'=>$1, 'os'=>org})
	  else
	    raise "Error: OS Line. #{$!}\n#{fetch('OS')}\n"
	  end
	end
	@data['OS']=os
      end
      if num
	# EX. "Trifolium repens (white clover)"
	"#{@data['OS'][num]['os']} ({#data['OS'][num]['name'])"
      else
	@data['OS']
      end
    end

    # OG Line; organella (0 or 1/entry)
    #
    # Bio::SPTR#og  -> Array
    def og
      unless @data['OG']
	og=Array.new
	fetch('OG').sub(/.$/,'').sub(/ and/,'').split(',').each do |tmp|
	  og.push(tmp.strip)
	end
	@data['OG']=og
      end
      @data['OG']
    end


    # OC Line; organism classification (>=1)
    # OC   Eukaryota; Alveolata; Apicomplexa; Piroplasmida; Theileriidae;
    # OC   Theileria.
    #
    # Bio::SPTR#oc  -> Array
    def oc
      begin
	fetch('OC').sub(/.$/,'').split(';').collect {|e| e.strip }
      rescue NameError
	nil
      end
    end


    # KW Line; keyword (>=1)
    # KW   [Keyword;]+
    # Bio::SPTR#kw  -> Array
    #          #keywords  -> Array
    def kw
      tmp=fetch('KW').sub(/.$/,'')
      if block_given?
	tmp.split(';').each do |k|
	  yield k.strip
	end
      else
	tmp.split(';').collect{|e| e.strip }
      end      
    end
    alias keywords kw

    # R Lines
    # RN RC RP RX RA RT RL
    # same as Bio::EMBL#ref 
    def ref
      get('R')
    end

    # DR Line; defabases cross-reference (>=0)
    # a cross_ref pre one line
    # "DR  database_identifier; primary_identifier; secondary_identifier."
    # Bio::SPTR#dr  -> Hash w/in Array
    def dr
      unless @data['DR']
	tmp=Hash.new
	self.get('DR').split("\n").each do |db|
	  a=db.sub(/^DR   /,'').sub(/.$/,'').strip.split(";[ ]")
	  dbname=a.shift
	  tmp[dbname]=Array.new unless tmp[dbname]
	  tmp[dbname].push(a)
	end
	@data['DR']=tmp
      end
      if block_given?
	@data['DR'].each do |k,v|
	  yield(k,v)
	end
      else
	@data['DR']
      end
    end

    
    private

    # returns hash of the EMBL style fields (EMBL, Swiss-Prot etc.)
    def entry2hash(entry)
      hash = Hash.new('')
      tag = oldtag = ''
      entry.each_line do |line|
	next if line =~ /^$/
	tag = tag_get(line)
	tag = 'R' if tag =~ /^R[NCPXATL]/ # to keep References order
	next if tag == 'XX'               # Avoid XX lines to store
	if tag != oldtag
	  oldtag = tag
	end
	hash[tag] += line
      end
      return hash
    end

  end

end


=begin

= Bio::DB

* 'On-demand parsing' and the 'Parsed-data cache'

The flatfile parsers of the Bio::DB sub classes split the original entry
into a Hash and store the hash in the @orig instance variable.  Further
parsing is delayed until the method is called which uses the value of the
@orig hash.  The parsed data is cached in another hash @data separately.

== Class methods

--- Bio::DB.new(entry)

This class method accepts the String of one entire entry and parse it to
return the parsed database object.

--- Bio::DB.brdb(entry_id)

This class method accepts the ID string of the entry and access to the
BioRuby-DB to fetch the parsed database object.	     

== Object methods

--- Bio::DB#tags
--- Bio::DB#exists?(tag)
--- Bio::DB#get(tag)
--- Bio::DB#fetch(tag)

== Private/Protected methods

--- Bio::DB#truncate(str)
--- Bio::DB#tag_get(str)
--- Bio::DB#tag_cut(str)
--- Bio::DB#field_fetch(tag)

== For the sub class developpers

Each sub class should define the following constants if appropriate:

  * DELIMITER (RS)
    * entry separator of the flatfile of the database.
    * RS (= record separator) is a alias for the DELIMITER in short.
  * TAGSIZE
    * the length of the tag field in FORTRAN like format of the flatfile.

        |-- tag field --||-- data field                       -----|
        ENTRY_ID         A12345
        DEFINITION       Hoge gene of the Pokemonia pikachuae

Sub classes also should register the abbreviated database name and the class
name (itself) to the Bio::ID by Bio::ID.register('hoge', Bio::Hoge) method.

== Template of the sub class

  module Bio

    class Hoge < DB

      DELIMITER	= RS = "\n//\n"
      TAGSIZE	= 12		# You can omit this line if not needed

      Bio::ID.register('hoge', Bio::Hoge)

      def initialize(entry)
      end

      def entry_id
      end

    end

  end

== Recommended method names for sub classes

In general, the method name should be in the singular form when returns
a Object (including the case when the Object is a String), and should be
the plural form when returns same Objects in Array.  It depends on the
database classes that which form of the method name can be use.

For example, GenBank has several REFERENCE lines in one entry, so define
Bio::GenBank#references and this method should return an Array of the
Reference objects.  On the other hand, MEDLINE has one REFERENCE information
per one entry, so define Bio::MEDLINE#reference method and this should
return a Reference object.

The method name in sub classes should be one of the following if appropriate:

--- entry_id	-> String

The entry identifier.

--- definition	-> String

The description of the entry.

--- reference	-> Bio::Reference
--- references	-> Array of Bio::Reference

The reference field(s) of the entry.

--- dblink	-> Bio::ID
--- dblinks	-> Array of Bio::ID

The link(s) to the other database entry.

--- naseq	-> Bio::Sequence::NA

The DNA/RNA sequence of the entry.

--- nalen	-> Integer

The length of the DNA/RNA sequence of the entry.

--- aaseq	-> Bio::Sequence::AA

The amino acid sequence of the entry.

--- aalen	-> Integer

The length of the amino acid sequence of the entry.

--- position	-> String

The position of the sequence in the entry or in the genome (depends on the
database).  Should we return Bio::Locations(position) here (or define
locations method for this purpose)?

--- division	-> String

The sub division name of the database.

Example:
  * EST, VRL etc. for GenBank
  * PATTERN, RULE etc. for PROSITE

--- date	-> String

The date of the entry.  Should we use Date (by ParseDate) instead of String?

--- gene	-> String
--- genes	-> Array of String

The name(s) of the gene.  To define gene as genes[0] is a idea.

--- organism	-> String

The name of the organism.

--- keggorg	-> String

The ((<KEGG|URL:http://www.genome.ad.jp/kegg/>)) organism code in 3 letters.

--- taxonomy	-> String

Should we define Bio::Taxonomy class? (bio/taxonomy.rb)

= Bio::NCBIDB
= Bio::KEGGDB
= Bio::EMBLDB

=end
