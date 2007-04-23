#
# = bio/sequence/na.rb - nucleic acid sequence class
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>,
#               Ryan Raaum <ryan@raaum.org>
# License::     The Ruby License
#
# $Id: na.rb,v 1.7 2007/04/23 16:43:51 trevor Exp $
#

require 'bio/sequence/common'

module Bio

  autoload :NucleicAcid, 'bio/data/na'
  autoload :CodonTable,  'bio/data/codontable'

class Sequence


# = DESCRIPTION
# Bio::Sequence::NA represents a bare Nucleic Acid sequence in bioruby.
#
# = USAGE
#   # Create a Nucleic Acid sequence.
#   dna = Bio::Sequence.auto('atgcatgcATGCATGCAAAA')
#   rna = Bio::Sequence.auto('augcaugcaugcaugcaaaa')
#
#   # What are the names of all the bases?
#   puts dna.names
#   puts rna.names
#
#   # What is the GC percentage?
#   puts dna.gc_percent
#   puts rna.gc_percent
#
#   # What is the molecular weight?
#   puts dna.molecular_weight
#   puts rna.molecular_weight
#
#   # What is the reverse complement?
#   puts dna.reverse_complement
#   puts dna.complement
#
#   # Is this sequence DNA or RNA?
#   puts dna.rna?
#
#   # Translate my sequence (see method docs for many options)
#   puts dna.translate
#   puts rna.translate
class NA < String

  include Bio::Sequence::Common

  # Generate an nucleic acid sequence object from a string.
  #
  #   s = Bio::Sequence::NA.new("aagcttggaccgttgaagt")
  #
  # or maybe (if you have an nucleic acid sequence in a file)
  #
  #   s = Bio::Sequence:NA.new(File.open('dna.txt').read)
  #
  # Nucleic Acid sequences are *always* all lowercase in bioruby
  #
  #   s = Bio::Sequence::NA.new("AAGcTtGG")
  #   puts s                                  #=> "aagcttgg"
  #
  # Whitespace is stripped from the sequence
  #
  #   seq = Bio::Sequence::NA.new("atg\nggg\ttt\r  gc")
  #   puts s                                  #=> "atggggttgc"
  # ---
  # *Arguments*:
  # * (required) _str_: String
  # *Returns*:: Bio::Sequence::NA object
  def initialize(str)
    super
    self.downcase!
    self.tr!(" \t\n\r",'')
  end

  # Alias of Bio::Sequence::Common splice method, documented there.
  def splicing(position) #:nodoc:
    mRNA = super
    if mRNA.rna?
      mRNA.tr!('t', 'u')
    else
      mRNA.tr!('u', 't')
    end
    mRNA
  end

  # Returns a new complementary sequence object (without reversing).
  # The original sequence object is not modified.
  #
  #   s = Bio::Sequence::NA.new('atgc')
  #   puts s.forward_complement               #=> 'tacg'
  #   puts s                                  #=> 'atgc'
  # ---
  # *Returns*:: new Bio::Sequence::NA object
  def forward_complement
    s = self.class.new(self)
    s.forward_complement!
    s
  end

  # Converts the current sequence into its complement (without reversing).
  # The original sequence object is modified.
  #
  #   seq = Bio::Sequence::NA.new('atgc')
  #   puts s.forward_complement!              #=> 'tacg'
  #   puts s                                  #=> 'tacg'
  # ---
  # *Returns*:: current Bio::Sequence::NA object (modified)
  def forward_complement!
    if self.rna?
      self.tr!('augcrymkdhvbswn', 'uacgyrkmhdbvswn')
    else
      self.tr!('atgcrymkdhvbswn', 'tacgyrkmhdbvswn')
    end
    self
  end

  # Returns a new sequence object with the reverse complement 
  # sequence to the original.  The original sequence is not modified.
  #
  #   s = Bio::Sequence::NA.new('atgc')
  #   puts s.reverse_complement               #=> 'gcat'
  #   puts s                                  #=> 'atgc'
  # ---
  # *Returns*:: new Bio::Sequence::NA object
  def reverse_complement
    s = self.class.new(self)
    s.reverse_complement!
    s
  end

  # Converts the original sequence into its reverse complement.  
  # The original sequence is modified.
  #
  #   s = Bio::Sequence::NA.new('atgc')
  #   puts s.reverse_complement               #=> 'gcat'
  #   puts s                                  #=> 'gcat'
  # ---
  # *Returns*:: current Bio::Sequence::NA object (modified)
  def reverse_complement!
    self.reverse!
    self.forward_complement!
  end

  # Alias for Bio::Sequence::NA#reverse_complement
  alias complement reverse_complement
  
  # Alias for Bio::Sequence::NA#reverse_complement!
  alias complement! reverse_complement!


  # Translate into an amino acid sequence.
  #   
  #   s = Bio::Sequence::NA.new('atggcgtga')
  #   puts s.translate                        #=> "MA*"
  #
  # By default, translate starts in reading frame position 1, but you
  # can start in either 2 or 3 as well,
  #
  #   puts s.translate(2)                     #=> "WR"
  #   puts s.translate(3)                     #=> "GV"
  #
  # You may also translate the reverse complement in one step by using frame
  # values of -1, -2, and -3 (or 4, 5, and 6)
  #
  #   puts s.translate(-1)                    #=> "SRH"
  #   puts s.translate(4)                     #=> "SRH"
  #   puts s.reverse_complement.translate(1)  #=> "SRH"
  #
  # The default codon table in the translate function is the Standard
  # Eukaryotic codon table.  The translate function takes either a 
  # number or a Bio::CodonTable object for its table argument. 
  # The available tables are 
  # (NCBI[http://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi?mode=t]):
  #
  #   1. "Standard (Eukaryote)"
  #   2. "Vertebrate Mitochondrial"
  #   3. "Yeast Mitochondorial"
  #   4. "Mold, Protozoan, Coelenterate Mitochondrial and Mycoplasma/Spiroplasma"
  #   5. "Invertebrate Mitochondrial"
  #   6. "Ciliate Macronuclear and Dasycladacean"
  #   9. "Echinoderm Mitochondrial"
  #   10. "Euplotid Nuclear"
  #   11. "Bacteria"
  #   12. "Alternative Yeast Nuclear"
  #   13. "Ascidian Mitochondrial"
  #   14. "Flatworm Mitochondrial"
  #   15. "Blepharisma Macronuclear"
  #   16. "Chlorophycean Mitochondrial"
  #   21. "Trematode Mitochondrial"
  #   22. "Scenedesmus obliquus mitochondrial"
  #   23. "Thraustochytrium Mitochondrial"
  #
  # If you are using anything other than the default table, you must specify 
  # frame in the translate method call,
  #
  #   puts s.translate                #=> "MA*"  (using defaults)
  #   puts s.translate(1,1)           #=> "MA*"  (same as above, but explicit)
  #   puts s.translate(1,2)           #=> "MAW"  (different codon table)
  #
  # and using a Bio::CodonTable instance in the translate method call,
  #
  #   mt_table = Bio::CodonTable[2]
  #   puts s.translate(1, mt_table)           #=> "MAW"
  #
  # By default, any invalid or unknown codons (as could happen if the 
  # sequence contains ambiguities) will be represented by 'X' in the 
  # translated sequence. 
  # You may change this to any character of your choice.
  #
  #   s = Bio::Sequence::NA.new('atgcNNtga')
  #   puts s.translate                        #=> "MX*"
  #   puts s.translate(1,1,'9')               #=> "M9*"
  #
  # The translate method considers gaps to be unknown characters and treats 
  # them as such (i.e. does not collapse sequences prior to translation), so
  #
  #   s = Bio::Sequence::NA.new('atgc--tga')
  #   puts s.translate                        #=> "MX*"
  # ---
  # *Arguments*:
  # * (optional) _frame_:  one of 1,2,3,4,5,6,-1,-2,-3 (default 1)
  # * (optional) _table_: Fixnum in range 1,23 or Bio::CodonTable object
  #   (default 1)
  # * (optional) _unknown_: Character (default 'X')
  # *Returns*:: Bio::Sequence::AA object
  def translate(frame = 1, table = 1, unknown = 'X')
    if table.is_a?(Bio::CodonTable)
      ct = table
    else
      ct = Bio::CodonTable[table]
    end
    naseq = self.dna
    case frame
    when 1, 2, 3
      from = frame - 1
    when 4, 5, 6
      from = frame - 4
      naseq.complement!
    when -1, -2, -3
      from = -1 - frame
      naseq.complement!
    else
      from = 0
    end
    nalen = naseq.length - from
    nalen -= nalen % 3
    aaseq = naseq[from, nalen].gsub(/.{3}/) {|codon| ct[codon] or unknown}
    return Bio::Sequence::AA.new(aaseq)
  end

  # Returns counts of each codon in the sequence in a hash.
  #
  #   s = Bio::Sequence::NA.new('atggcgtga')
  #   puts s.codon_usage                #=> {"gcg"=>1, "tga"=>1, "atg"=>1}
  #
  # This method does not validate codons!  Any three letter group is a 'codon'. So,
  #
  #   s = Bio::Sequence::NA.new('atggNNtga')
  #   puts s.codon_usage                #=> {"tga"=>1, "gnn"=>1, "atg"=>1}
  #
  #   seq = Bio::Sequence::NA.new('atgg--tga')
  #   puts s.codon_usage                #=> {"tga"=>1, "g--"=>1, "atg"=>1}
  #
  # Also, there is no option to work in any frame other than the first.
  # ---
  # *Returns*:: Hash object
  def codon_usage
    hash = Hash.new(0)
    self.window_search(3, 3) do |codon|
      hash[codon] += 1
    end
    return hash
  end

  # Calculate the ratio of GC / ATGC bases as a percentage rounded to 
  # the nearest whole number. U is regarded as T.
  #
  #   s = Bio::Sequence::NA.new('atggcgtga')
  #   puts s.gc_percent                       #=> 55
  # ---
  # *Returns*:: Fixnum
  def gc_percent
    count = self.composition
    at = count['a'] + count['t'] + count['u']
    gc = count['g'] + count['c']
    return 0 if at + gc == 0
    gc = 100 * gc / (at + gc)
    return gc
  end

  # Calculate the ratio of GC / ATGC bases. U is regarded as T.
  #
  #   s = Bio::Sequence::NA.new('atggcgtga')
  #   puts s.gc_content                       #=> 0.555555555555556
  # ---
  # *Returns*:: Float
  def gc_content
    count = self.composition
    at = count['a'] + count['t'] + count['u']
    gc = count['g'] + count['c']
    return 0.0 if at + gc == 0
    return gc.quo(at + gc)
  end

  # Calculate the ratio of AT / ATGC bases. U is regarded as T.
  #
  #   s = Bio::Sequence::NA.new('atggcgtga')
  #   puts s.at_content                       #=> 0.444444444444444
  # ---
  # *Returns*:: Float
  def at_content
    count = self.composition
    at = count['a'] + count['t'] + count['u']
    gc = count['g'] + count['c']
    return 0.0 if at + gc == 0
    return at.quo(at + gc)
  end

  # Calculate the ratio of (G - C) / (G + C) bases.
  #
  #   s = Bio::Sequence::NA.new('atggcgtga')
  #   puts s.gc_skew                          #=> 0.6
  # ---
  # *Returns*:: Float
  def gc_skew
    count = self.composition
    g = count['g']
    c = count['c']
    return 0.0 if g + c == 0
    return (g - c).quo(g + c)
  end

  # Calculate the ratio of (A - T) / (A + T) bases. U is regarded as T.
  #
  #   s = Bio::Sequence::NA.new('atgttgttgttc')
  #   puts s.at_skew                          #=> -0.75
  # ---
  # *Returns*:: Float
  def at_skew
    count = self.composition
    a = count['a']
    t = count['t'] + count['u']
    return 0.0 if a + t == 0
    return (a - t).quo(a + t)
  end

  # Returns an alphabetically sorted array of any non-standard bases 
  # (other than 'atgcu').
  #
  #   s = Bio::Sequence::NA.new('atgStgQccR')
  #   puts s.illegal_bases                    #=> ["q", "r", "s"]
  # ---
  # *Returns*:: Array object
  def illegal_bases
    self.scan(/[^atgcu]/).sort.uniq
  end

  # Estimate molecular weight (using the values from BioPerl's 
  # SeqStats.pm[http://doc.bioperl.org/releases/bioperl-1.0.1/Bio/Tools/SeqStats.html] module).
  #
  #   s = Bio::Sequence::NA.new('atggcgtga')
  #   puts s.molecular_weight                 #=> 2841.00708
  #
  # RNA and DNA do not have the same molecular weights,
  #
  #   s = Bio::Sequence::NA.new('auggcguga')
  #   puts s.molecular_weight                 #=> 2956.94708
  # ---
  # *Returns*:: Float object
  def molecular_weight
    if self.rna?
      Bio::NucleicAcid.weight(self, true)
    else
      Bio::NucleicAcid.weight(self)
    end
  end

  # Create a ruby regular expression instance 
  # (Regexp)[http://corelib.rubyonrails.org/classes/Regexp.html]  
  #
  #   s = Bio::Sequence::NA.new('atggcgtga')
  #   puts s.to_re                            #=> /atggcgtga/
  # ---
  # *Returns*:: Regexp object
  def to_re
    if self.rna?
      Bio::NucleicAcid.to_re(self.dna, true)
    else
      Bio::NucleicAcid.to_re(self)
    end
  end

  # Generate the list of the names of each nucleotide along with the
  # sequence (full name).  Names used in bioruby are found in the
  # Bio::AminoAcid::NAMES hash.
  #
  #   s = Bio::Sequence::NA.new('atg')
  #   puts s.names                    #=> ["Adenine", "Thymine", "Guanine"]
  # ---
  # *Returns*:: Array object
  def names
    array = []
    self.each_byte do |x|
      array.push(Bio::NucleicAcid.names[x.chr.upcase])
    end
    return array
  end

  # Returns a new sequence object with any 'u' bases changed to 't'.
  # The original sequence is not modified.
  #
  #   s = Bio::Sequence::NA.new('augc')
  #   puts s.dna                              #=> 'atgc'
  #   puts s                                  #=> 'augc'
  # ---
  # *Returns*:: new Bio::Sequence::NA object
  def dna
    self.tr('u', 't')
  end

  # Changes any 'u' bases in the original sequence to 't'.
  # The original sequence is modified.
  #
  #   s = Bio::Sequence::NA.new('augc')
  #   puts s.dna!                             #=> 'atgc'
  #   puts s                                  #=> 'atgc'
  # ---
  # *Returns*:: current Bio::Sequence::NA object (modified)
  def dna!
    self.tr!('u', 't')
  end

  # Returns a new sequence object with any 't' bases changed to 'u'.
  # The original sequence is not modified.
  #
  #   s = Bio::Sequence::NA.new('atgc')
  #   puts s.dna                              #=> 'augc'  
  #   puts s                                  #=> 'atgc'
  # ---
  # *Returns*:: new Bio::Sequence::NA object
  def rna
    self.tr('t', 'u')
  end

  # Changes any 't' bases in the original sequence to 'u'.
  # The original sequence is modified.
  #
  #   s = Bio::Sequence::NA.new('atgc')
  #   puts s.dna!                             #=> 'augc'
  #   puts s                                  #=> 'augc'
  # ---
  # *Returns*:: current Bio::Sequence::NA object (modified)
  def rna!
    self.tr!('t', 'u')
  end

  def rna?
    self.index('u')
  end
  protected :rna?

  # Example:
  #
  #   seq = Bio::Sequence::NA.new('gaattc')
  #   cuts = seq.cut_with_enzyme('EcoRI')
  #
  # _or_
  #
  #   seq = Bio::Sequence::NA.new('gaattc')
  #   cuts = seq.cut_with_enzyme('g^aattc')
  # ---
  # See Bio::RestrictionEnzyme::Analysis.cut
  def cut_with_enzyme(*args)
    Bio::RestrictionEnzyme::Analysis.cut(self, *args)
  end
  alias cut_with_enzymes cut_with_enzyme

end # NA

end # Sequence

end # Bio

