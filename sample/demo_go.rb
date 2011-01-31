#
# = sample/demo_go.rb - demonstration of Bio::GO, classes for Gene Ontology
#
# Copyright::   Copyright (C) 2003 
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
#
# == Description
#
# Demonstration of Bio::GO, classes for Gene Ontology.
#
# == Requirement
#
# Internet connection is needed.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_go.rb
#
# == Note
#
# The code was originally written in 2003, and it can only parse GO format
# that is deprecated and no new data is available after August 2009.
#
# == Development information
#
# The code was moved from lib/bio/db/go.rb.
#

require 'bio'

#if __FILE__ == $0

  def wget(url)
    Bio::Command.read_uri(url)
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
  spkw2go = Bio::GO::External2go.parser(wget(e2g_url))

  puts "\n #==> spkw2go.dbs"
  p spkw2go.dbs

  puts "\n #==> spkw2go[1]"
  p spkw2go[1]



  require 'zlib'
  puts "\n #==> Bio::GO::GeenAssociation"
  p ga_url
  #
  # The workaround (Zlib::MAX_WBITS + 32) is taken from:
  #  http://d.hatena.ne.jp/ksef-3go/20070924/1190563143
  #
  ga = Zlib::Inflate.new(Zlib::MAX_WBITS + 32).inflate(wget(ga_url))
  #ga = Zlib::Inflate.inflate(wget(ga_url))
  ga = Bio::GO::GeneAssociation.parser(ga)

  puts "\n #==> ga.size"
  p ga.size

  puts "\n #==> ga[100]"
  p ga[100]




  
#end
