#
# bio/db/kegg/keggtab.rb - KEGG/GENES keggtab class
#
#   Copyright (C) 2001 Mitsuteru S. Nakao <n@bioruby.org>
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
#  $Id: keggtab.rb,v 1.1 2001/11/12 17:53:29 nakao Exp $
#


# name            type            directory                     abreviation
# 
# enzyme          enzyme          $BIOROOT/db/ideas/ligand                ec
# ec              alias           enzyme
#
# Taxonomy
#
# taxso   alias (korg|taxso)[+(korg|taxso)]
#

module Bio
  class KEGG

    ##
    # class Bio::KEGG::DBname 
    # 
    # Bio::KEGG::DBname#type -> type
    # Bio::KEGG::DBname#path -> File
    # Bio::KEGG::DBname#abrev -> String
    # Bio::KEGG::DBname#aliases -> Array
    class DBname
      def initialize(db_name, db_type, db_path, db_abrev)
	@name = db_name
	@type = db_type
	@path = db_path
	@abrev = db_abrev
	@aliases = Array.new
      end
      attr_reader :name
      attr_reader :type
      attr_reader :path
      attr_reader :abrev
      attr_reader :aliases
      ##
      # Bio::KEGG::DBname#add_alias(name)
      def add_alias(name)
	@aliases.push(name)
      end
      # Bio::KEGG::DBname#korg
      alias korg abrev
    end


    ##
    #
    #
    class Keggtab
      ##
      # path = keggtab file path
      # bio_root = $BIOROOT
      #
      def initialize(path, bio_root = nil)
	@keggtab_file = path
	@bio_root = bio_root
	@db_names = Hash.new
	@taxonomy = Hash.new
	@taxo_tmp = Array.new
	begin
	  keggtab = File.open(@keggtab_file, 'r').read
	rescue
	  raise IOError, " #{$!}"
	end

	taxo = nil
	keggtab.each do |line|
	  if line =~ /^\#|^ / 
	    taxo = 1 if line =~ /^# Taxonomy/
	    next

	  elsif line =~ /(^\w\S+)\s+(\w+)\s+(\$\S+)\s+(\w+)/
	    # db
	    db_name = $1
	    db_type = $2
	    db_path = $3
	    db_abrev = $4
	    @db_names[db_name] = Bio::KEGG::DBname.new(db_name, db_type, 
						      db_path, db_abrev)

	  elsif line =~ /(^\w\S+)\s+alias\s+(\w.+\w)/
	    # alias
	    db_alias = $1
	    db_name = $2#.downcase

	    if taxo
	      @taxonomy.update({db_alias=>db_name.split('+')})
	    else
	      if @db_names[db_name]
		@db_names[db_name].add_alias(db_alias)
	      end
	    end
	  end
	end
      end
      # Bio::KEGG::keggtab#db_names -> Hash
      attr_reader :db_names
      # Bio::KEGG::keggtab#taxonomy -> Hash
      attr_reader :taxonomy

      ## Methods for Taxonomy for GENES
      
      ##
      # Bio::KEGG::Keggtab#taxa_list -> anArray
      # Taxonomy ordered list
      def taxa_list
	@taxo_tmp = Array.new
	_taxa_list('genes')
	@taxo_tmp
      end
      def _taxa_list(taxa)
	unless  taxa =~ /^[a-z]{3}$/ or taxa == nil
	  @taxo_tmp.push(taxa)
	  tmp = taxonomy[taxa]
	  tmp.each do |o|
	    _taxa_list(o)
	  end
	else
	end
      end
      private :_taxa_list

      ##
      # Bio::KEGG::Keggtab#taxo2keggorgs(taxo_name) -> Array
      #    keggorg is a 3-letters notation of an organism, 'eco, hsa'
      def taxo2korgs(taxo)
	orgs = @taxonomy[taxo]
	if orgs[0].length == 3 or taxo == 'genes'
	  orgs
	else
	  orgs.each do |t|
	    @taxo_tmp.push(taxo2korgs(t))
	  end
	  tmp = @taxo_tmp
	  @taxo_tmp = Array.new
	  #	  tmp.flatten
	  return tmp
	end
      end
      alias taxo2keggorg taxo2korgs

      ##
      # Bio::KEGG::Keggtab#keggorg2taxo(keggorg) -> Array
      #    keggorg is a 3-letters notation of an organism, 'eco, hsa'
      # eco -> ['proteogamma','proteobacteria','eubacteria','genes']
      # 
      def korg2taxo(keggorg)
	@taxo_tmp = Array.new
	taxo_by_korg(keggorg)
      end
      alias keggorg2taxo korg2taxo
      def taxo_by_korg(keggorg)
	tmp = Array.new
	taxonomy.each do |k,v|
	  if v.include?(keggorg)
	    @taxo_tmp.push(k) 
	    taxo_by_korg(k)
	    tmp = @taxo_tmp
	    return tmp
	  end
	end
      end
      private :taxo_by_korg

      ## Methods for DB

      ##
      # Bio::KEGG::Keggtab#alias_list(db_name) -> Array
      #
      def alias_list(db_name)
	@db_names[db_name].aliases
      end
      

      ##
      # Bio::KEGG::Keggtab#db_by_abrev(db_abrev) -> Bio::KEGG::DBname
      #
      def db_by_abrev(db_abrev)
	tmp = nil
	@db_names.each do |k,db|
	  case db
	  when Bio::KEGG::DBname
	    if db.abrev == db_abrev
	      tmp = db
	    end
	  end
	end
	return tmp
      end

      ##
      # Bio::KEGG::Keggtab#name_by_abrev(db_abrev) -> db_name
      #
      def name_by_abrev(db_abrev)
	db_by_abrev(db_abrev).name
      end

      ##
      # Bio::KEGG::Keggtab#db_path(db_name) -> db_path
      #
      def db_path(db_name)
	if @bio_root
	  "#{@db_names[db_name].path.sub(/\$BIOROOT/,@bio_root)}/#{db_name}"
	else
	  raise ArgumentError, "@bio_root = #{@bio_root.inspect}"
	end
      end
      ##
      # Bio::KEGG::Keggtab#db_path_by_keggorg(db_name) -> db_path
      #
      def db_path_by_keggorg(korg)
	db_name = name_by_abrev(korg)
	db_path(db_name)
      end
      alias db_path_by_korg db_path_by_keggorg


    end # end of class Keggtab

  end # class KEGG
