# 
# = bio/io/flatfile/index.rb - OBDA flatfile index 
# 
# Copyright:: Copyright (C) 2002
#             GOTO Naohisa <ng@bioruby.org> 
# License:: The Ruby License
#
#  $Id: index.rb,v 1.19 2007/04/05 23:35:41 trevor Exp $ 
#
# = About Bio::FlatFileIndex
#
# Please refer documents of following classes.
# Classes/modules marked '#' are internal use only.
#
# == Classes/modules in index.rb
# * class  Bio::FlatFileIndex
# * class  Bio::FlatFileIndex::Results
# * module Bio::FlatFileIndex::DEBUG
# * #module Bio::FlatFileIndex::Template
# * #class  Bio::FlatFileIndex::Template::NameSpace
# * #class  Bio::FlatFileIndex::FileID
# * #class  Bio::FlatFileIndex::FileIDs
# * #module Bio::FlatFileIndex::Flat_1
# * #class  Bio::FlatFileIndex::Flat_1::Record
# * #class  Bio::FlatFileIndex::Flat_1::FlatMappingFile
# * #class  Bio::FlatFileIndex::Flat_1::PrimaryNameSpace
# * #class  Bio::FlatFileIndex::Flat_1::SecondaryNameSpace
# * #class  Bio::FlatFileIndex::NameSpaces
# * #class  Bio::FlatFileIndex::DataBank
#
# == Classes/modules in indexer.rb
# * module Bio::FlatFileIndex::Indexer
# * #class  Bio::FlatFileIndex::Indexer::NameSpace
# * #class  Bio::FlatFileIndex::Indexer::NameSpaces
# * #module Bio::FlatFileIndex::Indexer::Parser
# * #class  Bio::FlatFileIndex::Indexer::Parser::TemplateParser
# * #class  Bio::FlatFileIndex::Indexer::Parser::GenBankParser
# * #class  Bio::FlatFileIndex::Indexer::Parser::GenPeptParser
# * #class  Bio::FlatFileIndex::Indexer::Parser::EMBLParser
# * #class  Bio::FlatFileIndex::Indexer::Parser::SPTRParser
# * #class  Bio::FlatFileIndex::Indexer::Parser::FastaFormatParser
# * #class  Bio::FlatFileIndex::Indexer::Parser::MaXMLSequenceParser
# * #class  Bio::FlatFileIndex::Indexer::Parser::MaXMLClusterParser
# * #class  Bio::FlatFileIndex::Indexer::Parser::BlastDefaultParser
# * #class  Bio::FlatFileIndex::Indexer::Parser::PDBChemicalComponentParser
#
# == Classes/modules in bdb.rb
# * #module Bio::FlatFileIndex::BDBDefault
# * #class  Bio::FlatFileIndex::BDBWrapper
# * #module Bio::FlatFileIndex::BDB_1
# * #class  Bio::FlatFileIndex::BDB_1::BDBMappingFile
# * #class  Bio::FlatFileIndex::BDB_1::PrimaryNameSpace
# * #class  Bio::FlatFileIndex::BDB_1::SecondaryNameSpace
#
# = References
# * ((<URL:http://obda.open-bio.org/>))
# * ((<URL:http://cvs.open-bio.org/cgi-bin/viewcvs/viewcvs.cgi/obda-specs/?cvsroot=obf-common>))
#

require 'bio/io/flatfile/indexer'

