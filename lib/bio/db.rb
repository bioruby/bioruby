#
# bio/db.rb - DataBase parser general API
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: db.rb,v 0.11 2001/11/12 21:14:06 katayama Exp $
#

require 'bio/sequence'
require 'bio/reference'
#require 'bio/id'
#require 'bio/taxonomy'
require 'bio/data/keggorg'

module Bio

  class DB

    ### sub classes should define the following constants if appropriate

    DELIMITER	= RS = ""
    TAGSIZE	= 0


    ### sub classes should define the following methods if appropriate

    # returns ENTRY ID as String
    def id
      raise NotImplementedError
    end

    # returns DB division (gb -> VRL, ps -> PATTERN etc.) as String
    def division
      raise NotImplementedError
    end

    # returns date of the ENTRY as String
    def date
      raise NotImplementedError
    end

    # returns Array of gene names of the ENTRY as String
    def gene
      raise NotImplementedError
    end

    # returns DEFINITION as String
    def definition
      raise NotImplementedError
    end

    # returns REFERENCE as Reference : bio/reference.rb
    def reference
      raise NotImplementedError
    end

    # returns links to other DBs as Array of String or DBlinks? : id.rb
    def dblinks
      raise NotImplementedError
    end

    # returns organism as String
    def organism
      raise NotImplementedError
    end

    # returns KEGG organism code (3 letters) as String
    def keggorg
      raise NotImplementedError
    end

    # returns taxonomy as String or Taxonomy? : taxonomy.rb
    def taxonomy
      raise NotImplementedError
    end

    # returns Sequence position in the ENTRY or in the GENOME as String
    def position
      raise NotImplementedError
    end

    # returns Gene Ontology or KEGG map or classification of the ENTRY as ?
    def ontology
      raise NotImplementedError
    end

    # returns DNA/RNA sequence as Sequence::NA
    def naseq
      raise NotImplementedError
    end

    # returns DNA/RNA sequence length as integer
    def nalen
      raise NotImplementedError
    end

    # returns Amino Acid sequence as Sequence::AA
    def aaseq
      raise NotImplementedError
    end

    # returns Amino Acid sequence length as integer
    def aalen
      raise NotImplementedError
    end

    # returns Pattern or Profile?
    def pattern
      raise NotImplementedError
    end
    def profile
      raise NotImplementedError
    end

    # returns 3D coordinates of the Amino Acid? or Array of the coordinates?
    def coordinates
      raise NotImplementedError
    end


    ### common methods

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
	str += tag_cut(line)
      end
      return truncate(str)
    end


    ### private/protected methods

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
      field.each_line do |line|		# this may also slow : see entry2hash
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
      field.each_line do |line|		# this may also slow : see entry2hash
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

    # (2)+(3)returns Array of Hash of String of the multiple fields with subtag
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
      @data = {}				# Hash of the parsed entry
    end

    private

    # returns hash of the NCBI style fields (GenBank, KEGG etc.)
    def entry2hash(entry)
      hash = Hash.new('')

# this routine originally was
#
#     tag = ''
#     entry.each_line do |line|
#       next if line =~ /^$/
#	if line =~ /^\w/
#	  tag = tag_get(line)
#	end
#	hash[tag] += line
#     end
#
# however, this method was very slow because of the storm of malloc calls.

      entry.gsub(/\n(\w)/, "\n\n\001\\1").split("\n\001").each do |field|

# next time, try this ... (and make it more readable)
#
#     entry.gsub(/\n(\w)/, "\n\001\\1").split("\001").each do |field|
#
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
	  if tmp =~ /([A-Z][a-z]+ [a-z]+)/
	    org=$1
	    tmp =~ /\((.+)\)/ 
	    os.push({'name'=>$1, 'os'=>org})
	  else
	    raise "Error: OS Line \n#{fetch('OS')}\n"
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
      fetch('OC').sub(/.$/,'').split(';').collect {|e| e.strip }
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

== TODO

* independent from @orig, @data
* clear the structure of toptag_array, subtag_hash, field_sub, field_multi_sub
* rename id to entry_id or something

=end
