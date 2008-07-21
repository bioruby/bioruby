#
# = bio/io/flatfile/splitter.rb - input data splitter for FlatFile
#
#   Copyright (C) 2001-2006 Naohisa Goto <ng@bioruby.org>
#
# License:: The Ruby License
#
#  $Id:$
#
#
# See documents for Bio::FlatFile::Splitter and Bio::FlatFile.
#

require 'bio/io/flatfile'

module Bio

  class FlatFile

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

  end #class FlatFile
end #module Bio


