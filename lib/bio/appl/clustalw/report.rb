#
# bio/appl/clustalw/report.rb - CLUSTAL W format data (*.aln) class
#
#   Copyright (C) 2003 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
#
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
#
#  $Id: report.rb,v 1.4 2005/03/04 04:48:41 k Exp $
#

require 'bio/sequence'
require 'bio/db'
require 'bio/alignment'
require 'bio/appl/clustalw'

module Bio
  class ClustalW
    class Report < Bio::DB
      DELIMITER = nil

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
      attr_reader :raw
      attr_reader :seqclass

      def header
	@header or (do_parse or @header)
      end

      def match_line
	@match_line or (do_parse or @match_line)
      end

      def align
	do_parse() unless @align
	@align
      end
      alias :alignment :align

      def to_fasta(*arg)
	align.to_fasta(*arg)
      end

      def to_a
	align.to_fastaformat_array
      end

      private
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

=begin

= Bio::ClustalW::Report

 CLUSTAL W result data (*.aln file) parser class.

--- Bio::ClustalW::Report.new(raw, seqclass = nil)

    Creates new instance.
    'raw' should be a string of CLUSTAL format data.
    'seqclass' should on of following:
      Class:  Bio::Sequence::AA, Bio::Sequence::NA, ...
      String: 'PROTEIN', 'DNA', ...

--- Bio::ClustalW::Report#raw
--- Bio::ClustalW::Report#seqclass

    Acess methods of variables given in Bio::ClustalW::Report.new method.

--- Bio::ClustalW::Report#alginment
--- Bio::ClustalW::Report#algin

    Gets an multiple alignment.
    Returns an instance of Bio::Alignment class.

--- Bio::ClustalW::Report#to_a

    Gets an array of the sequences.
    Returns an array of Bio::FastaFormat instances.

--- Bio::ClustalW::Report#to_fasta

    Gets an fasta-format string of the sequences.
    Returns a string.

--- Bio::ClustalW::Report#header

    Shows first line of the result data, for example,
        'CLUSTAL W (1.82) multiple sequence alignment'.
    Returns a string.

--- Bio::ClustalW::Report#match_line

    Shows "match line" of CLUSTAL's alignment result, for example,
        ':* :* .*   *       .*::*.   ** :* . *    .        '.
    Returns a string.

=end
