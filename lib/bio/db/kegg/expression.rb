#
# bio/db/kegg/microarray.rb - KEGG/Microarray database class
#
#   Copyright (C) 2001 KAWASHIMA Shuichi <s@bioruby.org>
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
#  $Id: expression.rb,v 1.3 2001/11/08 09:55:37 shuichi Exp $
#

require "bio/db"
include Math

module Bio

  class KEGG

    class Microarrays
      def initialize(ary)	# ary = [ Microarray, Microarray, ... ]
      end
    end

    class Microarray

      def initialize(entry)
        @orf2val = Hash.new('')
        entry.split("\n").each do |line|
          unless /^#/ =~ line
            ary = line.split("\t")
            orf = ary.shift
            val = ary[2, 4].collect {|x| x.to_f}
            @orf2val[orf] = val 
          end
        end
      end
      attr_reader :orf2val

      def up_regulate(num=20)
        hash = logy_minus_logx
        ary = hash.to_a.sort{|a, b| b[1] <=> a[1]}
        ary[0..num]
      end

      def down_regulate(num=20)
        hash = logy_minus_logx
        ary = hash.to_a.sort{|a, b| a[1] <=> b[1]}
        ary[0..num]
      end

      def logy_minus_logx
        hash = Hash.new('')
        orf2val.each do |k, v|
          hash[k] = log10(v[2] - v[3]) - log10(v[0] - v[1])
        end
        hash
      end

      # private
    end

  end

end

