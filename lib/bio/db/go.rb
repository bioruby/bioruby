#
# bio/db/go.rb - Classes for Gene Ontology
#
#   Copyright (C) 2003 Mitsuteru C. Nakao <n@bioruby.org>
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
#  $Id: go.rb,v 1.5 2004/11/05 08:10:33 nakao Exp $
#

require 'bio/pathway'

module Bio

# Bio::GO
class GO

  # Bio::GO::Ontology - Class for a DAG Edit format of Gene Ontology.
  class Ontology < Bio::Pathway

    # Bio::GO::Ontology.parse_ogids(line)
    # Parsing GOID line in the DAGEdit format  
    # GO:ID[ ; GO:ID...]
    def self.parse_goids(line)
      goids = []
      loop {
        if /^ *[$%<]\S.+?;/ =~ line
          endpoint = line.index(';') + 1
          line = line[endpoint..line.size]
        elsif /^,* GO:(\d{7}),*/ =~ line
          goids << $1.clone
          endpoint = line.index(goids.last) + goids.last.size
          line = line[endpoint..line.size]
        else
          break
        end
      }
      return goids
    end


    attr_reader :header_lines
    attr_reader :id2term
    attr_reader :id2id


    # Bio::GO::Ontology.new(str)
    def initialize(str)
      @id2term      = {}
      @header_lines = {}
      @id2id        = {}
      adj_list = dag_edit_format_parser(str)
      super(adj_list)
    end

	
    # Bio::GO::Ontology.goid2term(goid)
    def goid2term(goid)
      term = id2term[goid]
      term = id2term[id2id[goid]] if term == nil
      return term
    end

      private

    # constructing adjaency list for the given ontology
    def dag_edit_format_parser(str)
      stack    = []
      adj_list = []
      
      str.each {|line|
        if /^!(.+?):\s+(\S.+)$/ =~ line  # Parsing head lines
          tag   = $1
          value = $2
          tag.gsub!(/-/,'_')
          next if tag == 'type'
          instance_eval("@header_lines['#{tag}'] = '#{value}'")
          next
        end
        
        case line
        when /^( *)([$<%])(.+?) ; GO:(\d{7})(\n*)/ # GO Term ; GO:ID
          depth = $1.length.to_i
          rel   = $2
          term  = $3
          goid1 = goid = $4
          en    = $5
          goids = parse_goids(line)   # GO:ID[ ; GO:ID...]
          synonyms = parse_synonyms(line)  # synonym:Term[ ; synonym:Term...]
          stack[depth]   = goids.first
          @id2term[goid] = term
          
          next if depth == 0

          goids.each {|goid|
            @id2term[goid] = term
            @id2id[goid]   = goids.first
            adj_list << Bio::Relation.new(stack[depth - 1], goid, rel)
          }
	    
          if en == ""
            loop {
              case line
              when /^\n$/
                break
              when /^ *([<%]) (.+?) ; GO:(\d{7})/ # <%GO Term ; GO:ID
                rel1  = $1
                term1 = $2
                goid1 = $3
                goids1 = parse_goids(line)
                synonyms1 = parse_synonyms(line)
                
                @id2term[goid1] = term1
                goids.each {|goid|
                  adj_list << Bio::Relation.new(goid1, goid, rel1)
                }
              else
                break
              end
            }
          end
        end
      }
      return adj_list
    end


    # Bio::GO::Ontology#parse_goids(line)
    def parse_goids(line)
      Ontology.parse_goids(line)
    end

    # Bio::GO::Ontology#parse_synonyms(line)
    def parse_synonyms(line)
      synonyms = []
      loop {
        if / ; synonym:(\S.+?) *[;<%\n]/ =~ line
          synonyms << $1.clone
          endpoint = line.index(synonyms.last) + synonyms.last.size
          line = line[endpoint..line.size]
        else
          break
        end
      }
      return synonyms
    end

  end # class Ontology


  # Bio::GO::GeneAssociation
  # $CVSROOT/go/gene-associations/gene_association.*
  class GeneAssociation # < Bio::DB

    DELIMITER = RS = "\n"

    # Bio::GO::GeneAssociation.parser(str)
    # gene_association.* file parser
    def self.parser(str)
      if block_given?
        str.each(DELIMITER) {|line|
          next if /^!/ =~ line
          yield GeneAssociation.new(line)
        }
      else
        galist = []
        str.each(DELIMITER) {|line|
          next if /^!/ =~ line
          galist << GeneAssociation.new(line)
        }
        return galist
      end
    end


    attr_reader :db, :db_object_id, :db_object_symbol,
       :qualifier, :db_reference, :evidence, :with, :aspect, 
       :db_object_name, :db_object_synonym, :db_object_type, 
       :taxon, :date, :assigned_by 
    alias :entry_id :db_object_id


    # Bio::GO::GeneAssociation.new(entry)
    def initialize(entry) 
      tmp = entry.chomp.split(/\t/)
      @db                = tmp[0] 
      @db_object_id      = tmp[1]
      @db_object_symbol  = tmp[2]
      @qualifier         = tmp[3]  # 
      @goid              = tmp[4]
      @db_reference      = tmp[5]
      @evidence          = tmp[6]
      @with              = tmp[7]  # 
      @aspect            = tmp[8]
      @db_object_name    = tmp[9]  #
      @db_object_synonym = tmp[10] #
      @db_object_type    = tmp[11]
      @taxon             = tmp[12] # taxon:4932
      @date              = tmp[13] # 20010118
      @assigned_by       = tmp[14] 
    end

    # Bio::GO::GeneAssociation.goid
    def goid(org = nil)
      if org
        @goid
      else
        @goid.sub('GO:','')
      end
    end

  end # class GeneAssociation   
  
