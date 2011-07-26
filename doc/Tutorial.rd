# This document is generated with a version of rd2html (part of Hiki)
#
#   rd2 Tutorial.rd
#
# or with style sheet:
#
#   rd2 -r rd/rd2html-lib.rb --with-css=bioruby.css Tutorial.rd > Tutorial.rd.html
#
# in Debian:
#
#   rd2 -r rd/rd2html-lib  --with-css="../lib/bio/shell/rails/vendor/plugins/bioruby/generators/bioruby/templates/bioruby.css" Tutorial.rd > Tutorial.rd.html
#
# A common problem is tabs in the text file! TABs are not allowed.
#
# To add tests run Toshiaki's bioruby shell and paste in the query plus
# results.
#
# To run the embedded Ruby doctests you can use the rubydoctest tool, though
# it needs a little conversion. Like:
#
#   cat Tutorial.rd | sed -e "s,bioruby>,>>," | sed "s,==>,=>," > Tutorial.rd.tmp
#   rubydoctest Tutorial.rd.tmp
#
# alternatively, the Ruby way is
#
#   ruby -p -e '$_.sub!(/bioruby\>/, ">>"); $_.sub!(/\=\=\>/, "=>")' Tutorial.rd > Tutorial.rd.tmp
#   rubydoctest Tutorial.rd.tmp
#
# Rubydoctest is useful to verify an example in this document (still) works
#
#

bioruby> $: << '../lib'  # make sure rubydoctest finds bioruby/lib

=begin
#doctest Testing bioruby

= BioRuby Tutorial

* Copyright (C) 2001-2003 KATAYAMA Toshiaki <k .at. bioruby.org>
* Copyright (C) 2005-2011 Pjotr Prins, Naohisa Goto and others

This document was last modified: 2011/03/24
Current editor: Michael O'Keefe <okeefm (at) rpi (dot) edu>

