#
# bio/io/keggapi.rb - KEGG API access class
#
#   Copyright (C) 2003 KATAYAMA Toshiaki <k@bioruby.org>
#                      KAWASHIMA Shuichi <s@bioruby.org>
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
#  $Id: keggapi.rb,v 1.3 2003/04/09 05:30:31 k Exp $
#

begin
  require 'soap/wsdlDriver'
rescue LoadError
end

module Bio
  class KEGG
    class API

      MIN_SW_THRESHOLD = 100  # server default for SSDB, should not be changed.

      def initialize(log = nil)
	@wsdl = 'http://soap.genome.ad.jp/KEGG.wsdl'
	@driver = SOAP::WSDLDriverFactory.new(@wsdl).createDriver
	@driver.generateEncodeType = true	# ?
	if log
	  @driver.setWireDumpFileBase(log)
	end
	@fields = [ :kid2, :sw_score ]
      end
      attr_accessor :fields

      def method_missing(*arg)
	@driver.send(*arg)
      end

      ### SSDB

      ## SSDBResultArray type

      def get_all_neighbors_by_gene(keggid, threshold = 100, orglist = nil)
	th_check threshold
	filter @driver.get_all_neighbors_by_gene(keggid, threshold, orglist)
      end

      def get_best_neighbors_by_gene(keggid, threshold = 100, orglist = nil)
	th_check threshold
	filter @driver.get_best_neighbors_by_gene(keggid, threshold, orglist)
      end

      def get_best_best_neighbors_by_gene(keggid, threshold = 100, orglist = nil)
	th_check threshold
	filter @driver.get_best_best_neighbors_by_gene(keggid, threshold, orglist)
      end
 
      def get_reverse_best_neighbors_by_gene(keggid, threshold = 100, orglist = nil)
	th_check threshold
	filter @driver.get_reverse_best_neighbors_by_gene(keggid, threshold, orglist)
      end

      def get_paralogs_by_gene(keggid, threshold = 100)
	th_check threshold
	filter @driver.get_paralogs_by_gene(keggid, threshold)
      end

      def get_best_homologs_by_genes(keggorg, keggidlist)
	filter @driver.get_best_homologs_by_genes(keggorg, keggidlist)
      end

      def get_best_best_homologs_by_genes(keggorg, keggidlist)
	filter @driver.get_best_best_homologs_by_genes(keggorg, keggidlist),
	  [:kid1, :kid2, :sw_score]
      end

      ## SSDBResult type

      def get_score_between_genes(keggid1, keggid2)
	if r = @driver.get_score_between_genes(keggid1, keggid2)
	  r.sw_score
	end
      end

      ## MOTIFResultArray type

      def get_common_motifs_by_genes(keggidlist)
	filter @driver.get_common_motifs_by_genes(keggidlist),
	  [:mid, :definition]
      end

      ## GeneArray type

      def get_genes_by_motifs(motiflist)
	filter @driver.get_genes_by_motifs(motiflist),
	  [:kid, :keggdef]
      end


      private

      def th_check(threshold)
	if threshold < MIN_SW_THRESHOLD
	  raise "threshold #{threshold} (< #{MIN_SW_THRESHOLD}) is out of range"
	end
      end

      def filter(results, fields = nil)
	fields = @fields unless fields.is_a?(Array)
	array = []
	if results
	  results.each do |r|
	    array << fields.collect { |m| r.send(m) }
	  end
	end
	return array
      end

    end
  end
end


if __FILE__ == $0

  begin
    require 'pp'
    alias :p :pp
  rescue LoadError
  end

  puts ">>> KEGG API"
