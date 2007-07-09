=begin

See the document in the CVS repository ./doc/((<Tutorial.rd|URL:http://cvs.open-bio.org/cgi-bin/viewcvs/viewcvs.cgi/*checkout*/bioruby/doc/Tutorial.rd?rev=HEAD&cvsroot=bioruby&content-type=text/plain>)) - for a potentially more up-to-date edition. This one was updated:

  $Id: Tutorial.rd,v 1.13 2007/07/09 12:28:07 pjotr Exp $

Translated into English: Naohisa Goto <ng@bioruby.org>

Editor:                  PjotrPrins <p@bioruby.org>

Copyright (C) 2001-2003 KATAYAMA Toshiaki <k@bioruby.org>, 2005-2007 Pjotr Prins, Naohisa Goto and others

IMPORTANT NOTICE: This page is maintained in the BioRuby CVS
repository. Please edit the file there otherwise changes may get
lost. See ((<BioRuby Developer Information>)) for CVS and mailing list
access.

= BioRuby Tutorial

== Introduction

This is a tutorial for using Bioruby. For BioRuby you need to install
Ruby and the BioRuby package on your computer. For each following the
instruction on the respective websites. (EDITOR's NOTE: include URL's)

(EDITOR's NOTE: describe rdoc use for individual classes)

For further information on the Ruby language see the section 'Further
reading' at the end.

You can check whether Ruby is installed on your computer and what
version it has with the

	% ruby -v

command. Showing something like:

  ruby 1.8.5 (2006-08-25) [powerpc-linux]


== Trying Bioruby

Bioruby comes with its own shell. After unpacking the sources run the
following command

  $BIORUBY/bin/bioruby

and you should see a prompt

  bioruby>

Now test the following:

  bioruby> seq = Bio::Sequence::NA.new("atgcatgcaaaa")
  bioruby> puts seq
  atgcatgcaaaa
  bioruby> puts seq.complement 
  ttttgcatgcat

== Working with nucleic / amino acid sequences (Bio::Sequence class)

The Bio::Sequence class allows the usual sequence transformations and
translations.  In the example below the DNA sequence "atgcatgcaaaa" is
converted into the complemental strand, spliced into a subsequence,
next the nucleic acid composition is calculated and the sequence is
translated into the amino acid sequence, the molecular weight
calculated, and so on. When translating into amino acid sequences the
frame can be specified and optionally the condon table selected (as
defined in codontable.rb).


    #!/usr/bin/env ruby

    require 'bio'

    seq = Bio::Sequence::NA.new("atgcatgcaaaa")

    puts seq                            # original sequence
    puts seq.complement                 # complemental sequence (Bio::Sequence::NA object)
    puts seq.subseq(3,8)                # gets subsequence of positions 3 to 8

    p seq.gc_percent                    # GC percent (BioRuby 0.6.X: Float, BioRuby 0.7 or later: Integer)
    p seq.composition                   # nucleic acid compositions (Hash)

    puts seq.translate                  # translation (Bio::Sequence::AA object)
    puts seq.translate(2)               # translation from frame 2 (default is frame 1)
    puts seq.translate(1,11)            # using codon table No.11 (see http://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi)

    p seq.translate.codes               # shows three-letter codes (Array)
    p seq.translate.names               # shows amino acid names (Array)
    p seq.translate.composition         # amino acid compositions (Hash)
    p seq.translate.molecular_weight    # calculating molecular weight (Float)

    puts seq.complement.translate       # translation of complemental strand

		counts = {'a'=>seq.count('a'),'c'=>seq.count('c'),'g'=>seq.count('g'),'t'=>seq.count('t')}
    p randomseq = Bio::Sequence::NA.randomize(counts)  # reshuffle sequence with same freq.

The p, print and puts methods are standard Ruby ways of outputting to
the screen. If you want to know more about standard Ruby commands you
can use the 'ri' command on the command line (or the help command in
Windows). For example

  % ri puts
  % ri p
  % ri File.open

Nucleic acid sequence is an object of +Bio::Sequence::NA+ class, and
amino acid sequence is an object of +Bio::Sequence::AA+ class.  Shared
methods are in the parent +Bio::Sequence+ class.

As Bio::Sequence class inherits Ruby's String class, you can use
String class methods. For example, to get a subsequence, you can
not only use subseq(from, to) but also String#[].

Please take note that the Ruby's string's are base 0 - i.e. the first letter
has index 0, for example:

  s = 'abc'
  puts s[0].chr

  >a

  puts s[0..1]

  >ab


So when using String methods, you should subtract 1 from positions
conventionally used in biology.  (subseq method will throw an exception if you
specify positions smaller than or equal to 0 for either one of the "from" or
"to".)

The window_search(window_size, step_size) method shows a typical Ruby
way of writing concise and clear code using 'closures'. Each sliding
window creates a subsequence which is supplied to the enclosed block
through a variable named +s+.

* Shows average percentage of GC content for 100 bases (stepping
the default one base at a time)

    seq.window_search(100) do |s|
      puts s.gc_percent
    end

Since the class of each subsequence is the same as original sequence
(Bio::Sequence::NA or Bio::Sequence::AA or Bio::Sequence), you can
use all methods on the subsequence. For example,

* Shows translation results for 15 bases shifting a codon at a time

    seq.window_search(15, 3) do |s|
      puts s.translate
    end

Finally, the window_search method returns the last leftover
subsequence. This allows for example

* Divide a genome sequence into sections of 10000bp and
  output FASTA formatted sequences. The 1000bp at the start and end of
	each subsequence overlapped. At the 3' end of the sequence the
  leftover subsequence shorter than 10000bp is also added

    i = 1
    remainder = seq.window_search(10000, 9000) do |s|
      puts s.to_fasta("segment #{i}", 60)
      i += 1
    end
    puts remainder.to_fasta("segment #{i}", 60)

If you don't want the overlapping window, set window size and stepping
size to equal values.

Other examples

* Count the codon usage

    codon_usage = Hash.new(0)
    seq.window_search(3, 3) do |s|
      codon_usage[s] += 1
    end

* Calculate molecular weight for each 10-aa peptide (or 10-nt nucleic acid)

    seq.window_search(10, 10) do |s|
      puts s.molecular_weight
    end

In most cases, sequences are read from files or retrieved from databases.
For example:

    require 'bio'

    input_seq = ARGF.read       # reads all files in arguments

    my_naseq = Bio::Sequence::NA.new(input_seq)
    my_aaseq = my_naseq.translate

    puts my_aaseq

Save the program as na2aa.rb. Prepare a nucleic acid sequence
described below and saves it as my_naseq.txt:

      gtggcgatctttccgaaagcgatgactggagcgaagaaccaaagcagtgacatttgtctg
      atgccgcacgtaggcctgataagacgcggacagcgtcgcatcaggcatcttgtgcaaatg
      tcggatgcggcgtga

na2aa.rb translates a nucleic acid sequence to a protein sequence.
For example, translates my_naseq.txt:

    % ruby na2aa.rb my_naseq.txt

Outputs

    VAIFPKAMTGAKNQSSDICLMPHVGLIRRGQRRIRHLVQMSDAA*

You can also write this, a bit fanciful, as a one-liner script.

    % ruby -r bio -e 'p Bio::Sequence::NA.new($<.read).translate' my_naseq.txt

In the next section we will retrieve data from databases instead of
using raw sequence files.

== Parsing GenBank data (Bio::GenBank class)

We assume that you already have some GenBank data files. (If you don't,
download some .seq files from ftp://ftp.ncbi.nih.gov/genbank/)

As an example we fetch the ID, definition and sequence of each entry
from the GenBank format and convert it to FASTA. This is also an example
script in the BioRuby distribution.

A first attempt could be to use the Bio::GenBank class for reading in
the data:

    #!/usr/bin/env ruby

    require 'bio'

    # Read all lines from STDIN split by the GenBank delimiter
    while entry = gets(Bio::GenBank::DELIMITER)
      gb = Bio::GenBank.new(entry)      # creates GenBank object

      print ">#{gb.accession} "         # Accession
      puts gb.definition                # Definition
      puts gb.naseq                     # Nucleic acid sequence (Bio::Sequence::NA object)
    end

But that has the disadvantage the code is tied to GenBank input. A more
generic method is to use Bio::FlatFile which allows you to use different
input formats:

    #!/usr/bin/env ruby
  
    require 'bio'
    
    ff = Bio::FlatFile.new(Bio::GenBank, ARGF)
    ff.each_entry do |gb|
      definition = "#{gb.accession} #{gb.definition}"
      puts gb.naseq.to_fasta(definition, 60)
    end

For example, in turn, reading FASTA format files:

    #!/usr/bin/env ruby

    require 'bio'

    ff = Bio::FlatFile.new(Bio::FastaFormat, ARGF)
    ff.each_entry do |f|
      puts "definition : " + f.definition
      puts "nalen      : " + f.nalen.to_s
      puts "naseq      : " + f.naseq
    end

In above two scripts, the first arguments of Bio::FlatFile.new are
database classes of BioRuby. This is expanded on in a later section.

Again another option is to use the Bio::DB.open class:

    #!/usr/bin/env ruby

    require 'bio'

    ff = Bio::GenBank.open("gbvrl1.seq")
    ff.each_entry do |gb|
      definition = "#{gb.accession} #{gb.definition}"
      puts gb.naseq.to_fasta(definition, 60)
    end

(TRANSLATOR'S NOTE: Bio::DB.open have not been used so well.)
(EDITOR's NOTE: Test code)

Next, we are going to parse the GenBank 'features', which is normally
very complicated:

    #!/usr/bin/env ruby

    require 'bio'

    ff = Bio::FlatFile.new(Bio::GenBank, ARGF)

    # iterates over each GenBank entry
    ff.each_entry do |gb|

      # shows accession and organism
      puts "# #{gb.accession} - #{gb.organism}"

      # iterates over each element in 'features'
      gb.features.each do |feature|
        position = feature.position
        hash = feature.assoc            # put into Hash

        # skips the entry if "/translation=" is not found
        next unless hash['translation']

        # collects gene name and so on and joins it into a string
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

* Note: In this example Feature#assoc method makes a Hash from a
  feature object. It is useful because you can get data from the hash
  by using qualifiers as keys.
  (But there is a risk some information is lost when two or more
  qualifiers are the same. Therefore an Array is returned by
  Feature#feature)

Bio::Sequence#splicing splices subsequence from nucleic acid sequence
according to location information used in GenBank, EMBL and DDBJ.

When the specified translation table is different from the default
(universal), or when the first codon is not "atg" or the protein
contains selenocysteine, the two amino acid sequences will differ.

The Bio::Sequence#splicing method takes not only DDBJ/EMBL/GenBank
feature style location text but also Bio::Locations object. For more
information about location format and Bio::Locations class, see
bio/location.rb.

* Splice according to location string used in a GenBank entry

    naseq.splicing('join(2035..2050,complement(1775..1818),13..345')

* Generate Bio::Locations object and pass the splicing method

    locs = Bio::Locations.new('join((8298.8300)..10206,1..855)')
    naseq.splicing(locs)

You can also use the splicing method for amino acid sequences
(Bio::Sequence::AA objects).

* Splicing peptide from a protein (e.g. signal peptide)

    aaseq.splicing('21..119')

(EDITOR's NOTE: why use STRINGs here?)

=== More databases

Databases in BioRuby are essentially accessed like that of GenBank
with classes like Bio::GenBank, Bio::KEGG::GENES,
(EDITOR's NOTE: include complete list)

In many cases the Bio::DatabaseClass acts as a factory pattern
and recognises the database type automatically - returning a
parsed object. For example using Bio::FlatFile

Bio::FlatFile class as described above. The first argument of the
Bio::FlatFile.new is database class name in BioRuby (such as Bio::GenBank,
Bio::KEGG::GENES and so on).

    ff = Bio::FlatFile.new(Bio::DatabaseClass, ARGF)

Isn't it wonderful that Bio::FlatFile automagically recognizes each
database class?

    #!/usr/bin/env ruby

    require 'bio'

    ff = Bio::FlatFile.auto(ARGF)
    ff.each_entry do |entry|
      p entry.entry_id          # identifier of the entry
      p entry.definition        # definition of the entry
      p entry.seq               # sequence data of the entry
    end

An example that can take any input, filter using a regular expression to output
to a FASTA file can be found in sample/any2fasta.rb.

Other methods to extract specific data from database objects can be
different between databases, though some methods are common (see the
guidelines for common methods as described in bio/db.rb).

  * entry_id --> gets ID of the entry
  * definition --> gets definition of the entry
  * reference --> gets references as Bio::Reference object
  * organism --> gets species
  * seq, naseq, aaseq --> returns sequence as corresponding sequence object

Refer to the documents of each database to find the exact naming
of the included methods.

In principal BioRuby uses the following conventions: when a method
name is plural the method returns some object as an Array. For
example, some classes have a "references" method which returns
multiple Bio::Reference objects as an Array. And some classes have a
"reference" method which returns a single Bio::Reference object.

=== Alignments (Bio::Alignment)

Bio::Alignment class in bio/alignment.rb is a container class like Ruby's Hash,
Array and BioPerl's Bio::SimpleAlign.  A very simple example is:

  require 'bio'

  seqs = [ 'atgca', 'aagca', 'acgca', 'acgcg' ]
  seqs = seqs.collect{ |x| Bio::Sequence::NA.new(x) }

  # creates alignment object
  a = Bio::Alignment.new(seqs)

  # shows consensus sequence
  p a.consensus             # ==> "a?gc?"

  # shows IUPAC consensus
  p a.consensus_iupac       # ==> "ahgcr"

  # iterates over each seq
  a.each { |x| p x }
    # ==>
    #    "atgca"
    #    "aagca"
    #    "acgca"
    #    "acgcg"
  # iterates over each site
  a.each_site { |x| p x }
    # ==>
    #    ["a", "a", "a", "a"]
    #    ["t", "a", "c", "c"]
    #    ["g", "g", "g", "g"]
    #    ["c", "c", "c", "c"]
    #    ["a", "a", "a", "g"]

  # doing alignment by using CLUSTAL W.
  # clustalw command must be installed.
  factory = Bio::ClustalW.new
  a2 = a.do_align(factory)

== Restriction Enzymes (Bio::RE)

BioRuby has extensive support for restriction enzymes (REs). It contains a full
library of commonly used REs (from REBASE) which can be used to cut single
stranded RNA or dubbel stranded DNA into fragments. To list all enzymes:

  rebase = Bio::RestrictionEnzyme.rebase
	rebase.each do |enzyme_name, info|
		p enzyme_name
  end

and cut a sequence with an enzyme follow up with:

   res = seq.cut_with_enzyme('EcoRII', {:max_permutations => 0}, {:view_ranges => true})
   if res.kind_of? Symbol #error
      err = Err.find_by_code(res.to_s)
      unless err
        err = Err.new(:code => res.to_s)
      end
   end
	 res.each do |frag|
	    em = EnzymeMatch.new

      em.p_left = frag.p_left
      em.p_right = frag.p_right
      em.c_left = frag.c_left
      em.c_right = frag.c_right

      em.err = nil
      em.enzyme = ar_enz
      em.sequence = ar_seq
			p em
    end


== Sequence homology search by using the FASTA program (Bio::Fasta)

Let's start with a query.pep file which contains a sequence in FASTA
format.  In this example we are going to execute a homology search
from a remote internet site or on your local machine. Note that you
can use the ssearch program instead of fasta when you use them in your
local machine.

=== using FASTA in local machine

Install the fasta program on your machine (the command name looks like
fasta34. FASTA can be downloaded from ftp://ftp.virginia.edu/pub/fasta/).
First, you must prepare your FASTA-formatted database sequence file
target.pep and FASTA-formatted query.pep.  (TRANSLATOR'S NOTE: I think
we should provide sample data to readers.)

    #!/usr/bin/env ruby

    require 'bio'

    # Creates FASTA factory object ("ssearch" instead of "fasta34" can also work)
    factory = Bio::Fasta.local('fasta34', ARGV.pop)
    (EDITOR's NOTE: not consistent pop command)

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

When you want to add options to FASTA command, you can set the
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

Most of above methods are common with the Bio::Blast::Report described
below. Please refer to document of Bio::Fasta::Report class for
FASTA-specific details.

If you need original output text of FASTA program you can use the "output"
method of the factory object after the "query" method.

    report = factory.query(entry)
    puts factory.output


=== using FASTA from a remote internet site

* Note: Currently, only GenomeNet (fasta.genome.jp) is
supported. check the class documentation for updates.

For accessing a remote site the Bio::Fasta.remote method is used
instead of Bio::Fasta.local.  When using a remote method, the
databases available may be limited, but, otherwise, you can do the
same things as with a local method.

Available databases in GenomeNet:

  * Protein database
    * nr-aa, genes, vgenes.pep, swissprot, swissprot-upd, pir, prf, pdbstr

  * Nucleic acid database
    * nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss, htgs, dbsts,
      embl-nonst, embnonst-upd, genes-nt, genome, vgenes.nuc

Select the databases you require.  Next, give the search program from
the type of query sequence and database.

  * When query is a amino acid sequence
    * When protein database, program is "fasta".
    * When nucleic database, program is "tfasta".

  * When query is a nucleic acid sequence
    * When nucleic database, program is "fasta".
    * (When protein database, you would fail to search.)

For example:

    program = 'fasta'
    database = 'genes'

    factory = Bio::Fasta.remote(program, database)

and try out the same commands as with the local search shown earlier.

== Homology search by using BLAST (Bio::Blast class)

The BLAST interface is very similar to that of FASTA and
both local and remote execution are supported. Basically
replace above examples Bio::Fasta with Bio::Blast!

For example the BLAST version of f_search.rb is:

    # create BLAST factory object
    factory = Bio::Blast.local('blastp', ARGV.pop)

For remote execution of BLAST in GenomeNet, Bio::Blast.remote is used.
The parameter "program" is different from FASTA - as you can expect:

  * When query is a amino acid sequence
    * When protein database, program is "blastp".
    * When nucleic database, program is "tblastn".

  * When query is a nucleic acid sequence
    * When protein database, program is "blastx"
    * When nucleic database, program is "blastn".
    * ("tblastx" for six-frame search.)

Bio::BLAST uses "-m 7" XML output of BLAST by default when either
XMLParser or REXML (both of them are XML parser libraries for Ruby -
of the two XMLParser is the fastest) is installed on your computer. In
Ruby version 1.8.0, or later, REXML is bundled with Ruby's
distribution.

When no XML parser library is present, Bio::BLAST uses "-m 8" tabular
deliminated format. Available information is limited with the
"-m 8" format so installing an XML parser is recommended.

Again, the methods in Bio::Fasta::Report and Bio::Blast::Report (and
Bio::Fasta::Report::Hit and Bio::Blast::Report::Hit) are similar.
There are some additional BLAST methods, for example, bit_score and
midline.

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
are extracted from the first Hsp (High-scoring Segment Pair).

Check the documentation for Bio::Blast::Report to see what can be
retrieved. For now suffice to state that Bio::Blast::Report has a
hierarchical structure mirroring the general BLAST output stream:

  * In a Bio::Blast::Report object, @iteratinos is an array of
    Bio::Blast::Report::Iteration objects.
    * In a Bio::Blast::Report::Iteration object, @hits is an array of
      Bio::Blast::Report::Hits objects.
      * In a Bio::Blast::Report::Hits object, @hsps is an array of
        Bio::Blast::Report::Hsp objects.

See bio/appl/blast.rb and bio/appl/blast/*.rb for more information.

=== Parsing existing BLAST output files

When you already have BLAST output files and you want to parse them,
you can directly create Bio::Blast::Report objects without the
Bio::Blast factory object. For this purpose use Bio::Blast.reports,
which supports the "-m 0" default and "-m 7" XML type output format.

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

Save the script as hits_under_0.001.rb and to process BLAST output
files *.xml, you can

   % ruby hits_under_0.001.rb *.xml

Sometimes BLAST XML output may be wrong and can not be parsed. We
recommended to install BLAST 2.2.5 or later, and try combinations of
the -D and -m options when you encounter problems.


=== Add remote BLAST search sites

  Note: this section is an advanced topic

Here a more advanced application for using BLAST sequence homology
search services. BioRuby currently only supports GenomeNet. If you
want to add other sites, you must write the following:

  * the calling CGI (command-line options must be processed for the site).
  * make sure you get BLAST output text as supported format by BioRuby
    (e.g. "-m 8", "-m 7" or default("-m 0")).

In addition, you must write a private class method in Bio::Blast
named "exec_MYSITE" to get query sequence and to pass the result to
Bio::Blast::Report.new(or Bio::Blast::Default::Report.new):

    factory = Bio::Blast.remote(program, db, option, 'MYSITE')

When you write above routines, please send to the BioRuby project and
they may be included.

== Generate a reference list using PubMed (Bio::PubMed)

Below script is an example which seaches PubMed and creates a reference list.

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

A keyword search is also available.

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

To give keywords in arguments, the script searches PubMed by given
keywords and shows bibliography informations in a BibTex format. Other
output formats are also avaialble like the bibitem method described
below. Some journal formats like nature and nar can be used, but lack
bold and italic font output.

(EDITORs NOTE: do we have some simple object that can be queried for
author, title etc.?)

Nowadays using NCBI E-Utils is recommended. Use Bio::PubMed.esearch
and Bio::PubMed.efetch instead of above methods.


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

The script works same as pmsearch.rb. But, by using NCBI E-Utils, more
options are available. For example published dates to search and
maximum number of hits to show results can be specified.

See the ((<help page of
E-Utils|URL:http://eutils.ncbi.nlm.nih.gov/entrez/query/static/eutils_help.html>))
for more details.



=== More about BibTeX

In this section, we explain the simple usage of TeX for the BibTeX format
bibliography list collected by above scripts. For example, to save
BibTeX format bibliography data to a file named genoinfo.bib.

    % ./pmfetch.rb 10592173 >> genoinfo.bib
    % ./pmsearch.rb genome bioinformatics >> genoinfo.bib

The BibTeX can be used with Tex or LaTeX to form bibliography
information with your journal article. For more information
on BibTex see (EDITORS NOTE: insert URL). A quick example:

Save this to hoge.tex:

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

Now, you get hoge.dvi and hoge.ps - the latter you can view any
Postscript viewer.

=== Bio::Reference#bibitem

When you don't want to create a bib file, you can use
Bio::Reference#bibitem method instead of Bio::Reference#bibtex.
In above pmfetch.rb and pmsearch.rb scripts, change

    puts reference.bibtex
to
    puts reference.bibitem


Output documents should be bundled in \begin{thebibliography}
and \end{thebibliography}. Save the following to hoge.tex

    \documentclass{jarticle}
    \begin{document}
    foo bar KEGG database~\cite{PMID:10592173} baz hoge fuga.

    \begin{thebibliography}{00}

    \bibitem{PMID:10592173}
    Kanehisa, M., Goto, S.
    KEGG: kyoto encyclopedia of genes and genomes.,
    {\em Nucleic Acids Res}, 28(1):27--30, 2000.

    \end{thebibliography}
    \end{document}

and run

    % latex hoge   # creates bibliography list
    % latex hoge   # inserts corrent bibliography reference


= OBDA

OBDA (Open Bio Database Access) is a standardized method of sequence
database access developed by the Open Bioinformatics Foundation.  It
was created during the BioHackathon by BioPerl, BioJava, BioPython,
BioRuby and other projects' members (2002).

* BioRegistry (Directory)
  * Mechanism to specify how and where to retrieve sequence data for each database.

* BioFlat
  * Flatfile indexing by using binary tree or BDB(Berkeley DB).

* BioFetch
  * Server-client model for getting entry from database via http.

* BioSQL
  * Schemas to store sequence data to relational database such as
    MySQL and PostgreSQL, and methods to retrieve entries from the database.

Here we give a quick overview. Check out
((<URL:http://obda.open-bio.org/>)) for more extensive details.

The specification is stored on CVS repository at cvs.open-bio.org,
also available via http from:
((<URL:http://cvs.open-bio.org/cgi-bin/viewcvs/viewcvs.cgi/obda-specs/?cvsroot=obf-common>))

== BioRegistry

BioRegistry allows for locating retrieval methods and database
locations through configuration files.  The priorities are

  * The file specified with method's parameter
  * ~/.bioinformatics/seqdatabase.ini
  * /etc/bioinformatics/seqdatabase.ini
  * http://www.open-bio.org/registry/seqdatabase.ini

Note that the last locaation refers to www.open-bio.org and is only used
when all local configulation files are not available.

In the current BioRuby implementation all local configulation files
are read. For databases with the same name settings encountered first
are used. This means that if you don't like some settings of a
database in system global configuration file
(/etc/bioinformatics/seqdatabase.ini), you can easily override it by
writing settings to ~/.bioinformatics/seqdatabase.ini.

The syntax of the configuration file is called a stanza format. For example

    [DatabaseName]
    protocol=ProtocolName
    location=ServeName

You can write a description like above entry for every database.

The database name is a local label for yourself, so you can name it
freely and it can differ from the name of the actual databases. In the
actual specification of BioRegistry where there are two or more
settings for a database of the same name, it is proposed that
connection to the database is tried sequentially with the order
written in configuration files. However, this has not (yet) been
implemented in BioRuby.

In addition, for some protocol, you must set additional options
other than locations (e.g. user name of MySQL). In the BioRegistory
specification, current available protocols are:

  * index-flat
  * index-berkeleydb
  * biofetch
  * biosql
  * bsane-corba
  * xembl

In BioRuby, you can use index-flat, index-berkleydb, biofetch and biosql.
Note that the BioRegistry specification sometimes gets updated and BioRuby
does not always follow quickly.

Here an example. Create a Bio::Registry object. It reads the configuration
files:

    reg = Bio::Registry.new

    # connects to the database "genbank"
    serv = reg.get_database('genbank')

    # gets entry of the ID
    entry = serv.get_by_id('AA2CG')


The variable "serv" is a server object corresponding to the setting
written in configuration files. The class of the object is one of
Bio::SQL, Bio::Fetch, and so on. Note that Bio::Registry#get_database("name")
returns nil if no database is found.

After that, you can use get_by_id method and some specific methods.
Please refer to below documents.

== BioFlat

BioFlat is a mechanism to create index files of flat files and to retrieve
these entries fast. There are two index types. index-flat is a simple index
performing binary search without using an external library of Ruby. index-berkeleydb
uses Berkeley DB for indexing - but requires installing bdb on your computer,
as well as the BDB Ruby package. For creating the index itself, you can use
br_bioflat.rb command bundled with BioRuby.

    % br_bioflat.rb --makeindex database_name [--format data_format] filename...

The format can be omitted because BioRuby has autodetection.  If that
does not work you can try specifying data format as a name of BioRuby
database class.

Search and retrieve data from database:

    % br_bioflat.rb database_name identifier

For example, to create index of GenBank files gbbct*.seq and get entry
from the database:

    % br_bioflat.rb --makeindex my_bctdb --format GenBank gbbct*.seq
    % br_bioflat.rb my_bctdb A16STM262

If you have Berkeley DB on your system and installed the bdb extension
module of Ruby (see http://raa.ruby-lang.org/project/bdb/), you can
create and search indexes with Berkeley DB - a very fast alternative
that uses little computer memory. When creating the index, use the
"--makeindex-bdb" option instead of "--makeindex".

    % br_bioflat.rb --makeindex-bdb database_name [--format data_format] filename...

== BioFetch

  Note: this section is an advanced topic

BioFetch is a database retrieval mechanism via CGI.  CGI Parameters,
options and error codes are standardized.  There client access via
http is possible giving the database name, identifiers and format to
retrieve entries.

The BioRuby project has a BioFetch server in bioruby.org. It uses
GenomeNet's DBGET system as a backend. The source code of the
server is in sample/ directory. Currently, there are only two
BioFetch servers in the world: bioruby.org and EBI.

Here are some methods to retrieve entries from our BioFetch server.

(1) Using a web browser

      http://bioruby.org/cgi-bin/biofetch.rb

(2) Using the br_biofetch.rb command

      % br_biofetch.rb db_name entry_id

(3) Directly using Bio::Fetch in a script

      serv = Bio::Fetch.new(server_url)
      entry = serv.fetch(db_name, entry_id)

(4) Indirectly using Bio::Fetch via BioRegistry in script

      reg = Bio::Registry.new
      serv = reg.get_database('genbank')
      entry = serv.get_by_id('AA2CG')

If you want to use (4), you, obviously, have to include some settings
in seqdatabase.ini. E.g.

    [genbank]
    protocol=biofetch
    location=http://bioruby.org/cgi-bin/biofetch.rb
    biodbname=genbank

=== The combination of BioFetch, Bio::KEGG::GENES and Bio::AAindex1

Bioinformatics is often about glueing things together. Here we give an
example to get the bacteriorhodopsin gene (VNG1467G) of the archaea
Halobacterium from KEGG GENES database and to get alpha-helix index
data (BURA740101) from the AAindex (Amino acid indices and similarity
matrices) database, and show the helix score for each 15-aa length
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
from other BioFetch servers, we used bioruby.org server with
Bio::Fetch.query method.)

== BioSQL

to be written...

== The BioRuby example programs

Some sample programs are stored in samples/ directry.
Some programs are obsolete. Since samples are not enough,
practical and interesting samples are welcome.

to be written...

(EDITOR's NOTE: I would like some examples automatically
included - with output)

== Further reading

See the BioRuby in anger Wiki and the class documentation for more
information on BioRuby.

The best book to get for understanding and getting productive with the
Ruby language is 'Programming Ruby' by Dave Thomas and Andy
Hunt. Strongly recommended!

= APPENDIX

== KEGG API

Please refer to KEGG_API.rd.ja (TRANSLATOR'S NOTE: English version: ((<URL:http://www.genome.jp/kegg/soap/doc/keggapi_manual.html>)) ) and

  * ((<URL:http://www.genome.jp/kegg/soap/>))

== Comparing BioProjects

For a quick functional comparison of BioRuby, BioPerl, BioPython and Bioconductor (R) see ((<http://sciruby.codeforpeople.com/sr.cgi/BioProjects>))

== Using BioRuby with R

Using Ruby with R Pjotr wrote a section on SciRuby. See ((<ULR:http://sciruby.codeforpeople.com/sr.cgi/RubyWithRlang>))

== Using BioPerl or BioPython from Ruby

At the moment there is no easy way of accessing BioPerl from Ruby. The best way, perhaps, is to create a Perl server that gets accessed through XML/RPC or SOAP.

== Installing required external library

At this point for using BioRuby no additional libraries are needed.
This may change, so keep an eye on the Bioruby website. Also when
a package is missing BioRuby should show an informative message.

At this point installing third party Ruby packages can be a bit
painful, as the gem standard for packages evolved late and some still
force you to copy things by hand. Therefore read the README's
carefully that come with each package.

=end

