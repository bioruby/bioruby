#
# = bio/appl/mafft/report.rb - MAFFT report class
#
# Copyright:: Copyright (C) 2003, 2007  Naohisa Goto <ng@bioruby.org>
# License::   The Ruby License
#
#  $Id: report.rb,v 1.13 2007/07/16 12:21:39 ngoto Exp $
#
# MAFFT result parser class.
# MAFFT is a very fast multiple sequence alignment software.
#
# Since a result of MAFFT is simply a multiple-fasta format,
# the significance of this class is to keep standard form and
# interface between Bio::ClustalW::Report.
#
# Bio::Alignment::MultiFastaFormat is a generic data class for
# fasta-formatted multiple sequence alignment data.
# Bio::MAFFT::Report inherits Bio::Alignment::MultiFastaFormat.
#
# == References
#
# * K. Katoh, K. Misawa, K. Kuma and T. Miyata.
#   MAFFT: a novel method for rapid multiple sequence alignment based
#   on fast Fourier transform. Nucleic Acids Res. 30: 3059-3066, 2002.
#   http://nar.oupjournals.org/cgi/content/abstract/30/14/3059
# * http://www.biophys.kyoto-u.ac.jp/~katoh/programs/align/mafft/
#

require 'stringio'
require 'bio/db/fasta'
require 'bio/io/flatfile'
require 'bio/alignment'
require 'bio/appl/mafft'

module Bio
  module Alignment
    # Data class for fasta-formatted multiple sequence alignment data,
    # which is simply multiple entiries of fasta formatted sequences.
    class MultiFastaFormat

      # delimiter for flatfile
      DELIMITER = RS = nil

      # Creates a new data object.
      # +str+ should be a (multi-)fasta formatted string.
      def initialize(str)
        ff = Bio::FlatFile.new(Bio::FastaFormat, StringIO.new(str))
        @data = ff.to_a
        @alignment = nil
        @seq_method = nil
      end

      # Gets an multiple alignment.
      # Returns a Bio::Alignment object.
      # +method+ should be one of :naseq, :aaseq, :seq, or nil (default).
      # nil means to automatically determine nucleotide or amino acid.
      #
      # This method returns previously parsed object
      # if the same method is given (or guessed method is the same).
      def alignment(method = nil)
        m = determine_seq_method(@data, method)
        if !@alignment or m != @seq_method then
          @seq_method = m
          @alignment = do_parse(@data, @seq_method)
        end
        @alignment
      end

      # Gets an array of the fasta formatted sequence objects.
      # Returns an array of Bio::FastaFormat objects.
      def entries
        @data
      end

      private
      # determines seqtype.
      # if nil is given, try to guess DNA or protein.
      def determine_seq_method(data, m = nil)
        case m
        when :aaseq
          :aaseq
        when :naseq
          :naseq
        when :seq
          :seq
        when nil
          # auto-detection
          score = 0
          data[0, 3].each do |e|
            k = e.to_seq.guess
            if k == Bio::Sequence::NA then
              score += 1
            elsif k == Bio::Sequence::AA then
              score -= 1
            end
          end
          if score > 0 then
            :naseq
          elsif score < 0 then
            :aaseq
          else
            :seq
          end
        else
          raise 'one of :naseq, :aaseq, :seq, or nil should be given'
        end
      end

      # Parses a result.
      def do_parse(ary, seqmethod)
        a = Bio::Alignment.new
        a.add_sequences(ary) do |x|
          [ x.__send__(seqmethod), x.definition ]
        end
        a
      end
    end #class MultiFastaFormat
  end #module Alignment

  class MAFFT

    # MAFFT result parser class.
    # MAFFT is a very fast multiple sequence alignment software.
    #
    # Since a result of MAFFT is simply a multiple-fasta format,
    # the significance of this class is to keep standard form and
    # interface between Bio::ClustalW::Report.
    class Report < Bio::Alignment::MultiFastaFormat

      # Creates a new Report object.
      # +str+ should be multi-fasta formatted text as a string.
      #
      # Compatibility Note: the old usage (to get array of Bio::FastaFormat
      # objects) is deprecated.
      #
      # Compatibility Note 2: the argument +seqclass+ is deprecated.
      #
      # +seqclass+ should be one of following:
      # Class:  Bio::Sequence::AA, Bio::Sequence::NA, ...
      # String: 'PROTEIN', 'DNA', ...
      #
      def initialize(str, seqclass = nil)
        if str.is_a?(Array) then
          warn "Array of Bio::FastaFormat objects will be no longer accepted."
          @data = str
        else
          super(str)
        end

        if seqclass then
          warn "the 2nd argument (seqclass) will be no deprecated."
          case seqclass
          when /PROTEIN/i
            @seqclass = Bio::Sequence::AA
          when /[DR]NA/i
            @seqclass = Bio::Sequence::NA
          else
            if seqclass.is_a?(Module) then
              @seqclass = seqclass
            else
              @seqclass = nil
            end
          end
        end
      end

      # sequence data. Returns an array of Bio::FastaFormat.
      attr_reader :data

      # Sequence class (Bio::Sequence::AA, Bio::Sequence::NA, ...)
      #
      # Compatibility note: This method will be removed in the tufure.
      attr_reader :seqclass

      # Gets an multiple alignment.
      # Returns a Bio::Alignment object.
      def alignment(method = nil)
        super
      end

      # This method will be deprecated. Instead, please use alignment.
      #
      # Gets an multiple alignment.
      # Returns a Bio::Alignment object.
      def align
        warn "Bio::MAFFT::Report#align is deprecated. Please use \'alignment\'."
        alignment
      end

      # This will be deprecated. Instead, please use alignment.output_fasta.
      #
      # Gets an fasta-format string of the sequences.
      # Returns a string.
      # Same as align.to_fasta.
      # Please refer to Bio::Alignment#output_fasta for arguments.
      def to_fasta(*arg)
        warn "Bio::MAFFT::report#to_fasta is deprecated. Please use \'alignment.output_fasta\'"
        alignment.output_fasta(*arg)
      end

      # Compatibility note: Behavior of the method will be changed
      # in the future.
      #
      # Gets an array of the sequences.
      # Returns an array of Bio::FastaFormat instances.
      def to_a
        @data
      end

      private
      # Parsing a result.
      def do_parse(ary, seqmethod)
        if @seqclass then
          a = Bio::Alignment.new
          a.add_sequences(ary) do |x|
            [ @seqclass.new(x.seq), x.definition ]
          end
        else
          super(ary, seqmethod)
        end
      end

    end #class Report
  end #class MAFFT
end #module Bio

