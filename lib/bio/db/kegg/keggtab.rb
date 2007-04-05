#
# = bio/db/kegg/keggtab.rb - KEGG keggtab class
#
# Copyright::  Copyright (C) 2001 Mitsuteru C. Nakao <n@bioruby.org>
#              Copyright (C) 2003, 2006 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#  $Id: keggtab.rb,v 1.10 2007/04/05 23:35:41 trevor Exp $
#

module Bio
class KEGG

# == Description
#
# Parse 'keggtab' KEGG database definition file which also includes
# Taxonomic category of the KEGG organisms.
#
# == References
#
# The 'keggtab' file is included in
#
# * ftp://ftp.genome.jp/pub/kegg/tarfiles/genes.tar.gz
# * ftp://ftp.genome.jp/pub/kegg/tarfiles/genes.weekly.last.tar.Z
#
# == Format
#
# File format is something like
# 
#   # KEGGTAB
#   #
#   # name            type            directory                    abbreviation
#   #
#   enzyme            enzyme          $BIOROOT/db/ideas/ligand     ec
#   ec                alias           enzyme
#   (snip)
#   # Human
#   h.sapiens         genes           $BIOROOT/db/kegg/genes       hsa
#   H.sapiens         alias           h.sapiens
#   hsa               alias           h.sapiens
#   (snip)
#   #
#   # Taxonomy
#   #
#   (snip)
#   animals           alias           hsa+mmu+rno+dre+dme+cel
#   eukaryotes        alias           animals+plants+protists+fungi
#   genes             alias           eubacteria+archaea+eukaryotes
#
class Keggtab

  # Path for keggtab file and optionally set bioroot top directory.
  # Environmental variable BIOROOT overrides bioroot.
  def initialize(file_path, bioroot = nil)
    @bioroot = ENV['BIOROOT'] || bioroot
    @db_names = Hash.new
    @database = Hash.new
    @taxonomy = Hash.new
    File.open(file_path) do |f|
      parse_keggtab(f.read)
    end
  end

  # Returns a string of the BIOROOT path prefix.
  attr_reader :bioroot
  attr_reader :db_names


  # Bio::KEGG::Keggtab::DB

  class DB
    # Create a container object for database definitions.
    def initialize(db_name, db_type, db_path, db_abbrev)
      @name = db_name
      @type = db_type
      @path = db_path
      @abbrev = db_abbrev
      @aliases = Array.new
    end
    # Database name. (e.g. 'enzyme', 'h.sapies', 'e.coli', ...)
    attr_reader :name
    # Definition type. (e.g. 'enzyme', 'alias', 'genes', ...)
    attr_reader :type
    # Database flat file path. (e.g. '$BIOROOT/db/kegg/genes', ...)
    attr_reader :path
    # Short name for the database. (e.g. 'ec', 'hsa', 'eco', ...)
    # korg and keggorg are alias for abbrev method.
    attr_reader :abbrev
    # Array containing all alias names for the database.
    # (e.g. ["H.sapiens", "hsa"], ["E.coli", "eco"], ...)
    attr_reader :aliases

    alias korg abbrev
    alias keggorg abbrev
  end


  # DB section

  # Returns a hash containing DB definition section of the keggtab file.
  # If database name is given as an argument, returns a Keggtab::DB object.
  def database(db_abbrev = nil)
    if db_abbrev
      @database[db_abbrev]
    else
      @database
    end
  end

  # Returns an Array containing all alias names for the database.
  # (e.g. 'hsa' -> ["H.sapiens", "hsa"], 'hpj' -> ["H.pylori_J99", "hpj"])
  def aliases(db_abbrev)
    if @database[db_abbrev]
      @database[db_abbrev].aliases
    end
  end

  # Returns a canonical database name for the abbreviation.
  # (e.g. 'ec' -> 'enzyme',  'hsa' -> 'h.sapies', ...)
  def name(db_abbrev)
    if @database[db_abbrev]
      @database[db_abbrev].name
    end
  end

  # Returns an absolute path for the flat file database.
  # (e.g. '/bio/db/kegg/genes', ...)
  def path(db_abbrev)
    if @database[db_abbrev]
      file = @database[db_abbrev].name
      if @bioroot
        "#{@database[db_abbrev].path.sub(/\$BIOROOT/,@bioroot)}/#{file}"
      else
        "#{@database[db_abbrev].path}/#{file}"
      end
    end
  end


  # deprecated
  def alias_list(db_name)
    if @db_names[db_name]
      @db_names[db_name].aliases
    end
  end

  # deprecated
  def db_path(db_name)
    if @bioroot
      "#{@db_names[db_name].path.sub(/\$BIOROOT/,@bioroot)}/#{db_name}"
    else
      "#{@db_names[db_name].path}/#{db_name}"
    end
  end

  # deprecated
  def db_by_abbrev(db_abbrev)
    @db_names.each do |k, db|
      return db if db.abbrev == db_abbrev
    end
    return nil
  end

  # deprecated
  def name_by_abbrev(db_abbrev)
    db_by_abbrev(db_abbrev).name
  end

  # deprecated
  def db_path_by_abbrev(db_abbrev)
    db_name = name_by_abbrev(db_abbrev)
    db_path(db_name)
  end


  # Taxonomy section

  # Returns a hash containing Taxonomy section of the keggtab file.
  # If argument is given, returns a List of all child nodes belongs
  # to the label node.
  # (e.g. "eukaryotes" -> ["animals", "plants", "protists", "fungi"], ...)
  def taxonomy(node = nil)
    if node
      @taxonomy[node]
    else
      @taxonomy
    end
  end

  # List of all node labels from Taxonomy section.
  # (e.g. ["actinobacteria", "animals", "archaea", "bacillales", ...)
  def taxa_list
    @taxonomy.keys.sort
  end

  def child_nodes(node = 'genes')
    return @taxonomy[node]
  end

  # Returns an array of organism names included in the specified taxon
  # label. (e.g. 'proteobeta' -> ["nme", "nma", "rso"])
  # This method has taxo2keggorgs, taxon2korgs, and taxon2keggorgs aliases.
  def taxo2korgs(node = 'genes')
    if node.length == 3
      return node
    else
      if @taxonomy[node]
        tmp = Array.new
        @taxonomy[node].each do |x|
          tmp.push(taxo2korgs(x))
        end
        return tmp
      else
        return nil
      end
    end
  end
  alias taxo2keggorgs  taxo2korgs
  alias taxon2korgs    taxo2korgs
  alias taxon2keggorgs taxo2korgs

  # Returns an array of taxonomy names the organism belongs.
  # (e.g. 'eco' -> ['proteogamma','proteobacteria','eubacteria','genes'])
  # This method has aliases as keggorg2taxo, korg2taxonomy, keggorg2taxonomy.
  def korg2taxo(keggorg)
    tmp = Array.new
    traverse = Proc.new {|keggorg|
      @taxonomy.each do |k,v|
        if v.include?(keggorg)
          tmp.push(k)
          traverse.call(k)
          break
        end
      end
    }
    traverse.call(keggorg)
    return tmp
  end
  alias keggorg2taxo     korg2taxo
  alias korg2taxonomy    korg2taxo
  alias keggorg2taxonomy korg2taxo


  private

  def parse_keggtab(keggtab)
    in_taxonomy = nil
    keggtab.each do |line|
      case line
      when /^# Taxonomy/		# beginning of the taxonomy section
        in_taxonomy = true
      when /^#|^$/
        next
      when /(^\w\S+)\s+(\w+)\s+(\$\S+)\s+(\w+)/	# db
        db_name = $1
        db_type = $2
        db_path = $3
        db_abbrev = $4
        @db_names[db_name] =
          Bio::KEGG::Keggtab::DB.new(db_name, db_type, db_path, db_abbrev)
      when /(^\w\S+)\s+alias\s+(\w.+\w)/		# alias
        db_alias = $1
        db_name = $2#.downcase
        if in_taxonomy
          @taxonomy.update(db_alias => db_name.split('+'))
        elsif @db_names[db_name]
          @db_names[db_name].aliases.push(db_alias)
        end
      end
    end
    # convert keys-by-names hash @db_names to keys-by-abbrev hash @database
    @db_names.each do |k,v|
      @database[v.abbrev] = v
    end
  end

