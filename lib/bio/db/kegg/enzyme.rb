#
# bio/db/kegg/enzyme.rb - KEGG/ENZYME database class
#
#   Copyright (C) 2001, 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: enzyme.rb,v 0.8 2005/09/08 01:22:11 k Exp $
#

require 'bio/db'

module Bio

  class KEGG

    class ENZYME < KEGGDB

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
        lines_fetch('NAME')
      end
      def name
        names[0]
      end

      # CLASS
      def classes
        lines_fetch('CLASS')
      end

      # SYSNAME
      def sysname
        field_fetch('SYSNAME')
      end

      # REACTION ';'
      def reaction
        field_fetch('REACTION')
      end
      
      # SUBSTRATE
      def substrates
        lines_fetch('SUBSTRATE')
      end

      # PRODUCT
      def products
        lines_fetch('PRODUCT')
      end

      # COFACTOR
      def cofactors
        lines_fetch('COFACTOR')
      end

      # COMMENT
      def comment
        field_fetch('COMMENT')
      end

      # PATHWAY
      def pathways
        lines_fetch('PATHWAY')
      end

      # GENES
      def genes
        lines_fetch('GENES')
      end

      # DISEASE
      def diseases
        lines_fetch('DISEASE')
      end

      # MOTIF
      def motifs
        lines_fetch('MOTIF')
      end

      # STRUCTURES
      def structures
        unless @data['STRUCTURES']
          @data['STRUCTURES'] =
            fetch('STRUCTURES').sub(/(PDB: )*/,'').split(/\s+/)
        end
        @data['STRUCTURES']
      end

      # DBLINKS
      def dblinks
        lines_fetch('DBLINKS')
      end

    end

  end

end

