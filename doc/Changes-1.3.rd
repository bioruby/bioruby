= Incompatible and important changes since the BioRuby 1.2.1 release

A lot of changes have been made to the BioRuby after the version 1.2.1
is released.

== New features

--- Support for sequence output with improvements of Bio::Sequence

Output of EMBL and GenBank formatted text are now supported in the
Bio::Sequence class. See the document of Bio::Sequence#output for details.
You can also create Bio::Sequence objects from many kinds of data such as
Bio::GenBank, Bio::EMBL, and Bio::FastaFormat by using the to_biosequence
method.

--- BioSQL support

BioSQL support is completely rewritten by using ActiveRecord.

--- Bio::Blast

Bio::Blast#reports can parse NCBI default (-m 0) format and tabular (-m 8)
format, in addition to XML (-m 7) format.

Bio::Blast.remote supports DDBJ, in addition to GenomeNet.
In addition, a list of available blast databases on remote sites
can be obtained by using Bio::Blast::Remote::DDBJ.databases and
Bio::Blast::Remote::GenomeNet.databases methods. Note that the above
remote blast methods may be changed in the future to support NCBI.

--- Bio::GFF::GFF2, Bio::GFF::GFF3

Output of GFF2/GFF3-formatted text are now supported. However, many
incompatible changes have been made (See below for details).

--- Bio::PAML::Codeml and Bio::PAML::Codeml::Report

Bio::PAML::Codeml, wrapper for PAML codeml program, and
Bio::PAML::Codeml::Report, parser for codeml result are newly added,
though some of them are still under construction and too specific to
particular use cases.

== Incompatible changes

--- Bio::Features

Bio::Features is obsoleted and changed to an array of Bio::Feature object
with some backward compatibility methods.  The backward compatibility methods
will soon be removed in the future.

--- Bio::References

Bio::References is obsoleted and changed to an array of Bio::Reference object
with some backward compatibility methods.  The backward compatibility methods
will soon be removed in the future.

--- Bio::Blast::Default::Report, Bio::Blast::Default::Report::Hit,
    Bio::Blast::Default::Report::HSP, Bio::Blast::WU::Report,
    Bio::Blast::WU::Report::Hit, Bio::Blast::WU::Report::HSP

Iteration#lambda, #kappa, #entropy, #gapped_lambda, #gapped_kappa,
and #gapped_entropy, and the same methods in the Report class are
changed to return float or nil instead of string or nil.

--- Bio::GFF, Bio::GFF2 and Bio::GFF3

Bio::GFF::Record#comments is renamed to #comment, and #comments= is
renamed to #comment=, because they only allow a single String (or nil)
and the plural form "comments" may be confusable.  The "comments" and
"comments=" methods can still be used, but warning messages will be
shown when using in GFF2::Record and GFF3::Record objects.

See below about GFF2 and/or GFF3 specific changes.

--- Bio::GFF::GFF2 and Bio::GFF::GFF3

Bio::GFF::GFF2::Record.new and Bio::GFF::GFF3::Record.new can also
get 9 arguments corresponding to GFF columns, which helps to create
Record object directly without formatted text.

Bio::GFF::GFF2::Record#start, #end, and #frame return Integer or nil,
and #score returns Float or nil, instead of String or nil.
The same changes are also made to Bio::GFF::GFF3::Record.

Bio::GFF::GFF2::Record#attributes and Bio::GFF::GFF3::Record#attributes
are changed to return a nested Array, containing [ tag, value ] pairs,
because of supporting multiple tags in the same tag names.  If you want
to get a Hash, use Record#attributes_to_hash method, though some
tag-value pairs in the same tag names may be lost.  Note that
Bio::GFF::Record#attribute still returns a Hash for compatibility.

New methods for getting, setting and manipulating attributes are added
to Bio::GFF::GFF2::Record and Bio::GFF::GFF3::Record classes:
attribute, get_attribute, get_attributes, set_attribute, replace_attributes,
add_attribute, delete_attribute, delete_attributes, sort_attributes_by_tag!.
It is recommended to use these methods instead of directly manipulating
the array returned by Record#attributes.

Bio::GFF::GFF2#to_s, Bio::GFF::GFF3#to_s, Bio::GFF::GFF2::Record#to_s,
and Bio::GFF::GFF3::Record#to_s are added to support output of
GFF2/GFF3 data.

--- Bio::GFF::GFF2

GFF2 attribute values are now automatically unescaped.  In addition,
if a value of an attribute is consisted of two or more tokens delimited
by spaces, an object of the new class Bio::GFF::GFF2::Record::Value is
returned instead of String.  The new class Bio::GFF::GFF2::Record::Value
aims to store a parsed value of an attribute.  If you really want to get
unparsed string, Bio::GFF::GFF2::Record::Value#to_s can be used.

The metadata (lines beginning with "##") are parsed to
Bio::GFF::GFF2::MetaData objects and are stored to Bio::GFF::GFF2#metadata
as an array, except the "##gff-version" line.  The "##gff-version" version
string is stored to the Bio::GFF::GFF2#gff_version as a string.

--- Bio::GFF::GFF3

Aliases of columns which are renamed in the GFF3 specification are added
to the Bio::GFF::GFF3::Record class: seqid (column 1; alias of "seqname"),
feature_type (column 3; alias of "feature"; in the GFF3 spec, it is
called "type", but because "type" is already used by Ruby, we use
"feature_type"), phase (column 8; formerly "frame"). Original names can
still be used because they are only aliases.

Sequences bundled within GFF3 after "##FASTA" are now supported
(Bio::GFF::GFF3#sequences).

GFF3 attribute keys and values are automatically unescaped. Each attribute
value is stored as a string, except for special attributes listed below:
* Bio::GFF::GFF3::Record::Target to store a "Target" attribute.
* Bio::GFF::GFF3::Record::Gap to store a "Gap" attribute.

The metadata (lines beginning with "##") are parsed to
Bio::GFF::GFF3::MetaData objects and stored to Bio::GFF::GFF3#metadata
as an array, except "##gff-version", "##sequence-region", "###",
and "##FASTA" lines.
* "##gff-version" version string is stored to Bio::GFF::GFF3#gff_version.
* "##sequence-region" lines are parsed to Bio::GFF::GFF3::SequenceRegion
  objects and stored to Bio::GFF::GFF3#sequence_regions as an array.
* "###" lines are parsed to Bio::GFF::GFF3::RecordBoundary objects.
* "##FASTA" is regarded as the beginning of bundled sequences.

--- Bio::SQL and BioSQL related classes

BioSQL support is completely rewritten by using ActiveRecord. See documents
in lib/bio/io/sql.rb, lib/bio/io/biosql, and lib/bio/db/biosql for details
of changes and usage of the classes/modules.

