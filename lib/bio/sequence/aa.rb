#
# = bio/sequence/aa.rb - amino acid sequence class
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: aa.rb,v 1.2 2006/02/06 14:11:31 k Exp $
#

require 'bio/sequence/common'

module Bio

  autoload :AminoAcid, 'bio/data/aa'

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
  def molecular_weight
    Bio::AminoAcid.weight(self)
  end

  def to_re
    Bio::AminoAcid.to_re(self)
  end

  # Generate the list of the names of the each residue along with the
  # sequence (3 letters code).
  def codes
    array = []
    self.each_byte do |x|
      array.push(Bio::AminoAcid.names[x.chr])
    end
    return array
  end

  # Similar to codes but returns long names.
  def names
    self.codes.map do |x|
      Bio::AminoAcid.names[x]
    end
  end

end # AA

end # Sequence

end # Bio

