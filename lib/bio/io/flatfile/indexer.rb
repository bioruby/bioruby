# 
# bio/io/flatfile/indexer.rb - OBDA flatfile indexer
# 
#   Copyright (C) 2002 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp> 
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
#  $Id: indexer.rb,v 1.3 2002/09/04 11:23:23 ng Exp $ 
# 

module Bio
  class FlatFileIndex

    module Indexer

      class NameSpace
	def initialize(name, method)
	  @name = name
	  @proc = method
	end
	attr_reader :name, :proc
      end #class NameSpace

      class NameSpaces < Hash
	def initialize(*arg)
	  super()
	  arg.each do |x|
	    self.store(x.name, x)
	  end
	end
	def names
	  self.keys
	end
	def <<(x)
	  self.store(x.name, x)
	end
	def add(x)
	  self.store(x.name, x)
	end
	#alias :each_orig :each
	alias :each :each_value
      end

      module Parser
	def self.new(format, *arg)
	  case format.to_s
	  when 'embl', 'Bio::EMBL'
	    EMBLParser.new(*arg)
	  when 'swiss', 'Bio::SPTR', 'Bio::TrEMBL', 'Bio::SwissProt'
	    SPTRParser.new(*arg)
	  when 'genbank', 'Bio::GenBank', 'Bio::RefSeq', 'Bio::DDBJ'
	    GenBankParser.new(*arg)
	  when 'Bio::GenPept'
	    GenPeptParser.new(*arg)
	  else
	    raise 'unknown or unsupported format'
	  end #case dbclass.to_s
	end
      end #module Parser
	
      class TemplateParser
	NAMESTYLE = NameSpaces.new
	def initialize
	  @namestyle = self.class::NAMESTYLE
	  @secondary = NameSpaces.new
	end
	attr_reader :primary, :secondary, :format, :dbclass
	
	def set_primary_namespace(name)
	  if name.is_a?(NameSpace) then
	    @primary = name
	  else
	    @primary = @namestyle[name] 
	  end
	  raise 'unknown primary namespace' unless @primary
	  @primary
	end
	
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

	def open_flatfile(file)
	  @flatfile = Bio::FlatFile.open(@dbclass, file, 'rb')
	  @flatfile.raw = nil
	  @entry = nil
	end

	def each
	  pos = @flatfile.pos
	  @flatfile.each do |x|
	    @entry = x
	    len = @flatfile.entry_raw.length
	    yield pos, len
	    pos = @flatfile.pos
	  end
	end

	def parse_primary
	  self.primary.proc.call(@entry)
	end

	def parse_secondary
	  self.secondary.each do |x|
	    p = x.proc.call(@entry)
	    p.each do |y|
	      yield x.name, y
	    end
	  end
	end

	def close_flatfile
	  @flatfile.close
	end

	protected
	attr_writer :format, :dbclass
      end #class TemplateParser

      class GenBankParser < TemplateParser
	NAMESTYLE = NameSpaces.new(
	   NameSpace.new( 'VERSION', Proc.new { |x| x.version } ),
	   NameSpace.new( 'LOCUS', Proc.new { |x| x.entry_id } ),
	   NameSpace.new( 'ACCESSION',
			 Proc.new { |x| x.accession.split } ),
	   NameSpace.new( 'GI', Proc.new { |x|
			   x.gi.to_s.gsub(/\AGI\:/, '') } )
				   )
	PRIMARY = 'VERSION'
	def initialize(pri_name = nil, sec_names = nil)
	  super()
	  self.format = 'genbank'
	  self.dbclass = Bio::GenBank
	  self.set_primary_namespace((pri_name or PRIMARY))
	  unless sec_names then
	    sec_names = []
	    @namestyle.each_value do |x|
	      sec_names << x.name if x.name != self.primary.name
	    end
	  end
	  self.add_secondary_namespaces(*sec_names)
	end
      end #class GenBankParser

      class GenPeptParser < GenBankParser
	def initialize(*arg)
	  super(*arg)
	  self.dbclass = Bio::GenPept
	end
      end #class GenPeptParser

      class EMBLParser < TemplateParser
	NAMESTYLE = NameSpaces.new(
	   NameSpace.new( 'ID', Proc.new { |x| x.entry_id } ),
	   NameSpace.new( 'AC', Proc.new { |x| x.accessions } ),
	   NameSpace.new( 'SV', Proc.new { |x| x.sv } ),
	   NameSpace.new( 'DR', Proc.new { |x|
			   y = []
			   x.dr.each_value { |z| y << z }
			   y.flatten!
			   y.find_all { |z| z.length > 1 } }
			 )
				   )
	PRIMARY = 'ID'
	SECONDARY = [ 'AC', 'SV' ]
	def initialize(pri_name = nil, sec_names = nil)
	  super()
	  self.format = 'embl'
	  self.dbclass = Bio::EMBL
	  self.set_primary_namespace((pri_name or PRIMARY))
	  unless sec_names then
	    sec_names = self.class::SECONDARY
	  end
	  self.add_secondary_namespaces(*sec_names)
	end
      end #class EMBLParser

      class SPTRParser < EMBLParser
	SECONDARY = [ 'AC' ]
	def initialize(*arg)
	  super(*arg)
	  self.format = 'swiss'
	  self.dbclass = Bio::SPTR
	end
      end #class SPTRParser

      def self.makeindexBDB(name, parser, *files)
	unless defined?(BDB)
	  raise RuntimeError, "Berkeley DB support not found"
	end
	DEBUG.print "makeing BDB DataBank...\n"
	db = DataBank.new(name, MAGIC_BDB)
	db.format = parser.format
	db.fileids.add(*files)
	db.fileids.recalc

	db.primary = parser.primary.name
	db.secondary = parser.secondary.names

	DEBUG.print "writing config.dat, config, fileids ...\n"
	db.write('wb', BDBdefault::flag_write)

	DEBUG.print "reading files...\n"

	pn = db.primary
	pn.file.close
	pn.file.flag = BDBdefault.flag_write

	db.secondary.each_files do |x|
	  x.file.close
	  x.file.flag = BDBdefault.flag_write
	end

	db.fileids.each_with_index do |fobj, fileid|
	  filename = fobj.filename
	  DEBUG.print fileid, " ", filename, "\n"

	  parser.open_flatfile(filename)
	  parser.each do |pos, len|
	    p = parser.parse_primary
	    pn.file.add_exclusive(p, [ fileid, pos, len ])
	    DEBUG.print "#{p} #{fileid} #{pos} #{len}\n"
	    parser.parse_secondary do |sn, sp|
	      db.secondary[sn].file.add_nr(sp, p)
	      DEBUG.print "#{sp} #{p}\n"
	    end
	  end
	  parser.close_flatfile
	end
	db.close
	true
      end

      def self.makeindexFlat(name, parser, *files)
	DEBUG.print "makeing flat/1 DataBank...\n"
	db = DataBank.new(name, nil)
	db.format = parser.format
	db.fileids.add(*files)
	db.primary = parser.primary.name
	db.secondary = parser.secondary.names

	pdata = []
	sdata = {}
	parser.secondary.names.each { |x| sdata[x] = [] }

	db.fileids.recalc
	DEBUG.print "writing DabaBank...\n"
	db.write('wb')

	DEBUG.print "reading files...\n"
	files.each_with_index do |filename, fileid|
	  DEBUG.print fileid, " ", filename, "\n"

	  parser.open_flatfile(filename)
	  parser.each do |pos, len|
	    p = parser.parse_primary
	    pdata << [ p, [ fileid, pos, len ] ]
	    DEBUG.print "#{p} #{fileid} #{pos} #{len}\n"
	    parser.parse_secondary do |sn, sp|
	      sdata[sn] << [ sp, p ]
	      DEBUG.print "#{sp} #{p}\n"
	    end
	  end
	  parser.close_flatfile
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
	sdata.each_value { |a| a.sort! { |x, y| x[0] <=> y[0] } }
	  
	ssize = sdata.collect { |x|  }

	DEBUG.print "writing...\n"
	DEBUG.print "get record size of primary...\n"
	psize = get_record_size(pdata)
	write_mapfile(pdata, psize, db.primary.file)
	sdata.each do |i, x|
	  ssize = get_record_size(x)
	  write_mapfile(x, ssize, db.secondary[parser.secondary[i].name].file)
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

      def self.makeindex(is_bdb, dbname, format, *files)
	if format then
	  case format
	  when /genbank/i
	    dbclass = Bio::GenBank
	    add_secondary = nil
	  when /genpept/i
	    dbclass = Bio::GenPept
	  when /embl/i
	    dbclass = Bio::EMBL
	  when /sptr/i
	    dbclass = Bio::SPTR
	  else
	    raise "Unsupported format : #{format}"
	  end
	else
	  dbclass = Bio::FlatFile.autodetect_file(files[0])
	  raise "Cannot determine format" unless dbclass
	  DEBUG.print "file format is #{dbclass}\n"
	end

	parser = Parser.new(dbclass)
	if /(EMBL|SPTR)/ =~ dbclass.to_s then
	  a = [ 'DR' ]
	  parser.add_secondary_namespaces(*a)
	end

	if is_bdb then
	  makeindexBDB(dbname, parser, *files)
	else
	  makeindexFlat(dbname, parser, *files)
	end
      end #def

    end #module Indexer

  end #class FlatFileIndex
end #module Bio
