#
# bio/db/kegg/glycan.rb - KEGG GLYCAN database class
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
#  $Id: glycan.rb,v 1.2 2005/09/08 01:22:11 k Exp $
#

require 'bio/db'

module Bio

  class KEGG

    class GLYCAN < KEGGDB

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
      def name
        field_fetch('NAME') 
      end

      # COMPOSITION
      def composition
        unless @data['COMPOSITION']
          hash = Hash.new(0)
          fetch('COMPOSITION').scan(/\((\S+)\)(\d+)/).each do |key, val|
            hash[key] = val.to_i
          end
          @data['COMPOSITION'] = hash
        end
        @data['COMPOSITION']
      end

      # MASS
      def mass
        unless @data['MASS']
          hash = Hash.new
          fetch('MASS').scan(/(\S+)\s+\((\S+)\)/).each do |val, key|
            hash[key] = val.to_f
          end
          @data['MASS'] = hash
        end
        @data['MASS']
      end

      # CLASS
      def keggclass
        field_fetch('CLASS') 
      end

      # BINDING
      def bindings
        unless @data['BINDING']
          ary = Array.new
          lines = lines_fetch('BINDING')
          lines.each do |line|
            if /^\S/.match(line)
              ary << line
            else
              ary.last << " #{line.strip}"
            end
          end
          @data['BINDING'] = ary
        end
        @data['BINDING']
      end

      # COMPOUND
      def compounds
        unless @data['COMPOUND']
          @data['COMPOUND'] = fetch('COMPOUND').split(/\s+/)
        end
        @data['COMPOUND']
      end

      # REACTION
      def reactions
        unless @data['REACTION']
          @data['REACTION'] = fetch('REACTION').split(/\s+/)
        end
        @data['REACTION']
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

      # ORTHOLOG
      def orthologs
        unless @data['ORTHOLOG']
          ary = Array.new
          lines = lines_fetch('ORTHOLOG')
          lines.each do |line|
            if /^\S/.match(line)
              ary << line
            else
              ary.last << " #{line.strip}"
            end
          end
          @data['ORTHOLOG'] = ary
        end
        @data['ORTHOLOG']
      end

      # REFERENCE
      def references
        unless @data['REFERENCE']
          ary = Array.new
          lines = lines_fetch('REFERENCE')
          lines.each do |line|
            if /^\d+\s+\[PMID/.match(line)
              ary << line
            else
              ary.last << " #{line.strip}"
            end
          end
          @data['REFERENCE'] = ary
        end
        @data['REFERENCE']
      end

      # DBLINKS
      def dblinks
        unless @data['DBLINKS']
          ary = Array.new
          lines = lines_fetch('DBLINKS')
          lines.each do |line|
            if /^\S/.match(line)
              ary << line
            else
              ary.last << " #{line.strip}"
            end
          end
          @data['DBLINKS'] = ary
        end
        @data['DBLINKS']
      end

      # ATOM, BOND
      def kcf
        return "#{get('NODE')}#{get('EDGE')}"
      end

    end

  end

end


if __FILE__ == $0
  entry = ARGF.read	# gl:G00024
  gl = Bio::KEGG::GLYCAN.new(entry)
  p gl.entry_id
  p gl.name
  p gl.composition
  p gl.mass
  p gl.keggclass
  p gl.bindings
  p gl.compounds
  p gl.reactions
  p gl.pathways
  p gl.enzymes
  p gl.orthologs
  p gl.references
  p gl.dblinks
  p gl.kcf
end


