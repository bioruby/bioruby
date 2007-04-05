#
# = bio/appl/mafft/report.rb - MAFFT report class
#
# Copyright:: Copyright (C) 2003 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
# License::   The Ruby License
#
#  $Id: report.rb,v 1.12 2007/04/05 23:35:40 trevor Exp $
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

require 'stringio'
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
      # +str+ should be multi-fasta formatted text as a string.
      # +seqclass+ should on of following:
      # Class:  Bio::Sequence::AA, Bio::Sequence::NA, ...
      # String: 'PROTEIN', 'DNA', ...
      #
      # Compatibility Note: the old usage (to get array of Bio::FastaFormat
      # objects) is deprecated.
      def initialize(str, seqclass = nil)
        if str.is_a?(Array) then
          warn "Array of Bio::FastaFormat objects will be no longer accepted."
          @data = str
        else
          ff = Bio::FlatFile.new(Bio::FastaFormat, StringIO.new(str))
          @data = ff.to_a
        end
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

