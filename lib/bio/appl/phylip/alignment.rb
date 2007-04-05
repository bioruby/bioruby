#
# = bio/appl/phylip/alignment.rb - phylip multiple alignment format parser
#
# Copyright:: Copyright (C) 2006
#             GOTO Naohisa <ng@bioruby.org>
#
# License:: The Ruby License
#
#  $Id: alignment.rb,v 1.2 2007/04/05 23:35:40 trevor Exp $
#
# = About Bio::Phylip::PhylipFormat
#
# Please refer document of Bio::Phylip::PhylipFormat class.
#

module Bio
  module Phylip

    # This is phylip multiple alignment format parser.
    # The two formats, interleaved and non-interleaved, are
    # automatically determined.
    #
    class PhylipFormat

      # create a new object from a string
      def initialize(str)
        @data = str.strip.split(/(?:\r\n|\r|\n)/)
        @first_line = @data.shift
        @number_of_sequences, @alignment_length =
          @first_line.to_s.strip.split(/\s+/).collect { |x| x.to_i }
      end

      # number of sequences
      attr_reader :number_of_sequences

      # alignment length
      attr_reader :alignment_length

      # If the alignment format is "interleaved", returns true.
      # If not, returns false.
      # It would mistake to determine if the alignment is very short.
      def interleaved?
        unless defined? @interleaved_flag then
          if /\A +/ =~ @data[1].to_s then
            @interleaved_flag = false
          else
            @interleaved_flag = true
          end
        end
        @interleaved_flag
      end

      # Gets the alignment. Returns a Bio::Alignment object.
      def alignment
        unless defined? @alignment then
          do_parse
          a = Bio::Alignment.new
          (0...@number_of_sequences).each do |i|
            a.add_seq(@sequences[i], @sequence_names[i])
          end
          @alignment = a
        end
        @alignment
      end

      private

      def do_parse
        if interleaved? then
          do_parse_interleaved
        else
          do_parse_noninterleaved
        end
      end

      def do_parse_interleaved
        first_block = @data[0, @number_of_sequences]
        @data[0, @number_of_sequences] = ''
        @sequence_names = Array.new(@number_of_sequences) { '' }
        @sequences = Array.new(@number_of_sequences) do
          ' ' * @alignment_length
        end
        first_block.each_with_index do |x, i|
          n, s = x.split(/ +/, 2)
          @sequence_names[i] = n
          @sequences[i].replace(s.gsub(/\s+/, ''))
        end
        i = 0
        @data.each do |x|
          if x.strip.length <= 0 then
            i = 0
          else
            @sequences[i] << x.gsub(/\s+/, '')
            i = (i + 1) % @number_of_sequences
          end
        end
        @data.clear
        true
      end

      def do_parse_noninterleaved
        @sequence_names = Array.new(@number_of_sequences) { '' }
        @sequences = Array.new(@number_of_sequences) do
          ' ' * @alignment_length
        end
        curseq = nil
        i = 0
        @data.each do |x|
          next if x.strip.length <= 0
          if !curseq or
              curseq.length > @alignment_length or /^\s/ !~ x then
            p i
            n, s = x.strip.split(/ +/, 2)
            @sequence_names[i] = n
            curseq = @sequences[i]
            curseq.replace(s.gsub(/\s+/, ''))
            i += 1
          else
            curseq << x.gsub(/\s+/, '')
          end
        end
        @data.clear
        true
      end

    end #class PhylipFormat
  end #module Phylip
end #module Bio

