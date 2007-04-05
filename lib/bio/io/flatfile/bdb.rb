# 
# bio/io/flatfile/bdb.rb - OBDA flatfile index by Berkley DB 
# 
# Copyright:: Copyright (C) 2002 GOTO Naohisa <ng@bioruby.org> 
# License::   The Ruby License
# 
#  $Id: bdb.rb,v 1.10 2007/04/05 23:35:41 trevor Exp $ 
# 
 
begin 
  require 'bdb' 
rescue LoadError,NotImplementedError
end 

require 'bio/io/flatfile/index'
require 'bio/io/flatfile/indexer'

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

      def flag_append
        'r+'
      end
      module_function :flag_append
    end #module BDBdefault

    class BDBwrapper
      def initialize(name, filename, *arg)
        @dbname = name
        @file = nil
        @filename = filename
        #self.open(*arg)
      end

      def filename
        File.join(@dbname, @filename)
      end

      def open(flag = BDBdefault.flag_read,
               permission = BDBdefault.permission)
        unless @file then
          DEBUG.print "BDBwrapper: open #{filename}\n"
          @file = BDB::Btree.open(filename, nil, flag, permission)
        end
        true
      end

      def close
        if @file
          DEBUG.print "BDBwrapper: close #{filename}\n"
          @file.close
          @file = nil
        end
        nil
      end

      def [](arg)
        #self.open
        if @file then
          @file[arg]
        else
          nil
        end
      end

      def []=(key, val)
        #self.open
        @file[key.to_s] = val.to_s
      end

      def writeback_array(prefix, array, *arg)
        self.close
        self.open(*arg)
        array.each_with_index do |val, key|
          @file["#{prefix}#{key}"] = val.to_s
        end
      end

      def keys
        if @file then
          @file.keys
        else
          []
        end
      end
    end #class BDBwrapper

    module BDB_1
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
        alias size records

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
          #DEBUG.print "add: key=#{key.inspect}, val=#{val.inspect}\n"
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
          #DEBUG.print "add_exclusive: key=#{key.inspect}, val=#{val.inspect}\n"
          val
        end

        def add_overwrite(key, val)
          open
          val = val.to_a.join("\t")
          s = @bdb[key]
          if s then
            DEBUG.print "Warining: overwrote unique id #{key.inspect}\n"
          end
          @bdb[key] = val
          #DEBUG.print "add_overwrite: key=#{key.inspect}, val=#{val.inspect}\n"
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
          #DEBUG.print "add_nr: key=#{key.inspect}, val=#{str.inspect}\n"
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
    end #module BDB_1

  end #class FlatFileIndex
end #module Bio

=begin

  * Classes/modules in this file are internal use only.

=end