end # Keggtab

end # KEGG
end # Bio



if __FILE__ == $0

  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  if ARGV.empty?
    prefix =  ENV['BIOROOT'] || '/bio'
    keggtab_file = "#{prefix}/etc/keggtab"
  else
    keggtab_file = ARGV.shift
  end

  puts "= Initialize: keggtab = Bio::KEGG::Keggtab.new(file)"
  keggtab = Bio::KEGG::Keggtab.new(keggtab_file)


  puts "\n--- Bio::KEGG::Keggtab#bioroot # -> String"
  p keggtab.bioroot


  puts "\n== Methods for DB section"

  puts "\n--- Bio::KEGG::Keggtab#database # -> Hash"
  p keggtab.database

  puts "\n--- Bio::KEGG::Keggtab#database('eco') # -> Keggtab::DB"
  p keggtab.database('eco')

  puts "\n--- Bio::KEGG::Keggtab#name('eco') # -> String"
  p keggtab.name('eco')

  puts "\n--- Bio::KEGG::Keggtab#path('eco') # -> String"
  p keggtab.path('eco')

  puts "\n--- Bio::KEGG::Keggtab#aliases(abbrev) # -> Array"
  puts "\n++ keggtab.aliases('eco')"
  p keggtab.aliases('eco')
  puts "\n++ keggtab.aliases('vg')"
  p keggtab.aliases('vg')


  puts "\n== Methods for Taxonomy section"

  puts "\n--- Bio::KEGG::Keggtab#taxonomy # -> Hash"
  p keggtab.taxonomy

  puts "\n--- Bio::KEGG::Keggtab#taxonomy('archaea') # -> Hash"
  p keggtab.taxonomy('archaea')

  puts "\n--- Bio::KEGG::Keggtab#taxa_list # -> Array"
  p keggtab.taxa_list

  puts "\n--- Bio::KEGG::Keggtab#taxo2korgs(node) # -> Array"
  puts "\n++ keggtab.taxo2korgs('proteobeta')"
  p keggtab.taxo2korgs('proteobeta')
  puts "\n++ keggtab.taxo2korgs('eubacteria')"
  p keggtab.taxo2korgs('eubacteria')
  puts "\n++ keggtab.taxo2korgs('archaea')"
  p keggtab.taxo2korgs('archaea')
  puts "\n++ keggtab.taxo2korgs('eukaryotes')"
  p keggtab.taxo2korgs('eukaryotes')

  puts "\n--- Bio::KEGG::Keggtab#korg2taxo(keggorg) # -> Array"
  puts "\n++ keggtab.korg2taxo('eco')"
  p keggtab.korg2taxo('eco')
  puts "\n++ keggtab.korg2taxo('plants')"
  p keggtab.korg2taxo('plants')

end


