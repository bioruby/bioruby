#
# bio/db/kegg/compound.rb - KEGG COMPOUND database class
#
#   Copyright (C) 2001, 2002, 2004 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: compound.rb,v 0.11 2005/09/08 01:22:11 k Exp $
#

require 'bio/db'

module Bio

  class KEGG

    class COMPOUND < KEGGDB

      DELIMITER	= RS = "\n///\n"
      TAGSIZE	= 12

      def initialize(entry)
        super(entry, TAGSIZE)
      end

      # ENTRY
      def entry_id
        unless @data['ENTRY']
          @data['ENTRY'] = fetch('ENTRY').split(/\s+/).first
        end
        @data['ENTRY']
      end

      # NAME
      def names
        lines_fetch('NAME') 
      end
      def name
        names[0]
      end

      # FORMULA
      def formula
        field_fetch('FORMULA')
      end

      # MASS
      def mass
        field_fetch('MASS').to_f
      end

      # REACTION
      def reactions
        unless @data['REACTION']
          @data['REACTION'] = fetch('REACTION').split(/\s+/)
        end
        @data['REACTION']
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
          field = fetch('ENZYME')
          if /\(/.match(field)	# old version
            @data['ENZYME'] = field.scan(/\S+ \(\S+\)/)
          else
            @data['ENZYME'] = field.scan(/\S+/)
          end
        end
        @data['ENZYME']
      end

      # DBLINKS
      def dblinks
        lines_fetch('DBLINKS')
      end

      # ATOM, BOND
      def kcf
        return "#{get('ATOM')}#{get('BOND')}"
      end

    end

  end

end


if __FILE__ == $0
  entry = ARGF.read
  cpd = Bio::KEGG::COMPOUND.new(entry)
  p cpd.entry_id
  p cpd.names
  p cpd.name
  p cpd.formula
  p cpd.mass
  p cpd.reactions
  p cpd.rpairs
  p cpd.pathways
  p cpd.enzymes
  p cpd.dblinks
  p cpd.kcf
end