module Bio


  # Bio::FlatFileIndex is a class for OBDA flatfile index.
  class FlatFileIndex

    autoload :Indexer,    'bio/io/flatfile/indexer'
    autoload :BDBdefault, 'bio/io/flatfile/bdb'
    autoload :BDBwrapper, 'bio/io/flatfile/bdb'
    autoload :BDB_1,      'bio/io/flatfile/bdb'

    # magic string for flat/1 index
    MAGIC_FLAT = 'flat/1'

    # magic string for BerkeleyDB/1 index
    MAGIC_BDB  = 'BerkeleyDB/1'

    #########################################################

    # Opens existing databank. Databank is a directory which contains
    # indexed files and configuration files. The type of the databank
    # (flat or BerkeleyDB) are determined automatically.
    #
    # If block is given, the databank object is passed to the block.
    # The databank will be automatically closed when the block terminates.
    #
    def self.open(name)
      if block_given? then
        begin
          i = self.new(name)
          r = yield i
        ensure
          if i then
            begin
              i.close
            rescue IOError
            end
          end
        end
      else
        r = self.new(name)
      end
      r
    end

    # Opens existing databank. Databank is a directory which contains
    # indexed files and configuration files. The type of the databank
    # (flat or BerkeleyDB) are determined automatically.
    #
    # Unlike +FlatFileIndex.open+, block is not allowed.
    #
    def initialize(name)
      @db = DataBank.open(name)
    end

    # common interface defined in registry.rb
    # Searching databank and returns entry (or entries) as a string.
    # Multiple entries (contatinated to one string) may be returned.
    # Returns empty string if not found.
    #
    def get_by_id(key)
      search(key).to_s
    end

    #--
    # original methods
    #++

    # Closes the databank.
    # Returns nil.
    def close
      check_closed?
      @db.close
      @db = nil
    end

    # Returns true if already closed. Otherwise, returns false.
    def closed?
      if @db then
        false
      else
        true
      end
    end

    # Set default namespaces.
    # <code>default_namespaces = nil</code>
    # means all namespaces in the databank.
    #
    # <code>default_namespaces= [ str1, str2, ... ]</code>
    # means set default namespeces to str1, str2, ...
    #
    # Default namespaces specified in this method only affect 
    # #get_by_id, #search, and #include? methods.
    #
    # Default of default namespaces is nil (that is, all namespaces
    # are search destinations by default).
    #
    def default_namespaces=(names)
      if names then
        @names = []
        names.each { |x| @names.push(x.dup) }
      else
        @names = nil
      end
    end

    # Returns default namespaces.
    # Returns an array of strings or nil.
    # nil means all namespaces.
    def default_namespaces
      @names
    end

    # Searching databank and returns a Bio::FlatFileIndex::Results object.
    def search(key)
      check_closed?
      if @names then
        @db.search_namespaces(key, *@names)
      else
        @db.search_all(key)
      end
    end

    # Searching only specified namespeces.
    # Returns a Bio::FlatFileIndex::Results object.
    #
    def search_namespaces(key, *names)
      check_closed?
      @db.search_namespaces(key, *names)
    end

    # Searching only primary namespece.
    # Returns a Bio::FlatFileIndex::Results object.
    #
    def search_primary(key)
      check_closed?
      @db.search_primary(key)
    end

    # Searching databank.
    # If some entries are found, returns an array of
    # unique IDs (primary identifiers).
    # If not found anything, returns nil.
    #
    # This method is useful when search result is very large and
    # #search method is very slow.
    #
    def include?(key)
      check_closed?
      if @names then
        r = @db.search_namespaces_get_unique_id(key, *@names)
      else
        r = @db.search_all_get_unique_id(key)
      end
      if r.empty? then
        nil
      else
        r
      end
    end

    # Same as #include?, but serching only specified namespaces.
    #
    def include_in_namespaces?(key, *names)
      check_closed?
      r = @db.search_namespaces_get_unique_id(key, *names)
      if r.empty? then
        nil
      else
        r
      end
    end

    # Same as #include?, but serching only primary namespace.
    #
    def include_in_primary?(key)
      check_closed?
      r = @db.search_primary_get_unique_id(key)
      if r.empty? then
        nil
      else
        r
      end
    end

    # Returns names of namespaces defined in the databank.
    # (example: [ 'LOCUS', 'ACCESSION', 'VERSION' ] )
    #
    def namespaces
      check_closed?
      r = secondary_namespaces
      r.unshift primary_namespace
      r
    end

    # Returns name of primary namespace as a string.
    def primary_namespace
      check_closed?
      @db.primary.name
    end

    # Returns names of secondary namespaces as an array of strings.
    def secondary_namespaces
      check_closed?
      @db.secondary.names
    end

    # Check consistency between the databank(index) and original flat files.
    #
    # If the original flat files are changed after creating
    # the databank, raises RuntimeError.
    #
    # Note that this check only compares file sizes as
    # described in the OBDA specification.
    #
    def check_consistency
      check_closed?
      @db.check_consistency
    end

    # If true is given, consistency checks will be performed every time
    # accessing flatfiles. If nil/false, no checks are performed.
    #
    # By default, always_check_consistency is true.
    #
    def always_check_consistency=(bool)
      @db.always_check=(bool)
    end

    # If true, consistency checks will be performed every time
    # accessing flatfiles. If nil/false, no checks are performed.
    #
    # By default, always_check_consistency is true.
    #
    def always_check_consistency(bool)
      @db.always_check
    end

    #--
    # private methods
    #++
    
    # If the databank is closed, raises IOError.
    def check_closed?
      @db or raise IOError, 'closed databank'
    end
    private :check_closed?

    #--
    #########################################################
    #++

    # <code>Results</code> stores search results created by
    # <code>Bio::FlatFileIndex</code> methods.
    #
    # Currently, this class inherits Hash, but internal
    # structure of this class may be changed anytime.
    # Only using methods described below are strongly recomended.
    #
    class Results < Hash

      # Add search results.
      # "a + b" means "a OR b".
      # * Example
      #    # I want to search 'ADH_IRON_1' OR 'ADH_IRON_2'
      #    db = Bio::FlatFIleIndex.new(location)
      #    a1 = db.search('ADH_IRON_1')
      #    a2 = db.search('ADH_IRON_2')
      #    # a1 and a2 are Bio::FlatFileIndex::Results objects.
      #    print a1 + a2
      #
      def +(a)
        raise 'argument must be Results class' unless a.is_a?(self.class)
        res = self.dup
        res.update(a)
        res
      end

      # Returns set intersection of results.
      # "a * b" means "a AND b".
      # * Example
      #    # I want to search 'HIS_KIN' AND 'human'
      #    db = Bio::FlatFIleIndex.new(location)
      #    hk = db.search('HIS_KIN')
      #    hu = db.search('human')
      #    # hk and hu are Bio::FlatFileIndex::Results objects.
      #    print hk * hu
      #
      def *(a)
        raise 'argument must be Results class' unless a.is_a?(self.class)
        res = self.class.new
        a.each_key { |x| res.store(x, a[x]) if self[x] }
        res
      end

      # Returns a string. (concatinated if multiple results exists).
      # Same as <code>to_a.join('')</code>.
      #
      def to_s
        self.values.join
      end

      #--
      #alias each_orig each
      #++

      # alias for each_value.
      alias each each_value

      # Iterates over each result (string).
      # Same as to_a.each.
      def each(&x) #:yields: str
        each_value(&x)
      end if false #dummy for RDoc

      #--
      #alias to_a_orig to_a
      #++

      # alias for to_a.
      alias to_a values

      # Returns an array of strings.
      # If no search results are exist, returns an empty array.
      #
      def to_a; values; end if false #dummy for RDoc

      # Returns number of results.
      # Same as to_a.size.
      def size; end if false #dummy for RDoc

    end #class Results

    #########################################################

    # Module for output debug messages.
    # Default setting: If $DEBUG or $VERBOSE is true, output debug
    # messages to $stderr; Otherwise, don't output messages.
    #
    module DEBUG
      @@out = $stderr
      @@flag = nil

      # Set debug messages output destination.
      # If true is given, outputs to $stderr.
      # If nil is given, outputs nothing.
      # This method affects ALL of FlatFileIndex related objects/methods.
      #
      def self.out=(io)
        if io then
          @@out = io
          @@out = $stderr if io == true
          @@flag = true
        else
          @@out = nil
          @@flag = nil
        end
        @@out
      end

      # get current debug messeages output destination
      def self.out
        @@out
      end

      # prints debug messages
      def self.print(*arg)
        @@flag = true if $DEBUG or $VERBOSE
        @@out.print(*arg) if @@out and @@flag
      end
    end #module DEBUG

    #########################################################

    # Templates
    #
    # Internal use only.
    module Template

      # templates of namespace
      #
      # Internal use only.
      class NameSpace
        def filename
          # should be redifined in child class
          raise NotImplementedError, "should be redefined in child class"
        end

        def mapping(filename)
          # should be redifined in child class
          raise NotImplementedError, "should be redefined in child class"
          #Flat_1::FlatMappingFile.new(filename)
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

    # FileID class.
    #
    # Internal use only.
    class FileID
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
        begin
          fsize = File.size(@filename)
          r = ( fsize == @filesize)
        rescue Errno::ENOENT
          fsize = -1
          r = nil
        end
        DEBUG.print "FileID: File.size(#{@filename.inspect}) = ",
          fsize, (r ? ' == ' : ' != ') , @filesize,
          (r ? '' : ' bad!'), "\n"
        r
      end

      def recalc
        @filesize = File.size(@filename)
      end

      def to_s(i = nil)
        if i then
          str = "fileid_#{i}\t"
        else
          str = ''
        end
        str << "#{@filename}\t#{@filesize}"
        str
      end

      def open
        unless @io then
          DEBUG.print "FileID: open #{@filename}\n"
          @io = File.open(@filename, 'rb')
          true
        else
          nil
        end
      end

      def close
        if @io then
          DEBUG.print "FileID: close #{@filename}\n"
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
    end #class FileID

    # FileIDs class.
    #
    # Internal use only.
    class FileIDs < Array
      def initialize(prefix, hash)
        @hash = hash
        @prefix = prefix
      end

      def [](n)
        r = super(n)
        if r then
          r
        else
          data = @hash["#{@prefix}#{n}"]
          if data then
            self[n] = data
          end
          super(n)
        end
      end

      def []=(n, data)
        if data.is_a?(FileID) then
          super(n, data)
        elsif data then
          super(n, FileID.new_from_string(data))
        else
          # data is nil
          super(n, nil)
        end
        self[n]
      end

      def add(*arg)
        arg.each do |filename|
          self << FileID.new(filename)
        end
      end

      def cache_all
        a = @hash.keys.collect do |k|
          if k =~ /\A#{Regexp.escape(@prefix)}(\d+)/ then
            $1.to_i
          else
            nil
          end
        end
        a.compact!
        a.each do |i|
          self[i]
        end
        a
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

      def keys
        self.cache_all
        a = []
        (0...self.size).each do |i|
          a << i if self[i]
        end
        a
      end

      def filenames
        self.cache_all
        a = []
        self.each do |x|
          a << x.filename
        end
        a
      end

      def check_all
        self.cache_all
        r = true
        self.each do |x|
          r = x.check
          break unless r
        end
        r
      end
      alias check check_all

      def close_all
        self.each do |x|
          x.close
        end
        nil
      end
      alias close close_all

      def recalc_all
        self.cache_all
        self.each do |x|
          x.recalc
        end
        true
      end
      alias recalc recalc_all

    end #class FileIDs

    # module for flat/1 databank
    #
    # Internal use only.
    module Flat_1

      # Record class.
      #
      # Internal use only.
      class Record
        def initialize(str, size = nil)
          a = str.split("\t")
          a.each { |x| x.to_s.gsub!(/[\000 ]+\z/, '') }
          @key = a.shift.to_s
          @val = a
          @size = (size or str.length)
          #DEBUG.print "key=#{@key.inspect},val=#{@val.inspect},size=#{@size}\n"
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

        def ==(x)
          self.to_s == x.to_s
        end
      end #class Record

      # FlatMappingFile class.
      #
      # Internal use only.
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
          #DEBUG.print "get_record(#{i})=#{str.inspect}\n"
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
        alias size records

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

        # export/import/edit data
        def each
          n = records
          seek(0)
          (0...n).each do |i|
            yield Record.new(get_record(i))
          end
          self
        end

        def export_tsv(stream)
          self.each do |x|
            stream << "#{x.to_s}\n"
          end
          stream
        end

        def init_with_sorted_tsv_file(filename, flag_primary = false)
          rec_size = 1
          f = File.open(filename)
          f.each do |y|
            rec_size = y.chomp.length if rec_size < y.chomp.length
          end
          self.init(rec_size)

          prev = nil
          f.rewind
          if flag_primary then
            f.each do |y|
              x = Record.new(y.chomp, rec_size)
              if prev then
                if x.key == prev.key
                  DEBUG.print "Warining: overwrote unique id #{x.key.inspect}\n"
                else
                  self.add_record(prev.to_s)
                end
              end
              prev = x
            end
            self.add_record(prev.to_s) if prev
          else
            f.each do |y|
              x = Record.new(y.chomp, rec_size)
              self.add_record(x.to_s) if x != prev
              prev = x
            end
          end
          f.close
          self
        end

        def self.external_sort_proc(sort_program = '/usr/bin/sort')
          Proc.new do |out, in1, *files|
            system(sort_program, '-o', out, in1, *files)
          end
        end

        def self.external_merge_sort_proc(sort_program = '/usr/bin/sort')
          Proc.new do |out, in1, *files|
            # (in1 may be sorted)
            tf_all = []
            tfn_all = []
            files.each do |fn|
              tf = Tempfile.open('sort')
              tf.close(false)
              system(sort_program, '-o', tf.path, fn)
              tf_all << tf
              tfn_all << tf.path
            end
            system(sort_program, '-m', '-o', out, in1, *tfn_all)
            tf_all.each do |tf|
              tf.close(true)
            end
          end
        end

        def self.external_merge_proc(sort_program = '/usr/bin/sort')
          Proc.new do |out, in1, *files|
            # files (and in1) must be sorted
            system(sort_program, '-m', '-o', out, in1, *files)
          end
        end

        def self.internal_sort_proc
          Proc.new do |out, in1, *files|
            a = IO.readlines(in1)
            files.each do |fn|
              IO.foreach(fn) do |x|
                a << x
              end
            end
            a.sort!
            of = File.open(out, 'w')
            a.each { |x| of << x }
            of.close
          end
        end

        def import_tsv_files(flag_primary, mode, sort_proc, *files)
          require 'tempfile'

          tmpfile1 = Tempfile.open('flat')
          self.export_tsv(tmpfile1) unless mode == :new
          tmpfile1.close(false)

          tmpfile0 = Tempfile.open('sorted')
          tmpfile0.close(false)

          sort_proc.call(tmpfile0.path, tmpfile1.path, *files)

          tmpmap = self.class.new(self.filename + ".#{$$}.tmp~", 'wb+')
          tmpmap.init_with_sorted_tsv_file(tmpfile0.path, flag_primary)
          tmpmap.close
          self.close

          begin
            File.rename(self.filename, self.filename + ".#{$$}.bak~")
          rescue Errno::ENOENT
          end
          File.rename(tmpmap.filename, self.filename)
          begin
            File.delete(self.filename + ".#{$$}.bak~")
          rescue Errno::ENOENT
          end

          tmpfile0.close(true)
          tmpfile1.close(true)
          self
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

      # primary name space
      #
      # Internal use only.
      class PrimaryNameSpace < Template::NameSpace
        def mapping(filename)
          FlatMappingFile.new(filename)
        end
        def filename
          File.join(dbname, "key_#{name}.key")
        end
      end #class PrimaryNameSpace

      # secondary name space
      #
      # Internal use only.
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
    end #module Flat_1

    # namespaces
    #
    # Internal use only.
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
      alias close close_all

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
          raise "undefined namespace #{x.inspect}" unless ns
          r.concat ns.search(key)
        end
        r
      end

      def to_s
        names.join("\t")
      end
    end #class NameSpaces

    # databank
    #
    # Internal use only.
    class DataBank
      def self.file2hash(fileobj)
        hash = {}
        fileobj.each do |line|
          line.chomp!
          a = line.split("\t", 2)
          hash[a[0]] = a[1]
        end
        hash
      end
      private_class_method :file2hash

      def self.filename(dbname)
        File.join(dbname, 'config.dat')
      end

      def self.read(name, mode = 'rb', *bdbarg)
        f = File.open(filename(name), mode)
        hash = file2hash(f)
        f.close
        db = self.new(name, nil, hash)
        db.bdb_open(*bdbarg)
        db
      end

      def self.open(*arg)
        self.read(*arg)
      end

      def initialize(name, idx_type = nil, hash = {})
        @dbname = name.dup
        @dbname.freeze
        @bdb = nil

        @always_check = true
        self.index_type = (hash['index'] or idx_type)

        if @bdb then
          @config = BDBwrapper.new(@dbname, 'config')
          @bdb_fileids = BDBwrapper.new(@dbname, 'fileids')
          @nsclass_pri = BDB_1::PrimaryNameSpace
          @nsclass_sec = BDB_1::SecondaryNameSpace
        else
          @config = hash
          @nsclass_pri = Flat_1::PrimaryNameSpace
          @nsclass_sec = Flat_1::SecondaryNameSpace
        end
        true
      end

      attr_reader :dbname, :index_type

      def index_type=(str)
        case str
        when MAGIC_BDB
          @index_type = MAGIC_BDB
          @bdb = true
          unless defined?(BDB)
            raise RuntimeError, "Berkeley DB support not found"
          end
        when MAGIC_FLAT, '', nil, false
          @index_type = MAGIC_FLAT
          @bdb = false
        else
          raise 'unknown or unsupported index type'
        end
      end

      def to_s
        a = ""
        a << "index\t#{@index_type}\n"

        unless @bdb then
          a << "format\t#{@format}\n"
          @fileids.each_with_index do |x, i|
            a << "#{x.to_s(i)}\n"
          end
          a << "primary_namespace\t#{@primary.name}\n"
          a << "secondary_namespaces\t"
          a << @secondary.names.join("\t")
          a << "\n"
        end
        a
      end

      def bdb_open(*bdbarg)
        if @bdb then
          @config.close
          @config.open(*bdbarg)
          @bdb_fileids.close
          @bdb_fileids.open(*bdbarg)
          true
        else
          nil
        end
      end

      def write(mode = 'wb', *bdbarg)
        unless FileTest.directory?(@dbname) then
          Dir.mkdir(@dbname)
        end
        f = File.open(self.class.filename(@dbname), mode)
        f.write self.to_s
        f.close

        if @bdb then
          bdb_open(*bdbarg)
          @config['format'] = format
          @config['primary_namespace'] = @primary.name
          @config['secondary_namespaces'] = @secondary.names.join("\t")
          @bdb_fileids.writeback_array('', fileids, *bdbarg)
        end
        true
      end

      def close
        DEBUG.print "DataBank: close #{@dbname}\n"
        primary.close
        secondary.close
        fileids.close
        if @bdb then
          @config.close
          @bdb_fileids.close
        end
        nil
      end

      ##parameters
      def primary
        unless @primary then
          self.primary = @config['primary_namespace']
        end
        @primary
      end

      def primary=(pri_name)
        if !pri_name or pri_name.empty? then
          pri_name = 'UNIQUE'
        end
        @primary = @nsclass_pri.new(@dbname, pri_name)
        @primary
      end

      def secondary
        unless @secondary then
          self.secondary = @config['secondary_namespaces']
        end
        @secondary
      end

      def secondary=(sec_names)
        if !sec_names then
          sec_names = []
        end
        @secondary = NameSpaces.new(@dbname, @nsclass_sec, sec_names)
        @secondary
      end

      def format=(str)
        @format = str.to_s.dup
      end

      def format
        unless @format then
          self.format = @config['format']
        end
        @format
      end

      def fileids
        unless @fileids then
          init_fileids
        end
        @fileids
      end

      def init_fileids
        if @bdb then
          @fileids = FileIDs.new('', @bdb_fileids)
        else
          @fileids = FileIDs.new('fileid_', @config)
        end
        @fileids
      end

      # high level methods
      def always_check=(bool)
        if bool then
          @always_check = true
        else
          @always_check = false
        end
      end
      attr_reader :always_check

      def get_flatfile_data(f, pos, length)
        fi = fileids[f.to_i]
        if @always_check then
          raise "flatfile #{fi.filename.inspect} may be modified" unless fi.check
        end
        fi.get(pos.to_i, length.to_i)
      end

      def search_all_get_unique_id(key)
        s = secondary.search(key)
        p = primary.include?(key)
        s.push p if p
        s.sort!
        s.uniq!
        s
      end

      def search_primary(*arg)
        r = Results.new
        arg.each do |x|
          a = primary.search(x)
          # a is empty or a.size==1 because primary key must be unique
          r.store(x, get_flatfile_data(*a[0])) unless a.empty?
        end
        r
      end

      def search_all(key)
        s = search_all_get_unique_id(key)
        search_primary(*s)
      end

      def search_primary_get_unique_id(key)
        s = []
        p = primary.include?(key)
        s.push p if p
        s
      end

      def search_namespaces_get_unique_id(key, *names)
        if names.include?(primary.name) then
          n2 = names.dup
          n2.delete(primary.name)
          p = primary.include?(key)
        else
          n2 = names
          p = nil
        end
        s = secondary.search_names(key, *n2)
        s.push p if p
        s.sort!
        s.uniq!
        s
      end

      def search_namespaces(key, *names)
        s = search_namespaces_get_unique_id(key, *names)
        search_primary(*s)
      end

      def check_consistency
        fileids.check_all
      end
    end #class DataBank

  end #class FlatFileIndex
end #module Bio