The latest version resides in the GIT source code repository:  ./doc/((<Tutorial.rd|URL:https://github.com/bioruby/bioruby/blob/master/doc/Tutorial.rd>)).

== Introduction

This is a tutorial for using Bioruby. A basic knowledge of Ruby is required.
If you want to know more about the programming language, we recommend the
latest Ruby book ((<Programming Ruby|URL:http://www.pragprog.com/titles/ruby>))
by Dave Thomas and Andy Hunt - the first edition can be read online
((<here|URL:http://www.ruby-doc.org/docs/ProgrammingRuby/>)).

For BioRuby install Ruby and the BioRuby package on your computer.

Check whether Ruby is installed on your computer with

  % ruby -v

You should see something like:

  ruby 1.9.2p136 (2010-12-25 revision 30365) [i686-linux]

If you see no such thing you'll have to install Ruby using your installation
manager. For example in Debian
  
  apt-get install ruby

For other installations, see
((<Ruby|URL:http://www.ruby-lang.org/en/>)).

With Ruby download and install Bioruby using the links on the
((<Bioruby|URL:http://bioruby.org/>)) website. The recommended installation is via 
RubyGems (which comes with Ruby):

  gem install bio

See also the Bioruby ((<wiki|URL:http://bioruby.open-bio.org/wiki/Installation>)).

A lot of BioRuby's documentation exists in the source code and unit tests. To
really dive in you will need the latest source code tree. The embedded rdoc
documentation can be viewed online at
((<bioruby's rdoc|URL:http://bioruby.org/rdoc/>)). But first lets start!

== Trying Bioruby

Bioruby comes with its own shell. After installing, run

  bioruby

or, from the source tree

  cd bioruby
  ruby -I lib bin/bioruby

and you should see a prompt

  bioruby>

Now, test the following:

  bioruby> require 'bio'
  bioruby> seq = Bio::Sequence::NA.new("atgcatgcaaaa")
  ==> "atgcatgcaaaa"

  bioruby> seq.complement
  ==> "ttttgcatgcat"

See the the Bioruby shell section below for more tweaking. If you have trouble running
examples also check the section below on trouble shooting. You can also post a 
question to the mailing list. BioRuby developers usually try to help.

== Working with nucleic / amino acid sequences (Bio::Sequence class)

The Bio::Sequence class allows the usual sequence transformations and
translations.  In the example below the DNA sequence "atgcatgcaaaa" is
converted into the complemental strand and spliced into a subsequence; 
next, the nucleic acid composition is calculated and the sequence is
translated into the amino acid sequence, the molecular weight
calculated, and so on. When translating into amino acid sequences, the
frame can be specified and optionally the codon table selected (as
defined in codontable.rb).

  bioruby> seq = Bio::Sequence::NA.new("atgcatgcaaaa")
  ==> "atgcatgcaaaa"

  # complemental sequence (Bio::Sequence::NA object)
  bioruby> seq.complement
  ==> "ttttgcatgcat"

  bioruby> seq.subseq(3,8) # gets subsequence of positions 3 to 8 (starting from 1)
  ==> "gcatgc"
  bioruby> seq.gc_percent 
  ==> 33
  bioruby> seq.composition 
  ==> {"a"=>6, "c"=>2, "g"=>2, "t"=>2}
  bioruby> seq.translate 
  ==> "MHAK"
  bioruby> seq.translate(2)        # translate from frame 2
  ==> "CMQ"
  bioruby> seq.translate(1,11)     # codon table 11
  ==> "MHAK"
  bioruby> seq.translate.codes
  ==> ["Met", "His", "Ala", "Lys"]
  bioruby> seq.translate.names
  ==> ["methionine", "histidine", "alanine", "lysine"]
  bioruby>  seq.translate.composition
  ==> {"K"=>1, "A"=>1, "M"=>1, "H"=>1}
  bioruby> seq.translate.molecular_weight
  ==> 485.605
  bioruby> seq.complement.translate
  ==> "FCMH"

get a random sequence with the same NA count:

  bioruby> counts = {'a'=>seq.count('a'),'c'=>seq.count('c'),'g'=>seq.count('g'),'t'=>seq.count('t')}
  ==> {"a"=>6, "c"=>2, "g"=>2, "t"=>2}
  bioruby!> randomseq = Bio::Sequence::NA.randomize(counts) 
  ==!> "aaacatgaagtc"

  bioruby!> print counts
  a6c2g2t2  
  bioruby!> p counts
  {"a"=>6, "c"=>2, "g"=>2, "t"=>2}


The p, print and puts methods are standard Ruby ways of outputting to
the screen. If you want to know more about standard Ruby commands you
can use the 'ri' command on the command line (or the help command in
Windows). For example

  % ri puts
  % ri p
  % ri File.open

Nucleic acid sequence are members of the Bio::Sequence::NA class, and
amino acid sequence are members of the Bio::Sequence::AA class.  Shared
methods are in the parent Bio::Sequence class.

As Bio::Sequence inherits Ruby's String class, you can use
String class methods. For example, to get a subsequence, you can
not only use subseq(from, to) but also String#[].

Please take note that the Ruby's string's are base 0 - i.e. the first letter
has index 0, for example:

  bioruby> s = 'abc'
  ==> "abc"
  bioruby> s[0].chr
  ==> "a"
  bioruby> s[0..1]
  ==> "ab"

So when using String methods, you should subtract 1 from positions
conventionally used in biology.  (subseq method will throw an exception if you
specify positions smaller than or equal to 0 for either one of the "from" or "to".)

The window_search(window_size, step_size) method shows a typical Ruby
way of writing concise and clear code using 'closures'. Each sliding
window creates a subsequence which is supplied to the enclosed block
through a variable named +s+.

* Show average percentage of GC content for 20 bases (stepping the default one base at a time):

   bioruby> seq = Bio::Sequence::NA.new("atgcatgcaattaagctaatcccaattagatcatcccgatcatcaaaaaaaaaa")
   ==> "atgcatgcaattaagctaatcccaattagatcatcccgatcatcaaaaaaaaaa"

   bioruby> a=[]; seq.window_search(20) { |s| a.push s.gc_percent } 
   bioruby> a
   ==> [30, 35, 40, 40, 35, 35, 35, 30, 25, 30, 30, 30, 35, 35, 35, 35, 35, 40, 45, 45, 45, 45, 40, 35, 40, 40, 40, 40, 40, 35, 35, 35, 30, 30, 30]

 
Since the class of each subsequence is the same as original sequence
(Bio::Sequence::NA or Bio::Sequence::AA or Bio::Sequence), you can
use all methods on the subsequence. For example,

* Shows translation results for 15 bases shifting a codon at a time

   bioruby> a = []
   bioruby> seq.window_search(15, 3) { | s | a.push s.translate }
   bioruby> a
   ==> ["MHAIK", "HAIKL", "AIKLI", "IKLIP", "KLIPI", "LIPIR", "IPIRS", "PIRSS", "IRSSR", "RSSRS", "SSRSS", "SRSSK", "RSSKK", "SSKKK"]

Finally, the window_search method returns the last leftover
subsequence. This allows for example

* Divide a genome sequence into sections of 10000bp and
  output FASTA formatted sequences (line width 60 chars). The 1000bp at the
  start and end of each subsequence overlapped. At the 3' end of the sequence
  the leftover is also added:

    i = 1
    textwidth=60
    remainder = seq.window_search(10000, 9000) do |s|
      puts s.to_fasta("segment #{i}", textwidth)
      i += 1
    end
    if remainder
      puts remainder.to_fasta("segment #{i}", textwidth) 
    end

If you don't want the overlapping window, set window size and stepping
size to equal values.

Other examples

* Count the codon usage

   bioruby> codon_usage = Hash.new(0)
   bioruby> seq.window_search(3, 3) { |s| codon_usage[s] += 1 }
   bioruby> codon_usage
   ==> {"cat"=>1, "aaa"=>3, "cca"=>1, "att"=>2, "aga"=>1, "atc"=>1, "cta"=>1, "gca"=>1, "cga"=>1, "tca"=>3, "aag"=>1, "tcc"=>1, "atg"=>1}


* Calculate molecular weight for each 10-aa peptide (or 10-nt nucleic acid)

   bioruby> a = []
   bioruby> seq.window_search(10, 10) { |s| a.push s.molecular_weight }
   bioruby> a
   ==> [3096.2062, 3086.1962, 3056.1762, 3023.1262, 3073.2262]

In most cases, sequences are read from files or retrieved from databases.
For example:

    require 'bio'

    input_seq = ARGF.read       # reads all files in arguments

    my_naseq = Bio::Sequence::NA.new(input_seq)
    my_aaseq = my_naseq.translate

    puts my_aaseq

Save the program above as na2aa.rb. Prepare a nucleic acid sequence
described below and save it as my_naseq.txt:

      gtggcgatctttccgaaagcgatgactggagcgaagaaccaaagcagtgacatttgtctg
      atgccgcacgtaggcctgataagacgcggacagcgtcgcatcaggcatcttgtgcaaatg
      tcggatgcggcgtga

na2aa.rb translates a nucleic acid sequence to a protein sequence.
For example, translates my_naseq.txt:

    % ruby na2aa.rb my_naseq.txt

or use a pipe!

    % cat my_naseq.txt|ruby na2aa.rb

Outputs

    VAIFPKAMTGAKNQSSDICLMPHVGLIRRGQRRIRHLVQMSDAA*

You can also write this, a bit fancifully, as a one-liner script.

    % ruby -r bio -e 'p Bio::Sequence::NA.new($<.read).translate' my_naseq.txt

In the next section we will retrieve data from databases instead of using raw
sequence files. One generic example of the above can be found in
./sample/na2aa.rb.

== Parsing GenBank data (Bio::GenBank class)

We assume that you already have some GenBank data files. (If you don't,
download some .seq files from ftp://ftp.ncbi.nih.gov/genbank/)

As an example we will fetch the ID, definition and sequence of each entry
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
      puts gb.naseq                     # Nucleic acid sequence 
                                        # (Bio::Sequence::NA object)
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

In the above two scripts, the first arguments of Bio::FlatFile.new are
database classes of BioRuby. This is expanded on in a later section.

Again another option is to use the Bio::DB.open class:

    #!/usr/bin/env ruby

    require 'bio'

    ff = Bio::GenBank.open("gbvrl1.seq")
    ff.each_entry do |gb|
      definition = "#{gb.accession} #{gb.definition}"
      puts gb.naseq.to_fasta(definition, 60)
    end

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
  by using qualifiers as keys. But there is a risk some information is lost  when two or more qualifiers are the same. Therefore an Array is returned by  Feature#feature.

Bio::Sequence#splicing splices subsequences from nucleic acid sequences
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

You can also use this splicing method for amino acid sequences
(Bio::Sequence::AA objects).

* Splicing peptide from a protein (e.g. signal peptide)

    aaseq.splicing('21..119')


=== More databases

Databases in BioRuby are essentially accessed like that of GenBank
with classes like Bio::GenBank, Bio::KEGG::GENES. A full list can be found in 
the ./lib/bio/db directory of the BioRuby source tree.

In many cases the Bio::DatabaseClass acts as a factory pattern
and recognises the database type automatically - returning a
parsed object. For example using Bio::FlatFile class as described above. The first argument of the Bio::FlatFile.new is database class name in BioRuby (such as Bio::GenBank, Bio::KEGG::GENES and so on).

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

An example that can take any input, filter using a regular expression and output
to a FASTA file can be found in sample/any2fasta.rb. With this technique it is
possible to write a Unix type grep/sort pipe for sequence information. One
example using scripts in the BIORUBY sample folder:

 fastagrep.rb '/At|Dm/' database.seq | fastasort.rb

greps the database for Arabidopsis and Drosophila entries and sorts the output to FASTA.

Other methods to extract specific data from database objects can be
different between databases, though some methods are common (see the
guidelines for common methods in bio/db.rb).

  * entry_id --> gets ID of the entry
  * definition --> gets definition of the entry
  * reference --> gets references as Bio::Reference object
  * organism --> gets species
  * seq, naseq, aaseq --> returns sequence as corresponding sequence object

Refer to the documents of each database to find the exact naming
of the included methods.

In general, BioRuby uses the following conventions: when a method
name is plural, the method returns some object as an Array. For
example, some classes have a "references" method which returns
multiple Bio::Reference objects as an Array. And some classes have a
"reference" method which returns a single Bio::Reference object.

=== Alignments (Bio::Alignment)

The Bio::Alignment class in bio/alignment.rb is a container class like Ruby's Hash and Array classes and BioPerl's Bio::SimpleAlign.  A very simple example is:

  bioruby> seqs = [ 'atgca', 'aagca', 'acgca', 'acgcg' ]
  bioruby> seqs = seqs.collect{ |x| Bio::Sequence::NA.new(x) }
  # creates alignment object
  bioruby> a = Bio::Alignment.new(seqs)
  bioruby> a.consensus 
  ==> "a?gc?"
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

Read a ClustalW or Muscle 'ALN' alignment file:
 
  bioruby> aln = Bio::ClustalW::Report.new(File.read('../test/data/clustalw/example1.aln'))
  bioruby> aln.header
  ==> "CLUSTAL 2.0.9 multiple sequence alignment"

Fetch a sequence:

  bioruby> seq = aln[1]
  bioruby> seq.definition
  ==> "gi|115023|sp|P10425|"

Get a partial sequence:
  
  bioruby> seq.to_s[60..120]
  ==> "LGYFNG-EAVPSNGLVLNTSKGLVLVDSSWDNKLTKELIEMVEKKFQKRVTDVIITHAHAD"

Show the full alignment residue match information for the sequences in the set:

  bioruby> aln.match_line[60..120]
  ==> "     .     **. .   ..   ::*:       . * : : .        .: .* * *"

Return a Bio::Alignment object:

  bioruby> aln.alignment.consensus[60..120]
  ==> "???????????SN?????????????D??????????L??????????????????H?H?D"

== Restriction Enzymes (Bio::RE)

BioRuby has extensive support for restriction enzymes (REs). It contains a full
library of commonly used REs (from REBASE) which can be used to cut single
stranded RNA or double stranded DNA into fragments. To list all enzymes:

  rebase = Bio::RestrictionEnzyme.rebase
  rebase.each do |enzyme_name, info|
    p enzyme_name
  end

and to cut a sequence with an enzyme follow up with:

   res = seq.cut_with_enzyme('EcoRII', {:max_permutations => 0}, 
     {:view_ranges => true})
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
can use the ssearch program instead of fasta when you use it in your
local machine.

=== using FASTA in local machine

Install the fasta program on your machine (the command name looks like
fasta34. FASTA can be downloaded from ftp://ftp.virginia.edu/pub/fasta/).

First, you must prepare your FASTA-formatted database sequence file
target.pep and FASTA-formatted query.pep. 

    #!/usr/bin/env ruby

    require 'bio'

    # Creates FASTA factory object ("ssearch" instead of 
    # "fasta34" can also work)
    factory = Bio::Fasta.local('fasta34', ARGV.pop)
    (EDITOR's NOTE: not consistent pop command)

    ff = Bio::FlatFile.new(Bio::FastaFormat, ARGF)

    # Iterates over each entry. the variable "entry" is a 
    # Bio::FastaFormat object:
    ff.each do |entry|
      # shows definition line (begins with '>') to the standard error output
      $stderr.puts "Searching ... " + entry.definition

      # executes homology search. Returns Bio::Fasta::Report object.
      report = factory.query(entry)

      # Iterates over each hit
      report.each do |hit|
        # If E-value is smaller than 0.0001
        if hit.evalue < 0.0001
          # shows identifier of query and hit, E-value, start and 
          # end positions of homologous region 
          print "#{hit.query_id} : evalue #{hit.evalue}\t#{hit.target_id} at "
          p hit.lap_at
        end
      end
    end

We named above script f_search.rb. You can execute it as follows:

    % ./f_search.rb query.pep target.pep > f_search.out

In above script, the variable "factory" is a factory object for executing
FASTA many times easily. Instead of using Fasta#query method,
Bio::Sequence#fasta method can be used.

    seq = ">test seq\nYQVLEEIGRGSFGSVRKVIHIPTKKLLVRKDIKYGHMNSKE"
    seq.fasta(factory)

When you want to add options to FASTA commands, you can set the
third argument of the Bio::Fasta.local method. For example, the following sets ktup to 1 and gets a list of the top 10 hits:

    factory = Bio::Fasta.local('fasta34', 'target.pep', '-b 10')
    factory.ktup = 1

Bio::Fasta#query returns a Bio::Fasta::Report object.
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
      puts hit.query_seq        # sequence of homologous region
      puts hit.target_id        # identifier of hit sequence
      puts hit.target_def       # definition(comment line) of hit sequence
      puts hit.target_len       # length of hit sequence
      puts hit.target_seq       # hit of homologous region of hit sequence
      puts hit.query_start      # start position of homologous 
                                # region in query sequence
      puts hit.query_end        # end position of homologous region 
                                # in query sequence
      puts hit.target_start     # start posiotion of homologous region 
                                # in hit(target) sequence
      puts hit.target_end       # end position of homologous region 
                                # in hit(target) sequence
      puts hit.lap_at           # array of above four numbers
    end

Most of above methods are common to the Bio::Blast::Report described
below. Please refer to the documentation of the Bio::Fasta::Report class for
FASTA-specific details.

If you need the original output text of FASTA program you can use the "output" method of the factory object after the "query" method.

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

  * When query is an amino acid sequence
    * When protein database, program is "fasta".
    * When nucleic database, program is "tfasta".

  * When query is a nucleic acid sequence
    * When nucleic database, program is "fasta".
    * (When protein database, the search would fail.)

For example, run:

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
Ruby version 1.8.0 or later, REXML is bundled with Ruby's
distribution.

When no XML parser library is present, Bio::BLAST uses "-m 8" tabular
deliminated format. Available information is limited with the
"-m 8" format so installing an XML parser is recommended.

Again, the methods in Bio::Fasta::Report and Bio::Blast::Report (and
Bio::Fasta::Report::Hit and Bio::Blast::Report::Hit) are similar.
There are some additional BLAST methods, for example, bit_score and
midline.

    report.each do |hit|
      puts hit.bit_score       
      puts hit.query_seq       
      puts hit.midline         
      puts hit.target_seq      

      puts hit.evalue          
      puts hit.identity        
      puts hit.overlap         
      puts hit.query_id        
      puts hit.query_def       
      puts hit.query_len       
      puts hit.target_id       
      puts hit.target_def      
      puts hit.target_len      
      puts hit.query_start     
      puts hit.query_end       
      puts hit.target_start    
      puts hit.target_end      
      puts hit.lap_at          
    end

For simplicity and API compatibility, some information such as score
is extracted from the first Hsp (High-scoring Segment Pair).

Check the documentation for Bio::Blast::Report to see what can be
retrieved. For now suffice to say that Bio::Blast::Report has a
hierarchical structure mirroring the general BLAST output stream:

  * In a Bio::Blast::Report object, @iterations is an array of
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

* For example: 

    blast_version = nil; result = []
    Bio::Blast.reports(File.new("../test/data/blast/blastp-multi.m7")) do |report|
      blast_version = report.version
      report.iterations.each do |itr|
        itr.hits.each do |hit|
          result.push hit.target_id
        end
      end
    end
    blast_version
    # ==> "blastp 2.2.18 [Mar-02-2008]"
    result
    # ==> ["BAB38768", "BAB38768", "BAB38769", "BAB37741"]

* another example:

    require 'bio'
    Bio::Blast.reports(ARGF) do |report| 
      puts "Hits for " + report.query_def + " against " + report.db
      report.each do |hit|
        print hit.target_id, "\t", hit.evalue, "\n" if hit.evalue < 0.001
      end
    end

Save the script as hits_under_0.001.rb and to process BLAST output
files *.xml, you can run it with:

   % ruby hits_under_0.001.rb *.xml

Sometimes BLAST XML output may be wrong and can not be parsed. Check whether 
blast is version 2.2.5 or later. See also blast --help. 

Bio::Blast loads the full XML file into memory. If this causes a problem
you can split the BLAST XML file into smaller chunks using XML-Twig. An
example can be found in ((<Biotools|URL:http://github.com/pjotrp/biotools/>)).

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

When you write above routines, please send them to the BioRuby project, and they may be included in future releases.

== Generate a reference list using PubMed (Bio::PubMed)

Nowadays using NCBI E-Utils is recommended. Use Bio::PubMed.esearch
and Bio::PubMed.efetch.

    #!/usr/bin/env ruby

    require 'bio'

    # NCBI announces that queries without email address will return error
    # after June 2010. When you modify the script, please enter your email
    # address instead of the staff's.
    Bio::NCBI.default_email = 'staff@bioruby.org'

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
on using BibTex see ((<BibTex HowTo site|URL:http://www.bibtex.org/Using/>)). A quick example:

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

Now, you get hoge.dvi and hoge.ps - the latter of which can be viewed with any Postscript viewer.

=== Bio::Reference#bibitem

When you don't want to create a bib file, you can use
Bio::Reference#bibitem method instead of Bio::Reference#bibtex.
In the above pmfetch.rb and pmsearch.rb scripts, change

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
  * Schemas to store sequence data to relational databases such as
    MySQL and PostgreSQL, and methods to retrieve entries from the database.

This tutorial only gives a quick overview of OBDA. Check out
((<the OBDA site|URL:http://obda.open-bio.org>)) for more extensive details.

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
database in the system's global configuration file
(/etc/bioinformatics/seqdatabase.ini), you can easily override them by
writing settings to ~/.bioinformatics/seqdatabase.ini.

The syntax of the configuration file is called a stanza format. For example

    [DatabaseName]
    protocol=ProtocolName
    location=ServerName

You can write a description like the above entry for every database.

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

Here is an example. It creates a Bio::Registry object and reads the configuration files:

    reg = Bio::Registry.new

    # connects to the database "genbank"
    serv = reg.get_database('genbank')

    # gets entry of the ID
    entry = serv.get_by_id('AA2CG')


The variable "serv" is a server object corresponding to the settings
written in the configuration files. The class of the object is one of
Bio::SQL, Bio::Fetch, and so on. Note that Bio::Registry#get_database("name")
returns nil if no database is found.

After that, you can use the get_by_id method and some specific methods.
Please refer to the sections below for more information.

== BioFlat

BioFlat is a mechanism to create index files of flat files and to retrieve
these entries fast. There are two index types. index-flat is a simple index
performing binary search without using an external library of Ruby. index-berkeleydb
uses Berkeley DB for indexing - but requires installing bdb on your computer,
as well as the BDB Ruby package. For creating the index itself, you can use br_bioflat.rb command bundled with BioRuby.

    % br_bioflat.rb --makeindex database_name [--format data_format] filename...

The format can be omitted because BioRuby has autodetection.  If that
does not work you can try specifying data format as the name of a BioRuby database class.

Search and retrieve data from database:

    % br_bioflat.rb database_name identifier

For example, to create index of GenBank files gbbct*.seq and get the entry from the database:

    % br_bioflat.rb --makeindex my_bctdb --format GenBank gbbct*.seq
    % br_bioflat.rb my_bctdb A16STM262

If you have Berkeley DB on your system and installed the bdb extension
module of Ruby (see ((<the BDB project page|URL:http://raa.ruby-lang.org/project/bdb/>)) ), you can
create and search indexes with Berkeley DB - a very fast alternative
that uses little computer memory. When creating the index, use the
"--makeindex-bdb" option instead of "--makeindex".

    % br_bioflat.rb --makeindex-bdb database_name [--format data_format] filename...

== BioFetch

  Note: this section is an advanced topic

BioFetch is a database retrieval mechanism via CGI. CGI Parameters,
options and error codes are standardized. Client access via
http is possible giving the database name, identifiers and format to
retrieve entries.

The BioRuby project has a BioFetch server at bioruby.org. It uses
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

If you want to use (4), you have to include some settings
in seqdatabase.ini. For example:

    [genbank]
    protocol=biofetch
    location=http://bioruby.org/cgi-bin/biofetch.rb
    biodbname=genbank

=== The combination of BioFetch, Bio::KEGG::GENES and Bio::AAindex1

Bioinformatics is often about gluing things together. Here is an
example that gets the bacteriorhodopsin gene (VNG1467G) of the archaea
Halobacterium from KEGG GENES database and gets alpha-helix index
data (BURA740101) from the AAindex (Amino acid indices and similarity
matrices) database, and shows the helix score for each 15-aa length
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

The special method Bio::Fetch.query uses the preset BioFetch server
at bioruby.org. (The server internally gets data from GenomeNet.
Because the KEGG/GENES database and AAindex database are not available
from other BioFetch servers, we used bioruby.org server with
Bio::Fetch.query method.)

== BioSQL

BioSQL is a well known schema to store and retrive biological sequences using a RDBMS like PostgreSQL or MySQL: note that SQLite is not supported.
First of all, you must install a database engine or have access to a remote one. Then create the schema and populate with the taxonomy. You can follow the ((<Official Guide|URL:http://code.open-bio.org/svnweb/index.cgi/biosql/view/biosql-schema/trunk/INSTALL>)) to accomplish these steps.
Next step is to install these gems:
* ActiveRecord
* CompositePrimaryKeys (Rails doesn't handle by default composite primary keys)
* The layer to comunicate with you preferred RDBMS (postgresql, mysql, jdbcmysql in case you are running JRuby )


You can find ActiveRecord's models in /bioruby/lib/bio/io/biosql

When you have your database up and running, you can connect to it like this:

    #!/usr/bin/env ruby
    
    require 'bio'

    connection = Bio::SQL.establish_connection({'development'=>{'hostname'=>"YourHostname",
    'database'=>"CoolBioSeqDB",
    'adapter'=>"jdbcmysql",
    'username'=>"YourUser",
    'password'=>"YouPassword"
          }
      },
    'development')

    #The first parameter is the hash contaning the description of the configuration; similar to database.yml in Rails applications, you can declare different environment. 
    #The second parameter is the environment to use: 'development', 'test', or 'production'.
    
    #To store a sequence into the database you simply need a biosequence object.
    biosql_database = Bio::SQL::Biodatabase.find(:first)
    ff = Bio::GenBank.open("gbvrl1.seq")
    
    ff.each_entry do |gb|
      Bio::SQL::Sequence.new(:biosequence=>gb.to_biosequence, :biodatabase=>biosql_database
    end

    #You can list all the entries into every database 
    Bio::SQL.list_entries

    #list databases:
    Bio::SQL.list_databases

    #retriving a generic accession
    bioseq = Bio::SQL.fetch_accession("YouAccession")

    #If you use biosequence objects, you will find all its method mapped to BioSQL sequences. 
    #But you can also access to the models directly:

    #get the raw sequence associated with your accession
    bioseq.entry.biosequence 
   
    #get the length of your sequence; this is the explicit form of bioseq.length
    bioseq.entry.biosequence.length

    #convert the sequence into GenBank format
    bioseq.to_biosequence.output(:genbank)

BioSQL's ((<schema|URL:http://www.biosql.org/wiki/Schema_Overview>)) is not very intuitive for beginners, so spend some time on understanding it. In the end if you know a little bit of Ruby on Rails, everything will go smoothly. You can find information on Annotation ((<here|URL:http://www.biosql.org/wiki/Annotation_Mapping>)).
ToDo: add exemaples from George. I remember he did some cool post on BioSQL and Rails.

= PhyloXML

PhyloXML is an XML language for saving, analyzing and exchanging data of 
annotated phylogenetic trees. PhyloXML's parser in BioRuby is implemented in 
Bio::PhyloXML::Parser, and its writer in Bio::PhyloXML::Writer. 
More information can be found at ((<www.phyloxml.org|URL:http://www.phyloxml.org>)).

== Requirements

In addition to BioRuby, you need the libxml Ruby bindings. To install, execute:

  % gem install -r libxml-ruby

For more information see the ((<libxml installer page|URL:http://libxml.rubyforge.org/install.xml>))

== Parsing a file

    require 'bio'
    
    # Create new phyloxml parser
    phyloxml = Bio::PhyloXML::Parser.open('example.xml')
    
    # Print the names of all trees in the file
    phyloxml.each do |tree|
      puts tree.name
    end

If there are several trees in the file, you can access the one you wish by specifying its index:

    tree = phyloxml[3]

You can use all Bio::Tree methods on the tree, since PhyloXML::Tree inherits from Bio::Tree. For example, 

   tree.leaves.each do |node|
     puts node.name
   end

PhyloXML files can hold additional information besides phylogenies at the end of the file. This info can be accessed through the 'other' array of the parser object.

    phyloxml = Bio::PhyloXML::Parser.open('example.xml')
    while tree = phyloxml.next_tree
      # do stuff with trees
    end 
      
    puts phyloxml.other

== Writing a file

    # Create new phyloxml writer
    writer = Bio::PhyloXML::Writer.new('tree.xml')
   
    # Write tree to the file tree.xml
    writer.write(tree1) 
    
    # Add another tree to the file
    writer.write(tree2)

== Retrieving data

Here is an example of how to retrieve the scientific name of the clades included in each tree.

    require 'bio'
    
    phyloxml = Bio::PhyloXML::Parser.open('ncbi_taxonomy_mollusca.xml')
    phyloxml.each do |tree|
      tree.each_node do |node|
        print "Scientific name: ", node.taxonomies[0].scientific_name, "\n"
      end
    end

== Retrieving 'other' data

    require 'bio'
    
    phyloxml = Bio::PhyloXML::Parser.open('phyloxml_examples.xml')
    while tree = phyloxml.next_tree
     #do something with the trees
    end

    p phyloxml.other
    puts "\n"
    #=> output is an object representation
    
    #Print in a readable way
    puts phyloxml.other[0].to_xml, "\n"
    #=>:
    #
    #<align:alignment xmlns:align="http://example.org/align">
    #  <seq name="A">acgtcgcggcccgtggaagtcctctcct</seq>
    #  <seq name="B">aggtcgcggcctgtggaagtcctctcct</seq>
    #  <seq name="C">taaatcgc--cccgtgg-agtccc-cct</seq>
    #</align:alignment>
    
    #Once we know whats there, lets output just sequences
    phyloxml.other[0].children.each do |node|
     puts node.value
    end
    #=>
    #
    #acgtcgcggcccgtggaagtcctctcct
    #aggtcgcggcctgtggaagtcctctcct
    #taaatcgc--cccgtgg-agtccc-cct


== The BioRuby example programs

Some sample programs are stored in ./samples/ directory. For example, the n2aa.rb program (transforms a nucleic acid sequence into an amino acid sequence) can be run using:

  ./sample/na2aa.rb test/data/fasta/example1.txt 

== Unit testing and doctests

BioRuby comes with an extensive testing framework with over 1300 tests and 2700
assertions. To run the unit tests:

  cd test
  ruby runner.rb

We have also started with doctest for Ruby. We are porting the examples
in this tutorial to doctest - more info upcoming.

== Further reading

See the BioRuby in anger Wiki.  A lot of BioRuby's documentation exists in the
source code and unit tests. To really dive in you will need the latest source
code tree. The embedded rdoc documentation for the BioRuby source code can be viewed online at
((<URL:http://bioruby.org/rdoc/>)).

== BioRuby Shell

The BioRuby shell implementation is located in ./lib/bio/shell. It is very interesting
as it uses IRB (the Ruby intepreter) which is a powerful environment described in
((<Programming Ruby's IRB chapter|URL:http://ruby-doc.org/docs/ProgrammingRuby/html/irb.html>)). IRB commands can be typed directly into the shell, e.g.

  bioruby!> IRB.conf[:PROMPT_MODE]
  ==!> :PROMPT_C

Additionally, you also may want to install the optional Ruby readline support -
with Debian libreadline-ruby. To edit a previous line you may have to press
line down (down arrow) first.

= Helpful tools

Apart from rdoc you may also want to use rtags - which allows jumping around
source code by clicking on class and method names. 

  cd bioruby/lib
  rtags -R --vi

For a tutorial see ((<here|URL:http://rtags.rubyforge.org/>))

= APPENDIX

== KEGG API

Please refer to KEGG_API.rd.ja (English version: ((<URL:http://www.genome.jp/kegg/soap/doc/keggapi_manual.html>)) ) and

  * ((<URL:http://www.genome.jp/kegg/soap/>))

== Ruby Ensembl API

The Ruby Ensembl API is a Ruby API to the Ensembl database. It is NOT currently
included in the BioRuby archives. To install it, see
((<the Ruby-Ensembl Github|URL:http://wiki.github.com/jandot/ruby-ensembl-api>))
for more information.

=== Gene Ontology (GO) through the Ruby Ensembl API

Gene Ontologies can be fetched through the Ruby Ensembl API package:

   require 'ensembl'
   Ensembl::Core::DBConnection.connect('drosophila_melanogaster')
   infile = IO.readlines(ARGV.shift) # reading your comma-separated accession mapping file (one line per mapping)
   infile.each do |line|
     accs = line.split(",")          # Split the comma-sep.entries into an array
     drosphila_acc = accs.shift      # the first entry is the Drosophila acc
     mosq_acc = accs.shift           # the second entry is your Mosq. acc
     gene = Ensembl::Core::Gene.find_by_stable_id(drosophila_acc)
     print "#{mosq_acc}"
     gene.go_terms.each do |go|
        print ",#{go}"
     end
   end

Prints each mosq. accession/uniq identifier and the GO terms from the Drosphila
homologues.

== Using BioPerl or BioPython from Ruby

At the moment there is no easy way of accessing BioPerl from Ruby. The best way, perhaps, is to create a Perl server that gets accessed through XML/RPC or SOAP.

== Installing required external libraries

At this point for using BioRuby no additional libraries are needed, except if
you are using the Bio::PhyloXML module; then you have to install libxml-ruby.

This may change, so keep an eye on the Bioruby website. Also when
a package is missing BioRuby should show an informative message.

At this point installing third party Ruby packages can be a bit
painful, as the gem standard for packages evolved late and some still
force you to copy things by hand. Therefore read the README's
carefully that come with each package.

=== Installing libxml-ruby

The simplest way is to use gem packaging system:

  gem install -r libxml-ruby

If you get `require': no such file to load - mkmf (LoadError) error then do

  sudo apt-get install ruby-dev

If you have other problems with installation, then see ((<URL:http://libxml.rubyforge.org/install.xml>))  

== Trouble shooting

* Error: in `require': no such file to load -- bio (LoadError)

Ruby is failing to find the BioRuby libraries - add it to the RUBYLIB path, or pass
it to the interpeter. For example:

  ruby -I$BIORUBYPATH/lib yourprogram.rb

== Modifying this page

IMPORTANT NOTICE: This page is maintained in the BioRuby source code 
repository. Please edit the file there otherwise changes may get
lost. See ((<BioRuby Developer Information>)) for repository and mailing list
access.

=end
