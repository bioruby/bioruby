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
#  $Id: expression.rb,v 1.2 2001/11/08 07:06:04 katayama Exp $
#

require "bio/db"

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

      # private
    end

  end

end

