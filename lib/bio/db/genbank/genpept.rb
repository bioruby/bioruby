#
# bio/db/genpept.rb - GenPept database class
#
#   Copyright (C) 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: genpept.rb,v 1.1 2002/07/30 10:13:34 k Exp $
#

require 'bio/db/genbank'

module Bio

  class GenPept < GenBank

    # LOCUS
    class Locus
      def initialize(locus_line)
	@entry_id = locus_line[12..27].strip
	@seq_len  = locus_line[29..39].to_i
	@circular = locus_line[55..62].strip	# always linear
	@division = locus_line[63..66].strip
	@date     = locus_line[68..78].strip
      end
    end

    alias :aalen :nalen
    undef :nalen, :strand, :natype, :each_cds, :each_gene, :basecount, :gc

    # ORIGIN
    def origin
      unless @data['ORIGIN']
        ori = get('ORIGIN')[/.*/]			# 1st line
        seq = get('ORIGIN').sub(/.*/, '')		# sequence lines
        @data['ORIGIN']   = truncate(tag_cut(ori))
        @data['SEQUENCE'] = Sequence::AA.new(seq.tr('^a-z', ''))
      end
      @data['ORIGIN']
    end
    alias :aaseq :naseq
    undef :naseq
    alias :seq :aaseq

    # DBSOURCE
    def dbsource
      get('DBSOURCE')
    end

  end

end
