=begin

  $Id: Tutorial.rd,v 1.1 2005/08/31 12:35:41 ngoto Exp $

  Copyright (C) 2001-2003 KATAYAMA Toshiaki <k@bioruby.org>

= How to use BioRuby

== Manipulating nucleic / amino acid sequences (Bio::Sequence class)

For simple example, by using a short DNA seuquence "atgcatgcaaaa",
we are now converting into complemental strand, splicing subsequence,
calculating nucleic acid compositions, translating to amino acid sequence,
calculating molecular weight, and so on. About translation to
amino acid sequences, you can specify frame where you want to start
translation from and condon table ID defined in codontable.rb.


    #!/usr/bin/env ruby
    
    require 'bio'
    
    seq = Bio::Sequence::NA.new("atgcatgcaaaa")
    
    puts seq                            # original sequence
    puts seq.complement                 # complemental sequence (Bio::Sequence::NA object)
    puts seq.subseq(3,8)                # gets subsequence of positions 3 to 8
    
    p seq.gc_percent                    # GC percent (Float)
    p seq.composition                   # nucleic acid compositions (Hash)
    
    puts seq.translate                  # translation (Bio::Sequence::AA object)
    puts seq.translate(2)               # translation from frame 2 (default is frame 1)
    puts seq.translate(1,11)            # using codon table No.11 (TRANSLATOR'S NOTE: codon tables are showed at http://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi )
    
    p seq.translate.codes               # shows three-letter codes (Array)
    p seq.translate.names               # shows amino acid names (Array)
    p seq.translate.composition         # amino acid compositions (Hash)
    p seq.translate.molecular_weight    # calculating molecular weight (Float)
    
    puts seq.complement.translate       # translation of complemental strand

Nucleic acid sequence is an object of Bio::Sequence::NA class, and
amino acid sequenc is an object of Bio::Sequence::AA class.
Because both classes inherit Bio::Sequence class, most methods
are common.

