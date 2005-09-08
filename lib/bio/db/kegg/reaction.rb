#
# bio/db/kegg/reaction.rb - KEGG REACTION database class
#
#   Copyright (C) 2004 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: reaction.rb,v 1.3 2005/09/08 01:22:11 k Exp $
#

require 'bio/db'

module Bio

  class KEGG

    class REACTION < KEGGDB

      DELIMITER	= RS = "\n///\n"
      TAGSIZE	= 12

      def initialize(entry)
        super(entry, TAGSIZE)
      end

      # ENTRY
      def entry_id
        field_fetch('ENTRY')
      end

      # NAME
      def name
        field_fetch('NAME') 
      end

      # DEFINITION
      def definition
        field_fetch('DEFINITION')
      end

      # EQUATION
      def equation
        field_fetch('EQUATION')
      end

      # RPAIR
      def rpairs
        unless @data['RPAIR']
          @data['RPAIR'] = fetch('RPAIR').split(/\s+/)
        end
        @data['RPAIR']
      end

      # PATHWAY
      def pathways
        lines_fetch('PATHWAY') 
      end

      # ENZYME
      def enzymes
        unless @data['ENZYME']
          @data['ENZYME'] = fetch('ENZYME').scan(/\S+/)
        end
        @data['ENZYME']
      end

    end

  end

end


if __FILE__ == $0
  entry = ARGF.read
  rn = Bio::KEGG::REACTION.new(entry)
  p rn.entry_id
  p rn.name
  p rn.definition
  p rn.equation
  p rn.rpairs
  p rn.pathways
  p rn.enzymes
end

