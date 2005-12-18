#
# = bio/appl/clustalw/report.rb - CLUSTAL W format data (*.aln) class
#
# Copyright:: Copyright (C) 2003 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
# License::   LGPL
#
#--
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#++
#
#  $Id: report.rb,v 1.9 2005/12/18 15:58:40 k Exp $
#
# Bio::ClustalW::Report is a CLUSTAL W report (*.aln file) parser.
# CLUSTAL W is a very popular software for multiple sequence alignment.
#
# == References
#
# * Thompson,J.D., Higgins,D.G. and Gibson,T.J..
#   CLUSTAL W: improving the sensitivity of progressive multiple sequence
#   alignment through sequence weighting, position-specific gap penalties
#   and weight matrix choice. Nucleic Acids Research, 22:4673-4680, 1994.
#   http://nar.oxfordjournals.org/cgi/content/abstract/22/22/4673
# * http://www.ebi.ac.uk/clustalw/
# * ftp://ftp.ebi.ac.uk/pub/software/unix/clustalw/
#

require 'bio/sequence'
require 'bio/db'
require 'bio/alignment'
require 'bio/appl/clustalw'

module Bio
  class ClustalW

    # CLUSTAL W result data (*.aln file) parser class.
    class Report < Bio::DB

      # Delimiter of each entry. Bio::FlatFile uses it.
      # In Bio::ClustalW::Report, it it nil (1 entry 1 file).
      DELIMITER = nil

      # Creates new instance.
      # +str+ should be a CLUSTAL format string.
      # +seqclass+ should on of following:
      # * Class:  Bio::Sequence::AA, Bio::Sequence::NA, ...
      # * String: 'PROTEIN', 'DNA', ...
      def initialize(str, seqclass = nil)
        @raw = str
        @align = nil
        @match_line = nil
        @header = nil
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
      # string of whole result
      attr_reader :raw

      # sequence class (one of Bio::Sequence, Bio::Sequence::NA,
      # Bio::Sequence::AA, ...)
      attr_reader :seqclass

      # Shows first line of the result data, for example,
      # 'CLUSTAL W (1.82) multiple sequence alignment'.
      # Returns a string.
      def header
        @header or (do_parse or @header)
      end

      # Shows "match line" of CLUSTAL's alignment result, for example,
      # ':* :* .*   *       .*::*.   ** :* . *    .        '.
      # Returns a string.
      def match_line
        @match_line or (do_parse or @match_line)
      end

      # Gets an multiple alignment.
      # Returns a Bio::Alignment object.
      def align
        do_parse() unless @align
        @align
      end
      alias alignment align

      # Gets an fasta-format string of the sequences.
      # Returns a string.
      def to_fasta(*arg)
        align.to_fasta(*arg)
      end

      # Gets an array of the sequences.
      # Returns an array of Bio::FastaFormat objects.
      def to_a
        align.to_fastaformat_array
      end

      private
      # Parses Clustal W result text.
      def do_parse
        return nil if @align
        a = @raw.split(/\r?\n\r?\n/)
        @header = a.shift.to_s
        xalign = Bio::Alignment.new
        @match_line = ''
        if a.size > 0 then
          a[0].gsub!(/\A(\r?\n)+/, '')
          a.collect! { |x| x.split(/\r?\n/) }
          a.each { |x|
            x.each { |y| y.sub!(/ +\d+\s*$/, '') }} #for -SEQNOS=on option
          @tagsize = ( a[0][0].rindex(/\s/) or -1 ) + 1
          a.each do |x|
            @match_line << x.pop.to_s[@tagsize..-1]
          end
          a[0].each do |y|
            xalign.store(y[0, @tagsize].sub(/\s+\z/, ''), '')
          end
          a.each do |x|
            x.each do |y|
              name = y[0, @tagsize].sub(/\s+\z/, '')
              seq = y[@tagsize..-1]
              xalign[name] << seq
            end
          end
          xalign.collect! { |x| @seqclass.new(x) }
        end
        @align = xalign
        nil
      end

    end #class Report
  end #class ClustalW
end #module Bio

