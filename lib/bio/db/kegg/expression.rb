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
#  $Id: expression.rb,v 1.7 2001/11/19 14:19:07 shuichi Exp $
#

require "bio/db"

module Bio

  class KEGG

    class Microarrays

      def initialize(ary)	# ary = [ Microarray, Microarray, ... ]
        @orf2val = Hash.new('')
        ary.each do |x|
          x.orf2val.each do |k, v|
            if !@orf2val.key?(k)
              @orf2val[k] = v
            else 
              @orf2val[k].concat(v)
            end
          end
        end
      end
      attr_reader :orf2val

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

      def control_avg
        sum = 0.0
        orf2val.values.each do |v|
          sum += v[0] - v[1]
        end
        sum/orf2val.size
      end

      def target_avg
        sum = 0.0
        orf2val.values.each do |v|
          sum += v[2] - v[3]
        end
        sum/orf2val.size
      end

      def control_var
        sum = 0.0
        avg = self.control_avg
        orf2val.values.each do |v|
          tmp = v[0] - v[1]
          sum += (tmp - avg)*(tmp - avg)
        end
        sum/orf2val.size
      end

      def target_var
        sum = 0.0
        avg = self.target_avg
        orf2val.values.each do |v|
          tmp = v[2] - v[3]
          sum += (tmp - avg)*(tmp - avg)
        end
        sum/orf2val.size
      end

      def control_sd
        var = self.control_var
        Math.sqrt(var)
      end

      def target_sd
        var = self.target_var
        Math.sqrt(var)
      end

      def up_regulate(num=20, threshold=nil)
        hash = logy_minus_logx
        ary = hash.to_a.sort{|a, b| b[1] <=> a[1]}
        if threshold != nil
          i = 0
          while ary[i][1] > threshold
            i += 1
          end
          return ary[0..i]
        else
          return ary[0..num-1]
        end
      end

      def down_regulate(num=20, threshold=nil)
        hash = logy_minus_logx
        ary = hash.to_a.sort{|a, b| a[1] <=> b[1]}
        if threshold != nil
          i = 0
          while ary[i][1] < threshold
            i += 1
          end
          return ary[0..i]
        else
          return ary[0..num-1]
        end
      end

      def logy_minus_logx
        hash = Hash.new('')
        orf2val.each do |k, v|
          hash[k] = Math.log10(v[2] - v[3]) - Math.log10(v[0] - v[1])
        end
        hash
      end

      # private
    end

  end

end
