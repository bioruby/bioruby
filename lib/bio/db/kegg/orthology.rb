#
# bio/db/kegg/ko.rb - KO (KEGG Orthology) database class
#
#   Copyright (C) 2003 KATAYAMA Toshiaki <k@bioruby.org>
#   Copyright (C) 2003 Masumi Itoh <m@bioruby.org>
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
#  $Id: orthology.rb,v 1.2 2003/08/21 05:01:45 k Exp $
#

require 'bio/db'

module Bio

  class KEGG
    
    class KO < KEGGDB
      
      DELIMITER	= RS = "\n///\n"
      TAGSIZE	= 12

      def initialize(entry)
	super(entry, TAGSIZE)
      end
      
      
      def entry_id
	field_fetch('ENTRY')[/\S+/]
      end
      
      def name
	field_fetch('NAME')
      end
      
      def names
	name.split(', ')
      end
      
      def definition
	field_fetch('DEFINITION')
      end
      
      def keggclass
	field_fetch('CLASS')
      end

      def keggclasses
	keggclass.gsub(/ \[[^\]]+/, '').split(/\] ?/)
      end
      
      def pathways
	keggclass.scan(/\[PATH:(.*?)\]/).flatten
      end
      
      def dblinks
	unless @data['DBLINKS']
	  hash = {}
	  get('DBLINKS').scan(/(\S+):\s*(.*)\n/).each do |k, v|
	    hash[k] = v.split(/\s+/)
	  end
	  @data['DBLINKS'] = hash
	end
	@data['DBLINKS']		# Hash of DB:ID in DBLINKS
      end
      
      def genes
	unless @data['GENES']
	  hash = {}
	  k = ''
	  get('GENES').each_line do |line|
	    line.chomp!
	    line[0, @tagsize] = '' 
	    if line =~ /(\S+):/
	      k = $1
	      hash[k] = []
	    end
	    line[0, 5] = ''
	    line.gsub(/\(\S+/, '').each(' ') do |u|
	      hash[k] << u
	    end
	  end
	  @data['GENES'] = hash
        end
	@data['GENES']		# Hash of DB:ID in DBLINKS
      end
      
    end
    
  end
  
end



if __FILE__ == $0

  require 'bio/io/fetch'

  flat = Bio::Fetch.query('ko', 'K00001')
  entry = Bio::KEGG::KO.new(flat)

  p entry.entry_id
  p entry.name
  p entry.names
  p entry.definition
  p entry.keggclass
  p entry.keggclasses
  p entry.pathways
  p entry.dblinks
  p entry.genes

end


=begin

= Bio::KEGG::KO

KO (KEGG Orthology) entry parser.

* ((<URL:http://www.genome.ad.jp/dbget-bin/get_htext?KO>))
* ((<URL:ftp://ftp.genome.ad.jp/pub/kegg/tarfiles/ko>))

--- Bio::KEGG::KO.new(entry)

Reads a flat file format entry of the KO database.

--- Bio::KEGG::KO#entry_id -> String

Returns ID of the entry.

--- Bio::KEGG::KO#name -> String

Returns NAME field of the entry.

--- Bio::KEGG::KO#names -> Array

Returns an Array of names in NAME field.

--- Bio::KEGG::KO#definition -> String

Returns DEFINITION field of the entry.

--- Bio::KEGG::KO#keggclass

Returns CLASS field of the entry.

--- Bio::KEGG::KO#keggclasses

Returns an Array of biological classes in CLASS field.

--- Bio::KEGG::KO#pathways

Returns an Array of KEGG/PATHWAY ID in CLASS field.

--- Bio::KEGG::KO#dblinks

Returns a Hash of Array of the database name and entry IDs in DBLINKS field.

--- Bio::KEGG::KO#genes

Returns a Hash of Array of the organism ID and entry IDs in GENES field.

=end

