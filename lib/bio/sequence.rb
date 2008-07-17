#
# = bio/sequence.rb - biological sequence class
#
# Copyright::   Copyright (C) 2000-2006
#               Toshiaki Katayama <k@bioruby.org>,
#               Yoshinori K. Okuji <okuji@enbug.org>,
#               Naohisa Goto <ng@bioruby.org>,
#               Ryan Raaum <ryan@raaum.org>,
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#
# $Id: sequence.rb,v 0.58.2.12 2008/06/17 15:25:22 ngoto Exp $
#

require 'bio/sequence/compat'

module Bio

# = DESCRIPTION
# Bio::Sequence objects represent annotated sequences in bioruby.
# A Bio::Sequence object is a wrapper around the actual sequence, 
# represented as either a Bio::Sequence::NA or a Bio::Sequence::AA object.
# For most users, this encapsulation will be completely transparent.
# Bio::Sequence responds to all methods defined for Bio::Sequence::NA/AA
# objects using the same arguments and returning the same values (even though 
# these methods are not documented specifically for Bio::Sequence).
#
# = USAGE
#   # Create a nucleic or amino acid sequence
#   dna = Bio::Sequence.auto('atgcatgcATGCATGCAAAA')
#   rna = Bio::Sequence.auto('augcaugcaugcaugcaaaa')
#   aa = Bio::Sequence.auto('ACDEFGHIKLMNPQRSTVWYU')
# 
#   # Print it out
#   puts dna.to_s
#   puts aa.to_s
# 
#   # Get a subsequence, bioinformatics style (first nucleotide is '1')
#   puts dna.subseq(2,6)
# 
#   # Get a subsequence, informatics style (first nucleotide is '0')
#   puts dna[2,6]
# 
#   # Print in FASTA format
#   puts dna.output(:fasta)
# 
#   # Print all codons
#   dna.window_search(3,3) do |codon|
#     puts codon
#   end
# 
#   # Splice or otherwise mangle your sequence
#   puts dna.splicing("complement(join(1..5,16..20))")
#   puts rna.splicing("complement(join(1..5,16..20))")
# 
#   # Convert a sequence containing ambiguity codes into a 
#   # regular expression you can use for subsequent searching
#   puts aa.to_re
# 
#   # These should speak for themselves
#   puts dna.complement
#   puts dna.composition
#   puts dna.molecular_weight
#   puts dna.translate
#   puts dna.gc_percent
class Sequence

  autoload :Common,  'bio/sequence/common'
  autoload :NA,      'bio/sequence/na'
  autoload :AA,      'bio/sequence/aa'
  autoload :Generic, 'bio/sequence/generic'
  autoload :Format,  'bio/sequence/format'
  autoload :Adapter, 'bio/sequence/adapter'

  include Format

  # Create a new Bio::Sequence object
  #
  #   s = Bio::Sequence.new('atgc')
  #   puts s                                  #=> 'atgc'
  #
  # Note that this method does not intialize the contained sequence
  # as any kind of bioruby object, only as a simple string
  #
  #   puts s.seq.class                        #=> String
  #
  # See Bio::Sequence#na, Bio::Sequence#aa, and Bio::Sequence#auto 
  # for methods to transform the basic String of a just created 
  # Bio::Sequence object to a proper bioruby object
  # ---
  # *Arguments*:
  # * (required) _str_: String or Bio::Sequence::NA/AA object
  # *Returns*:: Bio::Sequence object
  def initialize(str)
    @seq = str
  end

  # Pass any unknown method calls to the wrapped sequence object.  see
  # http://www.rubycentral.com/book/ref_c_object.html#Object.method_missing
  def method_missing(sym, *args, &block) #:nodoc:
    begin
      seq.__send__(sym, *args, &block)
    rescue NoMethodError => evar
      lineno = __LINE__ - 2
      file = __FILE__
      bt_here = [ "#{file}:#{lineno}:in \`__send__\'",
                  "#{file}:#{lineno}:in \`method_missing\'"
                ]
      if bt_here == evar.backtrace[0, 2] then
        bt = evar.backtrace[2..-1]
        evar = evar.class.new("undefined method \`#{sym.to_s}\' for #{self.inspect}")
        evar.set_backtrace(bt)
      end
      #p lineno
      #p file
      #p bt_here
      #p evar.backtrace
      raise(evar)
    end
  end
  
  # The sequence identifier (String).  For example, for a sequence
  # of Genbank origin, this is the locus name.
  # For a sequence of EMBL origin, this is the primary accession number.
  attr_accessor :entry_id
  
  # A String with a description of the sequence (String)
  attr_accessor :definition
  
  # Features (An Array of Bio::Feature objects)
  attr_accessor :features
  
  # References (An Array of Bio::Reference objects)
  attr_accessor :references
  
  # Comments (String or an Array of String)
  attr_accessor :comments
  
  # Keywords (An Array of String)
  attr_accessor :keywords
  
  # Links to other database entries.
  # (An Array of Bio::Sequence::DBLink objects)
  attr_accessor :dblinks

  # Bio::Sequence::NA/AA
  attr_accessor :moltype
  
  # The sequence object, usually Bio::Sequence::NA/AA, 
  # but could be a simple String
  attr_accessor :seq

  #---
  # Attributes below have been added during BioHackathon2008
  #+++
  
  # Version number of the sequence (String or Integer).
  # Unlike <tt>entry_version</tt>, <tt>sequence_version</tt> will be changed
  # when the submitter of the sequence updates the entry.
  # Normally, the same entry taken from different databases (EMBL, GenBank,
  # and DDBJ) may have the same sequence_version.
  attr_accessor :sequence_version

  # Topology (String). "circular", "linear", or nil.
  attr_accessor :topology

  # Strandedness (String). "single" (single-stranded),
  # "double" (double-stranded), "mixed" (mixed-stranded), or nil.
  attr_accessor :strandedness

  # molecular type (String). "DNA" or "RNA" for nucleotide sequence.
  attr_accessor :molecule_type

  # Data Class defined by EMBL (String)
  # See http://www.ebi.ac.uk/embl/Documentation/User_manual/usrman.html#3_1
  attr_accessor :data_class

  # Taxonomic Division defined by EMBL/GenBank/DDBJ (String)
  # See http://www.ebi.ac.uk/embl/Documentation/User_manual/usrman.html#3_2
  attr_accessor :division

  # Primary accession number (String)
  attr_accessor :primary_accession

  # Secondary accession numbers (Array of String)
  attr_accessor :secondary_accessions

  # Created date of the sequence entry (Date, DateTime, Time, or String)
  attr_accessor :date_created

  # Last modified date of the sequence entry (Date, DateTime, Time, or String)
  attr_accessor :date_modified

  # Release information when created (String)
  attr_accessor :release_created

  # Release information when last-modified (String)
  attr_accessor :release_modified

  # Version of the entry (String or Integer).
  # Unlike <tt>sequence_version</tt>, <tt>entry_version</tt> is a database
  # maintainer's internal version number.
  # The version number will be changed when the database maintainer
  # modifies the entry.
  # The same enrty in EMBL, GenBank, and DDBJ may have different
  # entry_version.
  attr_accessor :entry_version

  # Organism species (String). For example, "Escherichia coli".
  attr_accessor :species

  # Organism classification, taxonomic classification of the source organism.
  # (Array of String)
  attr_accessor :classification
  alias taxonomy classification

  # (not well supported) Organelle information (String).
  attr_accessor :organelle

  # Namespace of the sequence IDs described in entry_id, primary_accession,
  # and secondary_accessions methods (String).
  # For example, 'EMBL', 'GenBank', 'DDBJ', 'RefSeq'.
  attr_accessor :id_namespace

  # Sequence identifiers which are not described in entry_id,
  # primary_accession,and secondary_accessions methods
  # (Array of Bio::Sequence::DBLink objects).
  # For example, NCBI GI number can be stored.
  # Note that only identifiers of the entry itself should be stored.
  # For database cross references, <tt>dblinks</tt> should be used.
  attr_accessor :other_seqids

  # Guess the type of sequence, Amino Acid or Nucleic Acid, and create a 
  # new sequence object (Bio::Sequence::AA or Bio::Sequence::NA) on the basis
  # of this guess.  This method will change the current Bio::Sequence object.
  #
  #   s = Bio::Sequence.new('atgc')
  #   puts s.seq.class                        #=> String
  #   s.auto
  #   puts s.seq.class                        #=> Bio::Sequence::NA
  # ---
  # *Returns*:: Bio::Sequence::NA/AA object
  def auto
    @moltype = guess
    if @moltype == NA
      @seq = NA.new(seq)
    else
      @seq = AA.new(seq)
    end
  end

  # Given a sequence String, guess its type, Amino Acid or Nucleic Acid, and
  # return a new Bio::Sequence object wrapping a sequence of the guessed type
  # (either Bio::Sequence::AA or Bio::Sequence::NA)
  # 
  #   s = Bio::Sequence.auto('atgc')
  #   puts s.seq.class                        #=> Bio::Sequence::NA
  # ---
  # *Arguments*:
  # * (required) _str_: String *or* Bio::Sequence::NA/AA object
  # *Returns*:: Bio::Sequence object
  def self.auto(str)
    seq = self.new(str)
    seq.auto
    return seq
  end

  # Guess the class of the current sequence.  Returns the class
  # (Bio::Sequence::AA or Bio::Sequence::NA) guessed.  In general, used by
  # developers only, but if you know what you are doing, feel free.
  # 
  #   s = Bio::Sequence.new('atgc')
  #   puts s.guess                            #=> Bio::Sequence::NA
  #
  # There are three parameters: `threshold`, `length`, and `index`.  
  #
  # The `threshold` value (defaults to 0.9) is the frequency of 
  # nucleic acid bases [AGCTUagctu] required in the sequence for this method
  # to produce a Bio::Sequence::NA "guess".  In the default case, if less
  # than 90% of the bases (after excluding [Nn]) are in the set [AGCTUagctu],
  # then the guess is Bio::Sequence::AA.
  # 
  #   s = Bio::Sequence.new('atgcatgcqq')
  #   puts s.guess                            #=> Bio::Sequence::AA
  #   puts s.guess(0.8)                       #=> Bio::Sequence::AA
  #   puts s.guess(0.7)                       #=> Bio::Sequence::NA
  #
  # The `length` value is how much of the total sequence to use in the
  # guess (default 10000).  If your sequence is very long, you may 
  # want to use a smaller amount to reduce the computational burden.
  #
  #   s = Bio::Sequence.new(A VERY LONG SEQUENCE)
  #   puts s.guess(0.9, 1000)  # limit the guess to the first 1000 positions
  #
  # The `index` value is where to start the guess.  Perhaps you know there
  # are a lot of gaps at the start...
  #
  #   s = Bio::Sequence.new('-----atgcc')
  #   puts s.guess                            #=> Bio::Sequence::AA
  #   puts s.guess(0.9,10000,5)               #=> Bio::Sequence::NA
  # ---
  # *Arguments*:
  # * (optional) _threshold_: Float in range 0,1 (default 0.9)
  # * (optional) _length_: Fixnum (default 10000)
  # * (optional) _index_: Fixnum (default 1)
  # *Returns*:: Bio::Sequence::NA/AA
  def guess(threshold = 0.9, length = 10000, index = 0)
    str = seq.to_s[index,length].to_s.extend Bio::Sequence::Common
    cmp = str.composition

    bases = cmp['A'] + cmp['T'] + cmp['G'] + cmp['C'] + cmp['U'] +
            cmp['a'] + cmp['t'] + cmp['g'] + cmp['c'] + cmp['u']

    total = str.length - cmp['N'] - cmp['n']

    if bases.to_f / total > threshold
      return NA
    else
      return AA
    end
  end 

  # Guess the class of a given sequence.  Returns the class
  # (Bio::Sequence::AA or Bio::Sequence::NA) guessed.  In general, used by
  # developers only, but if you know what you are doing, feel free.
  # 
  #   puts .guess('atgc')        #=> Bio::Sequence::NA
  #
  # There are three optional parameters: `threshold`, `length`, and `index`.  
  #
  # The `threshold` value (defaults to 0.9) is the frequency of 
  # nucleic acid bases [AGCTUagctu] required in the sequence for this method
  # to produce a Bio::Sequence::NA "guess".  In the default case, if less
  # than 90% of the bases (after excluding [Nn]) are in the set [AGCTUagctu],
  # then the guess is Bio::Sequence::AA.
  # 
  #   puts Bio::Sequence.guess('atgcatgcqq')      #=> Bio::Sequence::AA
  #   puts Bio::Sequence.guess('atgcatgcqq', 0.8) #=> Bio::Sequence::AA
  #   puts Bio::Sequence.guess('atgcatgcqq', 0.7) #=> Bio::Sequence::NA
  #
  # The `length` value is how much of the total sequence to use in the
  # guess (default 10000).  If your sequence is very long, you may 
  # want to use a smaller amount to reduce the computational burden.
  #
  #   # limit the guess to the first 1000 positions
  #   puts Bio::Sequence.guess('A VERY LONG SEQUENCE', 0.9, 1000)  
  #
  # The `index` value is where to start the guess.  Perhaps you know there
  # are a lot of gaps at the start...
  #
  #   puts Bio::Sequence.guess('-----atgcc')             #=> Bio::Sequence::AA
  #   puts Bio::Sequence.guess('-----atgcc',0.9,10000,5) #=> Bio::Sequence::NA
  # ---
  # *Arguments*:
  # * (required) _str_: String *or* Bio::Sequence::NA/AA object
  # * (optional) _threshold_: Float in range 0,1 (default 0.9)
  # * (optional) _length_: Fixnum (default 10000)
  # * (optional) _index_: Fixnum (default 1)
  # *Returns*:: Bio::Sequence::NA/AA
  def self.guess(str, *args)
    self.new(str).guess(*args)
  end

  # Transform the sequence wrapped in the current Bio::Sequence object
  # into a Bio::Sequence::NA object.  This method will change the current
  # object.  This method does not validate your choice, so be careful!
  #
  #   s = Bio::Sequence.new('RRLE')
  #   puts s.seq.class                        #=> String
  #   s.na
  #   puts s.seq.class                        #=> Bio::Sequence::NA !!!
  #
  # However, if you know your sequence type, this method may be 
  # constructively used after initialization,
  #
  #   s = Bio::Sequence.new('atgc')
  #   s.na
  # ---
  # *Returns*:: Bio::Sequence::NA
  def na
    @seq = NA.new(seq)
    @moltype = NA
  end

  # Transform the sequence wrapped in the current Bio::Sequence object
  # into a Bio::Sequence::NA object.  This method will change the current
  # object.  This method does not validate your choice, so be careful!
  #
  #   s = Bio::Sequence.new('atgc')
  #   puts s.seq.class                        #=> String
  #   s.aa
  #   puts s.seq.class                        #=> Bio::Sequence::AA !!!
  #
  # However, if you know your sequence type, this method may be 
  # constructively used after initialization,
  #
  #   s = Bio::Sequence.new('RRLE')
  #   s.aa
  # ---
  # *Returns*:: Bio::Sequence::AA
  def aa
    @seq = AA.new(seq)
    @moltype = AA
  end

  # Create a new Bio::Sequence object from a formatted string
  # (GenBank, EMBL, fasta format, etc.)
  #
  #   s = Bio::Sequence.input(str)
  # ---
  # *Arguments*:
  # * (required) _str_: string
  # * (optional) _format_: format specification (class or nil)
  # *Returns*:: Bio::Sequence object
  def self.input(str, format = nil)
    if format then
      klass = format
    else
      klass = Bio::FlatFile::AutoDetect.default.autodetect(str)
    end
    obj = klass.new(str)
    obj.to_biosequence
  end

  # alias of Bio::Sequence.input
  def self.read(str, format = nil)
    input(str, format)
  end

  # accession numbers of the sequence
  #
  # *Returns*:: Array of String
  def accessions
    [ primary_accession, secondary_accessions ].flatten.compact
  end

  # Normally, users should not call this method directly.
  # Use Bio::*#to_biosequence (e.g. Bio::GenBank#to_biosequence).
  #
  # Creates a new Bio::Sequence object from database data with an
  # adapter module.
  def self.adapter(source_data, adapter_module)
    biosequence = self.new(nil)
    biosequence.instance_eval {
      remove_instance_variable(:@seq)
      @source_data = source_data
    }
    biosequence.extend(adapter_module)
    biosequence
  end

end # Sequence


end # Bio

