#
# = bio/db/gff.rb - GFF format class
#
# Copyright::  Copyright (C) 2003 KATAYAMA Toshiaki <k@bioruby.org>
# Licence::    LGPL
#
#  $Id: gff.rb,v 1.4 2005/11/07 13:19:17 nakao Exp $
#
# == Description
#
#
# == Example
# == References
# * http://www.sanger.ac.uk/Software/formats/GFF/
#
#--
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
#++
#

module Bio

  # = GFF
  class GFF

    # Returns
    attr_accessor :records

    #
    def initialize(str = '')
      @records = Array.new
      str.each_line do |line|
        @records << Record.new(line)
      end
    end

    # = GFF::Record
    class Record

      # Returns
      attr_accessor :seqname

      # Returns
      attr_accessor :source

      # Returns
      attr_accessor :feature

      # Returns
      attr_accessor :start

      # Returns
      attr_accessor :end

      # Returns
      attr_accessor :score

      # Returns
      attr_accessor :strand

      # Returns
      attr_accessor :frame

      # Returns
      attr_accessor :attributes

      # Returns
      attr_accessor :comments

      #
      def initialize(str)
        @comments = str.chomp[/#.*/]
        return if /^#/.match(str)
        @seqname, @source, @feature, @start, @end, @score, @strand, @frame,
          attributes, = str.chomp.split("\t")
        @attributes = parse_attributes(attributes) if attributes
      end

      private

      def parse_attributes(attributes)
        hash = Hash.new
        attributes.split(/[^\\];/).each do |atr|
          key, value = atr.split(' ', 2)
          hash[key] = value
        end
        return hash
      end
    end
  end

  # = GFF2
  class GFF2 < GFF

    #
    VERSION = 2
  end

  # = GFF3
  class GFF3 < GFF

    #
    VERSION = 3
  end

end


if __FILE__ == $0
  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  p Bio::GFF.new(ARGF.read)
end
