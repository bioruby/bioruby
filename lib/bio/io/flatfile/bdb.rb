# 
# bio/io/flatfile/bdb.rb - flatfile index by Berkley DB 
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
#  $Id: bdb.rb,v 1.1 2002/08/19 11:43:37 k Exp $ 
# 
 
begin 
  require 'bdb' 
rescue LoadError 
end 

module Bio
  class FlatFileIndex

    module BDBdefault
      def permission
	(0666 & (0777 ^ File.umask))
      end
      module_function :permission

      def flag_read
	BDB::RDONLY
      end
      module_function :flag_read

      def flag_write
	(BDB::CREATE | BDB::TRUNCATE)
      end
      module_function :flag_write
    end #module BDBdefault

    class BDBDataBank
      def initialize(name, *arg)
	@dbname = name
	self.open(*arg)
      end
      attr_reader :file

      def filename
	File.join(@dbname, 'config')
      end

      def open(flag = BDBdefault.flag_read,
	       permission = BDBdefault.permission)
	unless @file then
	  @file = BDB::Btree.open(filename, nil, flag, permission)
	end
	true
      end

      def close
	@file.close
	@file = nil
	nil
      end

      def primary
	self.open
	@file['primary_namespace']
      end

      def secondary
	self.open
	@file['secondary_namespaces']
      end

      def writeback_primary(pri)
	@file['primary_namespace'] = pri.name
      end
      def writeback_secondary(sec_names)
	@file['secondary_namespaces'] = sec_names.to_s
      end
    end #class BDBDataBank

    module BDBsolution

      class BDBMappingFile
	def self.open(*arg)
	  self.new(*arg)
	end

	def initialize(filename, flag = BDBdefault.flag_read,
		       permission = BDBdefault.permission)
	  @filename = filename
	  @flag = flag
	  @permission = permission
	  #@bdb = BDB::Btree.open(@filename, nil, @flag, @permission)
	end
	attr_reader :filename
	attr_accessor :flag, :permission

	def open
	  unless @bdb then
	    DEBUG.print "BDBMappingFile: open #{@filename}\n"
	    @bdb = BDB::Btree.open(@filename, nil, @flag, @permission)
	    true
	  else
	    nil
	  end
	end

	def close
	  if @bdb then
	    DEBUG.print "BDBMappingFile: close #{@filename}\n"
	    @bdb.close
            @bdb = nil
	  end
	  nil
	end

	def records
	  @bdb.size
	end
	alias :size :records

	# methods for writing
	def add(key, val)
	  open
	  val = val.to_a.join("\t")
	  s = @bdb[key]
	  if s then
	    s << "\t"
	    s << val
	    val = s
	  end
	  @bdb[key] = val
	  DEBUG.print "add: key=#{key.inspect}, val=#{val.inspect}\n"
	  val
	end

	def add_exclusive(key, val)
	  open
	  val = val.to_a.join("\t")
	  s = @bdb[key]
	  if s then
	    raise RuntimeError, "keys must be unique, but key #{key.inspect} already exists"
	  end
	  @bdb[key] = val
	  DEBUG.print "add_exclusive: key=#{key.inspect}, val=#{val.inspect}\n"
	  val
	end

	def add_nr(key, val)
	  open
	  s = @bdb[key]
	  if s then
	    a = s.split("\t")
	  else
	    a = []
	  end
	  a.concat val.to_a
	  a.sort!
	  a.uniq!
	  str = a.join("\t")
	  @bdb[key] = str
	  DEBUG.print "add_nr: key=#{key.inspect}, val=#{str.inspect}\n"
	  str
	end
	    
	# methods for searching
	def search(key)
	  open
	  s = @bdb[key]
	  if s then
	    a = s.split("\t")
	    a
	  else
	    []
	  end
	end
      end #class BDBMappingFile

      class Fields
	def initialize(bdbfile)
	  @file = bdbfile
	end

	def [](n)
	  x = @file[n.to_s]
	  if x then
	    Field.new_from_string(x)
	  else
	    nil
	  end
	end

	def []=(n, data)
	  if data.is_a?(Field) then
	    @file[n.to_s] = data.to_s
	  elsif data then
	    self[n] = Field.new_from_string(data)
	  else #data is nil
	    #@file[n.to_s] = data
	    @file.delete(n.to_s)
	  end
	  self[n.to_s]
	end

	def add(*arg)
	  k = self.keys
	  if k.empty? then
	    i = 0
	  else
	    i = k.max + 1
	  end
	  arg.each do |x|
	    self[i] = Field.new_from_string(x)
	    i += 1
	  end
	end

	def each
	  @file.each do |i, x|
	    yield(Field.new_from_string(x)) if x and /\A\d+\z/ =~ i 
	  end
	  self
	end

	def each_with_index
	  @file.each do |i, x|
	    yield(Field.new_from_string(x), i.to_i) if x and /\A\d+\z/ =~ i
	  end
	  self
	end

	def keys
	  r = []
	  self.each_with_index do |x, i|
	    r << i
	  end
	  r
	end

	def each_key
	  self.each_with_index do |x, i|
	    yield i
	  end
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
	  self.each_key do |x|
	    if x and /\A\d+\z/ =~ i then
	      y = self[x]
	      y.recalc
	      self[x] = y.to_s
	    end
	  end
	  true
	end
	alias :recalc :recalc_all

	def set_list(ary)
	  ary.each do |x|
	    self[x[0]] = x[1]
	  end
	end

	def show_list
	  r = []
	  self.each_with_index do |x, i|
	    r << [ i.to_i, x ]
	  end
	  r
	end
      end #class Fields

      class PrimaryNameSpace < Template::NameSpace
	def mapping(filename)
	  BDBMappingFile.new(filename)
	end
	def filename
	  File.join(dbname, "key_#{name}")
	end
	def search(key)
	  r = super(key)
	  unless r.empty? then
	    [ r ]
	  else
	    r
	  end
	end
      end #class PrimaryNameSpace

      class SecondaryNameSpace < Template::NameSpace
	def mapping(filename)
	  BDBMappingFile.new(filename)
	end
	def filename
	  File.join(dbname, "id_#{name}")
	end #class SecondaryNameSpaces
      
	def search(key)
	  r = super(key)
	  file.close
	  r
	end
      end #class SecondaryNameSpace
    end #module BDBsolution

  end #class FlatFileIndex
end #module Bio

