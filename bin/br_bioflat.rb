#!/usr/bin/env ruby  
# 
# bioflat - OBDA flat file indexer 
# 
#   Copyright (C) 2002 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp> 
# 
#  This program is free software; you can redistribute it and/or modify 
#  it under the terms of the GNU General Public License as published by 
#  the Free Software Foundation; either version 2 of the License, or 
#  (at your option) any later version. 
# 
#  This program is distributed in the hope that it will be useful, 
#  but WITHOUT ANY WARRANTY; without even the implied warranty of 
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
#  GNU General Public License for more details. 
# 
#  You should have received a copy of the GNU General Public License 
#  along with this program; if not, write to the Free Software 
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
# 
#  $Id: br_bioflat.rb,v 1.1 2002/08/19 11:43:37 k Exp $ 
# 

require 'bio'

module Bio
  class FlatFileIndex

    module Indexer
      class NameSpace
	def initialize(name, method)
	  @name = name
	  @proc = method
	end
	attr_reader :name, :proc

	EMBL_STYLE = {
	  'ID' => self.new( 'ID', Proc.new { |x| x.entry_id } ),
	  'AC' => self.new( 'AC', Proc.new { |x| x.accessions } ),
	  'SV' => self.new( 'SV', Proc.new { |x| x.sv } ),
	  'DR' => self.new( 'DR', Proc.new { |x|
			     y = []
			     x.dr.each_value { |z| y << z }
			     y.flatten!
			     y.find_all { |z| z.length > 1 } }
			   )
	}

	NCBI_STYLE = {
	  'VERSION'   => self.new( 'VERSION', Proc.new { |x| x.version } ),
	  'LOCUS'     => self.new( 'LOCUS', Proc.new { |x| x.entry_id } ),
	  'ACCESSION' => self.new( 'ACCESSION',
				  Proc.new { |x| x.accession.split } ),
	  'GI'        => self.new( 'GI', Proc.new { |x|
				    x.gi.to_s.gsub(/\AGI\:/, '') } )
	}
      end #class NameSpace

      class NameSpaces < Array
	def names
	  self.collect { |x| x.name }
	end
      end

      class Parser
	# parsing data
	# only necessary for makeing index
	def initialize(dbclass, pri = nil, secs = nil)
	  @primary = nil
	  @secondary = NameSpaces.new
	  @format = nil
	  @dbclass = nil
	  @namestyle = nil

	  case dbclass.to_s
	  when 'embl', 'Bio::EMBL'
	    @format = 'embl'
	    @dbclass = Bio::EMBL
	    @namestyle = NameSpace::EMBL_STYLE
	    pri = 'ID' unless pri
	    unless secs then
	      secs = [ 'AC', 'SV' ]
	    end

	  when 'swiss', 'Bio::SPTR', 'Bio::TrEMBL', 'Bio::SwissProt'
	    @format = 'swiss'
	    @dbclass = Bio::SPTR
	    @namestyle = NameSpace::EMBL_STYLE
	    pri = 'ID' unless pri
	    unless secs then
	      secs = [ 'AC' ]
	    end

	  when 'genbank', 'Bio::GenBank', 'Bio::RefSeq', 'Bio::DDBJ'
	    @format = 'genbank'
	    @dbclass = Bio::GenBank
	    #pri = 'GI' unless pri
	    @namestyle = NameSpace::NCBI_STYLE
	    pri = 'VERSION' unless pri
	    unless secs then
	      secs = []
	      @namestyle.each_value { |x|
		secs << x.name if x.name != pri
	      }
	    end

	  when 'Bio::GenPept'
	    @format = 'genbank'
	    @dbclass = Bio::GenPept
	    @namestyle = NameSpace::NCBI_STYLE
	    pri = 'VERSION' unless pri
	    unless secs then
	      secs = []
	      @namestyle.each_value { |x|
		secs << x.name if x.name != pri
	      }
	    end

	  else
	    raise 'unknown or unsupported format'
	  end #case dbclass.to_s

	  @primary = @namestyle[pri] unless pri.is_a?(NameSpace)
	  raise 'unknown primary namespace' unless @primary
	  add_secondary_namespaces(*secs)
	end
	attr_reader :primary, :secondary, :format, :dbclass

	def add_secondary_namespaces(*names)
	  DEBUG.print "add_secondary_namespaces: #{names.inspect}\n"
	  names.each do |x|
	    unless x.is_a?(NameSpace) then
	      y = @namestyle[x]
	      raise 'unknown secondary namespace' unless y
	      @secondary << y
	    end
	  end
	  true
	end
      end #class Parser

      def self.makeindexBDB(name, format, pri, sec,
			    add_sec_ns, *files)
	DEBUG.print "makeing BDB DataBank...\n"
	fmt = Parser.new(format, pri, sec)
	fmt.add_secondary_namespaces(*add_sec_ns)

	db = DataBank.new(name, nil)

	db.index_type = MAGIC_BDB
	DEBUG.print "writing config.dat...\n"
	DataBank.write(db)

	db.format = fmt.format
	db.fields.add(*files)
	db.fields.recalc

	db.close_bdbdata
	db.open_bdbdata(BDBdefault::flag_write)

	db.set_primary_namespace(fmt.primary.name)
	db.set_secondary_namespaces(fmt.secondary.names)
	db.writeback_namespaces
	db.reinit_fields

	dbclass = fmt.dbclass

	DEBUG.print "reading files...\n"

	pn = db.primary
	pn.file.close
	pn.file.flag = BDBdefault.flag_write

	db.secondary.each_files do |x|
	  x.file.close
	  x.file.flag = BDBdefault.flag_write
	end

	db.fields.each_with_index do |fobj, field|
	  filename = fobj.filename
	  DEBUG.print field, " ", filename, "\n"

	  ff = Bio::FlatFile.open(dbclass, filename)
	  ff.raw = true
	  pos = ff.io.pos
	  ff.each do |txt|
	    len = txt.length
	    obj = dbclass.new(txt)
	    p = fmt.primary.proc.call(obj)
	    pn.file.add_exclusive(p, [ field, pos, len ])
	    DEBUG.print "#{p} #{field} #{pos} #{len}\n"
	    fmt.secondary.each_index do |i|
	      sn = fmt.secondary[i].name
	      s = fmt.secondary[i].proc.call(obj)
	      s.each { |x|
		db.secondary[sn].file.add_nr(x, p)
		DEBUG.print "#{x} #{p}\n"
	      }
	    end
	    pos = ff.io.pos
	  end
	  ff.close
	end
	db.close
	true
      end

      def self.makeindexFlat(name, format, pri, sec,
			 add_sec_ns, *files)
	DEBUG.print "makeing FlatOnly DataBank...\n"
	fmt = Parser.new(format, pri, sec)
	fmt.add_secondary_namespaces(*add_sec_ns)

	db = DataBank.new(name, nil)
	db.format = fmt.format
	db.fields.add(*files)
	db.set_primary_namespace(fmt.primary.name)
	db.set_secondary_namespaces(fmt.secondary.names)

	dbclass = fmt.dbclass
	pdata = []
	sdata = Array.new(fmt.secondary.names.size)
	sdata.collect! { |x| [] }

	db.fields.recalc
	DEBUG.print "writing DabaBank...\n"
	DataBank.write(db)

	DEBUG.print "reading files...\n"
	files.each_with_index do |filename, field|
	  DEBUG.print field, " ", filename, "\n"

	  ff = Bio::FlatFile.open(dbclass, filename)
	  ff.raw = true
	  pos = ff.io.pos
	  ff.each do |txt|
	    len = txt.length
	    obj = dbclass.new(txt)
	    p = fmt.primary.proc.call(obj)
	    pdata << [ p, [ field, pos, len ] ]
	    DEBUG.print "#{p} #{field} #{pos} #{len}\n"
	    fmt.secondary.each_index do |i|
	      s = fmt.secondary[i].proc.call(obj)
	      s.each { |x|
		sdata[i] << [ x, p ]
		DEBUG.print "#{x} #{p}\n"
	      }
	    end
	    pos = ff.io.pos
	  end
	  ff.close
	end

	DEBUG.print "sorting primary...\n"
	pdata.sort! do |x, y|
	  r = (x[0] <=> y[0])
	  if r == 0 then
	    raise RuntimeError, "keys must be unique, but duplicated key #{x[0].inspect} exists"
	  end
	  r
	end

	DEBUG.print "sorting secondary...\n"
	sdata.each { |a| a.sort! { |x, y| x[0] <=> y[0] } }
	  
	DEBUG.print "get record size...\n"
	psize = get_record_size(pdata)
	ssize = sdata.collect { |x| get_record_size(x) }

	DEBUG.print "writing...\n"
	write_mapfile(pdata, psize, db.primary.file)
	sdata.each_with_index do |x, i|
	  write_mapfile(x, ssize[i], db.secondary[fmt.secondary.names[i]].file)
	end

	db.close
	true
      end #def

      def self.get_record_size(a)
	size = 0
	a.each do |x|
	  l = x.flatten.join("\t").length
	  if l > size
	    size = l
	  end
	end
	size + 1
      end

      def self.write_mapfile(data, rec_size, mapfile)
	mapfile.mode = 'wb'
	mapfile.init(rec_size)
	data.each do |x|
	  mapfile.write_record(x.flatten.join("\t"))
	end
	mapfile.close
	mapfile.mode = 'rb'
	true
      end
    end #module Indexer

  end #class FlatFileIndex
