#
# = bio/sequence/na.rb - nucleic acid sequence class
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: na.rb,v 1.2 2006/02/06 14:13:52 k Exp $
#

require 'bio/sequence/common'

module Bio

  autoload :NucleicAcid, 'bio/data/na'
  autoload :CodonTable,  'bio/data/codontable'

class Sequence


# Nucleic Acid sequence
class NA < String

  include Bio::Sequence::Common

  # Generate a nucleic acid sequence object from a string.
  def initialize(str)
    super
    self.downcase!
    self.tr!(" \t\n\r",'')
  end

  # This method depends on Locations class, see bio/location.rb
  def splicing(position)
    mRNA = super
    if mRNA.rna?
      mRNA.tr!('t', 'u')
    else
      mRNA.tr!('u', 't')
    end
    mRNA
  end

  # Returns complement sequence without reversing ("atgc" -> "tacg")
  def forward_complement
    s = self.class.new(self)
    s.forward_complement!
    s
  end

  # Convert to complement sequence without reversing ("atgc" -> "tacg")
  def forward_complement!
    if self.rna?
      self.tr!('augcrymkdhvbswn', 'uacgyrkmhdbvswn')
    else
      self.tr!('atgcrymkdhvbswn', 'tacgyrkmhdbvswn')
    end
    self
  end

  # Returns reverse complement sequence ("atgc" -> "gcat")
  def reverse_complement
    s = self.class.new(self)
    s.reverse_complement!
    s
  end

  # Convert to reverse complement sequence ("atgc" -> "gcat")
  def reverse_complement!
    self.reverse!
    self.forward_complement!
  end

  # Aliases for short
  alias complement reverse_complement
  alias complement! reverse_complement!


  # Translate into the amino acid sequence from the given frame and the
  # selected codon table.  The table also can be a Bio::CodonTable object.
  # The 'unknown' character is used for invalid/unknown codon (can be
  # used for 'nnn' and/or gap translation in practice).
  #
  # Frame can be 1, 2 or 3 for the forward strand and -1, -2 or -3
  # (4, 5 or 6 is also accepted) for the reverse strand.
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

  # Returns counts of the each codon in the sequence by Hash.
  def codon_usage
    hash = Hash.new(0)
    self.window_search(3, 3) do |codon|
      hash[codon] += 1
    end
    return hash
  end

  # Calculate the ratio of GC / ATGC bases in percent.
  def gc_percent
    count = self.composition
    at = count['a'] + count['t'] + count['u']
    gc = count['g'] + count['c']
    gc = 100 * gc / (at + gc)
    return gc
  end

  # Show abnormal bases other than 'atgcu'.
  def illegal_bases
    self.scan(/[^atgcu]/).sort.uniq
  end

  # Estimate the weight of this biological string molecule.
  def molecular_weight
    if self.rna?
      Bio::NucleicAcid.weight(self, true)
    else
      Bio::NucleicAcid.weight(self)
    end
  end

  # Convert the universal code string into the regular expression.
  def to_re
    if self.rna?
      Bio::NucleicAcid.to_re(self.dna, true)
    else
      Bio::NucleicAcid.to_re(self)
    end
  end

  # Convert the self string into the list of the names of the each base.
  def names
    array = []
    self.each_byte do |x|
      array.push(Bio::NucleicAcid.names[x.chr.upcase])
    end
    return array
  end

  # Output a DNA string by substituting 'u' to 't'.
  def dna
    self.tr('u', 't')
  end

  def dna!
    self.tr!('u', 't')
  end

  # Output a RNA string by substituting 't' to 'u'.
  def rna
    self.tr('t', 'u')
  end

  def rna!
    self.tr!('t', 'u')
  end

  def rna?
    self.index('u')
  end
  protected :rna?

end # NA

end # Sequence

end # Bio

