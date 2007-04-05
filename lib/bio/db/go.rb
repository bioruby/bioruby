#
# = bio/db/go.rb - Classes for Gene Ontology
#
# Copyright::   Copyright (C) 2003 
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
#  $Id: go.rb,v 1.11 2007/04/05 23:35:40 trevor Exp $
#
# == Gene Ontology
#
# == Example
#
# == References
#

require 'bio/pathway'

module Bio

# = Bio::GO
# Classes for Gene Ontology http://www.geneontology.org
class GO

  # = Bio::GO::Ontology
  #
  # Container class for ontologies in the DAG Edit format.
  #
  # == Example
  #
  #  c_data = File.open('component.oontology').read
  #  go_c = Bio::GO::Ontology.new(c_data)
  #  p go_c.bfs_shortest_path('0003673','0005632')
  class Ontology < Bio::Pathway

    # Bio::GO::Ontology.parse_ogids(line)
    #
    # Parsing GOID line in the DAGEdit format  
    #  GO:ID[ ; GO:ID...]
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

    # Returns a Hash instance of the header lines in ontology flatfile.
    attr_reader :header_lines

    # 
    attr_reader :id2term

    #
    attr_reader :id2id


    # Bio::GO::Ontology.new(str)
    # The DAG Edit format ontology data parser.
    def initialize(str)
      @id2term      = {}
      @header_lines = {}
      @id2id        = {}
      adj_list = dag_edit_format_parser(str)
      super(adj_list)
    end

        
    # Returns a GO_Term correspondig with the given GO_ID.
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


    # Returns an ary of GO IDs by parsing an entry line in the DAG Edit 
    # format.
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



  # = Bio::GO::GeneAssociation
  # $CVSROOT/go/gene-associations/gene_association.*
  #
  # Data parser for the gene_association go annotation.
  # See also the file format http://www.geneontology.org/doc/GO.annotation.html#file
  #
  # == Example
  #
  #  mgi_data = File.open('gene_association.mgi').read
  #  mgi = Bio::GO::GeneAssociation.parser(mgi_data)
  #
  #  Bio::GO::GeneAssociation.parser(mgi_data) do |entry|
  #    p [entry.entry_id, entry.evidence, entry.goid]
  #  end
  #
  class GeneAssociation # < Bio::DB

    # Delimiter
    DELIMITER = "\n"

    # Delimiter
    RS = DELIMITER 

    # Retruns an Array of parsed gene_association flatfile.
    # Block is acceptable.  
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

    # Returns DB variable.
    attr_reader :db                # -> aStr

    # Returns Db_Object_Id variable. Alias to entry_id.
    attr_reader :db_object_id      # -> aStr

    # Returns Db_Object_Symbol variable.
    attr_reader :db_object_symbol

    # Returns Db_Object_Name variable.
    attr_reader :qualifier
    
    # Returns Db_Reference variable.
    attr_reader :db_reference      # -> []

    # Retruns Evidence code variable.
    attr_reader :evidence

    # Returns the entry is associated with this value.
    attr_reader :with              # -> []

    # Returns Aspect valiable.
    attr_reader :aspect

    #
    attr_reader :db_object_name

    #
    attr_reader :db_object_synonym # -> []

    # Returns Db_Object_Type variable.
    attr_reader :db_object_type

    # Returns Taxon variable.
    attr_reader :taxon

    # Returns Date variable.
    attr_reader :date
    
    # 
    attr_reader :assigned_by 
    
    alias entry_id db_object_id


    # Parsing an entry (in a line) in the gene_association flatfile.  
    def initialize(entry) 
      tmp = entry.chomp.split(/\t/)
      @db                = tmp[0] 
      @db_object_id      = tmp[1]
      @db_object_symbol  = tmp[2]
      @qualifier         = tmp[3]  # 
      @goid              = tmp[4]
      @db_reference      = tmp[5].split(/\|/)  #
      @evidence          = tmp[6]
      @with              = tmp[7].split(/\|/)  # 
      @aspect            = tmp[8]
      @db_object_name    = tmp[9]  #
      @db_object_synonym = tmp[10].split(/\|/) #
      @db_object_type    = tmp[11]
      @taxon             = tmp[12] # taxon:4932
      @date              = tmp[13] # 20010118
      @assigned_by       = tmp[14] 
    end


    # Returns GO_ID in /\d{7}/ format. Giving not nil arg, returns 
    # /GO:\d{7}/ style.
    #
    # * Bio::GO::GeneAssociation#goid -> "001234"
    # * Bio::GO::GeneAssociation#goid(true) -> "GO:001234"
    def goid(org = nil)
      if org
        @goid
      else
        @goid.sub('GO:','')
      end
    end

    # Bio::GO::GeneAssociation#to_str -> a line of gene_association file.
    def to_str
      return [@db, @db_object_id, @db_object_symbol, @quialifier, @goid, 
              @qualifier.join("|"), @evidence, @with.join("|"), @aspect,
              @db_object_name, @db_object_synonym.join("|"), @db_object_type,
              @taxon, @date, @assigned_by].join("\t")
    end

  end # class GeneAssociation   



  # = Container class for files in geneontology.org/go/external2go/*2go.
  #
  # The line syntax is: 
  #
  # database:<identifier> > GO:<term> ; GO:<GO_id>
  #
  # == Example
  # 
  #  spkw2go = Bio::GO::External2go.new(File.read("spkw2go"))
  #  spkw2go.size
  #  spkw2go.each do |relation|
  #    relation # -> {:db => "", :db_id => "", :go_term => "", :go_id => ""}
  #  end
  #  spkw2go.dbs
  #
  # == SAMPLE
  #  !date: 2005/02/08 18:02:54
  #  !Mapping of SWISS-PROT KEYWORDS to GO terms.
  #  !Evelyn Camon, SWISS-PROT.
  #  !
  #  SP_KW:ATP synthesis > GO:ATP biosynthesis ; GO:0006754
  #  ...
  #
  class External2go < Array

    # Returns aHash of the external2go header information
    attr_reader :header

    # Constructor from parsing external2go file.
    def self.parser(str)
      e2g = self.new
      str.each_line do |line|
        line.chomp!
        if line =~ /^\!date: (.+)/
          e2g.header[:date] = $1
        elsif line =~ /^\!(.*)/
          e2g.header[:desc] << $1
        elsif ary = line.scan(/^(.+?):(.+) > GO:(.+) ; (GO:\d{7})/).first
          e2g << {:db_id => ary[1], :db => ary[0], :go_term => ary[2], :go_id => ary[3]}
        else
          raise("Invalid Format Line: \n #{line.inspect}\n")
        end
      end
      return e2g
    end


    # Constructor.
    # relation := {:db => aStr, :db_id => aStr, :go_term => aStr, :go_id => aStr}
    def initialize
      @header = {:date => '', :desc => []}
      super
    end


    # Bio::GO::External2go#set_date(value)
    def set_date(value)
      @header[:date] = value
    end


    # Bio::GO::External2go#set_desc(ary)
    def set_desc(ary)
      @header[:desc] = ary
    end


    # Bio::GO::External2go#to_str
    # Returns the contents in the external2go format.
    def to_str
      ["!date: #{@header[:date]}",
       @header[:desc].map {|e| "!#{e}" },
        self.map { |e| [e[:db], ':', e[:db_id], ' > GO:', e[:go_term], ' ; ', e[:go_id]].join }
      ].join("\n")
    end
    

    # Returns ary of databases.
    def dbs
      self.map {|rel| rel[:db] }.uniq
    end


    # Returns ary of database IDs.
    def db_ids
      self.map {|rel| rel[:db_id] }.uniq
    end

    # Returns ary of GO Terms.
    def go_terms
      self.map {|rel| rel[:go_term] }.uniq
    end

    # Returns ary of GO IDs.
    def go_ids
      self.map {|rel| rel[:go_id] }.uniq
    end

  end # class External2go
  
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

    result = Net::HTTP.new(host).get(path).body
  end



  go_c_url = 'http://www.geneontology.org/ontology/component.ontology'
  ga_url = 'http://www.geneontology.org/gene-associations/gene_association.sgd.gz'
  e2g_url = 'http://www.geneontology.org/external2go/spkw2go'



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


  puts "\n #==> Bio::GO::External2go"
  p e2g_url
  spkw2go = Bio::GO::External2go.new(wget(e2g_url))

  puts "\n #==> spkw2go.db"
  p spkw2go.db

  puts "\n #==> spkw2go[1]"
  p spkw2go[1]



  require 'zlib'
  puts "\n #==> Bio::GO::GeenAssociation"
  p ga_url
  ga = Zlib::Inflate.inflate(wget(ga_url))
  ga = Bio::GO::GeneAssociation.parser(ga)

  puts "\n #==> ga.size"
  p ga.size

  puts "\n #==> ga[100]"
  p ga[100]




  
end
