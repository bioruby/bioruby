#
# bio/db/kegg/compound.rb - KEGG/COMPOUND database class
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: compound.rb,v 0.6 2002/08/19 02:01:47 k Exp $
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
	field_fetch('ENTRY')
      end

      # NAME
      def names
	unless @data['NAME']
	  @data['NAME'] = get('NAME').split("\n").map{ |l| tag_cut(l) }
	end
	@data['NAME']
      end
      def name
	names[0]
      end

      # FORMULA
      def formula
	field_fetch('FORMULA')
      end

      # REACTION
      def reactions
	unless @data['REACTION']
	  @data['REACTION'] = fetch('REACTION').split("\s+")
	end
	@data['REACTION']
      end

      # PATHWAY
      def pathways
	unless @data['PATHWAY']
	  @data['PATHWAY'] = get('PATHWAY').split("\n").map{ |l| tag_cut(l) }
	end
	@data['PATHWAY']
      end

      # ENZYME
      def enzymes
	unless @data['ENZYME']
	  @data['ENZYME'] = fetch('ENZYME').scan(/\S+ \(\S+\)/)
	end
	@data['ENZYME']
      end

      # DBLINKS
      def dblinks
	unless @data['DBLINKS']
	  @data['DBLINKS'] = get('DBLINKS').split("\n").map{ |l| tag_cut(l) }
	end
	@data['DBLINKS']
      end

    end

  end

end