end # class GO

end # module Bio



if __FILE__ == $0

  require 'net/http'

  def wget(url)
    if /http:\/\/(.+?)\// =~ url
      host = $1
      path = url[(url.index(host) + host.size)..url.size]
    else
      raise ArgumentError, "Invalid URL\n#{url}"
    end

    result, = Net::HTTP.new(host).get(path)
    result.body
  end



  go_c_url = 'http://www.geneontology.org/ontology/component.ontology'
  ga_url = 'http://www.geneontology.org/gene-associations/gene_association.sgd'



  puts "\n #==> Bio::GO::Ontology"
  p go_c_url
  component_ontology = wget(go_c_url)
  comp = Bio::GO::Ontology.new(component_ontology)

  [['0003673', '0005632'],
    ['0003673', '0005619'],
    ['0003673', '0004649']].each {|pair|
    puts
    p pair
    p [:pair, pair.map {|i| [comp.id2term[i], comp.goid2term(i)] }]
    puts "\n #==> comp.bfs_shortest_path(pair[0], pair[1])"
    p comp.bfs_shortest_path(pair[0], pair[1])
  }

  puts "\n #==> Bio::GO::GeenAssociation"
  p ga_url
  ga = wget(ga_url)
  ga = Bio::GO::GeneAssociation.parser(ga)

  puts "\n #==> ga.size"
  p ga.size

  puts "\n #==> ga[100]"
  p ga[100]

  
end




=begin

= Bio::GO

* Classes for ((<Gene Ontology|URL:http://www.geneontology.org>)).


= Bio::GO::Ontology < Bio::Pathway

* Container class for ontologies in the DAG Edit format.

  c_data = File.open('component.oontology').read
  go_c = Bio::GO::Ontology.new(c_data)
  p go_c.bfs_shortest_path('0003673','0005632')


--- Bio::GO::Ontology.new(data)

      The DAG Edit format ontology data is allowed.

--- Bio::GO::Ontology#hader_lines

      Returns a Hash instance of the header lines in ontology flatfile.


--- Bio::GO::Ontology#goid2term(GO_ID)

      Returns a GO_Term correspondig with the given GO_ID.

--- Bio::GO::Ontology.parse_goids(line)

      Returns an ary of GO IDs by parsing an entry line in the DAG Edit 
      format.


= Bio::GO::GeneAssociation < Bio::DB

* Data parser for the gene_association go annotation.
  See also ((<the file format|URL:http://www.geneontology.org/doc/GO.annotation.html#file>)).


  mgi_data = File.open('gene_association.mgi').read
  mgi = Bio::GO::GeneAssociation.parser(mgi_data)

or

  Bio::GO::GeneAssociation.parser(mgi_data) {|entry|
    p [entry.entry_id, entry.evidence, entry.goid]
  }


--- Bio::GO::GeneAssociation.parser(data) 

      Retruns an Array of parsed gene_association flatfile.
      Block is acceptable.  

--- Bio::GO::GeneAssociation.new(line)

      Parsing an entry (in a line) in the gene_association flatfile.  

--- Bio::GO::GeneAssociation.DELIMITER

      The entry delimiter is "\n".
      alias as RS.

--- Bio::GO::GeneAssociation#goid(arg = nil)

      Returns GO_ID in /\d{7}/ format. Giving not nil arg, returns 
      /GO:\d{7}/ style.

--- Bio::GO::GeneAssociation#db

      DB variable.

--- Bio::GO::GeneAssociation#db_object_id

      Db_Object_Id variable. Alias to entry_id.

--- Bio::GO::GeneAssociation#db_object_symbol

      Db_Object_Symbol variable.

--- Bio::GO::GeneAssociation#db_object_name

      Db_Object_Name variable.

--- Bio::GO::GeneAssociation#db_object_type

      Db_Object_Type variable.

--- Bio::GO::GeneAssociation#db_reference

      Db_Reference variable.

--- Bio::GO::GeneAssociation#evidence

      Evidence code variable.

--- Bio::GO::GeneAssociation#with

      The entry is associated with this value.

--- Bio::GO::GeneAssociation#aspect

      Aspect valiable.

--- Bio::GO::GeneAssociation#taxon

      Taxon variable.

--- Bio::GO::GeneAssociation#date

      Date variable.



=end