# serv = Bio::KEGG::API.new('keggapi/log')
  serv = Bio::KEGG::API.new

  puts "### get_all_neighbors_by_gene('eco:b0002', 500)"
  p serv.get_all_neighbors_by_gene('eco:b0002', 500)

  puts " -- get_all_neighbors_by_gene('eco:b0002', 500, 'hin')"
  p serv.get_all_neighbors_by_gene('eco:b0002', 500, 'hin')

  puts " -- get_all_neighbors_by_gene('eco:b0002', 500, ['hin', 'ece'])"
  p serv.get_all_neighbors_by_gene('eco:b0002', 500, ['hin', 'ece'])

  puts " -- add :definition2 field"
  serv.fields = [:kid2, :sw_score, :definition2]
  p serv.fields
  p serv.get_all_neighbors_by_gene('eco:b0002', 500, ['hin', 'ece'])

  puts " -- return all the fields"
  # to return all the fields
  serv.fields = [
    :kid1,
    :kid2,
    :sw_score,
    :ident,
    :overlap,
    :s1_start,
    :s1_end,
    :s2_start,
    :s2_end,
    :b1,
    :b2,
    :definition1,
    :definition2,
    :length1,
    :length2,
  ]
  p serv.get_all_neighbors_by_gene('eco:b0002', 2000, ['hin', 'ece'])
  # reset fields to the defaults
  serv.fields = [:kid2, :sw_score]

  puts "### get_best_neighbors_by_gene('eco:b0002', 500)"
  p serv.get_best_neighbors_by_gene('eco:b0002', 500)

  puts "### get_best_best_neighbors_by_gene('eco:b0002', 500)"
  p serv.get_best_best_neighbors_by_gene('eco:b0002', 500)

  puts "### get_reverse_best_neighbors_by_gene('eco:b0002', 500)"
  p serv.get_reverse_best_neighbors_by_gene('eco:b0002', 500)

  puts "### get_paralogs_by_gene('eco:b0002', 500)"
  p serv.get_paralogs_by_gene('eco:b0002', 500)

  puts "### get_best_homologs_by_genes('hin', 'eco:b0002')"
  list = 'eco:b0002'
  p serv.get_best_homologs_by_genes('hin', list)

  puts " -- get_best_homologs_by_genes('hin', ['eco:b0002', 'eco:b0003', ...])"
  list = ['eco:b0002', 'eco:b0003', 'eco:b0004', 'eco:b0005', 'eco:b0006']
  p serv.get_best_homologs_by_genes('hin', list)

  puts "### get_best_best_homologs_by_genes('hin', 'eco:b0002')"
  list = 'eco:b0002'
  p serv.get_best_best_homologs_by_genes('hin', list)

  puts " -- get_best_best_homologs_by_genes('hin', ['eco:b0002', ...])"
  list = ['eco:b0002', 'eco:b0003', 'eco:b0004', 'eco:b0005', 'eco:b0006']
  p serv.get_best_best_homologs_by_genes('hin', list)

  puts "### get_score_between_genes('eco:b0002', 'eco:b3940')"
  p serv.get_score_between_genes('eco:b0002', 'eco:b3940')

  puts "### get_definition_by_gene('eco:b0002')"
  p serv.get_definition_by_gene('eco:b0002')

  puts "### get_common_motifs_by_genes(['eco:b0002', 'eco:b3940'])"
  list = ['eco:b0002', 'eco:b3940']
  p serv.get_common_motifs_by_genes(list)

  puts "### get_genes_by_motifs(['pf:DnaJ', 'ps:DNAJ_2'])"
  list = ['pf:DnaJ', 'ps:DNAJ_2']
  p serv.get_genes_by_motifs(list)


  puts "### get_genes_by_pathway('path:eco00020')"
  p serv.get_genes_by_pathway('path:eco00020')

  puts "### get_compounds_by_pathway('path:eco00020')"
  p serv.get_compounds_by_pathway('path:eco00020')

  puts "### get_enzymes_by_pathway('path:eco00020')"
  p serv.get_enzymes_by_pathway('path:eco00020')

  puts "### get_pathways_by_genes(['eco:b0077' , 'eco:b0078'])"
  p serv.get_pathways_by_genes(['eco:b0077' , 'eco:b0078'])

  puts "### get_pathways_by_compounds(['cpd:C00033', 'cpd:C00158'])"
  p serv.get_pathways_by_compounds(['cpd:C00033', 'cpd:C00158'])

  puts "### get_pathways_by_enzymes(['ec:1.3.99.1'])"
  p serv.get_pathways_by_enzymes(['ec:1.3.99.1'])

end


=begin

= Bio::KEGG::API