end # module Bio





if __FILE__ == $0

  keggtab = '/bio/org/genes/keggtab'
  
  kg = Bio::KEGG::Keggtab.new(keggtab, '/bio/org/genes')
  puts "== Initialize: kg = Bio::KEGG::Keggtab.new(keggtab) "


  puts "\n==> Methods for DBs <=="

  puts "\n == kg.db_names.each {|k,v| --}"
  kg.db_names.each do |k,v|
    p k
    p v
    puts
  end
  puts "\n == kg.db_names.keys "
  p  kg.db_names.keys 


  puts "\n==> Methods for DB <=="

  puts "\n == Bio::KEGG::Keggtab#db_path(db_name) -> String"
  puts "\n == kg.db_path('e.coli')"
  p kg.db_path('e.coli')

  puts "\n == kg.db_path_by_korg('hsa')"
  p kg.db_path_by_korg('hsa')

  puts "\n == Bio::KEGG::Keggtab.db_by_abrev('korg')"
  puts "\n == p db_by_abrev('eco') "
  p kg.db_by_abrev('eco')
  p kg.db_names['e.coli']

  puts "\n == Bio::KEGG::Keggtab.alias_list"
  korg='e.coli'
  p  kg.alias_list(korg)
  p kg.db_names[korg]


  puts "\n==> Methods for GENES Taxonomy <=="
  puts "\n == Bio::KEGG::Keggtab#taxonomy -> Hash"
  puts "\n  == kg.taxonomy.type"
  p kg.taxonomy.type


  puts "\n == Bio::KEGG::Keggtab#taxo2korgs(taso_name) -> Array"
  puts "\n  == kg.taxo2korgs('lowgc')"
  p kg.taxo2korgs('lowgc')
  puts "\n  == kg.korgs('eubacteria')"
  p kg.taxo2korgs('eubacteria')
  puts "\n  == kg.korgs('archaea')"
  p kg.taxo2korgs('archaea')
  puts "\n  == kg.korgs('eukaryotes')"
  p kg.taxo2korgs('eukaryotes')


  puts "\n == Bio::KEGG::Keggtab#korg2t(korg) -> Array"
  puts "\n  == kg.korg2t('eco') ->"
  p kg.korg2taxo('eco')

  puts "\n  == kg.korg2t('plants') ->"
  p kg.korg2taxo('plants')

  puts "\n  == taxa_list"
  p kg.taxa_list
end



=begin
== NAME

  bio/db/kegg/keggtab.rb - keggtab class

== Usage:

  tab = Bio::KEGG::Keggtab.new('genes/keggtab')

== Author
  Mitsuteru S. Nakao <n@BioRuby.org>,
  The BioRuby Project (http://BioRuby.org/)

== Class

  class Bio::KEGG::DBname
  class Bio::KEGG::Keggtab

== Methods

=== Bio::KEGG::DBname

* Initialize 
--- Bio::KEGG::DBname#new(name, type, path, abrev)

* Adding an alias name of db name
--- Bio::KEGG::DBname#add_alias(alias)

* Attributes accessor
--- Bio::KEGG::DBname#name -> str
--- Bio::KEGG::DBname#type -> str
--- Bio::KEGG::DBname#path -> str
--- Bio::KEGG::DBname#abrev -> str
--- Bio::KEGG::DBname#aliases -> anArray
--- Bio::KEGG::DBname#korg -> str


=== Bio::KEGG::Keggtab

* Initialize
--- Bio::KEGG::Keggtab#new(file_path, bio_root = nil)

* Attributes accessor
--- Bio::KEGG::Keggtab#db_names -> aHash
--- Bio::KEGG::Keggtab#taxonomy -> aHash

* Methods for KEGG/GENES Taxonomy
--- Bio::KEGG::Keggtab#taxa_list -> anArray

--- Bio::KEGG::Keggtab#taxo2keggorgs(taxo) -> anArray
    
Return an array of organism names included a taxa (taxo).

--- Bio::KEGG::Keggtab#keggorg2taxo(korg) -> anArray

Return an array of taxa names includeing a organism name (keggorg). 


* Methods for KEGG::DBname
--- Bio::KEGG::Keggtab#db_names[db_name] -> Bio::KEGG::DBname
--- Bio::KEGG::Keggtab#db_by_abrev(db_abrev) -> Bio::KEGG::DBname
--- Bio::KEGG::Keggtab#alias_list(db_name) -> anArray
--- Bio::KEGG::Keggtab#name_by_abrev(db_abrev) -> str
--- Bio::KEGG::Keggtab#db_path(db_name) -> str
--- Bio::KEGG::Keggtab#db_path_by_keggorg(keggorg) -> str



=end