end #module Bio




if __FILE__ == $0


  def create_index(is_bdb, dbname, format, *files)
    case format
    when /genbank/i
      dbclass = Bio::GenBank
      add_secondary = nil
    when /genpept/i
      dbclass = Bio::GenPept
      add_secondary = nil
    when /embl/i
      dbclass = Bio::EMBL
      add_secondary = [ 'DR' ]
    when /sptr/i
      dbclass = Bio::SPTR
      add_secondary = [ 'DR' ]
    else
      raise "Unsupported format : #{format}"
    end
    if is_bdb then
      Bio::FlatFileIndex::Indexer::makeindexBDB(dbname, dbclass, nil, nil, add_secondary, *files)
    else
      Bio::FlatFileIndex::Indexer::makeindexFlat(dbname, dbclass, nil, nil, add_secondary, *files)
    end
  end

  def do_index
    is_bdb = /bdb/.match(ARGV[0]) ? Bio::FlatFileIndex::MAGIC_BDB : nil
    dbname = ARGV[1]
    format = ARGV[3]
    files  = ARGV[4..-1]
    files.shift if files[0] == '--files'
    create_index(is_bdb, dbname, format, *files)
  end


  def do_search
    ARGV.shift if ARGV[0] == '--search'
    dbname = ARGV.shift
    db = Bio::FlatFileIndex.open(dbname)
    ARGV.each do |key|
      STDERR.print "Searching for \'#{key}\'...\n"
      r = db.search(key)
      STDERR.print "OK, #{r.size} entry found\n"
      if r.size > 0 then
	print r
      end
    end
    db.close
  end


  def usage
    print "Create index: \n"
    print "#{$0} --makeindex DBNAME --format CLASS [--files] FILENAME...\n"
    print "#{$0} --makeindexBDB DBNAME --format CLASS [--files] FILENAME...\n"
    print "Search: \n"
    print "#{$0} [--search] DBNAME KEYWORD...\n"
  end


  if ARGV.size > 1
    case ARGV[0]
    when /--make/
      do_index
    when /--search/
      do_search
    end
  else
    usage
  end


end

