= Incompatible and important changes since the BioRuby 0.6.4 release

A lot of changes have been made to the BioRuby after the version 0.6.4
is released.

--- Ruby 1.6 series are no longer supported.

We use autoload functionality and many other libraries bundled in
Ruby 1.8.2 (such as SOAP, open-uri, pp etc.) by default.

--- BioRuby will be loaded about 30 times faster than before.

As we changed to use autoload instead of require, time required
to start up the BioRuby library made surprisingly faster.

Other changes (including exciting BioRuby shell etc.) made in this release
is described in this file.

== New features

--- BioRuby shell

Command line user interface for the BioRuby is included.
You can invoke the shell by

  % bioruby

--- UnitTest

Test::Unit now covers wide range of the BioRuby library.
You can run them by

  % ruby test/runner.rb

or

  % ruby install.rb config
  % ruby install.rb setup
  % ruby install.rb test

during the installation procedure.

--- Documents

README, README.DEV, doc/Tutorial.rd, doc/Tutorial.rd.ja etc. are updated
or newly added.

== Incompatible changes

--- Bio::Sequence

* Bio::Sequence::NA#gc_percent returns integer instead of float
* Bio::Sequence::NA#gc (was aliased to gc_percent) is removed

Previously, GC% is rounded to one decimal place.  However, how many digits
should be left when rounding the value is not clear and as the GC% is an
rough measure by its nature, we have changed to return integer part only.
If you need a precise value, you can calculate it by values from the
'composition' method by your own criteria.

Also, the 'gc' method is removed as the method name doesn't represent
its value is ambiguous.

* Bio::Sequence#blast
* Bio::Sequence#fasta

These two methods are removed.  Use Bio::Blast and Bio::Fasta to execute
BLAST and FASTA search.

--- Bio::NucleicAcid

Bio::NucleicAcid::Names and Bio::NucleicAcid::Weight no longer exists.

Bio::NucleicAcid::Names is renamed to Bio::NucleicAcid::Data::NAMES and
can be accessed by Bio::NucleicAcid#names, Bio::NucleicAcid.names methods
and Bio::NucleicAcid::WEIGHT hash as the Data module is included.

Bio::NucleicAcid::Weight is renamed to Bio::NucleicAcid::Data::Weight and
can be accessed by Bio::NucleicAcid#weight, Bio::NucleicAcid.weight methods
and Bio::NucleicAcid::WEIGHT hash as the Data module is included.

--- Bio::AminoAcid

Bio::AminoAcid::Names and Bio::AminoAcid::Weight no longer exists.

Bio::AminoAcid::Names is renamed to Bio::AminoAcid::Data::NAMES and
can be accessed by Bio::AminoAcid#names, Bio::AminoAcid.names methods
and Bio::AminoAcid::WEIGHT hash as the Data module is included.

Bio::AminoAcid::Weight is renamed to Bio::AminoAcid::Data::Weight and
can be accessed by Bio::AminoAcid#weight, Bio::AminoAcid.weight methods
and Bio::AminoAcid::WEIGHT hash as the Data module is included.

--- Bio::CodonTable

Bio::CodonTable::Tables, Bio::CodonTable::Definitions,
Bio::CodonTable::Starts, and Bio::CodonTable::Stops
are renamed to
Bio::CodonTable::TABLES, Bio::CodonTable::DEFINITIONS,
Bio::CodonTable::STARTS, and Bio::CodonTable::STOPS
respectively.

--- Bio::KEGG::Microarrays, Bio::KEGG::Microarray

* lib/bio/db/kegg/microarray.rb is renamed to lib/bio/db/kegg/expression.rb
* Bio::KEGG::Microarray is renamed to Bio::KEGG::EXPRESSION
* Bio::KEGG::Microarrays is removed

Bio::KEGG::Microarrays was intended to store a series of microarray
expressions as a Hash of Array -like data structure,

  gene1 => [exp1, exp2, exp3, ... ]
  gene2 => [exp1, exp2, exp3, ... ]

however, it is not utilized well and more suitable container class
can be proposed.  Until then, this class is removed.

--- Bio::Pathway

* Bio::Pathway#nodes returns an Array of the node objects instead of
  the number of the node objects.
* Bio::Pathway#edges returns an Array of the edge objects instead of
  the number of the edge objects.

--- Bio::GenBank

Bio::GenBank#gc is removed as the value can be calculated by the
Bio::Sequence::NA#gc method and the method is also changed to
return integer instead of float.

Bio::GenBank#varnacular_name is renamed to Bio::GenBank#vernacular_name
as it was a typo.

--- Bio::GenBank::Common

* lib/bio/db/genbank/common.rb is removed.

Renamed to Bio::NCBIDB::Common for the simple autoload dependency.

--- Bio::EMBL::Common

* lib/bio/db/embl/common.rb is removed.

Renamed to Bio::EMBLDB::Common for the simple autoload dependency.

--- Bio::KEGG::GENES

* lib/bio/db/kegg/genes.rb

linkdb method is changed to return a Hash of an Array of entry IDs
instead of a Hash of a entry ID string.

=== Deleted files

: lib/bio/db/genbank.rb
: lib/bio/db/embl.rb

These files are removed as we changed to use autoload.  You can safely
replace

  require 'bio/db/genbank'

or

  require 'bio/db/embl'

in your code to

  require 'bio'

and this change will also speeds up loading time if you only need
one of the sub classes under the genbank/ or embl/ directory.

: lib/bio/extend.rb

This file contained some additional methods to String and Array classes.
The methods added to Array are already included in Ruby itself since the
version 1.8, and the methods added to String are moved to the BioRuby shell
(lib/bio/shell/plugin/seq.rb).


