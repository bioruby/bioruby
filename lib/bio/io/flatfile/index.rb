# 
# bio/io/flatfile/index.rb - flatfile index 
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
#  $Id: index.rb,v 1.1 2002/08/19 11:43:37 k Exp $ 
# 


module Bio
  class FlatFileIndex
    MAGIC_FLAT = 'flat/1'
    MAGIC_BDB = 'BerkeleyDB/1'

    #########################################################
    def self.open(name)
      self.new(name)
    end

    def initialize(name)
      @db = DataBank.open(name)
    end

    def close
      check_closed?
      @db.close
      @db = nil
    end

    def closed?
      if @db then
	false
      else
	true
      end
    end

    def check_closed?
      @db or raise IOError, 'closed databank'
    end
    private :check_closed?

    def search(key)
      check_closed?
      @db.search_all(key)
    end

    def search_namespaces(key, *names)
      check_closed?
      @db.search_namespaces(key, *names)
    end

    def search_primary(key)
      check_closed?
      @db.search_primary(key)
    end

    def include?(key)
      check_closed?
      r = @db.search_all_get_unique_id(key)
      if r.empty? then
	nil
      else
	r
      end
    end

    def include_in_namespaces?(key, *names)
      check_closed?
      r = @db.search_namespaces_get_unique_id(key, *names)
      if r.empty? then
	nil
      else
	r
      end
    end

    def include_in_primary?(key)
      check_closed?
      r = @db.search_primary_get_unique_id(key)
      if r.empty? then
	nil
      else
	r
      end
    end

    def namespaces
      check_closed?
      r = secondary_namespaces
      r.unshift primary_namespace
      r
    end

    def primary_namespace
      check_closed?
      @db.primary.name
    end

    def secondary_namespaces
      check_closed?
      @db.secondary.names
    end

    def check_consistency
      check_closed?
      @db.check_consistency
    end

    def always_check=(bool)
      @db.always_check=(bool)
    end
    def always_check(bool)
      @db.always_check
    end
    #########################################################

    module DEBUG
      @@out = STDERR
      def self.out=(io)
	@@out = io
      end
      def self.out
	@@out
      end
      def self.print(*arg)
	@@out.print(*arg) if @@out
      end
    end #class DEBUG

    module IOroutines
      def file2hash(fileobj)
	hash = {}
	fileobj.each do |line|
	  line.chomp!
	  a = line.split("\t", 2)
	  hash[a[0]] = a[1]
	end
	hash
      end
      module_function :file2hash
      private :file2hash
    end #module IOroutines

    module Template
      class NameSpace
	def filename
	  # should be redifined in child class
	  raise NotImplementedError, "should be redefined in child class"
	end

	def mapping(filename)
	  # should be redifined in child class
	  raise NotImplementedError, "should be redefined in child class"
	  #FlatOnly::FlatMappingFile.new(filename)
	end

	def initialize(dbname, name)
	  @dbname = dbname
	  @name = name.dup
	  @name.freeze
	  @file = mapping(filename)
	end
	attr_reader :dbname, :name, :file

	def search(key)
	  @file.open
	  @file.search(key)
	end

	def close
	  @file.close
	end

	def include?(key)
	  r = search(key)
	  unless r.empty? then
	    key
	  else
	    nil
	  end
	end
      end #class NameSpace
    end #module Template

    class Field
      def self.new_from_string(str)
	a = str.split("\t", 2)
	a[1] = a[1].to_i if a[1]
	self.new(a[0], a[1])
      end

      def initialize(filename, filesize = nil)
	@filename = filename
	@filesize = filesize
	@io = nil
      end
      attr_reader :filename, :filesize

      def check
	r =  (File.size(@filename) == @filesize)
	DEBUG.print "Field: File.size(#{@filename.inspect})", (r ? '==' : '!=') , "#{@filesize} ", (r ? ': good!' : ': bad!'), "\n"
	r
      end

      def recalc
	@filesize = File.size(@filename)
      end

      def to_s(i = nil)
	if i then
	  str = "field_#{i}\t"
	else
	  str = ''
	end
	str << "#{@filename}\t#{@filesize}"
	str
      end

      def open
	unless @io then
	  DEBUG.print "Field: open #{@filename}\n"
	  @io = File.open(@filename, 'rb')
	  true
	else
	  nil
	end
      end

      def close
	if @io then
	  DEBUG.print "Field: close #{@filename}\n"
	  @io.close
	  @io = nil
	  nil
	else
	  true
	end
      end

      def seek(*arg)
	@io.seek(*arg)
      end

      def read(size)
	@io.read(size)
      end

      def get(pos, length)
	open
	seek(pos, IO::SEEK_SET)
	data = read(length)
	close
	data
      end
    end #class Field

    module FlatOnly
      class Record
	def initialize(str, size = nil)
	  a = str.split("\t")
	  a.each { |x| x.to_s.gsub!(/[\000 ]+\z/, '') }
	  @key = a.shift.to_s
	  @val = a
	  @size = (size or str.length)
	  DEBUG.print "key=#{@key.inspect},val=#{@val.inspect},size=#{@size}\n"
	end
	attr_reader :key, :val, :size

	def to_s
	  self.class.to_string(@size, @key, @val)
	end

	def self.to_string(size, key, val)
	  sprintf("%-*s", size, key + "\t" + val.join("\t"))
	end

	def self.create(size, key, val)
	  self.new(self.to_string(size, key, val))
	end
      end #class Record

      class FlatMappingFile
	@@recsize_width = 4
	@@recsize_regex = /\A\d{4}\z/

	def self.open(*arg)
	  self.new(*arg)
	end

	def initialize(filename, mode = 'rb')
	  @filename = filename
	  @mode = mode
	  @file = nil
	  #@file = File.open(filename, mode)
	  @record_size = nil
	  @records = nil
	end
	attr_accessor :mode
	attr_reader :filename
	
	def open
	  unless @file then
	    DEBUG.print "FlatMappingFile: open #{@filename}\n"
	    @file = File.open(@filename, @mode)
	    true
	  else
	    nil
	  end
	end

	def close
	  if @file then
	    DEBUG.print "FlatMappingFile: close #{@filename}\n"
	    @file.close
	    @file = nil
	  end
	  nil
	end

	def record_size
	  unless @record_size then
	    open
	    @file.seek(0, IO::SEEK_SET)
	    s = @file.read(@@recsize_width)
	    raise 'strange record size' unless s =~ @@recsize_regex
	    @record_size = s.to_i
	    DEBUG.print "FlatMappingFile: record_size: #{@record_size}\n"
	  end
	  @record_size
	end

	def get_record(i)
	  rs = record_size
	  seek(i)
	  str = @file.read(rs)
	  DEBUG.print "get_record(#{i})=#{str.inspect}\n"
	  str
	end

	def seek(i)
	  rs = record_size
	  @file.seek(@@recsize_width + rs * i)
	end

	def records
	  unless @records then
	    rs = record_size
	    @records = (@file.stat.size - @@recsize_width) / rs
	    DEBUG.print "FlatMappingFile: records: #{@records}\n"
	  end
	  @records
	end
	alias :size :records

	# methods for writing file
	def write_record(str)
	  rs = record_size
	  rec = sprintf("%-*s", rs, str)[0..rs]
	  @file.write(rec)
	end

	def add_record(str)
	  n = records
	  rs = record_size
	  @file.seek(0, IO::SEEK_END)
	  write_record(str)
	  @records += 1
	end

	def put_record(i, str)
	  n = records
	  rs = record_size
	  if i >= n then
	    @file.seek(0, IO::SEEK_END)
	    @file.write(sprintf("%-*s", rs, '') * (i - n))
	    @records = i + 1
	  else
	    seek(i)
	  end
	  write_record(str)
	end

	def init(rs)
	  unless 0 < rs and rs < 10 ** @@recsize_width then
	    raise 'record size out of range'
	  end
	  open
	  @record_size = rs
	  str = sprintf("%0*d", @@recsize_width, rs)
	  @file.truncate(0)
	  @file.seek(0, IO::SEEK_SET)
	  @file.write(str)
	  @records = 0
	end

	def self.create(record_size, filename, mode = 'wb+')
	  f = self.new(filename, mode)
	  f.init(record_size)
	end

	# methods for searching
	def search(key)
	  n = records
	  return [] if n <= 0
	  i = n / 2
	  i_prev = nil
	  DEBUG.print "binary search starts...\n"
	  begin
	    rec = Record.new(get_record(i))
	    i_prev = i
	    if key < rec.key then
	      n = i
	      i = i / 2
	    elsif key > rec.key then
	      i = (i + n) / 2
	    else # key == rec.key
	      result = [ rec.val ]
	      j = i - 1
	      while j >= 0 and
		  (rec = Record.new(get_record(j))).key == key
		result << rec.val
		j = j - 1
	      end
	      result.reverse!
	      j = i + 1
	      while j < n and
		  (rec = Record.new(get_record(j))).key == key
		result << rec.val
		j = j + 1
	      end
	      DEBUG.print "#{result.size} hits found!!\n"
	      return result
	    end
	  end until i_prev == i
	  DEBUG.print "no hits found\n"
	  #nil
	  []
	end
      end #class FlatMappingFile

      class Fields < Array
	def []=(n, data)
	  if data.is_a?(Field) then
	    super(n, data)
	  elsif data then
	    a = data.split("\t", 2)
	    super(n, Field.new(a[0], a[1].to_i))
	  else
	    # data is nil
	    super(n, nil)
	  end
	  self[n]
	end

	def add(*arg)
	  arg.each do |filename|
	    self << Field.new(filename)
	  end
	end

	def each
	  (0...self.size).each do |i|
	    x = self[i]
	    yield(x) if x
	  end
	  self
	end

	def each_with_index
	  (0...self.size).each do |i|
	    x = self[i]
	    yield(x, i) if x
	  end
	  self
	end

	def check_all
	  r = true
	  self.each do |x|
	    r = x.check
	    break unless r
	  end
	  r
	end
	alias :check :check_all

	def close_all
	  self.each do |x|
	    x.close
	  end
	  nil
	end
	alias :close :close_all

	def recalc_all
	  self.each do |x|
	    x.recalc
	  end
	  true
	end
	alias :recalc :recalc_all

	def set_list(ary)
	  ary.each do |x|
	    self[ary[0]] = ary[1]
	  end
	end

	def show_list
	  r = []
	  each_with_index do |x, i|
	    r << [ i, x ]
	  end
	  r
	end
      end #class Fields

      class PrimaryNameSpace < Template::NameSpace
	def mapping(filename)
	  FlatMappingFile.new(filename)
	end
	def filename
	  File.join(dbname, "key_#{name}.key")
	end
      end #class PrimaryNameSpace

      class SecondaryNameSpace < Template::NameSpace
	def mapping(filename)
	  FlatMappingFile.new(filename)
	end
	def filename
	  File.join(dbname, "id_#{name}.index")
	end
	def search(key)
	  r = super(key)
	  file.close
	  r.flatten!
	  r
	end
      end #class SecondaryNameSpace
    end #module FlatOnly


    class NameSpaces < Hash
      def initialize(dbname, nsclass, arg)
	@dbname = dbname
	@nsclass = nsclass
	if arg.is_a?(String) then
	  a = arg.split("\t")
	else
	  a = arg
	end
	a.each do |x|
	  self[x] = @nsclass.new(@dbname, x)
	end
	self
      end

      def each_names
	self.names.each do |x|
	  yield x
	end
      end

      def each_files
	self.values.each do |x|
	  yield x
	end
      end

      def names
	keys
      end

      def close_all
	values.each { |x| x.file.close }
      end
      alias :close :close_all

      def search(key)
	r = []
	values.each do |ns|
	  r.concat ns.search(key)
	end
	r.sort!
	r.uniq!
	r
      end

      def search_names(key, *names)
	r = []
	names.each do |x|
	  ns = self[x]
	  raise "undefined namespace #{x}" unless ns
	  r.concat ns.search(key)
	end
	r
      end

      def to_s
	names.join("\t")
      end
    end #class NameSpaces

    class DataBank
      def self.write(db, mode = 'wb')
	unless FileTest.directory?(db.dbname) then
	  Dir.mkdir(db.dbname)
	end
	f = File.open(File.join(db.dbname, 'config.dat'), mode)
	f.write db.to_s
	f.close
      end

      def self.read(name, mode = 'rb')
	f = File.open(File.join(name, 'config.dat'), mode)
	hash = IOroutines::file2hash(f)
	f.close
	self.new(name, nil, hash)
      end

      def self.open(*arg)
	self.read(*arg)
      end

      def initialize(name, idx_type = nil, hash = {})
	@dbname = name.dup
	#p @dbname
	@fields = nil
	@bdb = nil
	@bdbdata = nil
	@always_check = true
	self.index_type = (hash['index'] or idx_type)

	set_primary_namespace(nil)
	set_secondary_namespaces(nil)

	if @bdb then
	  self.open_bdbdata
	  self.init_fields
	  set_primary_namespace(@bdbdata.primary)
	  set_secondary_namespaces(@bdbdata.secondary)
	else
	  self.init_fields
	  @misc = {}
	  hash.each do |key,val|
	    case key
	    when 'format'
	      self.format = val.to_s.dup
	    when 'primary_namespace'
	      set_primary_namespace(val)
	    when 'secondary_namespaces'
	      set_secondary_namespaces(val)
	    when /\Afield_(\d+)\z/
	      @fields[$1.to_i] = val
	    else
	      @misc[key] = val.to_s.dup
	    end
	  end
	end
	true
      end

      attr_reader :dbname, :index_type, :format, :fields
      attr_reader :primary, :secondary
      attr_reader :always_check

      def index_type=(str)
	case str
	when MAGIC_BDB
	  @index_type = MAGIC_BDB
	  @bdb = true
	  unless defined?(Bio::FlatFileIndex::BDBDataBank)
	    raise RuntimeError, "Berkeley DB support not found"
	  end
	when MAGIC_FLAT, '', nil, false
	  @index_type = MAGIC_FLAT
	  @bdb = false
	else
	  raise 'unknown or unsupported index type'
	end
      end

      def always_check=(bool)
	if bool then
	  @always_check = true
	else
	  @always_check = false
	end
      end

      def open_bdbdata(*arg)
	unless @bdbdata then
	  @bdbdata = BDBDataBank.new(@dbname, *arg)
	end
	true
      end

      def close_bdbdata
	if @bdbdata then
	  @bdbdata.close
	  @bdbdata = nil
	end
	nil
      end

      def writeback_namespaces
	@bdbdata.writeback_primary(@primary)
	@bdbdata.writeback_secondary(@secondary)
      end

      def init_fields
	if @bdb then
	  @fields = BDBsolution::Fields.new(@bdbdata.file)
	else
	  @fields = FlatOnly::Fields.new
	end
      end

      def reinit_fields
	ls = nil
	if @fields then
	  ls = @fields.show_list
	end
	init_fields
	@fields.set_list(ls) if ls
	@fields
      end

      def format=(str)
	@format = str.to_s.dup
      end

      def set_primary_namespace(pri_name)
	if !pri_name or pri_name.empty? then
	  pri_name = 'UNIQUE'
	end
	if @bdb then
	  nsclass = BDBsolution::PrimaryNameSpace
	else
	  nsclass = FlatOnly::PrimaryNameSpace
	end
	@primary = nsclass.new(@dbname, pri_name)
      end

      def set_secondary_namespaces(sec_names)
	if !sec_names then
	  sec_names = []
	end
	if @bdb then
	  nsclass = BDBsolution::SecondaryNameSpace
	else
	  nsclass = FlatOnly::SecondaryNameSpace
	end
	@secondary = NameSpaces.new(@dbname, nsclass, sec_names)
      end

      def to_s
	a = ""
	a << "index\t#{@index_type}\n"

	unless @bdb then
	  a << "format\t#{@format}\n"
	  @fields.each_with_index do |x, i|
	    a << "#{x.to_s(i)}\n"
	  end
	  a << "primary_namespace\t#{@primary.name}\n"
	  str = "secondary_namespaces"
	  @secondary.names.each do |x|
	    str << "\t#{x}"
	  end
	  str << "\n"
	  a << str
	  @misc.each do |i, x|
	    a << "#{i}\t#{x}\n"
	  end
	end
	a
      end

      def get_flatfile_data(f, pos, length)
	fi = fields[f.to_i]
	if @always_check then
	  raise "flatfile #{fi.filename.inspect} may be modified" unless fi.check
	end
	fi.get(pos.to_i, length.to_i)
      end

      # high level methods
      def search_all_get_unique_id(key)
	s = @secondary.search(key)
	p = @primary.include?(key)
	s.push p if p
	s.sort!
	s.uniq!
	s
      end

      def search_primary(*arg)
	r = []
	arg.each do |x|
	  a = @primary.search(x)
	  a.each { |y| r << get_flatfile_data(*y) }
	end
	r
      end

      def search_all(key)
	s = search_all_get_unique_id(key)
	search_primary(*s)
      end

      def search_primary_get_unique_id(key)
	s = []
	p = @primary.include?(key)
	s.push p if p
	s
      end

      def search_namespaces_get_unique_id(key, *names)
	if names.include?(@primary.name) then
	  n2 = names.dup
	  n2.delete(@primary.name)
	  p = @primary.include?(key)
	else
	  n2 = names
	  p = nil
	end
	s = @secondary.search_names(key, *n2)
	s.push p if p
	s.sort!
	s.uniq!
	s
      end

      def search_namespaces(key, *names)
	s = search_namespaces_get_unique_id(key, *names)
	search_primary(*s)
      end

      def close
	@primary.close
	@secondary.close
	@fields.close
	close_bdbdata
	nil
      end

      def check_consistency
	@fields.check_all
      end
    end #class DataBank

  end #class FlatFileIndex
end #module Bio


