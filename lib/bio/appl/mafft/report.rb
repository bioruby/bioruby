#
# bio/appl/mafft/report.rb - MAFFT report class
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
#  $Id: report.rb,v 1.1 2003/07/25 07:51:47 ng Exp $
#

require 'bio/db/fasta'
require 'bio/io/flatfile'
require 'bio/appl/alignfactory'
require 'bio/appl/mafft'

module Bio
  class MAFFT < AlignFactory
    class Report

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
      attr_reader :data
      attr_reader :seqclass

      def align
	do_parse() unless @align
	@align
      end
      alias :alignment :align

      def to_fasta(*arg)
	align.to_fasta(*arg)
      end

      def to_a
	@data
      end

      private
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

