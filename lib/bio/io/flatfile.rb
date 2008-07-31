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

module Bio

  # Bio::FlatFile is a helper and wrapper class to read a biological data file.
  # It acts like a IO object.
  # It can automatically detect data format, and users do not need to tell
  # the class what the data is.
  class FlatFile

    autoload :AutoDetect,          'bio/io/flatfile/autodetection'
    autoload :Splitter,            'bio/io/flatfile/splitter'
    autoload :BufferedInputStream, 'bio/io/flatfile/buffer'

    include Enumerable

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
      if raw then
        r = @splitter.get_entry
      else
        r = @splitter.get_parsed_entry
      end
      @firsttime_flag = false
      return nil unless r
      if raw then
	r
      else
        @entry = r
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
      r = (@splitter || @stream).rewind
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
          begin
            splitter_class = @dbclass::FLATFILE_SPLITTER
          rescue NameError
            splitter_class = Splitter::Default
          end
          @splitter = splitter_class.new(klass, @stream)
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

  end #class FlatFile

end #module Bio

if __FILE__ == $0
  if ARGV.size == 2
    require 'bio'
    p Bio::FlatFile.open(eval(ARGV.shift), ARGV.shift).next_entry
  end
end
