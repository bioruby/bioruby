#
# = bio/io/flatfile/buffer.rb - Input stream buffer for FlatFile
#
#   Copyright (C) 2001-2006 Naohisa Goto <ng@bioruby.org>
#
# License:: The Ruby License
#
#  $Id:$
#
#
# See documents for Bio::FlatFile::BufferedInputStream and Bio::FlatFile.
#

require 'bio/io/flatfile'

module Bio

  class FlatFile

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
      #
      # Unlike File.open, the default is binary mode, unless text mode
      # is explicity specified in mode.
      def self.open_file(filename, *arg)
        params = _parse_file_open_arg(*arg)
        if params[:textmode] or /t/ =~ params[:fmode_string].to_s then
          textmode = true
        else
          textmode = false
        end
        if block_given? then
          File.open(filename, *arg) do |fobj|
            fobj.binmode unless textmode
            yield self.new(fobj, filename)
          end
        else
          fobj = File.open(filename, *arg)
          fobj.binmode unless textmode
          self.new(fobj, filename)
        end
      end

      # Parses file open mode parameter.
      # mode must be an Integer or a String.
      def self._parse_file_open_mode(mode)
        modeint = nil
        modestr = nil
        begin
          modeint = mode.to_int
        rescue NoMethodError
        end
        unless modeint then
          begin
            modestr = mode.to_str
          rescue NoMethodError
          end
        end
        if modeint then
          return { :fmode_integer => modeint }
        end
        if modestr then
          fmode, ext_enc, int_enc = modestr.split(/\:/)
          ret = { :fmode_string => fmode }
          ret[:external_encoding] = ext_enc if ext_enc
          ret[:internal_encoding] = int_enc if int_enc
          return ret
        end
        nil
      end
      private_class_method :_parse_file_open_mode
          
      # Parses file open arguments
      def self._parse_file_open_arg(*arg)
        fmode_hash = nil
        perm = nil

        elem = arg.shift
        if elem then
          fmode_hash = _parse_file_open_mode(elem)
          if fmode_hash then
            elem = arg.shift
            if elem then
              begin
                perm = elem.to_int
              rescue NoMethodError
              end
            end
            elem = arg.shift if perm
          end
        end
        if elem.kind_of?(Hash) then
          opt = elem.dup
        else
          opt = {}
        end
        if elem = opt[:mode] then
          fmode_hash = _parse_file_open_mode(elem)
        end
        fmode_hash ||= {}
        fmode_hash[:perm] = perm if perm
        unless enc = opt[:encoding].to_s.empty? then
          ext_enc, int_enc = enc.split(/\:/)
          fmode_hash[:external_encoding] = ext_enc if ext_enc
          fmode_hash[:internal_encoding] = int_enc if int_enc
        end

        [ :external_encoding, :internal_encoding,
          :textmode, :binmode, :autoclose, :perm ].each do |key|
          val = opt[key]
          fmode_hash[key] = val if val
        end
        fmode_hash
      end
      private_class_method :_parse_file_open_arg

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
      #
      # Compatibility note: the bahavior of paragraph mode (io_rs = '')
      # may differ from that of IO#gets('').
      def gets(io_rs = $/)
        if @buffer.size > 0
          if io_rs == nil then
            r = @buffer + @io.gets(nil).to_s
            @buffer = ''
          else
            if io_rs == '' then # io_rs.empty?
              sp_rs = /((?:\r?\n){2,})/n
            else
              sp_rs = io_rs
            end
            a = @buffer.split(sp_rs, 2)
            if a.size > 1 then
              r = a.shift
              r += (io_rs.empty? ? a.shift : io_rs)
              @buffer = a.shift.to_s
            else
              @buffer << @io.gets(io_rs).to_s
              a = @buffer.split(sp_rs, 2)
              if a.size > 1 then
                r = a.shift
                r += (io_rs.empty? ? a.shift : io_rs)
                @buffer = a.shift.to_s
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

  end #class FlatFile
end #module Bio
