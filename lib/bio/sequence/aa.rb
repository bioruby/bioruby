module Bio

class Sequence

# Amino Acid sequence

class AA < String

  include Bio::Sequence::Common

  # Generate a amino acid sequence object from a string.
  def initialize(str)
    super
    self.upcase!
    self.tr!(" \t\n\r",'')
  end

  # Estimate the weight of this protein.
  # AminoAcid is defined in bio/data/aa.rb
  def molecular_weight
    AminoAcid.weight(self)
  end

  def to_re
    AminoAcid.to_re(self)
  end

  # Generate the list of the names of the each residue along with the
  # sequence (3 letters code).
  def codes
    array = []
    self.each_byte do |x|
      array.push(AminoAcid.names[x.chr])
    end
    return array
  end

  # Similar to codes but returns long names.
  def names
    self.codes.map do |x|
      AminoAcid.names[x]
    end
  end

end # AA

end # Sequence

end # Bio
