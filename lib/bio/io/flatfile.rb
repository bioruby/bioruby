#
# = bio/io/flatfile.rb - flatfile access wrapper class
#
#   Copyright (C) 2001-2006 Naohisa Goto <ng@bioruby.org>
#
# License:: The Ruby License
#
#  $Id: flatfile.rb,v 1.61 2007/11/15 07:07:16 k Exp $
#
#
# Bio::FlatFile is a helper and wrapper class to read a biological data file.
# It acts like a IO object.
# It can automatically detect data format, and users do not need to tell
# the class what the data is.
#
require 'tsort'

module Bio

  # Bio::FlatFile is a helper and wrapper class to read a biological data file.
  # It acts like a IO object.
  # It can automatically detect data format, and users do not need to tell
  # the class what the data is.
  class FlatFile

    include Enumerable

    # Wrapper for a IO (or IO-like) object.
    # It can input with a buffer.
    class BufferedInputStream
      # Creates a new input stream wrapper
      def initialize(io, path)
        @io = io
        @path = path
        # initialize prefetch buffer
        @buffer = ''
      end

      # Creates a new input stream wrapper from the given IO object.
      def self.for_io(io)
        begin
          path = io.path
        rescue NameError
          path = nil
        end
        self.new(io, path)
      end

      # Creates a new input stream wrapper to open file _filename_
      # by using File.open.
      # *arg is passed to File.open.
      #
      # Like File.open, a block can be accepted.
      def self.open_file(filename, *arg)
        if block_given? then
          File.open(filename, *arg) do |fobj|
            yield self.new(fobj, filename)
          end
        else
          fobj = File.open(filename, *arg)
          self.new(fobj, filename)
        end
      end

      # Creates a new input stream wrapper from URI specified as _uri_.
      # by using OpenURI.open_uri or URI#open.
      # _uri_ must be a String or URI object.
      # *arg is passed to OpenURI.open_uri or URI#open.
      #
      # Like OpenURI.open_uri, it can accept a block.
      def self.open_uri(uri, *arg)
        if uri.kind_of?(URI)
          if block_given?
            uri.open(*arg) do |fobj|
              yield self.new(fobj, uri.to_s)
            end
          else
            fobj = uri.open(*arg)
            self.new(fobj, uri.to_s)
          end
        else
          if block_given?
            OpenURI.open_uri(uri, *arg) do |fobj|
              yield self.new(fobj, uri)
            end
          else
            fobj = OpenURI.open_uri(uri, *arg)
            self.new(fobj, uri)
          end
        end
      end

      # Pathname, filename or URI to open the object.
      # Like File#path, returned value isn't normalized.
      attr_reader :path

      # Converts to IO object if possible
      def to_io
        @io.to_io
      end

      # Closes the IO object if possible
      def close
        @io.close
      end

      # Rewinds the IO object if possible
      # Internal buffer in this wrapper is cleared.
      def rewind
        r = @io.rewind
        @buffer = ''
        r
      end

      # Returns current file position
      def pos
        @io.pos - @buffer.size
      end

      # Sets current file position if possible
      # Internal buffer in this wrapper is cleared.
      def pos=(p)
        r = (@io.pos = p)
        @buffer = ''
        r
      end

      # Returns true if end-of-file. Otherwise, returns false.
      #
      # Note that it returns false if internal buffer is this wrapper
      # is not empty,
      def eof?
        if @buffer.size > 0
          false
        else
          @io.eof?
        end
      end

      # Same as IO#gets.
      def gets(io_rs = $/)
        if @buffer.size > 0
          if io_rs == nil then
            r = @buffer + @io.gets(nil).to_s
            @buffer = ''
          else
            if io_rs == '' then
              sp_rs = /\n\n/n
              sp_rs_orig = "\n\n"
            else
              sp_rs = Regexp.new(Regexp.escape(io_rs, 'n'), 0, 'n')
              sp_rs_orig = io_rs
            end
            a = @buffer.split(sp_rs, 2)
            if a.size > 1 then
              r = a[0] + sp_rs_orig
              @buffer = a[1]
            else
              @buffer << @io.gets(io_rs).to_s
              a = @buffer.split(sp_rs, 2)
              if a.size > 1 then
                r = a[0] + sp_rs_orig
                @buffer = a[1].to_s
              else
                r = @buffer
                @buffer = ''
              end
            end
          end
          r
        else
          @io.gets(io_rs)
        end
      end

      # Pushes back given str to the internal buffer.
      # Returns nil.
      # str must be read previously with the wrapper object.
      #
      # Note that in current implementation, the str can be everything,
      # but please don't depend on it.
      #
      def ungets(str)
        @buffer = str + @buffer
        nil
      end

      # Same as IO#getc.
      def getc
        if @buffer.size > 0 then
          r = @buffer[0]
          @buffer = @buffer[1..-1]
        else
          r = @io.getc
        end
        r
      end
      
      # Pushes back one character into the internal buffer.
      # Unlike IO#getc, it can be called more than one time.
      def ungetc(c)
        @buffer = sprintf("%c", c) + @buffer
        nil
      end

      # Gets current prefetch buffer
      def prefetch_buffer
        @buffer
      end

      # It does @io.gets,  and addes returned string
      # to the internal buffer, and returns the string.
      def prefetch_gets(*arg)
        r = @io.gets(*arg)
        @buffer << r if r
        r
      end
      
      # It does @io.readpartial, and addes returned string
      # to the internal buffer, and returns the string.
      def prefetch_readpartial(*arg)
        r = @io.readpartial(*arg)
        @buffer << r if r
        r
      end

      # Skips space characters in the stream.
      # returns nil.
      def skip_spaces
        ws = { ?\s => true, ?\n => true, ?\r => true, ?\t => true }
        while r = self.getc
          unless ws[r] then
            self.ungetc(r)
            break
          end
        end
        nil
      end
    end #class BufferedInputStream

    # Splitter is a class to get entries from a buffered input stream.
    module Splitter
      # This is a template of splitter.
      class Template
        # Creates a new splitter.
        def initialize(klass, bstream)
          @stream = bstream
          raise NotImplementedError
        end

        # skips leader of the entry.
        def skip_leader
          raise NotImplementedError
        end

        # Gets entry as a string
        def get_entry
          raise NotImplementedError
        end

        # the last entry read from the stream
        attr_reader :entry

        # a flag to write down entry start and end positions
        attr_accessor :entry_pos_flag

        # start position of the entry
        attr_reader :entry_start_pos

        # (end position of the entry) + 1
        attr_reader :entry_ended_pos
      end

      # Default splitter.
      # It sees following constants in the given class.
      # DELIMITER:: (String) delimiter indicates the end of a entry.
      # FLATFILE_HEADER:: (String) start of a entry, located on head of a line.
      # DELIMITER_OVERRUN:: (Integer) excess read size included in DELIMITER.
      #
      class Default < Template
        # Creates a new splitter.
        # klass:: database class
        # bstream:: input stream. It must be a BufferedInputStream object.
        def initialize(klass, bstream)
          @stream = bstream
          @delimiter = klass::DELIMITER rescue nil
          @header = klass::FLATFILE_HEADER rescue nil
          # for specific classes' benefit
          unless header
            if klass == Bio::GenBank or klass == Bio::GenPept
              @header = 'LOCUS '
            end
          end
          @delimiter_overrun = klass::DELIMITER_OVERRUN rescue nil
          @entry_pos_flag = nil
        end

        # (String) delimiter indicates the end of a entry.
        attr_accessor :delimiter

        # (String) start of a entry, located on head of a line.
        attr_accessor :header

        # (Integer) excess read data size included in delimiter.
        attr_accessor :delimiter_overrun
        
        # Skips leader of the entry.
        #
        # If @header is not nil, it reads till the contents of @header
        # comes at the head of a line.
        # If correct FLATFILE_HEADER is found, returns true.
        # Otherwise, returns nil.
        def skip_leader
          if @header then
            data = ''
            while s = @stream.gets(@header)
              data << s
              if data.split(/[\r\n]+/)[-1] == @header then
                @stream.ungets(@header)
                return true
              end
            end
            # @header was not found. For safety,
            # pushes back data with removing white spaces in the head.
            data.sub(/\A\s+/, '')
            @stream.ungets(data)
            return nil
          else
            @stream.skip_spaces
            return nil
          end
        end

        # gets a entry
        def get_entry
          p0 = @entry_pos_flag ? @stream.pos : nil
          e  = @stream.gets(@delimiter)
          if e and @delimiter_overrun then
            if e[-@delimiter.size, @delimiter.size ] == @delimiter then
              overrun = e[-@delimiter_overrun, @delimiter_overrun]
              e[-@delimiter_overrun, @delimiter_overrun] = ''
              @stream.ungets(overrun)
            end
          end
          p1 = @entry_pos_flag ? @stream.pos : nil
          @entry_start_pos = p0
          @entry = e
          @entry_ended_pos = p1
          @entry
        end
      end #class Defalult
    end #module Splitter

    #
    #   Bio::FlatFile.open(file, *arg)
    #   Bio::FlatFile.open(dbclass, file, *arg)
    #
    # Creates a new Bio::FlatFile object to read a file or a stream
    # which contains _dbclass_ data.
    #
    # _dbclass_ should be a class (or module) or nil.
    # e.g. Bio::GenBank, Bio::FastaFormat.
    #
    # If _file_ is a filename (which doesn't have gets method),
    # the method opens a local file named _file_
    # with <code>File.open(filename, *arg)</code>.
    #
    # When _dbclass_ is omitted or nil is given to _dbclass_,
    # the method tries to determine database class
    # (file format) automatically.
    # When it fails to determine, dbclass is set to nil
    # and FlatFile#next_entry would fail.
    # You can still set dbclass using FlatFile#dbclass= method.
    #
    # * Example 1
    #     Bio::FlatFile.open(Bio::GenBank, "genbank/gbest40.seq")
    # * Example 2
    #     Bio::FlatFile.open(nil, "embl/est_hum17.dat")
    # * Example 3
    #     Bio::FlatFile.open("genbank/gbest40.seq")
    #
    # * Example 4
    #     Bio::FlatFile.open(Bio::GenBank, $stdin)
    #
    # If it is called with a block, the block will be executed with
    # a new Bio::FlatFile object. If filename is given,
    # the file is automatically closed when leaving the block.
    #
    # * Example 5
    #     Bio::FlatFile.open(nil, 'test4.fst') do |ff|
    #         ff.each { |e| print e.definition, "\n" }
    #     end
    #
    # * Example 6
    #     Bio::FlatFile.open('test4.fst') do |ff|
    #         ff.each { |e| print e.definition, "\n" }
    #     end
    #
    # Compatibility Note:
    # <em>*arg</em> is completely passed to the <code>File.open</code>
    # and you cannot specify ":raw => true" or ":raw => false".
    #
    def self.open(*arg, &block)
      # FlatFile.open(dbclass, file, mode, perm)
      # FlatFile.open(file, mode, perm)
      if arg.size <= 0
        raise ArgumentError, 'wrong number of arguments (0 for 1)'
      end
      x = arg.shift
      if x.is_a?(Module) then
        # FlatFile.open(dbclass, filename_or_io, ...)
        dbclass = x
      elsif x.nil? then
        # FlatFile.open(nil, filename_or_io, ...)
        dbclass = nil
      else
        # FlatFile.open(filename, ...)
        dbclass = nil
        arg.unshift(x)
      end
      if arg.size <= 0
        raise ArgumentError, 'wrong number of arguments (1 for 2)'
      end
      file = arg.shift
      # check if file is filename or IO object
      unless file.respond_to?(:gets)
        # 'file' is a filename
        _open_file(dbclass, file, *arg, &block)
      else
        # 'file' is a IO object
        ff = self.new(dbclass, file)
        block_given? ? (yield ff) : ff
      end
    end

    # Same as Bio::FlatFile.open(nil, filename_or_stream, mode, perm, options).
    #
    # * Example 1
    #    Bio::FlatFile.auto(ARGF)
    # * Example 2
    #    Bio::FlatFile.auto("embl/est_hum17.dat")
    # * Example 3
    #    Bio::FlatFile.auto(IO.popen("gzip -dc nc1101.flat.gz"))
    #
    def self.auto(*arg, &block)
      self.open(nil, *arg, &block)
    end

    # Same as FlatFile.auto(filename_or_stream, *arg).to_a
    #
    # (This method might be OBSOLETED in the future.)
    def self.to_a(*arg)
      self.auto(*arg) do |ff|
        raise 'cannot determine file format' unless ff.dbclass
        ff.to_a
      end
    end

    # Same as FlatFile.auto(filename, *arg),
    # except that it only accept filename and doesn't accept IO object.
    # File format is automatically determined.
    #
    # It can accept a block.
    # If a block is given, it returns the block's return value.
    # Otherwise, it returns a new FlatFile object.
    #
    def self.open_file(filename, *arg)
      _open_file(nil, filename, *arg)
    end

    # Same as FlatFile.open(dbclass, filename, *arg),
    # except that it only accept filename and doesn't accept IO object.
    #
    # It can accept a block.
    # If a block is given, it returns the block's return value.
    # Otherwise, it returns a new FlatFile object.
    #
    def self._open_file(dbclass, filename, *arg)
      if block_given? then
        BufferedInputStream.open_file(filename, *arg) do |stream|
          yield self.new(dbclass, stream)
        end
      else
        stream = BufferedInputStream.open_file(filename, *arg)
        self.new(dbclass, stream)
      end
    end
    private_class_method :_open_file

    # Opens URI specified as _uri_.
    # _uri_ must be a String or URI object.
    # *arg is passed to OpenURI.open_uri or URI#open.
    #
    # Like FlatFile#open, it can accept a block.
    #
    # Note that you MUST explicitly require 'open-uri'.
    # Because open-uri.rb modifies existing class,
    # it isn't required by default.
    # 
    def self.open_uri(uri, *arg)
      if block_given? then
        BufferedInputStream.open_uri(uri, *arg) do |stream|
          yield self.new(nil, stream)
        end
      else
        stream = BufferedInputStream.open_uri(uri, *arg)
        self.new(nil, stream)
      end
    end

    # Executes the block for every entry in the stream.
    # Same as FlatFile.open(*arg) { |ff| ff.each { |entry| ... }}.
    # 
    # * Example
    #     Bio::FlatFile.foreach('test.fst') { |e| puts e.definition }
    #
    def self.foreach(*arg)
      self.open(*arg) do |flatfileobj|
        flatfileobj.each do |entry|
          yield entry
        end
      end
    end

    # Same as FlatFile.open, except that 'stream' should be a opened
    # stream object (IO, File, ..., who have the 'gets' method).
    #
    # * Example 1
    #    Bio::FlatFile.new(Bio::GenBank, ARGF)
    # * Example 2
    #    Bio::FlatFile.new(Bio::GenBank, IO.popen("gzip -dc nc1101.flat.gz"))
    #
    # Compatibility Note:
    # Now, you cannot specify ":raw => true" or ":raw => false".
    # Below styles are DEPRECATED.
    #
    # * Example 3 (deprecated)
    #    # Bio::FlatFile.new(nil, $stdin, :raw=>true) # => ERROR
    #    # Please rewrite as below.
    #    ff = Bio::FlatFile.new(nil, $stdin)
    #    ff.raw = true
    # * Example 3 in old style (deprecated)
    #    # Bio::FlatFile.new(nil, $stdin, true) # => ERROR
    #    # Please rewrite as below.
    #    ff = Bio::FlatFile.new(nil, $stdin)
    #    ff.raw = true
    #
    def initialize(dbclass, stream)
      # 2nd arg: IO object
      if stream.kind_of?(BufferedInputStream)
        @stream = stream
      else
        @stream = BufferedInputStream.for_io(stream)
      end
      # 1st arg: database class (or file format autodetection)
      if dbclass then
	self.dbclass = dbclass
      else
	autodetect
      end
      #
      @skip_leader_mode = :firsttime
      @firsttime_flag = true
      # default raw mode is false
      self.raw = false
    end

    # The mode how to skip leader of the data.
    # :firsttime :: (DEFAULT) only head of file (= first time to read)
    # :everytime :: everytime to read entry
    # nil :: never skip
    attr_accessor :skip_leader_mode

    # (DEPRECATED) IO object in the flatfile object.
    #
    # Compatibility Note: Bio::FlatFile#io is deprecated.
    # Please use Bio::FlatFile#to_io instead.
    def io
      warn "Bio::FlatFile#io is deprecated."
      @stream.to_io
    end

    # IO object in the flatfile object.
    #
    # Compatibility Note: Bio::FlatFile#io is deprecated.
    def to_io
      @stream.to_io
    end

    # Pathname, filename or URI (or nil).
    def path
      @stream.path
    end

    # Exception class to be raised when data format hasn't been specified.
    class UnknownDataFormatError < IOError
    end

    # Get next entry.
    def next_entry
      raise UnknownDataFormatError, 
      'file format auto-detection failed?' unless @dbclass
      if @skip_leader_mode and
          ((@firsttime_flag and @skip_leader_mode == :firsttime) or
             @skip_leader_mode == :everytime)
        @splitter.skip_leader
      end
      r = @splitter.get_entry
      @firsttime_flag = false
      return nil unless r
      if raw then
	r
      else
	@entry = @dbclass.new(r)
        @entry
      end
    end
    attr_reader :entry

    # Returns the last raw entry as a string.
    def entry_raw
      @splitter.entry
    end

    # a flag to write down entry start and end positions
    def entry_pos_flag
      @splitter.entry_pos_flag
    end

    # Sets flag to write down entry start and end positions
    def entry_pos_flag=(x)
      @splitter.entry_pos_flag = x
    end

    # start position of the last entry
    def entry_start_pos
      @splitter.entry_start_pos
    end

    # (end position of the last entry) + 1
    def entry_ended_pos
      @splitter.entry_ended_pos
    end

    # Iterates over each entry in the flatfile.
    #
    # * Example
    #    include Bio
    #    ff = FlatFile.open(GenBank, "genbank/gbhtg14.seq")
    #    ff.each_entry do |x|
    #      puts x.definition
    #    end
    def each_entry
      while e = self.next_entry
	yield e
      end
    end
    alias :each :each_entry

    # Resets file pointer to the start of the flatfile.
    # (similar to IO#rewind)
    def rewind
      r = @stream.rewind
      @firsttime_flag = true
      r
    end

    # Closes input stream.
    # (similar to IO#close)
    def close
      @stream.close
    end

    # Returns current position of input stream.
    # If the input stream is not a normal file,
    # the result is not guaranteed.
    # It is similar to IO#pos.
    # Note that it will not be equal to io.pos,
    # because FlatFile has its own internal buffer.
    def pos
      @stream.pos
    end

    # (Not recommended to use it.)
    # Sets position of input stream.
    # If the input stream is not a normal file,
    # the result is not guaranteed.
    # It is similar to IO#pos=.
    # Note that it will not be equal to io.pos=,
    # because FlatFile has its own internal buffer.
    def pos=(p)
      @stream.pos=(p)
    end

    # Returns true if input stream is end-of-file.
    # Otherwise, returns false.
    # (Similar to IO#eof?, but may not be equal to io.eof?,
    # because FlatFile has its own internal buffer.)
    def eof?
      @stream.eof?
    end

    # If true is given, the next_entry method returns
    # a entry as a text, whereas if false, returns as a parsed object.
    def raw=(bool)
      @raw = (bool ? true : false)
    end

    # If true, raw mode.
    attr_reader :raw

    # Similar to IO#gets.
    # Internal use only. Users should not call it directly.
    def gets(*arg)
      @stream.gets(*arg)
    end

    # Sets database class. Plese use only if autodetect fails.
    def dbclass=(klass)
      if klass then
	@dbclass = klass
        begin
          @splitter = @dbclass.flatfile_splitter(@dbclass, @stream)
        rescue NameError, NoMethodError
          @splitter = Splitter::Default.new(klass, @stream)
        end
      else
	@dbclass = nil
	@splitter = nil
      end
    end

    # Returns database class which is automatically detected or
    # given in FlatFile#initialize.
    attr_reader :dbclass

    # Performs determination of database class (file format).
    # Pre-reads +lines+ lines for format determination (default 31 lines).
    # If fails, returns nil or false. Otherwise, returns database class.
    #
    # The method can be called anytime if you want (but not recommended).
    # This might be useful if input file is a mixture of muitiple format data.
    def autodetect(lines = 31, ad = AutoDetect.default)
      if r = ad.autodetect_flatfile(self, lines)
        self.dbclass = r
      else
        self.dbclass = nil unless self.dbclass
      end
      r
    end

    # Detects database class (== file format) of given file.
    # If fails to determine, returns nil.
    def self.autodetect_file(filename)
      self.open_file(filename).dbclass
    end

    # Detects database class (== file format) of given input stream.
    # If fails to determine, returns nil.
    # Caution: the method reads some data from the input stream,
    # and the data will be lost.
    def self.autodetect_io(io)
      self.new(nil, io).dbclass
    end

    # This is OBSOLETED. Please use autodetect_io(io) instead.
    def self.autodetect_stream(io)
      $stderr.print "Bio::FlatFile.autodetect_stream will be deprecated." if $VERBOSE
      self.autodetect_io(io)
    end

    # Detects database class (== file format) of given string.
    # If fails to determine, returns false or nil.
    def self.autodetect(text)
      AutoDetect.default.autodetect(text)
    end


    # AutoDetect automatically determines database class of given data.
    class AutoDetect

      include TSort

      # Array to store autodetection rules.
      # This is defined only for inspect.
      class RulesArray < Array
        # visualize contents
        def inspect
          "[#{self.collect { |e| e.name.inspect }.join(' ')}]"
        end
      end #class RulesArray

      # Template of a single rule of autodetection
      class RuleTemplate
        # Creates a new element.
        def self.[](*arg)
          self.new(*arg)
        end
        
        # Creates a new element.
        def initialize
          @higher_priority_elements = RulesArray.new
          @lower_priority_elements  = RulesArray.new
          @name = nil
        end

        # self is prior to the _elem_.
        def is_prior_to(elem)
          return nil if self == elem
          elem.higher_priority_elements << self
          self.lower_priority_elements << elem
          true
        end

        # higher priority elements
        attr_reader :higher_priority_elements
        # lower priority elements
        attr_reader :lower_priority_elements

        # database classes
        attr_reader :dbclasses

        # unique name of the element
        attr_accessor :name

        # If given text (and/or meta information) is known, returns
        # the database class.
        # Otherwise, returns nil or false.
        #
        # _text_ will be a String.
        # _meta_ will be a Hash.
        # _meta_ may contain following keys.
        # :path => pathname, filename or uri.
        def guess(text, meta)
          nil
        end

        private
        # Gets constant from constant name given as a string.
        def str2const(str)
          const = Object
          str.split(/\:\:/).each do |x|
            const = const.const_get(x)
          end
          const
        end

        # Gets database class from given object.
        # Current implementation is: 
        # if _obj_ is kind of String, regarded as a constant.
        # Otherwise, returns _obj_ as is.
        def get_dbclass(obj)
          obj.kind_of?(String) ? str2const(obj) : obj
        end
      end #class Rule_Template

      # RuleDebug is a class for debugging autodetect classes/methods
      class RuleDebug < RuleTemplate
        # Creates a new instance.
        def initialize(name)
          super()
          @name = name
        end

        # prints information to the $stderr.
        def guess(text, meta)
          $stderr.puts @name
          $stderr.puts text.inspect
          $stderr.puts meta.inspect
          nil
        end
      end #class RuleDebug

      # Special element that is always top or bottom priority.
      class RuleSpecial < RuleTemplate
        def initialize(name)
          #super()
          @name = name
        end
        # modification of @name is inhibited.
        def name=(x)
          raise 'cannot modify name'
        end

        # always returns void array
        def higher_priority_elements
          []
        end
        # always returns void array
        def lower_priority_elements
          []
        end
      end #class RuleSpecial

      # Special element that is always top priority.
      TopRule = RuleSpecial.new('top')
      # Special element that is always bottom priority.
      BottomRule = RuleSpecial.new('bottom')

      # A autodetection rule to use a regular expression
      class RuleRegexp < RuleTemplate
        # Creates a new instance.
        def initialize(dbclass, re)
          super()
          @re = re
          @name = dbclass.to_s
          @dbclass = nil
          @dbclass_lazy = dbclass
        end

        # database class (lazy evaluation)
        def dbclass
          unless @dbclass
            @dbclass = get_dbclass(@dbclass_lazy)
          end
          @dbclass
        end
        private :dbclass

        # returns database classes
        def dbclasses
          [ dbclass ]
        end

        # If given text matches the regexp, returns the database class.
        # Otherwise, returns nil or false.
        # _meta_ is ignored.
        def guess(text, meta)
          @re =~ text ? dbclass : nil
        end
      end #class RuleRegexp

      # A autodetection rule to use more than two regular expressions.
      # If given string matches one of the regular expressions,
      # returns the database class.
      class RuleRegexp2 < RuleRegexp
        # Creates a new instance.
        def initialize(dbclass, *regexps)
          super(dbclass, nil)
          @regexps = regexps
        end

        # If given text matches one of the regexp, returns the database class.
        # Otherwise, returns nil or false.
        # _meta_ is ignored.
        def guess(text, meta)
          @regexps.each do |re|
            return dbclass if re =~ text
          end
          nil
        end
      end #class RuleRegexp

      # A autodetection rule that passes data to the proc object.
      class RuleProc < RuleTemplate
        # Creates a new instance.
        def initialize(*dbclasses, &proc)
          super()
          @proc = proc
          @dbclasses = nil
          @dbclasses_lazy = dbclasses
          @name = dbclasses.collect { |x| x.to_s }.join('|')
        end

        # database classes (lazy evaluation)
        def dbclasses
          unless @dbclasses
            @dbclasses = @dbclasses_lazy.collect { |x| get_dbclass(x) }
          end
          @dbclasses
        end

        # If given text (and/or meta information) is known, returns
        # the database class.
        # Otherwise, returns nil or false.
        #
        # Refer RuleTemplate#guess for _meta_.
        def guess(text, meta)
          @proc.call(text)
        end
      end #class RuleProc
      
      # Creates a new Autodetect object
      def initialize
        # stores autodetection rules.
        @rules = Hash.new
        # stores elements (cache)
        @elements = nil
        self.add(TopRule)
        self.add(BottomRule)
      end

      # Adds a new element.
      # Returns _elem_.
      def add(elem)
        raise 'element name conflicts' if @rules[elem.name]
        @elements = nil
        @rules[elem.name] = elem
        elem
      end

      # (required by TSort.)
      # For all elements, yields each element.
      def tsort_each_node(&x)
        @rules.each_value(&x)
      end

      # (required by TSort.)
      # For a given element, yields each child
      # (= lower priority elements) of the element.
      def tsort_each_child(elem)
        if elem == TopRule then
          @rules.each_value do |e|
            yield e unless e == TopRule or 
              e.lower_priority_elements.index(TopRule)
          end
        elsif elem == BottomRule then
          @rules.each_value do |e|
            yield e if e.higher_priority_elements.index(BottomRule)
          end
        else
          elem.lower_priority_elements.each do |e|
            yield e if e != BottomRule
          end
          unless elem.higher_priority_elements.index(BottomRule)
            yield BottomRule
          end
        end
      end

      # Returns current elements as an array
      # whose order fulfills all elements' priorities.
      def elements
        unless @elements
          ary = tsort
          ary.reverse!
          @elements = ary
        end
        @elements
      end

      # rebuilds the object and clears internal cache.
      def rehash
        @rules.rehash
        @elements = nil
      end

      # visualizes the object (mainly for debug)
      def inspect
        "<#{self.class.to_s} " +
          self.elements.collect { |e| e.name.inspect }.join(' ') +
          ">"
      end

      # Iterates over each element.
      def each_rule(&x) #:yields: elem
        elements.each(&x)
      end

      # Autodetect from the text.
      # Returns a database class if succeeded.
      # Returns nil if failed.
      def autodetect(text, meta = {})
        r = nil
        elements.each do |e|
          #$stderr.puts e.name
          r = e.guess(text, meta)
          break if r
        end
        r
      end

      # autodetect from the FlatFile object.
      # Returns a database class if succeeded.
      # Returns nil if failed.
      def autodetect_flatfile(ff, lines = 31)
        meta = {}
        stream = ff.instance_eval { @stream }
        begin
          path = stream.path
        rescue NameError
        end
        if path then
          meta[:path] = path
          # call autodetect onece with meta and without any read action
          if r = self.autodetect(stream.prefetch_buffer, meta)
            return r
          end
        end
        # reading stream
        1.upto(lines) do |x|
          break unless line = stream.prefetch_gets
          if line.strip.size > 0 then
            if r = self.autodetect(stream.prefetch_buffer, meta)
              return r
            end
          end
        end
        return nil
      end

      # default autodetect object for class method
      @default = nil

      # returns the default autodetect object
      def self.default
        unless @default then
          @default = self.make_default
        end
        @default
      end

      # sets the default autodetect object.
      def self.default=(ad)
        @default = ad
      end

      # make a new autodetect object
      def self.[](*arg)
        a = self.new
        arg.each { |e| a.add(e) }
        a
      end

      # make a default of default autodetect object
      def self.make_default
        a = self[
          genbank  = RuleRegexp[ 'Bio::GenBank',
            /^LOCUS       .+ bp .*[a-z]*[DR]?NA/ ],
          genpept  = RuleRegexp[ 'Bio::GenPept',
            /^LOCUS       .+ aa .+/ ],
          medline  = RuleRegexp[ 'Bio::MEDLINE',
            /^PMID\- [0-9]+$/ ],
          embl     = RuleRegexp[ 'Bio::EMBL',
            /^ID   .+\; .*(DNA|RNA|XXX)\;/ ],
          sptr     = RuleRegexp2[ 'Bio::SPTR',
            /^ID   .+\; *PRT\;/,
            /^ID   [-A-Za-z0-9_\.]+ .+\; *[0-9]+ *AA\./ ],
          prosite  = RuleRegexp[ 'Bio::PROSITE',
            /^ID   [-A-Za-z0-9_\.]+\; (PATTERN|RULE|MATRIX)\.$/ ],
          transfac = RuleRegexp[ 'Bio::TRANSFAC',
            /^AC  [-A-Za-z0-9_\.]+$/ ],

          aaindex  = RuleProc.new('Bio::AAindex1', 'Bio::AAindex2') do |text|
            if /^H [-A-Z0-9_\.]+$/ =~ text then
              if text =~ /^M [rc]/ then
                Bio::AAindex2
              elsif text =~ /^I    A\/L/ then
                Bio::AAindex1
              else
                false #fail to determine
              end
            else
              nil
            end
          end,

          litdb    = RuleRegexp[ 'Bio::LITDB',
            /^CODE        [0-9]+$/ ],
          brite    = RuleRegexp[ 'Bio::KEGG::BRITE',
            /^Entry           [A-Z0-9]+/ ],
          orthology = RuleRegexp[ 'Bio::KEGG::ORTHOLOGY',
            /^ENTRY       .+ KO\s*/ ],
          drug     = RuleRegexp[ 'Bio::KEGG::DRUG',
            /^ENTRY       .+ Drug\s*/ ],
          glycan   = RuleRegexp[ 'Bio::KEGG::GLYCAN',
            /^ENTRY       .+ Glycan\s*/ ],
          enzyme   = RuleRegexp2[ 'Bio::KEGG::ENZYME',
            /^ENTRY       EC [0-9\.]+$/,
            /^ENTRY       .+ Enzyme\s*/
          ],
          compound = RuleRegexp2[ 'Bio::KEGG::COMPOUND',
            /^ENTRY       C[A-Za-z0-9\._]+$/,
            /^ENTRY       .+ Compound\s*/
          ],
          reaction = RuleRegexp2[ 'Bio::KEGG::REACTION',
            /^ENTRY       R[A-Za-z0-9\._]+$/,
            /^ENTRY       .+ Reaction\s*/
          ],
          genes    = RuleRegexp[ 'Bio::KEGG::GENES',
            /^ENTRY       .+ (CDS|gene|.*RNA|Contig) / ],
          genome   = RuleRegexp[ 'Bio::KEGG::GENOME',
            /^ENTRY       [a-z]+$/ ],

          fantom = RuleProc.new('Bio::FANTOM::MaXML::Cluster',
                                'Bio::FANTOM::MaXML::Sequence') do |text|
            if /\<\!DOCTYPE\s+maxml\-(sequences|clusters)\s+SYSTEM/ =~ text
              case $1
              when 'clusters'
                Bio::FANTOM::MaXML::Cluster
              when 'sequences'
                Bio::FANTOM::MaXML::Sequence
              else
                nil #unknown
              end
            else
              nil
            end
          end,

          pdb = RuleRegexp[ 'Bio::PDB',
            /^HEADER    .{40}\d\d\-[A-Z]{3}\-\d\d   [0-9A-Z]{4}/ ],
          het = RuleRegexp[ 'Bio::PDB::ChemicalComponent',
            /^RESIDUE +.+ +\d+\s*$/ ],

          clustal = RuleRegexp2[ 'Bio::ClustalW::Report',
          /^CLUSTAL .*\(.*\).*sequence +alignment/,
          /^CLUSTAL FORMAT for T-COFFEE/ ],

          gcg_msf = RuleRegexp[ 'Bio::GCG::Msf',
          /^!!(N|A)A_MULTIPLE_ALIGNMENT .+/ ],

          gcg_seq = RuleRegexp[ 'Bio::GCG::Seq',
          /^!!(N|A)A_SEQUENCE .+/ ],

          blastxml = RuleRegexp[ 'Bio::Blast::Report',
            /\<\!DOCTYPE BlastOutput PUBLIC / ],
          wublast  = RuleRegexp[ 'Bio::Blast::WU::Report',
            /^BLAST.? +[\-\.\w]+\-WashU +\[[\-\.\w ]+\]/ ],
          wutblast = RuleRegexp[ 'Bio::Blast::WU::Report_TBlast',
            /^TBLAST.? +[\-\.\w]+\-WashU +\[[\-\.\w ]+\]/ ],
          blast    = RuleRegexp[ 'Bio::Blast::Default::Report',
            /^BLAST.? +[\-\.\w]+ +\[[\-\.\w ]+\]/ ],
          tblast   = RuleRegexp[ 'Bio::Blast::Default::Report_TBlast',
            /^TBLAST.? +[\-\.\w]+ +\[[\-\.\w ]+\]/ ],

          blat   = RuleRegexp[ 'Bio::Blat::Report',
            /^psLayout version \d+/ ],
          spidey = RuleRegexp[ 'Bio::Spidey::Report',
            /^\-\-SPIDEY version .+\-\-$/ ],
          hmmer  = RuleRegexp[ 'Bio::HMMER::Report',
            /^HMMER +\d+\./ ],
          sim4   = RuleRegexp[ 'Bio::Sim4::Report',
            /^seq1 \= .*\, \d+ bp(\r|\r?\n)seq2 \= .*\, \d+ bp(\r|\r?\n)/ ],

          fastaformat = RuleProc.new('Bio::FastaFormat',
                                     'Bio::NBRF',
                                     'Bio::FastaNumericFormat') do |text|
            if /^>.+$/ =~ text
              case text
              when /^>([PF]1|[DR][LC]|N[13]|XX)\;.+/
                Bio::NBRF
              when /^>.+$\s+(^\#.*$\s*)*^\s*\d*\s*[-a-zA-Z_\.\[\]\(\)\*\+\$]+/
                  Bio::FastaFormat
              when /^>.+$\s+^\s*\d+(\s+\d+)*\s*$/
                Bio::FastaNumericFormat
              else
                false
              end
            else
              nil
            end
          end
        ]

        # dependencies
        # NCBI
        genbank.is_prior_to genpept
        # EMBL/UniProt
        embl.is_prior_to sptr
        sptr.is_prior_to prosite
        prosite.is_prior_to transfac
        # KEGG
        #aaindex.is_prior_to litdb
        #litdb.is_prior_to brite
        brite.is_prior_to orthology
        orthology.is_prior_to drug
        drug.is_prior_to glycan
        glycan.is_prior_to enzyme
        enzyme.is_prior_to compound
        compound.is_prior_to reaction
        reaction.is_prior_to genes
        genes.is_prior_to genome
        # PDB
        pdb.is_prior_to het
        # BLAST
        wublast.is_prior_to wutblast
        wutblast.is_prior_to blast
        blast.is_prior_to tblast
        # FastaFormat
        BottomRule.is_prior_to(fastaformat)

        # for debug
        #debug_first = RuleDebug.new('debug_first')
        #a.add(debug_first)
        #debug_first.is_prior_to(TopRule)

        ## for debug
        #debug_last = RuleDebug.new('debug_last')
        #a.add(debug_last)
        #BottomRule.is_prior_to(debug_last)
        #fastaformat.is_prior_to(debug_last)

        a.rehash
        return a
      end
      
    end #class AutoDetect
    
  end #class FlatFile

end #module Bio

if __FILE__ == $0
  if ARGV.size == 2
    require 'bio'
    p Bio::FlatFile.open(eval(ARGV.shift), ARGV.shift).next_entry
  end
end
