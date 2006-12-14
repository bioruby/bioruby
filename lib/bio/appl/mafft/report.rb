#
# = bio/appl/mafft/report.rb - MAFFT report class
#
# Copyright:: Copyright (C) 2003 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
# License::   Ruby's
#
#  $Id: report.rb,v 1.10 2006/12/14 15:22:05 ngoto Exp $
#
# MAFFT result parser class.
# MAFFT is a very fast multiple sequence alignment software.
#
# Since a result of MAFFT is simply a multiple-fasta format,
# the significance of this class is to keep standard form and
# interface between Bio::ClustalW::Report.
#
# == References
#
# * K. Katoh, K. Misawa, K. Kuma and T. Miyata.
#   MAFFT: a novel method for rapid multiple sequence alignment based
#   on fast Fourier transform. Nucleic Acids Res. 30: 3059-3066, 2002.
#   http://nar.oupjournals.org/cgi/content/abstract/30/14/3059
# * http://www.biophys.kyoto-u.ac.jp/~katoh/programs/align/mafft/
#

require 'bio/db/fasta'
require 'bio/io/flatfile'
require 'bio/appl/mafft'

module Bio
  class MAFFT

    # MAFFT result parser class.
    # MAFFT is a very fast multiple sequence alignment software.
    #
    # Since a result of MAFFT is simply a multiple-fasta format,
    # the significance of this class is to keep standard form and
    # interface between Bio::ClustalW::Report.
    class Report

      # Creates a new Report object.
      # +ary+ should be an Array of Bio::FastaFormat.
      # +seqclass+ should on of following:
      # Class:  Bio::Sequence::AA, Bio::Sequence::NA, ...
      # String: 'PROTEIN', 'DNA', ...
      def initialize(ary, seqclass = nil)
        @data = ary
        @align = nil
        case seqclass
        when /PROTEIN/i
          @seqclass = Bio::Sequence::AA
        when /[DR]NA/i
          @seqclass = Bio::Sequence::NA
        else
          if seqclass.is_a?(Module) then
            @seqclass = seqclass
          else
            @seqclass = Bio::Sequence
          end
        end
      end

      # sequence data. Returns an array of Bio::FastaFormat.
      attr_reader :data

      # Sequence class (Bio::Sequence::AA, Bio::Sequence::NA, ...)
      attr_reader :seqclass

      # Gets an multiple alignment.
      # Returns a Bio::Alignment object.
      def alignment
        do_parse() unless @align
        @align
      end

      # This will be deprecated. Instead, please use alignment.
      #
      # Gets an multiple alignment.
      # Returns a Bio::Alignment object.
      def align
        warn "align method will be deprecated. Please use \'alignment\'."
        alignment
      end

      # Gets an fasta-format string of the sequences.
      # Returns a string.
      # Same as align.to_fasta.
      # Please refer to Bio::Alignment#to_fasta for arguments.
      def to_fasta(*arg)
        alignment.to_fasta(*arg)
      end

      # Gets an array of the sequences.
      # Returns an array of Bio::FastaFormat instances.
      def to_a
        @data
      end

      private
      # Parsing a result.
      def do_parse
        return nil if @align
        @align = Bio::Alignment.new(@data) do |x|
          [ @seqclass.new(x.seq), x.definition ]
        end
        nil
      end

    end #class Report
  end #class MAFFT
end #module Bio

