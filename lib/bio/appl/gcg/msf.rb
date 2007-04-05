#
# = bio/appl/gcg/msf.rb - GCG multiple sequence alignment (.msf) parser class
#
# Copyright::   Copyright (C) 2003, 2006
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#
# $Id: msf.rb,v 1.2 2007/04/05 23:35:39 trevor Exp $
#
# = About Bio::GCG::Msf
#
# Please refer document of Bio::GCG::Msf.
#

#---
# (depends on autoload)
#require 'bio/appl/gcg/seq'
#+++

module Bio
  module GCG

    # The msf is a multiple sequence alignment format developed by Wisconsin.
    # Bio::GCG::Msf is a msf format parser.
    class Msf #< DB

      # delimiter used by Bio::FlatFile
      DELIMITER = RS = nil

      # Creates a new Msf object.
      def initialize(str)
        str = str.sub(/\A[\r\n]+/, '')
        if /^\!\![A-Z]+\_MULTIPLE\_ALIGNMNENT/ =~ str[/.*/] then
          @heading = str[/.*/] # '!!NA_MULTIPLE_ALIGNMENT 1.0' or like this
          str.sub!(/.*/, '')
        end
        str.sub!(/.*\.\.$/m, '')
        @description = $&.to_s.sub(/^.*\.\.$/, '').to_s
        d = $&.to_s
        if m = /(.+)\s+MSF\:\s+(\d+)\s+Type\:\s+(\w)\s+(.+)\s+(Comp)?Check\:\s+(\d+)/.match(d) then
          @entry_id = m[1].to_s.strip
          @length   = (m[2] ? m[2].to_i : nil)
          @seq_type = m[3]
          @date     = m[4].to_s.strip
          @checksum = (m[6] ? m[6].to_i : nil)
        end

        str.sub!(/.*\/\/$/m, '')
        a = $&.to_s.split(/^/)
        @seq_info = []
        a.each do |x|
          if /Name\: / =~ x then
            s = {}
            x.scan(/(\S+)\: +(\S*)/) { |y| s[$1] = $2 }
            @seq_info << s
          end
        end

        @data = str
        @description.sub!(/\A(\r\n|\r|\n)/, '')
        @align = nil
      end

      # description
      attr_reader :description

      # ID of the alignment
      attr_reader :entry_id

      # alignment length
      attr_reader :length

      # sequence type ("N" for DNA/RNA or "P" for protein)
      attr_reader :seq_type

      # date
      attr_reader :date

      # checksum
      attr_reader :checksum

      # heading
      # ('!!NA_MULTIPLE_ALIGNMENT 1.0' or whatever like this)
      attr_reader :heading

      #---
      ## data (internally used, will be obsoleted)
      #attr_reader :data
      #
      ## seq. info. (internally used, will be obsoleted)
      #attr_reader :seq_info
      #+++

      # symbol comparison table
      def symbol_comparison_table
        unless defined?(@symbol_comparison_table)
          /Symbol comparison table\: +(\S+)/ =~ @description
          @symbol_comparison_table = $1
        end
        @symbol_comparison_table
      end

      # gap weight
      def gap_weight
        unless defined?(@gap_weight)
          /GapWeight\: +(\S+)/ =~ @description
          @gap_weight = $1
        end
        @gap_weight
      end

      # gap length weight
      def gap_length_weight
        unless defined?(@gap_length_weight)
          /GapLengthWeight\: +(\S+)/ =~ @description
          @gap_length_weight = $1
        end
        @gap_length_weight
      end

      # CompCheck field
      def compcheck
        unless defined?(@compcheck)
          if /CompCheck\: +(\d+)/ =~ @description then
            @compcheck = $1.to_i
          else
            @compcheck = nil
          end
        end
        @compcheck
      end

      # parsing
      def do_parse
        return if @align
        a = @data.strip.split(/\n\n/)
        @seq_data = Array.new(@seq_info.size)
        @seq_data.collect! { |x| Array.new }
        a.each do |x|
          b = x.split(/\n/)
          nw = 0
          if b.size > @seq_info.size then
            if /^ +/ =~ b.shift.to_s
              nw = $&.to_s.length
            end
          end
          if nw > 0 then
            b.each_with_index { |y, i| y[0, nw] = ''; @seq_data[i] << y }
          else
            b.each_with_index { |y, i|
              @seq_data[i] << y.strip.split(/  +/, 2)[1].to_s
            }
          end
        end

        case seq_type
        when 'P', 'p'
          k = Bio::Sequence::AA
        when 'N', 'n'
          k = Bio::Sequence::NA
        else
          k = Bio::Sequence::Generic
        end
        @seq_data.collect! do |x|
          y = x.join('')
          y.gsub!(/[\s\d]+/, '')
          k.new(y)
        end

        aln = Bio::Alignment.new
        @seq_data.each_with_index do |x, i|
          aln.store(@seq_info[i]['Name'], x)
        end
        @align = aln
      end
      private :do_parse

      # returns Bio::Alignment object.
      def alignment
        do_parse
        @align
      end

      # gets seq data (used internally) (will be obsoleted)
      def seq_data
        do_parse
        @seq_data
      end

      # validates checksum
      def validate_checksum
        do_parse
        valid = true
        total = 0
        @seq_data.each_with_index do |x, i|
          sum = Bio::GCG::Seq.calc_checksum(x)
          if sum != @seq_info[i]['Check'].to_i
            valid = false
            break
          end
          total += sum
        end
        return false unless valid
        if @checksum != 0 # "Check:" field of BioPerl is always 0
          valid = ((total % 10000) == @checksum)
        end
        valid
      end

    end #class Msf
  end #module GCG
end # module Bio
