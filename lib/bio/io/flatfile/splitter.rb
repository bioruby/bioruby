#
# = bio/io/flatfile/splitter.rb - input data splitter for FlatFile
#
#   Copyright (C) 2001-2008 Naohisa Goto <ng@bioruby.org>
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

    # The Bio::FlatFile::Splitter is a namespace for flatfile splitters.
    # Each splitter is a class to get entries from a buffered input stream.
    #
    # It is internally called in Bio::FlatFile.
    # Normally, users do not need to use it directly.
    module Splitter

      # This is a template of splitter.
      class Template
        # Creates a new splitter.
        def initialize(klass, bstream)
          @dbclass = klass
          @stream = bstream
          @entry_pos_flag = nil
        end

        # skips leader of the entry.
        def skip_leader
          raise NotImplementedError
        end

        # rewind the stream
        def rewind
          @stream.rewind
        end

        # Gets entry as a string. (String)
        def get_entry
          raise NotImplementedError
        end

        # Gets entry as a data class's object
        def get_parsed_entry
          ent = get_entry
          if ent then
            self.parsed_entry = dbclass.new(ent)
          else
            self.parsed_entry = ent
          end
          parsed_entry
        end

        # the last entry string read from the stream (String)
        attr_reader :entry

        # The last parsed entry read from the stream (entry data class).
        # Note that it is valid only after get_parsed_entry is called,
        # and the get_entry may not affect the parsed_entry attribute.
        attr_reader :parsed_entry

        # a flag to write down entry start and end positions
        attr_accessor :entry_pos_flag

        # start position of the entry
        attr_reader :entry_start_pos

        # (end position of the entry) + 1
        attr_reader :entry_ended_pos

        #--
        #private
        #
        ## to prevent warning message "warning: private attribute?",
        ## private attributes are explicitly declared.
        #++

        # entry data class
        attr_reader :dbclass
        private     :dbclass

        # input stream
        attr_reader :stream
        private     :stream

        # the last entry string read from the stream
        attr_writer :entry
        private     :entry=

        # the last entry as a parsed data object
        attr_writer :parsed_entry
        private     :parsed_entry=

        # start position of the entry
        attr_writer :entry_start_pos
        private     :entry_start_pos=

        # (end position of the entry) + 1
        attr_writer :entry_ended_pos
        private     :entry_ended_pos=

        # Does stream.pos if entry_pos_flag is not nil.
        # Otherwise, returns nil.
        def stream_pos
          entry_pos_flag ? stream.pos : nil
        end
        private :stream_pos
      end #class Template

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
          super(klass, bstream)

          @delimiter = klass::DELIMITER rescue nil
          @header = klass::FLATFILE_HEADER rescue nil
          # for specific classes' benefit
          unless header
            if klass == Bio::GenBank or klass == Bio::GenPept
              @header = 'LOCUS '
            end
          end
          @delimiter_overrun = klass::DELIMITER_OVERRUN rescue nil
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
            while s = stream.gets(@header)
              data << s
              if data.split(/[\r\n]+/)[-1] == @header then
                stream.ungets(@header)
                return true
              end
            end
            # @header was not found. For safety,
            # pushes back data with removing white spaces in the head.
            data.sub(/\A\s+/, '')
            stream.ungets(data)
            return nil
          else
            stream.skip_spaces
            return nil
          end
        end

        # gets a entry
        def get_entry
          p0 = stream_pos()
          e  = stream.gets(@delimiter)
          if e and @delimiter_overrun then
            if e[-@delimiter.size, @delimiter.size ] == @delimiter then
              overrun = e[-@delimiter_overrun, @delimiter_overrun]
              e[-@delimiter_overrun, @delimiter_overrun] = ''
              stream.ungets(overrun)
            end
          end
          p1 = stream_pos()
          self.entry_start_pos = p0
          self.entry = e
          self.entry_ended_pos = p1
          return entry
        end
      end #class Defalult


      # A splitter for line oriented text data.
      #
      # The given class's object must have following methods.
      #   Klass#add_header_line(line)
      #   Klass#add_line(line)
      # where 'line' is a string. They normally returns self.
      # If the line is not suitable to add to the current entry,
      # nil or false should be returned.
      # Then, the line is treated as (for add_header_line) the entry data
      # or (for add_line) the next entry's data.
      #
      class LineOriented < Template
        # Creates a new splitter.
        # klass:: database class
        # bstream:: input stream. It must be a BufferedInputStream object.
        def initialize(klass, bstream)
          super(klass, bstream)
          self.flag_to_fetch_header = true
        end

        # do nothing
        def skip_leader
          nil
        end

        # get an entry and return the entry as a string
        def get_entry
          if e = get_parsed_entry then
            entry
          else
            e
          end
        end

        # get an entry and return the entry as a data class object
        def get_parsed_entry
          p0 = stream_pos()
          ent = @dbclass.new()

          lines = []
          line_overrun = nil

          if flag_to_fetch_header then
            while line = stream.gets("\n")
              unless ent.add_header_line(line) then
                line_overrun = line
                break
              end
              lines.push line
            end
            stream.ungets(line_overrun) if line_overrun
            line_overrun = nil
            self.flag_to_fetch_header = false
          end
              
          while line = stream.gets("\n")
            unless ent.add_line(line) then
              line_overrun = line
              break
            end
            lines.push line
          end
          stream.ungets(line_overrun) if line_overrun
          p1 = stream_pos()

          return nil if lines.empty?

          self.entry_start_pos = p0
          self.entry = lines.join('')
          self.parsed_entry = ent
          self.entry_ended_pos = p1

          return ent
        end

        # rewinds the stream
        def rewind
          ret = super
          self.flag_to_fetch_header = true
          ret
        end

        #--
        #private methods / attributes
        #++

        # flag to fetch header
        attr_accessor :flag_to_fetch_header
        private       :flag_to_fetch_header
        private       :flag_to_fetch_header=

      end #class LineOriented

    end #module Splitter

  end #class FlatFile
end #module Bio