KEGG API is a web service to use KEGG system via SOAP/WSDL.  For more
general informations on KEGG API, see:

  * ((<URL:http://www.genome.ad.jp/kegg/soap/>))

--- Bio::KEGG::API.new(log_file_name_prefix = nil)

Connect to the KEGG API's SOAP server.  A WSDL file will be automatically
downloaded and parsed to generate the SOAP client driver.

You can specify a prefix string of the log file name as an argument.
If specified, SOAP messages will be logged in the working directory.

  # Normal use
  serv = Bio::KEGG::API.new

  # Log files will be saved in 'log/' sub directory with prefix 'kegg_'
  serv = Bio::KEGG::API.new("log/kegg_")

In the following description,

  * 'keggorg' is a three letter organism code used in KEGG.  The list can be
    found at:

    * ((<URL:http://www.genome.ad.jp/kegg/kegg2.html#genes>))

  * 'keggid' is a unique identifier of which format is the combination of
    the database name and the identifier of an entry joined by a colon sign
    (e.g. 'database:entry' or 'keggorg':'gene name') used in KEGG.

  * 'threshold' is a threshold value for the Smith-Waterman score (no fewer
    than 100).

== SSDB

This section describes the KEGG API for SSDB database.  For more details
on SSDB, see:

  * ((<URL:http://www.genome.ad.jp/kegg/ssdb/>))

--- get_all_neighbors_by_gene(keggid, threshold = 100, orglist = nil)

Search homologous genes of the user specified 'keggid' from all organisms
having a 'sw_score' over the threshold.  You can narrow the target organisms
to search by passing a list of 'keggorg' as the third argument.

Returns a array of 'keggid' and 'sw_score' fields.  You can select returning
fields by 'fields=' method (see below). 

  # This will search all the homologous genes for E. coli gene 'b0002',
  # over the default threshold score 100.
  serv.get_all_neighbors_by_gene('eco:b0002')

  # This will search homologous genes only in E. coli O157 strain and
  # H. influenzae with 'sw_score' over 500.
  serv.get_all_neighbors_by_gene('eco:b0002', 500, ['ece', 'hin'])

  # You can use a String 'hin' instead of Array ['hin'] when searching
  # single target organism.
  serv.get_all_neighbors_by_gene('eco:b0002', 500, 'hin')

--- get_best_best_neighbors_by_gene(keggid, threshold = 100, orglist = nil)

Search best-best neighbor of the gene in each organism.  You can select
the target organisms as described in method 'get_all_neighbors_by_gene'.

  serv.get_best_best_neighbors_by_gene('eco:b0002', 500)

--- get_best_neighbors_by_gene(keggid, threshold = 100, orglist = nil)

Search best neighbors in each organism.

  # List up best neighbors of 'eco:b0002' having 'sw_score' over 500.
  serv.get_best_neighbors_by_gene('eco:b0002', 500)

--- get_reverse_best_neighbors_by_gene(keggid, threshold = 100, orglist = nil)

Search reverse best neighbors in each organism.

  # List up reverse best neighbors of 'eco:b0002' having 'sw_score' over 500.
  serv.get_reverse_best_neighbors_by_gene('eco:b0002', 500)

--- get_paralogs_by_gene(keggid, threshold = 100)

Search paralogous genes in the same organism.

  # List up paralogous genes of 'eco:b0002' having 'sw_score' over 500.
  serv.get_paralogs_by_gene('eco:b0002', 500)

--- get_best_homologs_by_genes(keggorg, keggidlist)

Search best neighbors in the target organism of the list of genes
user specified.  This method may be useful to search how the genes in operon
in organism A are distributed in organism B, for example.

  # Search the corresponding genes in H. influenzae
  list = ['eco:b0002', 'eco:b0003', 'eco:b0004', 'eco:b0005', 'eco:b0006']
  serv.get_best_homologs_by_genes('hin', list)

--- get_best_best_homologs_by_genes(keggorg, keggidlist)

Similar to 'get_best_homologs_by_genes', but returns only genes having
best-best relationships.

  list = ['eco:b0002', 'eco:b0003', 'eco:b0004', 'eco:b0005', 'eco:b0006']
  serv.get_best_best_homologs_by_genes('hin', list)

--- get_score_between_genes(keggid1, keggid2)

Returns a Smith-Waterman score between the two genes.

  # Returns a 'sw_score' between two E. coli genes 'b0002' and 'b3940'
  serv.get_score_between_genes('eco:b0002', 'eco:b3940')

--- get_definition_by_gene(keggid)

Returns a definition of the gene (annotated by KEGG) as a string.

  # Retrieve a definition of the E. coli gene 'b0002'
  serv.get_definition_by_gene('eco:b0002')

--- get_common_motifs_by_genes(keggidlist)

Search common motifs among the specified gene list.

  # Returns the common motifs among the two E. coli genes 'b0002' and 'b3940'
  list = ['eco:b0002', 'eco:b3940']
  serv.get_common_motifs_by_genes(list)

--- get_genes_by_motifs(motiflist)

Search all the genes which contains all of the specified motifs.

  # Returns all the genes which have Pfam 'DnaJ' and Prosite 'DNAJ_2' motifs.
  list = ['pf:DnaJ', 'ps:DNAJ_2']
  serv.get_genes_by_motifs(list)

--- fields

By default, some KEGG API methods will return a set of values (called
SSDBResultArray type) as

  kid1		keggid of the query
  kid2		keggid of the target
  sw_score	Smith-Waterman score between kid1 and kid2
  ident		% identity between kid1 and kid2
  overlap	overlap length between kid1 and kid2
  s1_start	start position of the alignment in kid1
  s1_end	end positoin of the alignment in kid1
  s2_start	start position of the alignment in kid2
  s2_end	end positoin of the alignment in kid2
  b1		best-best flag from kid1 to kid2 (1 means best, otherwise 0)
  b2		best-best flag from kid2 to kid1 (1 means best, otherwise 0)
  definition1	definition string of the kid1
  definition2	definition string of the kid2
  length1	amino acid length of the kid1
  length2	amino acid length of the kid2

However, in most cases, users will not need all of them.  In BioRuby,  
we default it to return 'kid2' and 'sw_score' fields only if appropriate.

This method will show which fields will be returned after the filtering.
You can change the fields to be returned by 'fields=' method.

--- fields=([:symbol1, :symbol2, ... ])

User can change the list of fields to be returned by passing an array
of symbols which corresponds to the fields.

  # Include 'definition2' in addition to the default 'kid2, 'sw_score' fields.
  serv.fields = [:kid2, :sw_score, :definition2]


== PATHWAY

This section describes the KEGG API for PATHWAY database.  For more details
on PATHWAY database, see:

  * ((<URL:http://www.genome.ad.jp/kegg/kegg2.html#pathway>))

--- get_genes_by_pathway(pathwayid)

Search all genes on the specified pathway.  Organism name is given by
the name of a pathway map.

  # Returns all the E. coli genes on the pathway map '00020'.
  serv.get_genes_by_pathway('path:eco00020')

--- get_compounds_by_pathway(pathwayid)

Search all compounds on the specified pathway.

  # Returns all the compounds on the pathway map '00020'.
  serv.get_compounds_by_pathway('path:eco00020')

--- get_enzymes_by_pathway(pathwayid)

Search all enzymes on the specified pathway.

  # Returns all the enzymes on the pathway map '00020'.
  serv.get_enzymes_by_pathway('path:eco00020')

--- get_pathways_by_genes(keggidlist)

Search all pathways which include all the given genes.

  # Returns all pathways include E. coli genes 'b0077' and 'b0078'
  serv.get_pathways_by_genes(['eco:b0077' , 'eco:b0078'])

--- get_pathways_by_compounds(cpdlist)

Search all pathways which include all the given compounds.

  # Returns all pathways include compounds 'C00033' and 'C00158'
  serv.get_pathways_by_compounds(['cpd:C00033', 'cpd:C00158'])

--- get_pathways_by_enzymes(enzymelist)

Search all pathways which include all the given enzymes.

  # Returns all pathways include enzyme '1.3.99.1'
  serv.get_pathways_by_enzymes(['ec:1.3.99.1'])

=end

