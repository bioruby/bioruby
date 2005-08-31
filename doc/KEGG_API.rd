=begin

  $Id: KEGG_API.rd,v 1.1 2005/08/31 13:29:01 k Exp $

    Copyright (C) 2003-2005 Toshiaki Katayama <k@bioruby.org>

= KEGG API

KEGG API is a web service to use the KEGG system from your program via
SOAP/WSDL.

We have been making the ((<KEGG|URL:/kegg/>)) system available at
((<GenomeNet|URL:/>)).  KEGG is a suite of databases including GENES,
SSDB, PATHWAY, LIGAND, LinkDB, etc.  for genome research and related
research areas in molecular and cellular biology.  These databases and
associated computation services are available via WWW and the user
interfaces are built on web browsers.  Thus, the interfaces are
designed to be accessed by humans, not by machines, which means that
it is troublesome for the researchers who want to use KEGG in an
automated manner.  Besides, from the database developer's side, it is
impossible to prepare all the CGI programs that satisfy a variety of
users' needs.

In recent years, the Internet technology for
application-to-application communication referred to as the
((<web service|URL:http://www.oreillynet.com/lpt/a/webservices/2002/02/12/webservicefaqs.html>))
is improving at a rapid rate. For exmaple, Google, a popular Internet
search engine, provides the web service called the
((<Google Web API|URL:http://www.google.com/apis/>)).
The service enables users to
develop software that accesses and manipulates a massive amount of web
documents that are constantly refreshed. In the field of genome
research, a similar kind of web service called
((<DAS|URL:http://www.biodas.org/>)) (distributed annotation system)
has been used on several web sites, including
((<Ensembl|URL:http://www.ensembl.org/>)),
((<Wormbase|URL:http://www.wormbase.org/>)),
((<Flybase|URL:http://www.flybase.org/>)),
((<SGD|URL:http://www.yeastgenome.org/>)),
((<TIGR|URL:http://www.tigr.org/>)).

With the background and the trends noted above, we have started developing
a new web service called KEGG API using 
((<SOAP|URL:http://www.w3.org/TR/SOAP/>)) and
((<WSDL|URL:http://www.w3.org/TR/wsdl20/>)).
The service has been tested with
((<Ruby|URL:http://www.ruby-lang.org/>))
(Ruby 1.8.2 or Ruby 1.6.8 with
((<SOAP4R|URL:http://raa.ruby-lang.org/project/soap4r/>))
version 1.4.8.1) and
((<Perl|URL:http://www.perl.org/>))
(((<SOAP::Lite|URL:http://www.soaplite.com/>)) version 0.55) languages.
Although the service has not been tested with clients written in other
languages, it should work if the language can treat SOAP/WSDL.

The ((<BioRuby|URL:http://bioruby.org/>)) project prepared a Ruby
library to handle the KEGG API, so users of the Ruby language should
check out the latest release of the BioRuby distribution.

For the general information on KEGG API, see the following
page at GenomeNet:

  * ((<URL:http://www.genome.jp/kegg/soap/>))

== Table of contents

* ((<Introduction>))
* ((<KEGG API Quick Start>))
  * ((<Quick Start with Perl>))
    * ((<Perl FAQ>))
  * ((<Quick Start with Ruby>))
  * ((<Quick Start with Python>))
  * ((<Quick Start with Java>))
* ((<KEGG API Reference>))
  * ((<WSDL file>))
  * ((<Terminology>))
  * ((<Returned values>))
    * ((<SSDBRelation>)), ((<ArrayOfSSDBRelation>))
    * ((<MotifResult>)), ((<ArrayOfMotifResult>))
    * ((<Definition>)), ((<ArrayOfDefinition>))
    * ((<LinkDBRelation>)), ((<ArrayOfLinkDBRelation>))
  * ((<Methods>))
    * ((<Meta information>))
      * ((<list_databases>)),
        ((<list_organisms>)),
        ((<list_pathways>))
    * ((<DBGET>))
      * ((<binfo>)),
        ((<bfind>)),
        ((<bget>)),
        ((<btit>))
    * ((<LinkDB>))
      * ((<get_linkdb_by_entry>))
    * ((<SSDB>))
      * ((<get_best_best_neighbors_by_gene>)),
        ((<get_best_neighbors_by_gene>)),
        ((<get_reverse_best_neighbors_by_gene>)),
        ((<get_paralogs_by_gene>))
#     * ((<get_neighbors_by_gene>)),
#       ((<get_similarity_between_genes>))
    * ((<Motif>))
      * ((<get_motifs_by_gene>)),
        ((<get_genes_by_motifs>))
    * ((<KO, OC, PC>))
      * ((<get_ko_by_gene>)),
        ((<get_ko_by_ko_class>)),
        ((<get_genes_by_ko_class>)),
        ((<get_genes_by_ko>)),
        ((<get_oc_members_by_gene>)),
        ((<get_pc_members_by_gene>))
#       ((<get_ko_members>)),
    * ((<PATHWAY>))
      * ((<mark_pathway_by_objects>)),
        ((<color_pathway_by_objects>)),
        ((<get_html_of_marked_pathway_by_objects>)),
        ((<get_html_of_colored_pathway_by_objects>))
      * ((<get_genes_by_pathway>)),
        ((<get_enzymes_by_pathway>)),
        ((<get_compounds_by_pathway>)),
        ((<get_glycans_by_pathway>)),
        ((<get_reactions_by_pathway>)),
        ((<get_kos_by_pathway>))
      * ((<get_pathways_by_genes>)),
        ((<get_pathways_by_enzymes>)),
        ((<get_pathways_by_compounds>)),
        ((<get_pathways_by_glycans>)),
        ((<get_pathways_by_reactions>)),
        ((<get_pathways_by_kos>))
      * ((<get_linked_pathways>))
      * ((<get_genes_by_enzyme>)),
        ((<get_enzymes_by_gene>))
      * ((<get_enzymes_by_compound>)),
        ((<get_enzymes_by_glycan>)),
        ((<get_enzymes_by_reaction>)),
        ((<get_compounds_by_enzyme>)),
        ((<get_compounds_by_reaction>)),
        ((<get_glycans_by_enzyme>)),
        ((<get_glycans_by_reaction>)),
        ((<get_reactions_by_enzyme>)),
        ((<get_reactions_by_compound>)),
        ((<get_reactions_by_glycan>))
    * ((<GENES>))
      * ((<get_genes_by_organism>))
    * ((<GENOME>))
      * ((<get_number_of_genes_by_organism>))
    * ((<LIGAND>))
      * ((<convert_mol_to_kcf>))

== Introduction

This guide explains how to use the KEGG API in your programs for 
searching and retrieving data from the KEGG database.

== KEGG API Quick Start

As always, the best way to become familar with it is by looking at an
example.  In this document, sample codes written in several languages
are shown.  After understanding the first exsample, try other APIs.

Firstly, you have to install the SOAP related libraries for the
programming language of your choice.


=== Quick Start with Perl

In the case of Perl, you need to install the following packages:

  * ((<SOAP Lite|URL:http://soaplite.com/>))
  * ((<MIME-Base64|URL:http://search.cpan.org/author/GAAS/MIME-Base64/>))
  * ((<LWP|URL:http://search.cpan.org/author/GAAS/libwww-perl/>))
  * ((<URI|URL:http://search.cpan.org/author/GAAS/URI/>))

Here's a first example in Perl language.

  #!/usr/bin/env perl
  
  use SOAP::Lite;
  
  $wsdl = 'http://soap.genome.jp/KEGG.wsdl';
  
  $serv = SOAP::Lite->service($wsdl);
  
  $start = 1;
  $max_results = 5;
  
  $top5 = $serv->get_best_neighbors_by_gene('eco:b0002', $start, $max_results);
  
  foreach $hit (@{$top5}) {
    print "$hit->{genes_id1}\t$hit->{genes_id2}\t$hit->{sw_score}\n";
  }

The output will be

  eco:b0002       eco:b0002       5283
  eco:b0002       ecj:JW0001      5283
  eco:b0002       sfx:S0002       5271
  eco:b0002       sfl:SF0002      5271
  eco:b0002       ecc:c0003       5269

showing that eco:b0002 has Smith-Waterman score 5271 with sfl:SF0002
as a 4th hit among the entire KEGG/GENES database (here, "eco" means
E. coli K-12 MG1655 and "sfl" means Shigella flexneri 2457T in the
KEGG organism codes).

The method internally searches the KEGG/SSDB (Sequence Similarity
Database) database which contains information about the amino acid
sequence similarities among all protein coding genes in the complete
genomes, together with information about best hits and bidirectional
best hits (best-best hits).  The relation of gene x in genome A and
gene y in genome B is called bidirectional best hits, when x is the
best hit of query y against all genes in A and vice versa, and it is
often used as an operational definition of ortholog.

Next example simply lists PATHWAYs for E. coli ("eco") in KEGG
database.

  #!/usr/bin/env perl

  use SOAP::Lite;

  $wsdl = 'http://soap.genome.jp/KEGG.wsdl';

  $results = SOAP::Lite
               -> service($wsdl)
               -> list_pathways("eco");

  foreach $path (@{$results}) {
    print "$path->{entry_id}\t$path->{definition}\n";
  }

This example colors the boxes corresponding to the E. coli genes b1002
and b2388 on a Glycolysis pathway of E. coli (path:eco00010).

  #!/usr/bin/env perl
  
  use SOAP::Lite;
  
  $wsdl = 'http://soap.genome.jp/KEGG.wsdl';
  
  $serv = SOAP::Lite -> service($wsdl);

  $genes = SOAP::Data->type(array => ["eco:b1002", "eco:b2388"]);

  $result = $serv -> mark_pathway_by_objects("path:eco00010", $genes);

  print $result;	# URL of the generated image

==== Perl FAQ

As you see in the above example, you always need to convert a Perl's array
into a SOAP object expicitly in SOAP::Lite by

  SOAP::Data->type(array => [value1, value2, .. ])

when you pass an array as the argument for any KEGG API method.

=== Quick Start with Ruby

If you are using Ruby 1.8.1 or later, you are ready to use KEGG API
as Ruby already supports SOAP in its standard library.

If your Ruby is 1.6.8 or older, you need to install followings:

  * ((<SOAP4R|URL:http://raa.ruby-lang.org/list.rhtml?name=soap4r>)) 1.5.1 or later
  * One of the following XML processing library
    * ((<rexml|URL:http://raa.ruby-lang.org/list.rhtml?name=rexml>))
    * ((<xmlparser|URL:http://raa.ruby-lang.org/list.rhtml?name=xmlparser>))
    * ((<xmlscan|URL:http://raa.ruby-lang.org/list.rhtml?name=xmlscan>))
  * ((<date2|URL:http://raa.ruby-lang.org/list.rhtml?name=date2>))
  * ((<devel-logger|URL:http://raa.ruby-lang.org/list.rhtml?name=devel-logger>))
  * ((<uconv|URL:http://raa.ruby-lang.org/list.rhtml?name=uconv>))
  * ((<http-access2|URL:http://raa.ruby-lang.org/list.rhtml?name=http-access2>))

Here's a sample code for Ruby having the same functionality with Perl's
first example shown above.

  #!/usr/bin/env ruby

  require 'soap/wsdlDriver'

  wsdl = "http://soap.genome.jp/KEGG.wsdl"
  serv = SOAP::WSDLDriverFactory.new(wsdl).createDriver
  serv.generate_explicit_type = true
  # if uncommented, you can see transactions for debug
  #serv.wiredump_dev = STDERR
  
  start = 1
  max_results = 5

  top5 = serv.get_best_neighbors_by_gene('eco:b0002', start, max_results)
  top5.each do |hit|
    print hit.genes_id1, "\t", hit.genes_id2, "\t", hit.sw_score, "\n"
  end

You may need to iterate to obtain all the results by increasing start
and/or max_results.

  #!/usr/bin/env ruby
  
  require 'soap/wsdlDriver'
  
  wsdl = "http://soap.genome.jp/KEGG.wsdl"
  serv = SOAP::WSDLDriverFactory.new(wsdl).create_driver
  serv.generate_explicit_type = true

  start = 1
  max_results = 100
  
  loop do
    results = serv.get_best_neighbors_by_gene('eco:b0002', start, max_results)
    break unless results
    results.each do |hit|
      print hit.genes_id1, "\t", hit.genes_id2, "\t", hit.sw_score, "\n"
    end
    start += max_results
  end

It is automatically done by using ((<BioRuby|URL:http://bioruby.org/>))
library, which implements get_all_* methods for this.  BioRuby also
provides filtering functionality for selecting needed fields from the
complex data type.

  #!/usr/bin/env ruby
  
  require 'bio'
  
  serv = Bio::KEGG::API.new
  
  results = serv.get_all_best_neighbors_by_gene('eco:b0002')

  results.each do |hit|
    print hit.genes_id1, "\t", hit.genes_id2, "\t", hit.sw_score, "\n"
  end

  # Same as above but using filter to select fields
  fields = [:genes_id1, :genes_id2, :sw_score]
  results.each do |hit|
    puts hit.filter(fields).join("\t")
  end

  # Different filters to pick additional fields for each amino acid sequence
  fields1 = [:genes_id1, :start_position1, :end_position1, :best_flag_1to2]
  fields2 = [:genes_id2, :start_position2, :end_position2, :best_flag_2to1]
  results.each do |hit|
    print "> score: ", hit.sw_score, ", identity: ", hit.identity, "\n"
    print "1:\t", hit.filter(fields1).join("\t"), "\n"
    print "2:\t", hit.filter(fields2).join("\t"), "\n"
  end

The equivalent for the Perl's second example described above will be

  #!/usr/bin/env ruby

  require 'bio'

  serv = Bio::KEGG::API.new

  list = serv.list_pathways("eco")
  list.each do |path|
    print path.entry_id, "\t", path.definition, "\n"
  end

and equivalent for the last example is as follows.

  #!/usr/bin/env ruby
  
  require 'bio'

  serv = Bio::KEGG::API.new
  
  genes = ["eco:b1002", "eco:b2388"]

  result = serv.mark_pathway_by_objects("path:eco00010", genes)

  print result		# URL of the generated image


=== Quick Start with Python

In the case of Python, you have to install

  * ((<SOAPpy|URL:http://pywebsvcs.sourceforge.net/>))

plus some extra packages required for SOAPpy (
((<fpconst|URL:http://www.analytics.washington.edu/Zope/projects/fpconst>)),
((<PyXML|URL:http://pyxml.sourceforge.net/>)) etc.).

Here's a sample code using KEGG API with Python.

  #!/usr/bin/env python

  from SOAPpy import WSDL
 
  wsdl = 'http://soap.genome.jp/KEGG.wsdl'
  serv = WSDL.Proxy(wsdl)

  results = serv.get_genes_by_pathway('path:eco00020')
  print results


=== Quick Start with Java

In the case of Java, you need to obtain Apache Axis library version
axis-1_2alpha or newer (axis-1_1 doesn't work properly for KEGG API)

  * ((<Apache Axis|URL:http://ws.apache.org/axis/>))

and put required jar files in an appropriate directory.

For the binary distribution of the Apache axis-1_2alpha release, copy
the jar files stored under the axis-1_2alpha/lib/ to the directory of
your choice.

  % cp axis-1_2alpha/lib/*.jar /path/to/lib/

You can use WSDL2Java coming with Apache Axis to generate classes
needed for the KEGG API automatically.

To generate classes and documents for the KEGG API, download the script
((<axisfix.pl|URL:http://www.genome.jp/kegg/soap/support/axisfix.pl>))
and follow the steps below:

  % java -classpath /path/to/lib/axis.jar:/path/to/lib/jaxrpc.jar:/path/to/lib/commons-logging.jar:/path/to/lib/commons-discovery.jar:/path/to/lib/saaj.jar:/path/to/lib/wsdl4j.jar:. org.apache.axis.wsdl.WSDL2Java -p keggapi http://soap.genome.jp/KEGG.wsdl
  % perl -i axisfix.pl keggapi/KEGGBindingStub.java
  % javac -classpath /path/to/lib/axis.jar:/path/to/lib/jaxrpc.jar:/path/to/lib/wsdl4j.jar:. keggapi/KEGGLocator.java
  % jar cvf keggapi.jar keggapi/*
  % javadoc -classpath /path/to/lib/axis.jar:/path/to/lib/jaxrpc.jar -d keggapi_javadoc keggapi/*.java

This program will do the same job as the Python's example (extended to
accept a pathway_id as the argument).

  import keggapi.*;
  
  class GetGenesByPathway {
          public static void main(String[] args) throws Exception {
                  KEGGLocator  locator = new KEGGLocator();
                  KEGGPortType serv    = locator.getKEGGPort();
  
                  String   query   = args[0];
                  String[] results = serv.get_genes_by_pathway(query);
  
                  for (int i = 0; i < results.length; i++) {
                          System.out.println(results[i]);
                  }
          }
  }

This is another example which uses ArrayOfSSDBRelation data type. 

  import keggapi.*;
  
  class GetBestNeighborsByGene {
          public static void main(String[] args) throws Exception {
                  KEGGLocator    locator  = new KEGGLocator();
                  KEGGPortType   serv     = locator.getKEGGPort();
  
                  String         query    = args[0];
                  SSDBRelation[] results  = null;
  
                  results = serv.get_best_neighbors_by_gene(query, 1, 50);
  
                  for (int i = 0; i < results.length; i++) {
                          String gene1  = results[i].getGenes_id1();
                          String gene2  = results[i].getGenes_id2();
                          int    score  = results[i].getSw_score();
                          System.out.println(gene1 + "\t" + gene2 + "\t" + score);
                  }
          }
  }

Compile and execute this program (don't forget to include keggapi.jar file
in your classpath) as follows:

  % javac -classpath /path/to/lib/axis.jar:/path/to/lib/jaxrpc.jar:/path/to/lib/wsdl4j.jar:/path/to/keggapi.jar GetBestNeighborsByGene.java

  % java -classpath /path/to/lib/axis.jar:/path/to/lib/jaxrpc.jar:/path/to/lib/commons-logging.jar:/path/to/lib/commons-discovery.jar:/path/to/lib/saaj.jar:/path/to/lib/wsdl4j.jar:/path/to/keggapi.jar:. GetBestNeighborsByGene eco:b0002

You may wish to set the CLASSPATH environmental variable.

bash/zsh:

  % for i in /path/to/lib/*.jar
  do
    CLASSPATH="${CLASSPATH}:${i}"
  done
  % export CLASSPATH

tcsh:

  % foreach i ( /path/to/lib/*.jar )
    setenv CLASSPATH ${CLASSPATH}:${i}
  end

For the other cases, consult the javadoc pages generated by WSDL2Java.

  * ((<URL:http://www.genome.jp/kegg/soap/doc/keggapi_javadoc/>))


== KEGG API Reference

=== WSDL file

Users can use a WSDL file to create a SOAP client driver.  The WSDL file for
the KEGG API can be found at:

  * ((<URL:http://soap.genome.jp/KEGG.wsdl>))

=== Terminology

  * 'org' is a three-letter organism code used in KEGG.  The list can be
    found at (see the description of the list_organisms method below):

    * ((<URL:http://www.genome.jp/kegg/catalog/org_list.html>))

  * 'db' is a database name used in GenomeNet service. See the
    description of the list_databases method below.

  * 'entry_id' is a unique identifier of which format is the combination of
    the database name and the identifier of an entry joined by a colon sign
    as 'database:entry' (e.g. 'embl:J00231' means an EMBL entry 'J00231').
    'entry_id' includes 'genes_id', 'enzyme_id', 'compound_id', 'glycan_id',
    'reaction_id', 'pathway_id' and 'motif_id' described in below.

  * 'genes_id' is a gene identifier used in KEGG/GENES which consists of
    'keggorg' and a gene name (e.g. 'eco:b0001' means an E. coli gene 'b0001').

  * 'enzyme_id' is an enzyme identifier consisting of database name 'ec'
    and an enzyme code used in KEGG/LIGAND (e.g. 'ec:1.1.1.1' means an
    alcohol dehydrogenase enzyme)

  * 'compound_id' is a compound identifier consisting of database name 'cpd'
    and a compound number used in KEGG/LIGAND (e.g. 'cpd:C00158' means a
    citric acid).  Note that some compounds also have 'glycan_id' and
    both IDs are accepted and converted internally by the corresponding
    methods.

  * 'glycan_id' is a glycan identifier consisting of database name 'gl'
    and a glycan number used in KEGG/GLYCAN (e.g. 'gl:G00050' means a
    Paragloboside).  Note that some glycans also have 'compound_id' and
    both IDs are accepted and converted internally by the corresponding
    methods.

  * 'reaction_id' is a reaction identifier consisting of database name 'rn'
    and a reaction number used in KEGG/REACTION (e.g. 'rn:R00959' is a
    reaction which catalyze cpd:C00103 into cpd:C00668)

  * 'pathway_id' is a pathway identifier consisting of 'path' and a pathway
    number used in KEGG/PATHWAY. Pathway numbers prefixed by 'map' specify
    the reference pathway and pathways prefixed by the 'keggorg' specify
    pathways specific to the organism (e.g. 'path:map00020' means a reference
    pathway for the cytrate cycle and 'path:eco00020' means a same pathway of
    which E. coli genes are marked).

  * 'motif_id' is a motif identifier consisting of motif database names
    ('ps' for prosite, 'bl' for blocks, 'pr' for prints, 'pd' for prodom,
    and 'pf' for pfam) and a motif entry name. (e.g. 'pf:DnaJ' means a Pfam
    database entry 'DnaJ').

  * 'ko_id' is a KO identifier consisting of 'ko' and a ko number used in 
    KEGG/KO. KO (KEGG Orthology) is an classification of orthologous genes 
    defined by KEGG (e.g. 'ko:K02598' means a KO group for nitrite transporter
    NirC genes).

  * 'ko_class_id' is a KO class identifier which is used to classify
    'ko_id' hierarchically (e.g. '01110' means a 'Carbohydrate Metabolism'
    class).

    * ((<URL:http://www.genome.jp/dbget-bin/get_htext?KO>))

  * 'start' and 'max_result' are both an integer and used to control the 
    number of the results returned at once.  Methods having these arguments
    will return first 'max_result' results starting from 'start'th.

  * 'fg_color_list' is a list of colors for the foreground (corresponding
    to the texts and borders of the objects on the KEGG pathway map).

  * 'bg_color_list' is a list of colors for the background (corresponding
    to the inside of the objects on the KEGG pathway map).

=== Returned values

Many of the KEGG API methods will return a set of values in a complex data
structure as described below.  This section summarizes all kind of these
data types.  Note that, the retuened values for the empty result will be
  * an empty array -- for the methods which return ArrayOf'OBJ'
  * an empty string -- for the methods which return String
  * -1 -- for the methods which return int
  * NULL -- for the methods which return any other 'OBJ'

+ SSDBRelation

SSDBRelation data type contains the following fields:

  genes_id1         genes_id of the query (string)
  genes_id2         genes_id of the target (string)
  sw_score          Smith-Waterman score between genes_id1 and genes_id2 (int)
  bit_score         bit score between genes_id1 and genes_id2 (float)
  identity          identity between genes_id1 and genes_id2 (float)
  overlap           overlap length between genes_id1 and genes_id2 (int)
  start_position1   start position of the alignment in genes_id1 (int)
  end_position1     end position of the alignment in genes_id1 (int)
  start_position2   start position of the alignment in genes_id2 (int)
  end_position2     end position of the alignment in genes_id2 (int)
  best_flag_1to2    best flag from genes_id1 to genes_id2 (boolean)
  best_flag_2to1    best flag from genes_id2 to genes_id1 (boolean)
  definition1       definition string of the genes_id1 (string)
  definition2       definition string of the genes_id2 (string)
  length1           amino acid length of the genes_id1 (int)
  length2           amino acid length of the genes_id2 (int)

Notice (26 Nov, 2004):

We found a serious bug with the 'best_flag_1to2' and 'best_flag_2to1'
fields in the SSDBRelation data type.  The methods returning the
SSDBRelation (and ArrayOfSSDBRelation) data type had returned the
opposite values of the intended results with the both fields.
The following methods had been affected by this bug:

# * get_neighbors_by_gene
  * get_best_neighbors_by_gene
  * get_reverse_best_neighbors_by_gene
  * get_paralogs_by_gene
# * get_similarity_between_genes

This problem is fixed in the version 3.2.

+ ArrayOfSSDBRelation

ArrayOfSSDBRelation data type is a list of the SSDBRelation data type.

+ MotifResult

MotifResult data type contains the following fields:

  motif_id          motif_id of the motif (string)
  definition        definition of the motif (string)
  genes_id          genes_id of the gene containing the motif (string)
  start_position    start position of the motif match (int)
  end_position      end position of the motif match (int)
  score             score of the motif match for TIGRFAM and PROSITE (float)
  evalue            E-value of the motif match for Pfam (double)

Note: 'score' and/or 'evalue' is set to -1 if the corresponding value is
not applicable.

+ ArrayOfMotifResult

ArrayOfMotifResult data type is a list of the MotifResult data type.

+ Definition

Definition data type contains the following fields:

  entry_id          database entry_id (string)
  definition        definition of the entry (string)

+ ArrayOfDefinition

ArrayOfDefinition data type is a list of the Definition data type.

+ LinkDBRelation

LinkDBRelation data type contains the following fields:

  entry_id1         entry_id of the starting entry (string)
  entry_id2         entry_id of the terminal entry (string)
  type              type of the link as "direct" or "indirect" (string)
  path              link path information across the databases (string)

+ ArrayOfLinkDBRelation

ArrayOfLinkDBRelation data type is a list of the LinkDBRelation data type.

=== Methods

==== Meta information

This section describes the APIs for retrieving the general information 
concerning latest version of the KEGG database.

--- list_databases

List of database names and its definitions available on the GenomeNet
is returned.

Return value:
  ArrayOfDefinition (db, definition)

--- list_organisms

List up the organisms in the KEGG/GENES database. 'org' code and the
organism's full name is returned in the Definition data type.

Return value:
  ArrayOfDefinition (org, definition)

--- list_pathways(org)

List up the pathway maps of the given organism in the KEGG/PATHWAY database.
Passing the string "map" as its argument, this method returns a list of the 
reference pathways.

Return value:
  ArrayOfDefinition (pathway_id, definition)

==== DBGET

This section describes the wrapper methods for DBGET system developed
at the GenomeNet.  For more details on DBGET system, see:

* ((<URL:http://www.genome.jp/dbget/dbget_manual.html>))

--- binfo(string)

Show the version information of the specified database.
Passing the string "all" as its argument, this method returns the version 
information of all databases available on the GenomeNet.

Return value:
  string

Example:
  # Show the information of the latest GenBank database.
  binfo("gb")

--- bfind(string)

Wrapper method for bfind command. bfind is used for searching entries by 
keywords. User need to specify a database from those which are supported 
by DBGET system before keywords.  Number of keywords given at a time is
restricted up to 100.

Return value:
  string

Example:
  # Returns the IDs and definitions of entries which have definition
  # including the word 'E-cadherin' and 'human' from GenBank.
  bfind("gb E-cadherin human")

--- bget(string)

The bget command is used for retrieving database entries specified by a list
of 'entry_id'.  This method accepts all the bget command line options as
a string.  Number of entries retrieved at a time is restricted up to 100.

Return value:
  string

Example:
  # retrieve two KEGG/GENES entries
  bget("eco:b0002 hin:tRNA-Cys-1")
  # retrieve nucleic acid sequences in a FASTA format
  bget("-f -n n eco:b0002 hin:tRNA-Cys-1")
  # retrieve amino acid sequence in a FASTA format
  bget("-f -n a eco:b0002")

--- btit(string)

Wrapper method for btit command. btit is used for retrieving the definitions
by given database entries.  Number of entries given at a time is restricted
up to 100.

Return value:
  string

Example:
  # Returns the ids and definitions of four GENES entries "hsa:1798",
  # "mmu:13478", "dme:CG5287-PA" and cel:Y60A3A.14".
  btit("hsa:1798 mmu:13478 dme:CG5287-PA cel:Y60A3A.14")

==== LinkDB

--- get_linkdb_by_entry(entry_id, db, start, max_results)

Retrieve the database entries linked from the user specified database entry.
It can also be specified the targeted database.

Return value:
  ArrayOfLinkDBRelation

Example:
  # Get the entries of KEGG/PATHWAY database linked from the entry 'eco:b0002'.
  get_linkdb_by_entry('eco:b0002', 'pathway', 1, 10)
  get_linkdb_by_entry('eco:b0002', 'pathway', 11, 10)

==== SSDB

This section describes the APIs for SSDB database.  For more details
on SSDB, see:

  * ((<URL:http://www.genome.jp/kegg/ssdb/>))

#--- get_neighbors_by_gene(genes_id, org, start, max_results)
#
#Search homologous genes of the user specified 'genes_id' from specified
#organism (or from all organisms if 'all' is given as org).
#
#Return value:
#  ArrayOfSSDBRelation
#
#Examples:
#  # This will search all homologous genes of E. coli gene 'b0002'
#  # in the SSDB and returns the first ten results.
#  get_neighbors_by_gene('eco:b0002', 'all', 1, 10)
#  # Next ten results.
#  get_neighbors_by_gene('eco:b0002', 'all', 11, 10)

--- get_best_best_neighbors_by_gene(genes_id, start, max_results)

Search best-best neighbor of the gene in all organisms.

Return value:
  ArrayOfSSDBRelation

Example:
  # List up best-best neighbors of 'eco:b0002'.
  get_best_best_neighbors_by_gene('eco:b0002', 1, 10)
  get_best_best_neighbors_by_gene('eco:b0002', 11, 10)

--- get_best_neighbors_by_gene(genes_id, start, max_results)

Search best neighbors in all organism.

Return value:
  ArrayOfSSDBRelation

Example:
  # List up best neighbors of 'eco:b0002'.
  get_best_neighbors_by_gene('eco:b0002', 1, 10)
  get_best_neighbors_by_gene('eco:b0002', 11, 10)

--- get_reverse_best_neighbors_by_gene(genes_id, start, max_results)

Search reverse best neighbors in all organisms.

Return value:
  ArrayOfSSDBRelation

Example:
  # List up reverse best neighbors of 'eco:b0002'.
  get_reverse_best_neighbors_by_gene('eco:b0002', 1, 10)
  get_reverse_best_neighbors_by_gene('eco:b0002', 11, 10)

--- get_paralogs_by_gene(genes_id, start, max_results)

Search paralogous genes of the given gene in the same organism.

Return value:
  ArrayOfSSDBRelation

Example:
  # List up paralogous genes of 'eco:b0002'.
  get_paralogs_by_gene('eco:b0002', 1, 10)
  get_paralogs_by_gene('eco:b0002', 11, 10)

#--- get_similarity_between_genes(genes_id1, genes_id2)
#
#Returns data containing Smith-Waterman score and alignment positions
#between the two genes.
#
#Return value:
#  SSDBRelation
#
#Example:
#  # Returns a 'sw_score' between two E. coli genes 'b0002' and 'b3940'
#  get_similarity_between_genes('eco:b0002', 'eco:b3940')

==== Motif

--- get_motifs_by_gene(genes_id, db)

Search motifs in the specified gene. As for 'db', 
user can specify one of the four database; Pfam, TIGRFAM, PROSITE pattern,
PROSITE profile as 'pfam', 'tfam', 'pspt', 'pspf', respectively.
You can also use 'all' to specify all of the four databases above.

Return value:
  ArrayOfMotifResult

Example:
  # Returns the all pfam motifs in the E. coli gene 'b0002'
  get_motifs_by_gene('eco:b0002', 'pfam')

--- get_genes_by_motifs(motif_id_list, start, max_results)

Search all genes which contains all of the specified motifs.

Return value:
  ArrayOfDefinition (genes_id, definition)

Example:
  # Returns all genes which have Pfam 'DnaJ' and Prosite 'DNAJ_2' motifs.
  list = ['pf:DnaJ', 'ps:DNAJ_2']
  get_genes_by_motifs(list, 1, 10)
  get_genes_by_motifs(list, 11, 10)


==== KO, OC, PC

--- get_ko_by_gene(genes_id)

Search all KOs to which given genes_id belongs.

Return value:
  ArrayOfstring (ko_id)

Example:
  # Returns ko_ids to which GENES entry 'eco:b0002' belongs.
  get_ko_by_gene('eco:b0002')

#--- get_ko_members(ko_id)
#
#Returns all genes assigned to the given KO entry.
#
#Return value:
#  ArrayOfstring (genes_id)
#
#Example
#  # Returns genes_ids those which belong to KO entry 'ko:K02598'.
#  get_ko_members('ko:K02598')

--- get_ko_by_ko_class(ko_class_id)

Return all KOs which belong to the given ko_class_id.

Return value:
  ArrayOfDefinition (ko_id, definition)

Example:
  # Returns ko_ids which belong to the KO class '01196'.
  get_ko_by_ko_class('01196')

--- get_genes_by_ko_class(ko_class_id, org, start, max_results)

Retrieve all genes of the specified organism which are classified
under the given ko_class_id.

Return value:
  ArrayOfDefinition (genes_id, definition)

Example:
  # Returns first 100 human genes which belong to the KO class '00930'
  get_genes_by_ko_class('00903', 'hsa' , 1, 100)

--- get_genes_by_ko(ko_id, org)

Retrieve all genes of the specified organism which belong to the
given ko_id.

Return value:
  ArrayOfDefinition (genes_id, definition)

Example
  # Returns E.coli genes which belong to the KO 'K00001'
  get_genes_by_ko('ko:K00001', 'eco')

  # Returns genes of all organisms which are assigned to the KO 'K00010'
  get_genes_by_ko('ko:K00010', 'all')

--- get_oc_members_by_gene(genes_id, start, max_results)

Search all members of the same OC (KEGG Ortholog Cluster) to which given
genes_id belongs.

Return value:
  ArrayOfstring (genes_id)

Example
  # Returns genes belonging to the same OC with eco:b0002 gene.
  get_oc_members_by_gene('eco:b0002', 1, 10)
  get_oc_members_by_gene('eco:b0002', 11, 10)

--- get_pc_members_by_gene(genes_id, start, max_results)

Search all members of the same PC (KEGG Paralog Cluster) to which given
genes_id belongs.

Return value:
  ArrayOfstring (genes_id)

Example
  # Returns genes belonging to the same PC with eco:b0002 gene.
  get_pc_members_by_gene('eco:b0002', 1, 10)
  get_pc_members_by_gene('eco:b0002', 11, 10)


==== PATHWAY

This section describes the APIs for PATHWAY database.  For more details
on PATHWAY database, see:

  * ((<URL:http://www.genome.jp/kegg/kegg2.html#pathway>))

+ Coloring pathways

--- mark_pathway_by_objects(pathway_id, object_id_list)

Mark the given objects on the given pathway map and return the URL of the
generated image.

Return value:
  string (URL)

Example:
  # Returns the URL of the generated image for the given map 'path:eco00260'
  # with objects corresponding to 'eco:b0002' and 'cpd:C00263' colored in red.
  obj_list = ['eco:b0002', 'cpd:C00263']
  mark_pathway_by_objects('path:eco00260', obj_list)

--- color_pathway_by_objects(pathway_id, object_id_list, fg_color_list, bg_color_list)

Color the given objects on the pathway map with the specified colors 
and return the URL of the colored image.  In the KEGG pathway maps,
a gene or enzyme is represented by a rectangle and a compound is
shown as a small circle.  'fg_color_list' is used for specifying the
color of text and border of the given objects and 'bg_color_list' is
used for its background area.  The order of colors in these lists
correspond with the order of objects in the 'object_id_list' list.

Return value:
  string (URL)

Example:
  # Returns the URL for the given pathway 'path:eco00260' with genes
  # 'eco:b0514' colored in red with yellow background and
  # 'eco:b2913' colored in green with yellow background.
  obj_list = ['eco:b0514', 'eco:b2913']
  fg_list  = ['#ff0000', '#00ff00']
  bg_list  = ['#ffff00', 'yellow']
  color_pathway_by_objects('path:eco00260', obj_list, fg_list, bg_list)

--- get_html_of_marked_pathway_by_objects(pathway_id, object_id_list)

HTML version of the 'mark_pathway_by_objects' method.
Mark the given objects on the given pathway map and return the URL of the
HTML with the generated image as a clickable map.

Return value:
  string (URL)

Example:
  # Returns the URL of the HTML which can be passed to the web browser
  # as a clickable map of the generated image of the given pathway
  # 'path:eco00970' with three objects corresponding to 'eco:b4258',
  # 'cpd:C00135' and 'ko:K01881' colored in red.
  obj_list = ['eco:b4258', 'cpd:C00135', 'ko:K01881']
  get_html_of_marked_pathway_by_objects('path:eco00970', obj_list)

--- get_html_of_colored_pathway_by_objects(pathway_id, object_id_list, fg_color_list, bg_color_list)

HTML version of the 'color_pathway_by_object' method.
Color the given objects on the pathway map with the specified colors 
and return the URL of the HTML containing the colored image as a
clickable map.

Return value:
  string (URL)

Example:
  # Returns the URL of the HTML which can be passed to the web browser
  # as a clickable map of coloerd image of the given pathway 'path:eco00970'
  # with a gene 'eco:b4258' colored in gray/red, a compound 'cpd:C00135'
  # coloerd in green/yellow and a KO 'ko:K01881' colored in blue/orange.
  obj_list = ['eco:b4258', 'cpd:C00135', 'ko:K01881']
  fg_list  = ['gray', '#00ff00', 'blue']
  bg_list  = ['#ff0000', 'yellow', 'orange']
  get_html_of_colored_pathway_by_objects('path:eco00970', obj_list, fg_list, bg_list)


+ Objects on the pathway

--- get_genes_by_pathway(pathway_id)

Search all genes on the specified pathway.  Organism name is given by
the name of the pathway map.

Return value:
  ArrayOfstring (genes_id)

Example:
  # Returns all E. coli genes on the pathway map '00020'.
  get_genes_by_pathway('path:eco00020')

--- get_enzymes_by_pathway(pathway_id)

Search all enzymes on the specified pathway.

Return value:
  ArrayOfstring (enzyme_id)

Example:
  # Returns all E. coli enzymes on the pathway map '00020'.
  get_enzymes_by_pathway('path:eco00020')

--- get_compounds_by_pathway(pathway_id)

Search all compounds on the specified pathway.

Return value:
  ArrayOfstring (compound_id)

Example:
  # Returns all E. coli compounds on the pathway map '00020'.
  get_compounds_by_pathway('path:eco00020')

--- get_glycans_by_pathway(pathway_id)

Search all glycans on the specified pathway.

Return value:
  ArrayOfstring (glycan_id)

Example
  # Returns all E. coli glycans on the pathway map '00510'
  get_glycans_by_pathway('path:eco00510')

--- get_reactions_by_pathway(pathway_id)

Retrieve all reactions on the specified pathway.

Return value:
  ArrayOfstring (reaction_id)

Example:
  # Returns all E. coli reactions on the pathway map '00260'
  get_reactions_by_pathway('path:eco00260')

--- get_kos_by_pathway(pathway_id)

Retrieve all KOs on the specified pathway.

Return value:
  ArrayOfstring (ko_id)

Example:
  # Returns all ko_ids on the pathway map 'path:hsa00010'
  get_kos_by_pathway('path:hsa00010')


+ Pathways by objects

--- get_pathways_by_genes(genes_id_list)

Search all pathways which include all the given genes.  How to pass the
list of genes_id will depend on the language specific implementations.

Return value:
  ArrayOfstring (pathway_id)

Example:
  # Returns all pathways including E. coli genes 'b0077' and 'b0078'
  get_pathways_by_genes(['eco:b0077' , 'eco:b0078'])

--- get_pathways_by_enzymes(enzyme_id_list)

Search all pathways which include all the given enzymes.

Return value:
  ArrayOfstring (pathway_id)

Example:
  # Returns all pathways including an enzyme '1.3.99.1'
  get_pathways_by_enzymes(['ec:1.3.99.1'])

--- get_pathways_by_compounds(compound_id_list)

Search all pathways which include all the given compounds.

Return value:
  ArrayOfstring (pathway_id)

Example:
  # Returns all pathways including compounds 'C00033' and 'C00158'
  get_pathways_by_compounds(['cpd:C00033', 'cpd:C00158'])

--- get_pathways_by_glycans(glycan_id_list)

Search all pathways which include all the given glycans.
 
Return value:
  ArrayOfstring (pathway_id)

Example
  # Returns all pathways including glycans 'G00009' and 'G00011'
  get_pathways_by_glycans(['gl:G00009', 'gl:G00011'])

--- get_pathways_by_reactions(reaction_id_list)

Retrieve all pathways which include all the given reaction_ids.

Return value:
  ArrayOfstring (pathway_id)

Example:
  # Returns all pathways including reactions 'rn:R00959', 'rn:R02740',
  # 'rn:R00960' and 'rn:R01786'
  get_pathways_by_reactions(['rn:R00959', 'rn:R02740', 'rn:R00960', 'rn:R01786'])

--- get_pathways_by_kos(ko_id_list, org)

Retrieve all pathways of the organisms which include all the given KO IDs.

Return value:
  ArrayOfstring (pathway_id)

Example:
  # Returns all human pathways including 'ko:K00016' and 'ko:K00382'
  get_pathways_by_kos(['ko:K00016', 'ko:K00382'], 'hsa')

  # Returns pathways of all organisms including 'ko:K00016' and 'ko:K00382'
  get_pathways_by_kos(['ko:K00016', 'ko:K00382'], 'all')


+ Relation among pathways

--- get_linked_pathways(pathway_id)

Retrieve all pathways which are linked from a given pathway_id.

Return value:
  ArrayOfstring (pathway_id)

Example:
  # Returns IDs of PATHWAY entries linked from 'path:eco00620'.
  get_linked_pathways('path:eco00620')


+ Relation among genes and enzymes

--- get_genes_by_enzyme(enzyme_id, org)

Retrieve all genes of the given organism.

Return value:
  ArrayOfstring (genes_id)

Example:
  # Returns all the GENES entry IDs in E.coli genome which are assigned 
  # EC number ec:1.2.1.1
  get_genes_by_enzyme('ec:1.2.1.1', 'eco')

--- get_enzymes_by_gene(genes_id)

Retrieve all the EC numbers which are assigned to the given gene.

Return value:
  ArrayOfstring (enzyme_id)

Example:
  # Returns the EC numbers which are assigned to E.coli genes b0002
  get_enzymes_by_gene('eco:b0002')


+ Relation among enzymes, compounds and reactions

--- get_enzymes_by_compound(compound_id)

Retrieve all enzymes which have a link to the given compound_id.

Return value:
  ArrayOfstring (enzyme_id)

Example:
  # Returns the ENZYME entry IDs which have a link to the COMPOUND entry,
  # 'cpd:C00345'
  get_enzymes_by_compound('cpd:C00345')

--- get_enzymes_by_glycan(glycan_id)

Retrieve all enzymes which have a link to the given glycan_id.

Return value:
  ArrayOfstring (enzyme_id)

Example
  # Returns the ENZYME entry IDs which have a link to the GLYCAN entry,
  # 'gl:G00001'
  get_enzymes_by_glycan('gl:G00001')

--- get_enzymes_by_reaction(reaction_id)

Retrieve all enzymes which have a link to the given reaction_id.

Return value:
  ArrayOfstring (enzyme_id)

Example:
  # Returns the ENZYME entry IDs which have a link to the REACTION entry, 
  # 'rn:R00100'.
  get_enzymes_by_reaction('rn:R00100')

--- get_compounds_by_enzyme(enzyme_id)

Retrieve all compounds which have a link to the given enzyme_id.

Return value:
  ArrayOfstring (compound_id)

Example:
  # Returns the COMPOUND entry IDs which have a link to the ENZYME entry, 
  # 'ec:2.7.1.12'.
  get_compounds_by_enzyme('ec:2.7.1.12')
 
--- get_compounds_by_reaction(reaction_id)

Retrieve all compounds which have a link to the given reaction_id.

Return value:
  ArrayOfstring (compound_id)

Example:
  # Returns the COMPOUND entry IDs which have a link to the REACTION entry, 
  # 'rn:R00100'
  get_compounds_by_reaction('rn:R00100')

--- get_glycans_by_enzyme(enzyme_id)

Retrieve all glycans which have a link to the given enzyme_id.

Return value:
  ArrayOfstring (glycan_id)

Example
  # Returns the GLYCAN entry IDs which have a link to the ENZYME entry,
  # 'ec:2.4.1.141'
  get_glycans_by_enzyme('ec:2.4.1.141')

--- get_glycans_by_reaction(reaction_id)

Retrieve all glycans which have a link to the given reaction_id.

Return value:
  ArrayOfstring (glycan_id)

Example
  # Returns the GLYCAN entry IDs which have a link to the REACTION entry,
  # 'rn:R06164'
  get_glycans_by_reaction('rn:R06164')

--- get_reactions_by_enzyme(enzyme_id)

Retrieve all reactions which have a link to the given enzyme_id.

Return value:
  ArrayOfstring (reaction_id)

Example:
  # Returns the REACTION entry IDs which have a link to the ENZYME entry,
  # 'ec:2.7.1.12'
  get_reactions_by_enzyme('ec:2.7.1.12')

--- get_reactions_by_compound(compound_id)

Retrieve all reactions which have a link to the given compound_id.

Return value:
  ArrayOfstring (reaction_id)

Example:
  # Returns the REACTION entry IDs which have a link to the COMPOUND entry,
  # 'cpd:C00199'
  get_reactions_by_compound('cpd:C00199')

--- get_reactions_by_glycan(glycan_id)

Retrieve all reactions which have a link to the given glycan_id.

Return value:
  ArrayOfstring (reaction_id)

Example
  # Returns the REACTION entry IDs which have a link to the GLYCAN entry,
  # 'gl:G00001'
  get_reactions_by_glycan('gl:G00001')


==== GENES

This section describes the APIs for GENES database. For more details
on GENES database, see:

  * ((<URL:http://www.genome.jp/kegg/kegg2.html#genes>))

--- get_genes_by_organism(org, start, max_results)

Retrieve all genes of the specified organism.

Return value:
  ArrayOfstring (genes_id)

Example:
  # Retrive hundred H. influenzae genes at once.
  get_genes_by_organism('hin', 1, 100)
  get_genes_by_organism('hin', 101, 100)


==== GENOME

This section describes the APIs for GENOME database. For more details
on GENOME database, see:

  * ((<URL:http://www.genome.jp/kegg/kegg2.html#genome>))

--- get_number_of_genes_by_organism(org)

Get the number of genes coded in the specified organism's genome. 

Return value:
  int

Example:
  # Get the number of the genes on the E.coli genome.
  get_number_of_genes_by_organism('eco')


==== LIGAND

This section describes the APIs for LIGAND database.

--- convert_mol_to_kcf(mol_text)

Convert a MOL format into the KCF format.

Return value:
  string

Example:
  convert_mol_to_kcf(mol_str)


== Notes

Last updated: May 31, 2005

=end