As Bio::Sequence class inherits Ruby's String class, you can use
methods of String class. For example, to get subsequence, you can
use not only subseq(from, to) method but also String#[] method.
Please be careful that positions of Ruby's string begin with 0
for first letter. When you use String's methods, you should subtract
1 from positions conventionally used in biology.
(subseq method returns nil if you specify positions smaller than
or equeal to 0 for  either one of the "from" or "to".)
(TRANSLATOR'S NOTE: the text in Japanese is something wrong?)

The window_search(window_size, step_size) method passes each subsequence
to the supplied block for each sliding window specified by parameters.
Since the class of each subsequence is the same as original sequence
(Bio::Sequence::NA or Bio::Seuence::AA or Bio::Sequence), you can
use all methods in the class. For example,

* Shows average GC% for each 100 bases (with stepping 1 base)

    seq.window_search(100) do |subseq|
      puts subseq.gc
    end

You can specify stepping size with the second argument.

* Shows translation results for each 15 bases with shifting per codon.

    seq.window_search(15, 3) do |subseq|
      puts subseq.translate
    end

Moreover, the window_search method returns leftover subsequence in the end
of the sequence shorter than stepping size.
By using it, you can easily do such as:

* Divides a genome sequence into pieces of 10000bp substring and
  shows FASTA formatted sequences. Both 1000bp end of each subsequence
  is overlapped. In the 3' end of the sequence, leftover subsequence
  shorter than 10000bp is separetely displayed.

    i = 1
    remainder = seq.window_search(10000, 9000) do |subseq|
      puts subseq.to_fasta("segment #{i}", 60)
      i += 1
    end
    puts remainder.to_fasta("segment #{i}", 60)

If you want non-overlapping window, you shall specify same length
to window size and stepping size.

* counts the codon usage

    codon_usage = Hash.new(0)
    seq.window_search(3, 3) do |subseq|
      codon_usage[subseq] += 1
    end

* calculates molecular weight for each 10-aa peptide (or 10-nt nucleic acid)

    seq.window_search(10, 10) do |subseq|
      puts subseq.molecular_weight
    end

In most cases, sequences are read from files or retrieved from databases.
For example:

    #!/usr/bin/env ruby
    
    require 'bio'
    
    input_seq = ARGF.read       # reads all files in arguments
    
    my_naseq = Bio::Sequence::NA.new(input_seq)
    my_aaseq = my_naseq.translate
    
    puts my_aaseq

We saves the program as na2aa.rb. We also prepare a nucleic acid sequence
described below and saves it as my_naseq.txt.

      gtggcgatctttccgaaagcgatgactggagcgaagaaccaaagcagtgacatttgtctg
      atgccgcacgtaggcctgataagacgcggacagcgtcgcatcaggcatcttgtgcaaatg
      tcggatgcggcgtga

na2aa.rb translates a nucleic acid sequence to a protein sequence.
For example, translates my_naseq.txt:
(TRANSLATOR'S NOTE: don't forget "chmod +x na2aa.rb")

    % ./na2aa.rb my_naseq.txt
    VAIFPKAMTGAKNQSSDICLMPHVGLIRRGQRRIRHLVQMSDAA*

You can also write it as a one-liner script.

    % ruby -r bio -e 'p Bio::Sequence::NA.new($<.read).translate' my_naseq.txt

In the next section, we are going to retrieve data from databases
instead of using raw sequence files.

== Parsing GenBank data (Bio::GenBank class)

We assume that you already have some GenBank data files. (If you don't have,
you shall download any *.seq files from ftp://ftp.ncbi.nih.gov/genbank/ .)
Now, let's get ID, definition and sequence of each entry form the file.
Like gb2fasta command, sequences are displayed as FASTA format text.
Note that the "DELIMITER" used in below scrpit is a constant defined in
GenBank class and means delimiter string of the database. For example, 
"//" for GenBank class. By using DELIMITER, you don't need to remember
each database's delimiter string different from each other. In addition,
the name RS (record separator) is an alias of DELIMITER.
(TRANSLATOR'S NOTE: gb2fasta command converts GenBank files to FASTA format
files. It have been independently developed in many places. It is also
included as a sample script in BioRuby.)
(TRANSLATOR'S NOTE: The script below is historical and not recommended now.)

    #!/usr/bin/env ruby
    
    require 'bio'
    
    while entry = gets(Bio::GenBank::DELIMITER)
      gb = Bio::GenBank.new(entry)      # creates GenBank object
    
      print ">#{gb.accession} "         # Accession
      puts gb.definition                # Definition
      puts gb.naseq                     # Nucleic acid sequence (Bio::Sequence::NA object)
    end

Now, using Bio::FlatFile is recommended. You can rewrite above script as:

    #!/usr/bin/env ruby
    
    require 'bio'
    
    ff = Bio::FlatFile.new(Bio::GenBank, ARGF)
    ff.each_entry do |gb|
      definition = "#{gb.accession} #{gb.definition}"
      puts gb.naseq.to_fasta(definition, 60)    
    end

On the other hand, reading FASTA format seuqnece files as follows:

    #!/usr/bin/env ruby
    
    require 'bio'
    
    ff = Bio::FlatFile.new(Bio::FastaFormat, ARGF)
    ff.each_entry do |f|
      puts "definition : " + f.definition
      puts "nalen      : " + f.nalen.to_s
      puts "naseq      : " + f.naseq
    end

In above two scripts, the first arguments of Bio::FlatFile.new are
database classes of BioRuby. Please refer to the next section for details.

By using Bio::DB.open class method, you can also write as follows:

    #!/usr/bin/env ruby
    
    require 'bio'
    
    ff = Bio::GenBank.open("gbvrl1.seq")
    ff.each_entry do |gb|
      definition = "#{gb.accession} #{gb.definition}"
      puts gb.naseq.to_fasta(definition, 60)    
    end

(TRANSLATOR'S NOTE: Bio::DB.open have not been used so well.)

Next, we are going to parse the FEATURES which is very complicated, and
to get nucleic and amino acid sequences of genes.

    #!/usr/bin/env ruby
    
    require 'bio'
    
    ff = Bio::FlatFile.new(Bio::GenBank, ARGF)

    # iterates over each entry the file
    ff.each_entry do |gb|

      # shows accession and organism
      puts "# #{gb.accession} - #{gb.organism}"
    
      gb.features.each do |feature|     # iterates over each element in FEATURES
        position = feature.position
        hash = feature.assoc            # changing to hash for simplicity (not so recommended)

        # skips the entry if "/translation=" are not found
        next unless hash['translation']

        # collects gene name and so on.
        gene_info = [
          hash['gene'], hash['product'], hash['note'], hash['function']
        ].compact.join(', ')

        # shows nucleic acid sequence
        puts ">NA splicing('#{position}') : #{gene_info}"
        puts gb.naseq.splicing(position)

        # shows amino acid sequence translated from nucleic acid sequence
        puts ">AA translated by splicing('#{position}').translate"
        puts gb.naseq.splicing(position).translate

        # shows amino acid sequence in the database entry (/translation=)
        puts ">AA original translation"
        puts hash['translation']
      end
    end

* Note: Feature#assoc method makes Hash from a feature object. It is useful
  because you can get data from the hash by using qualifiers as keys, but
  you will lost some information if there are two or more same qualifiers
  in a feature entry. (To prevent losing information, feature data is
  returned as an array by Feature#feature method.)

Bio::Sequence#splicing splices subsequence from nucleic acid sequence
according to location information used in GenBank, EMBL and DDBJ.
(TRANSLATOR'S NOTE: added EMBL and GenBank.) When translation
table is different from 0(universal), or first codon is not "atg" or
the protein contain selenocysteine, the two amino acid sequences will
differ. Of cource, if there were a bug in BioRuby, the two sequences
would be different, too. (TRANSLATOR'S NOTE: Some cases are added
when two amino acid sequences are different.)

The Bio::Sequence#splicing method takes not only DDBJ/EMBL/GenBank feature
style location text but also Bio::Locations object. For more information
about location format and Bio::Locations class, please refer to
bio/location.rb.

* Splicing according to location string used in a GenBank entry

    naseq.splicing('join(2035..2050,complement(1775..1818),13..345')

* Generating Bio::Locations object and passing to the splicing method

    locs = Bio::Locations.new('join((8298.8300)..10206,1..855)')
    naseq.splicing(locs)

You can also use the splicing method for amino acid sequences
(Bio::Sequence::AA objects).

* Splicing peptide from a protein (e.g. signal peptide)

    aaseq.splicing('21..119')


=== Databases other than GenBank

In BioRuby, for databases other than GenBank, essence is same as GenBank.
Passing text data of a entry to the DatabaseClass.new(), a parsed object
is returned.

If you want to get entries from database flatfile, you can also use
Bio::FlatFile class as described above. The first argument of the
Bio::FlatFile.new is database class name in BioRuby (such as Bio::GenBank,
Bio::KEGG::GENES and so on).

    ff = Bio::FlatFile.new(Bio::DatabaseClass, ARGF)

It is wonderful that Bio::FlatFile class can automatically recognize
database class. You can simply write as follows.

    ff = Bio::FlatFile.auto(ARGF)

    #!/usr/bin/env ruby
    
    require 'bio'
    
    ff = Bio::FlatFile.auto(ARGF)
    ff.each_entry do |entry|
      p entry.entry_id          # エントリの ID
      p entry.entry_id          # identifier of the entry
      p entry.definition        # エントリの説明文
      p entry.definition        # definition of the entry
      p entry.seq               # 配列データベースの場合
      p entry.seq               # sequence data of the entry
    end

Methods to extract specific data from database objects are different
for every database. Though some popular methods are common, not all methods
are inplemented for every database class (Guideline for common methods is
partially described in bio/db.rb).

  * entry_id --> gets ID of the entry
  * definition --> gets definition of the entry
  * reference --> gets references as Bio::Reference object
  * organism --> gets species
  * seq, naseq, aaseq --> returns sequence as corresponding sequence object

Please refer to document of each database because methods names and 
details of methods are differnt for each database.

As a principal, when method name is plural form, the method returns
some object as an array. For example, some classes have "references" method
which return multiple Bio::Referece objects as an Array object.
On the other hand, some classes have "reference" method which return
single Bio::Reference object.


== Sequence homology search by using FASTA program (Bio::Fasta class)

Assume that you have query.pep file which contains a sequence as FASTA format.
We are going to do homology search by using FASTA in remote internet site or
in your local machine. You can also use the ssearch program instead of fasta
when you use them in your local machine.

=== using FASTA in local machine

Assume that FASTA is already installed (command name is fasta34 and
installed directory is described in PATH environment variable).
First, you must prepare FASTA-formatted database sequence file target.pep
and FASTA-formatted query.pep.
(TRANSLATOR'S NOTE: FASTA can be downloaded from 
ftp://ftp.virginia.edu/pub/fasta/ . I think we should provide sample data
to readers.)


    #!/usr/bin/env ruby
    
    require 'bio'
    
    # Creates FASTA factory object ("ssearch" instead of "fasta34" can work)
    factory = Bio::Fasta.local('fasta34', ARGV.pop)
    
    # Reads FASTA-formatted files (TRANSLATOR'S NOTE: something wrong in Japanese text)
    ff = Bio::FlatFile.new(Bio::FastaFormat, ARGF)
    
    # Iterates over each entry. the variable "entry" is a Bio::FastaFormat object.
    ff.each do |entry|
      # shows definition line (begins with '>') to the standard error output
      $stderr.puts "Searching ... " + entry.definition
   
      # executes homology search. Returns Bio::Fasta::Report object.
      report = factory.query(entry)
    
      # Iterates over each hit
      report.each do |hit|
        # If E-value is smaller than 0.0001
        if hit.evalue < 0.0001
          # shows identifier of query and hit, E-value, start and end positions of homologous region (TRANSLATOR'S NOTE: should I change Japanese document?)
          print "#{hit.query_id} : evalue #{hit.evalue}\t#{hit.target_id} at "
          p hit.lap_at
        end
      end
    end

We named above script as f_search.rb. You can execute as follows:

    % ./f_search.rb query.pep target.pep > f_search.out

In above script, the variable "factory" is a factory object for executing
FASTA many times easily. Instead of using Fasta#query method,
Bio::Sequence#fasta method can be used.
(TRANSLATOR'S NOTE: Bio::Sequence#fasta are not so frequently used.)

    seq = ">test seq\nYQVLEEIGRGSFGSVRKVIHIPTKKLLVRKDIKYGHMNSKE"
    seq.fasta(factory)


When you want to add options to FASTA command, you can set it as
third argument of Bio::Fasta.local method. For example, setting ktup to 1
and getting top-10 hits:

    factory = Bio::Fasta.local('fasta34', 'target.pep', '-b 10')
    factory.ktup = 1

Bio::Fasta#query returns Bio::Fasta::Report object.
We can get almost all information described in FASTA report text
with the Report object. For example, getting information for hits:


    report.each do |hit|
      puts hit.evalue           # E-value
      puts hit.sw               # Smith-Waterman score (*)
      puts hit.identity         # % identity
      puts hit.overlap          # length of overlapping region
      puts hit.query_id         # identifier of query sequence
      puts hit.query_def        # definition(comment line) of query sequence
      puts hit.query_len        # length of query sequence
      puts hit.query_seq        # query sequence (TRANSLATOR'S NOTE: sequence of homologous region of query sequence)
      puts hit.target_id        # identifier of hit sequence
      puts hit.target_def       # definition(comment line) of hit sequence
      puts hit.target_len       # length of hit sequence
      puts hit.target_seq       # hit sequence (TRANSLATOR'S NOTE: sequence of homologous region of hit sequence)
      puts hit.query_start      # start position of homologous region in query sequence
      puts hit.query_end        # end position of homologous region in query sequence
      puts hit.target_start     # start posiotion of homologous region in hit(target) sequence
      puts hit.target_end       # end position of homologous region in hit(target) sequence
      puts hit.lap_at           # array of above four numbers
    end

Most of above methods are common with Bio::Blast::Report described
below. Please refer to document of Bio::Fasta::Report class for
FASTA-specific details. (TRANSLATOR'S NOTE: I deleted a sentense because
I cannot translate it well and I think it is not needed here.)

If you need original output text of FASTA program you can use "output"
method of the factory object after "query" method.

    report = factory.query(entry)
    puts factory.output


=== using FASTA in remote internet site

Currently, only GenomeNet (fasta.genome.jp) is supported.
For remote site, Bio::Fasta.remote method is used instead of Bio::Fasta.local.
When using remote method, databases available are limited.
Except that, you can do almost same thing as local method.
(TRANSLATOR'S NOTE: changed order of sentences for smooth translation)

Available databases in GenomeNet:

  * Protein database
    * nr-aa, genes, vgenes.pep, swissprot, swissprot-upd, pir, prf, pdbstr

  * Nucleic acid database
    * nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss, htgs, dbsts,
      embl-nonst, embnonst-upd, genes-nt, genome, vgenes.nuc

First, you must select datasese from above list.
After that, you should determine search program from the type of query
sequence and database.

  * When query is a amino acid sequence
    * When protein database, program is "fasta".
    * When nucleic database, program is "tfasta".

  * When query is a nucleic acid sequence
    * When nucleic database, program is "fasta".
    * (TRANSLATOR'S NOTE: When protein database, you would fail to search.)

To set program and database and generates factory.

    program = 'fasta'
    database = 'genes'
    
    factory = Bio::Fasta.remote(program, database)

You can do almost same thing as local execution(e.g. factory.query).

== Homology search by using BLAST (Bio::Blast class)

For execution of homology search by using BLAST, like FASTA,
both local execution and remote service are supported.
Because most of the API is common with Bio::Fasta as far as possible,
you can do the same as above scripts with replacing Bio::Fasta to Bio::Blast.


For example, for BLAST version of f_search.rb, all you have to change is:

    # creates BLAST factory object
    factory = Bio::Blast.local('blastp', ARGV.pop) 

For remote execution of BLAST in GenomeNet, Bio::Blast.remote is used.
The paremeter "program" is different from FASTA.

  * When query is a amino acid sequence
    * When protein database, program is "blastp".
    * When nucleic database, program is "tblastn".

  * When query is a nucleic acid sequence
    * When protein database, program is "blastx"
    * When nucleic database, program is "blastn". (TRANSLATOR'S NOTE: "tblastx" for six-frame search.)

Bio::BLAST uses "-m 7" XML output of BLAST by default when XMLParser or
REXML (both of them are XML parser library for Ruby) is installed.
When no XML parser library, Bio::BLAST uses "-m 8" tabular deliminated format.
In Ruby 1.8.0 or higher version, REXML is bundled with Ruby's distribution
and shall already be installed. Because available information is limited
with the "-m 8" format, it is strongly recommended to install XMLParser
or REXML library when you are using Ruby version 1.6. If both XMLParser
and REXML are installed, XMLParser is preferentially used becase it is
faster than REXML.
(TRANSLATOR'S NOTE: I changed this paragraph due to the change of BioRuby's
default and Ruby's major version up.)

As described above, some methods in Bio::Fasta::Report and Bio::Blast::Report
(and Bio::Fasta::Report::Hit and Bio::Blast::Report::Hit) are common. 
There are some BLAST original methods, for example, bit_score and midline,
which might be frequently used.

    report.each do |hit|
      puts hit.bit_score        # bit score (*)
      puts hit.query_seq        # query sequence (TRANSLATOR'S NOTE: sequence of homologous region of query sequence)
      puts hit.midline          # middle line string of alignment of homologous region (*)
      puts hit.target_seq       # hit sequence (TRANSLATOR'S NOTE: sequence of homologous region of query sequence)
      
      puts hit.evalue           # E-value
      puts hit.identity         # % identity
      puts hit.overlap          # length of overlapping region
      puts hit.query_id         # identifier of query sequence
      puts hit.query_def        # definition(comment line) of query sequence
      puts hit.query_len        # length of query sequence
      puts hit.target_id        # identifier of hit sequence
      puts hit.target_def       # definition(comment line) of hit sequence
      puts hit.target_len       # length of hit sequence
      puts hit.query_start      # start position of homologous region in query sequence
      puts hit.query_end        # end position of homologous region in query sequence
      puts hit.target_start     # start position of homologous region in hit(target) sequence
      puts hit.target_end       # end position of homologous region in hit(target) sequence
      puts hit.lap_at           # array of above four numbers
    end

For simplicity and API compatibility, some information such as score
are extracted from first Hsp (TRANSLATOR'S NOTE: abbreviation of
High-scoring Segment Pair).

When you want to access full information of BLAST output, you must
understand structure of Bio::Blast::Report object.
Indeed, Bio::Blast::Report object have following hierarchical structure.
(TRANSLATOR'S NOTE: First sentense of the paragraph is changed.)

  * In a Bio::Blast::Report object, @iteratinos is an array of
    Bio::Blast::Report::Iteration objects.
    * In a Bio::Blast::Report::Iteration object, @hits is an array of
      Bio::Blast::Report::Hits objects.
      * In a Bio::Blast::Report::Hits object, @hsps is an array of
        Bio::Blast::Report::Hsp objects.

Please refer to bio/appl/blast.rb and bio/appl/blast/*.rb for details.
(TRANSLATOR'S NOTE: Some sentenses are removed because I could not translate
well and I think they are not important.)


=== Parsing existing BLAST output files

When you already have BLAST output files and you want to parse them,
you can directly create Bio::Blast::Report objects without Bio::Blast
factory object. For the purpose, Bio::Blast.reports method is used.
This method supports "-m 7" XML output format. (TRANSLATOR'S NOTE:
Now, default "-m 0" output is also supported. In latest BioRuby,
Bio::FlatFile supports BLAST default("-m 0") and XML("-m 7") formats.)

    #!/usr/bin/env ruby
    
    require 'bio'

    # Iterates over each XML result.
    # The variable "report" is a Bio::Blast::Report object.
    Bio::Blast.reports(ARGF) do |report|
      puts "Hits for " + report.query_def + " against " + report.db
      report.each do |hit|
        print hit.target_id, "\t", hit.evalue, "\n" if hit.evalue < 0.001
      end
    end

We named the script as hits_under_0.001.rb.
(TRANSLATOR'S NOTE: don't forget chmod +x)
To process BLAST output files *.xml, you can do as follows:

   % ./hits_under_0.001.rb *.xml

With some version of BLAST or in some OS, BLAST XML output may be wrong
and can not be parsed. We recommended to install BLAST 2.2.5 or later,
or changing combinations of -D and -m options when you encounter problems.


=== How to add remote search sites

(TRANSLATOR'S NOTE: This section is for advanced users.)

Though BLAST sequence homology search services are available in NCBI and
many internet sites, BioRuby currently only supports GenomeNet.
If you want to add other sites, you must write following routines:

  * calling CGI (command-line options must be processed for the site).
  * getting BLAST output text as supported format by BioRuby
    (e.g. "-m 8", "-m 7" or default("-m 0")).

In addition, you must write a private class method in Bio::Blast
named "exec_XXXXX" to get query sequence and to pass resut to
Bio::Blast::Report.new(or Bio::Blast::Default::Report.new).
(TRANSLATOR'S NOTE: Added information about "-m 0" and "-m 7".)
After that, you can do as follows:

    factory = Bio::Blast.remote(program, db, option, 'XXXXX')

When you write above routines, please send to the BioRuby project and
they will be included in future version.

== Generates reference list using PubMed (Bio::PubMed class)

Below script is an example which seaches PubMed and creates reference list.

    #!/usr/bin/env ruby
    
    require 'bio'
    
    ARGV.each do |id|
      entry = Bio::PubMed.query(id)     # searches PubMed and get entry
      medline = Bio::MEDLINE.new(entry) # creates Bio::MEDLINE object from entry text
      reference = medline.reference     # converts into Bio::Reference object
      puts reference.bibtex             # shows BibTeX formatted text
    end

We named the script pmfetch.rb.

    % ./pmfetch.rb 11024183 10592278 10592173

To give some PubMed ID (PMID) in arguments, the script retrieves informations
from NCBI, parses MEDLINE format text, converts into BibTeX format and
shows them.


Keyword search is also available.

    #!/usr/bin/env ruby
    
    require 'bio'
    
    # Concatinates argument keyword list to a string
    keywords = ARGV.join(' ')
    
    # PubMed keyword search
    entries = Bio::PubMed.search(keywords)
    
    entries.each do |entry|
      medline = Bio::MEDLINE.new(entry) # creates Bio::MEDLINE object from text
      reference = medline.reference     # converts into Bio::Reference object
      puts reference.bibtex             # shows BibTeX format text
    end

We named the script pmsearch.rb.

    % ./pmsearch.rb genome bioinformatics

To give keywords in arguments, the script seaches PubMed by given keywords 
and shows hit bibliography informations as BibTex format.

Now, using NCBI E-Utils is recommended, it is recommended to use
Bio::PubMed.esearch and Bio::PubMed.efetch instead of above methods.


    #!/usr/bin/env ruby
    
    require 'bio'
    
    keywords = ARGV.join(' ')
    
    options = {
      'maxdate' => '2003/05/31',
      'retmax' => 1000,
    }
    
    entries = Bio::PubMed.esearch(keywords, options)
    
    Bio::PubMed.efetch(entries).each do |entry|
      medline = Bio::MEDLINE.new(entry)
      reference = medline.reference
      puts reference.bibtex
    end

The script works same as pmsearch.rb. In addition, by using NCBI E-Utils,
it is more powerful than pmsearch.rb, for example, you can specify published
dates to search and maximum number of hits to show results.
Please refer ((<help page of E-Utils|URL:http://eutils.ncbi.nlm.nih.gov/entrez/query/static/eutils_help.html>)) for details of options.

Bio::Reference#bibtex method shows reference information as BibTeX format.
It also has bibitem method described below. In addition, it has some
journal style format such as nature and nar methods (but you can hardly
use them in practice because there are no way to show bold and italic fonts
in plain text).

If every database parser parsed such as REFERENCE lines and created
Bio::Reference object, it would be very useful because you would be
able to convert reference object into BibTeX format and so on.
(It is difficult to implement such function because there are many
exceptions about personal name and so on).


=== Memo about BibTeX

In this section, we explain simple usage of TeX for the BibTeX format
bibliography list collected by above scripts. For example, to save
BibTeX format bibliography data to a file named genoinfo.bib.

    % ./pmfetch.rb 10592173 >> genoinfo.bib
    % ./pmsearch.rb genome bioinformatics >> genoinfo.bib

Next, to prepare TeX file named hoge.tex as follows.

    \documentclass{jarticle}
    \begin{document}
    \bibliographystyle{plain}
    foo bar KEGG database~\cite{PMID:10592173} baz hoge fuga.
    \bibliography{genoinfo}
    \end{document}

Then,

    % latex hoge
    % bibtex hoge # processes genoinfo.bib
    % latex hoge  # creates bibliography list
    % latex hoge  # inserts correct bibliography reference
(TRANSLATOR'S NOTE: I changed platex(Japanese localized version of LaTeX)
to latex.)

Now, you get hoge.dvi.
    
=== Memo for Bio::Reference#bibitem method

When you don't want to create separate .bib file, you can use
Bio::Reference#bibitem method instead of Bio::Reference#bibtex.
In above pmfetch.rb and pmsearch.rb scripts, change

    puts reference.bibtex
to
    puts reference.bibitem


Output documents should be bundled in \begin{thebibliography}
and \end{thebibliography} as follows:

    \documentclass{jarticle}
    \begin{document}
    foo bar KEGG database~\cite{PMID:10592173} baz hoge fuga。

    \begin{thebibliography}{00}

    \bibitem{PMID:10592173}
    Kanehisa, M., Goto, S.
    KEGG: kyoto encyclopedia of genes and genomes.,
    {\em Nucleic Acids Res}, 28(1):27--30, 2000.

    \end{thebibliography}
    \end{document}

We named above file hoge.tex.

    % latex hoge   # creates bibliography list
    % latex hoge   # inserts corrent bibliography reference
(TRANSLATOR'S NOTE: I changed platex(Japanese localized version of LaTeX)
to latex.)

You should execute latex command two times and you get hoge.dvi.

== How to use BioRuby sample program

Some sample programs are stored in samples/ directry.
Some programs are obsolete. Since samples are not enough,
practical and interesting samples are welcome.

to be written...

= OBDA

OBDA (Open Bio Database Access) is a standardized method of sequence
database access developed by the Open Bioinformatics Foundation.
It was created during BioHackathon by BioPerl, BioJava, BioPython,
BioRuby and other projects' members  in Arizona in January and
in Cape Town in February 2002.

* BioRegistry (Directory)
  * Mechanism to specify how and where to retrieve sequence data for each database.

* BioFlat
  * Flatfile indexing by using binary tree or BDB(Berkeley DB).

* BioFetch
  * Server-client model for getting entry from database via http.

* BioSQL
  * Schemas to store sequence data to relational database such as
    MySQL and PostgreSQL, and methods to retrieve entries from the database.

Please refer to ((<URL:http://obda.open-bio.org/>)) for details.
Specification of them are stored on CVS repository at cvs.open-bio.org.
(TRANSLATOR'S NOTE: you can get via http from:
((<URL:http://cvs.open-bio.org/cgi-bin/viewcvs/viewcvs.cgi/obda-specs/?cvsroot=obf-common>)) )

== BioRegistry

You can specify retrieval method and position for every database
in configuration files. Priority of configuration files is:

  * The file specified with method's parameter
  * ~/.bioinformatics/seqdatabase.ini
  * /etc/bioinformatics/seqdatabase.ini
  * http://www.open-bio.org/registry/seqdatabase.ini

Note that the last configuration refers to www.open-bio.org is used only
when all local configulation files are not available. In current BioRuby
implementation, all local configulation files are read. For databases who
have same names, settings encountered first is used. This means that if
you don't like some settings of a database in system global configuration
file (/etc/bioinformatics/seqdatabase.ini), you can easily override it
by writing settings to ~/.bioinformatics/seqdatabase.ini.
(TRANSLATOR'S NOTE: Order of sentenses are drastically changed for smooth translation.)

The syntax of the configuration file is called stanza format.

    [DatabaseName]
    protocol=ProtocolName
    location=ServeName

You can write description like above entry for every database.
Database name is a local label for yourself, so you can name it freely and
it can differ from the name of actual databases. In specification of
BioRegistry, when there are two or more settings for a database of
the same name, it is proposed that connection to the database is tried 
sequentially with the order written in configuration files. However,
it have not been implemented in BioRuby.

In addition, for some protocol, you must set additional options
other than locations (e.g. user name of MySQL). In BioRegistory
specification, available protocols are:

  * index-flat
  * index-berkeleydb
  * biofetch
  * biosql
  * bsane-corba
  * xembl

In BioRuby, you can use index-flat, index-berkleydb, biofetch and biosql.
(TRANSLATOR'S NOTE: Due to the change of BioRegistry specification,
we must change above. In addition, current implementation of BioSQL
in BioRuby is not up-to-date.)

Using BioRegistry, first, create Bio::Registry object. It reads
configuration files internally.

    reg = Bio::Registry.new

    # connects to the database "genbank"
    serv = reg.get_database('genbank')
    
    # gets entry of the ID
    entry = serv.get_by_id('AA2CG')


The variable "serv" is a server object corresponding to the setting
written in configuration files. The class of the object is one of 
Bio::SQL, Bio::Fetch, and so on. Note that Bio::Registry#get_database("name")
returns nil if no database named "name" are found.
After that, you can use get_by_id method and some specific methods.
Please refer to below documents. (TRANSLATOR'S NOTE: should fix Japanese
document.)

== BioFlat

BioFlat is a mechanism to create index files of flat files and to retrieve
entries fast. There are two index types. index-flat is a simple inde
performs binary search without external library of Ruby. index-berkeleydb
uses Berkeley DB for indexing. For creating index, you can use
br_bioflat.rb command bundled with BioRuby.
(TRANSLATOR'S NOTE: should change command name in Japanese text.)


    % br_bioflat.rb --makeindex database_name [--format data_format] filename...

Data format can be omitted because BioRuby have data format autodetection
function. If you really need, you can specify data format as a name of
BioRuby database class.
(TRANSLATOR'S NOTE: should fix errata in Japanese text.)

To search and retrieve data from database:

    % br_bioflat.rb database_name identifier

For example, to create index of GenBank files gbbct*.seq and get entry
from the database:

    % br_bioflat.rb --makeindex my_bctdb --format GenBank gbbct*.seq
    % br_bioflat.rb my_bctdb A16STM262

If you have installed bdb extension module of Ruby
(TRANSLATOR'S NOTE: http://raa.ruby-lang.org/project/bdb/ ),
you can create and search indexes with Berkeley DB.
When creating index, use "--makeindex-bdb" options instead of "--makeindex".


    % br_bioflat.rb --makeindex-bdb database_name [--format data_format] filename...


== BioFetch

BioFetch is a database retrieval mechanism via CGI.
CGI Parameters, options and error codes are standardized.
A client accesses to ta server via http and gives database, identifiers
and format to retrieve entries.

BioRuby project have BioFetch server in bioruby.org. It uses
GenomeNet's DBGET system as a backend. The source code of the
server is in sample/ directory. Currently, there are only two
BioFetch servers in the world: bioruby.org and EBI.

There are some methods to retrieve entries from BioFetch server.

(1) Using web browser

      http://bioruby.org/cgi-bin/biofetch.rb

(2) Using br_biofetch.rb command

      % br_biofetch.rb db_name entry_id

(3) Directly using Bio::Fetch in script

      serv = Bio::Fetch.new(server_url)
      entry = serv.fetch(db_name, entry_id)

(4) Indirectly using Bio::Fetch via BioRegistry in script

      reg = Bio::Registry.new
      serv = reg.get_database('genbank')
      entry = serv.get_by_id('AA2CG')

If you want to use (4), you should write some settings to seqdatabase.ini.
(Note that server URL and database name are set in the configuration file.)

    [genbank]
    protocol=biofetch
    location=http://bioruby.org/cgi-bin/biofetch.rb
    biodbname=genbank

=== Combination of BioFetch, Bio::KEGG::GENES and Bio::AAindex1

Following program is to get bacteriorhodopsin gene (VNG1467G) of the
archaea Halobacterium from KEGG GENES database and to get alpha-helix
index data (BURA740101) from AAindex (Amino acid indices and similarity
matrices) database, and shows helix score for each 15-aa length
overlapping window.

    #!/usr/bin/env ruby
    
    require 'bio'

    entry = Bio::Fetch.query('hal', 'VNG1467G')
    aaseq = Bio::KEGG::GENES.new(entry).aaseq
    
    entry = Bio::Fetch.query('aax1', 'BURA740101')
    helix = Bio::AAindex1.new(entry).index
    
    position = 1
    win_size = 15
    
    aaseq.window_search(win_size) do |subseq|
      score = subseq.total(helix)
      puts [ position, score ].join("\t")
      position += 1
    end

The special method Bio::Fetch.query uses preset BioFetch server
in bioruby.org. (The server internally get data from GenomeNet.
Because the KEGG/GENES database and AAindex database are not available
in other BioFetch servers, we used bioruby.org server with
Bio::Fetch.query method.)

== BioSQL

to be written...


= KEGG API

Please refer to KEGG_API.rd.ja (TRANSLATOR'S NOTE: English version: ((<URL:http://www.genome.jp/kegg/soap/doc/keggapi_manual.html>)) ) and

  * ((<URL:http://www.genome.jp/kegg/soap/>))

= APPENDIX

== Installing required external library

to be written...

(TRANSLATOR'S NOTE: No additional libraries are needed with Ruby 1.8.1 and later.)

=end

