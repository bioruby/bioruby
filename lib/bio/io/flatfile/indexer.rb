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
#  $Id: indexer.rb,v 1.4 2002/09/11 11:37:34 ng Exp $ 
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
      end #module Parser

      def self.makeindexBDB(name, parser, options, *files)
	# options are not used in this method
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

      def self.makeindexFlat(name, parser, options, *files)
	if options['onmemory'] then
	  makeindexFlat_onmemory(name, parser, options, *files)
	else
	  makeindexFlat_tempfile(name, parser, options, *files)
	end
      end

      def self.makeindexFlat_onmemory(name, parser, options, *files)
	# options are not used in this method
	DEBUG.print "makeing flat/1 DataBank...\n"
	db = DataBank.new(name, nil)
	db.format = parser.format
	db.fileids.add(*files)
	db.primary = parser.primary.name
	db.secondary = parser.secondary.names

	db.fileids.recalc
	DEBUG.print "writing DabaBank...\n"
	db.write('wb')

	pdata = []
	sdata = {}
	parser.secondary.names.each { |x| sdata[x] = [] }

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

	DEBUG.print "sorting primary (#{parser.primary.name})...\n"
	pdata.sort! do |x, y|
	  r = (x[0] <=> y[0])
	  if r == 0 then
	    raise RuntimeError, "keys must be unique, but duplicated key #{x[0].inspect} exists"
	  end
	  r
	end
	DEBUG.print "writing primary (#{parser.primary.name})...\n"
	psize = get_record_size(pdata)
	write_mapfile(pdata, psize, db.primary.file)

	sdata.each do |i, a|
	  DEBUG.print "sorting secondary (#{i})...\n"
	  a.sort! { |x, y| x[0] <=> y[0] }
	  ssize = get_record_size(a)
	  DEBUG.print "writing secondary (#{i})...\n"
	  write_mapfile(a, ssize, db.secondary[i].file)
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

      def self.makeindexFlat_tempfile(name, parser, options, *files)
	DEBUG.print "makeing flat/1 DataBank using temporary files...\n"
	require 'tempfile'
	ext = options['external_sort_program']

	db = DataBank.new(name, nil)
	db.format = parser.format
	db.fileids.add(*files)
	db.primary = parser.primary.name
	db.secondary = parser.secondary.names

	db.fileids.recalc
	DEBUG.print "writing DabaBank...\n"
	db.write('wb')

	DEBUG.print "prepare temporary files...\n"
	tempbase = "bioflat#{rand(10000)}-"
	pfile = Tempfile.open(tempbase + 'primary')
	DEBUG.print "open temporary file #{pfile.path.inspect}\n"
	sfiles = {}
	parser.secondary.names.each do |x|
	  sfiles[x] =  Tempfile.open(tempbase + 'secondary')
	  DEBUG.print "open temporary file #{sfiles[x].path.inspect}\n"
	end

	DEBUG.print "reading files...\n"
	files.each_with_index do |filename, fileid|
	  DEBUG.print fileid, " ", filename, "\n"

	  parser.open_flatfile(filename)
	  parser.each do |pos, len|
	    p = parser.parse_primary
	    pfile << "#{p}\t#{fileid}\t#{pos}\t#{len}\n"
	    DEBUG.print "#{p} #{fileid} #{pos} #{len}\n"
	    parser.parse_secondary do |sn, sp|
	      sfiles[sn] << "#{sp}\t#{p}\n"
	      DEBUG.print "#{sp} #{p}\n"
	    end
	  end
	  parser.close_flatfile
	end

	DEBUG.print "sorting primary (#{parser.primary.name})...\n"
	pfile2 = Tempfile.open(tempbase + 'primary-2')
	DEBUG.print "open temporary file #{pfile2.path.inspect}\n"
	file_sort_write(pfile, pfile2, db.primary.file, ext, true)
	pfile.close
	pfile2.close

	parser.secondary.names.each do |x|
	  DEBUG.print "sorting secondary (#{x})...\n"
	  tmpfile = Tempfile.open(tempbase + 'secondary-2')
	  DEBUG.print "open temporary file #{tmpfile.path.inspect}\n"
	  file_sort_write(sfiles[x], tmpfile, db.secondary[x].file, ext)
	  sfiles[x].close
	  tmpfile.close
	end

	db.close
	true
      end #def

      def self.file_get_record_size(a, primary = nil)
	size = 0
	pn = nil
	pn2 = nil
	a.each do |x|
	  x.chomp!
	  l = x.length
	  if l > size
	    size = l
	  end
	  if primary then
	    pn2 = x.split("\t", 2)[0]
	    if pn == pn2 then
	      raise RuntimeError, "keys must be unique, but duplicated key #{pn.inspect} exists"
	    else
	      pn = pn2
	    end
	  end
	end
	size + 1
      end

      def self.file_write_mapfile(data, rec_size, mapfile)
	mapfile.mode = 'wb'
	mapfile.init(rec_size)
	data.each do |x|
	  x.chomp!
	  mapfile.write_record(x)
	end
	mapfile.close
	mapfile.mode = 'rb'
	true
      end

      def self.file_sort_write(file, tmpfile, mapfile, prog, primary = nil)
	file.flush
	file.pos = 0
	if prog then
	  filesort_external(file.path, tmpfile, prog)
	else
	  filesort_internal(file, tmpfile)
	end
	tmpfile.flush
	tmpfile.pos = 0
	ssize = file_get_record_size(tmpfile, primary)
	DEBUG.print "writing to file...\n"
	tmpfile.pos = 0
	file_write_mapfile(tmpfile, ssize, mapfile)
      end

      def self.filesort_external(filename, out, prog = '/usr/bin/sort')
	require 'open3'
	DEBUG.print "executing #{prog.inspect}\n"
	Open3.popen3(prog, filename) do |i, o, e|
	  o.each { |line| out << line }
	end
      end
      def self.filesort_internal(file, out)
	p = file.pos
	a = []
	file.each do |line|
	  a << line.split("\t", 2)[0] + "\t" + p.to_s
	  p = file.pos
	end
	a.sort!
	a.each do |x|
	  b = x.split("\t")
	  file.pos = b[1].to_i
	  out << file.gets
	end
      end

    end #module Indexer

    def self.makeindex(is_bdb, dbname, format, options, *files)
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

      parser = Indexer::Parser.new(dbclass)
      if /(EMBL|SPTR)/ =~ dbclass.to_s then
	a = [ 'DR' ]
	parser.add_secondary_namespaces(*a)
      end

      options = {} unless options
      
      if is_bdb then
	Indexer::makeindexBDB(dbname, parser, options, *files)
      else
	Indexer::makeindexFlat(dbname, parser, options, *files)
      end
    end #def makeindex

  end #class FlatFileIndex
end #module Bio

=begin

= Bio::FlatFile

--- Bio::FlatFile.makeindex(is_bdb, dbname, format, options, *files)

      Creating index files (called a databank) of given files.

=end
