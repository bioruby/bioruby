#
# = bio/sequence/aa.rb - amino acid sequence class
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>,
#               Ryan Raaum <ryan@raaum.org>
# License::     The Ruby License
#
# $Id: aa.rb,v 1.4 2007/04/05 23:35:41 trevor Exp $
#

require 'bio/sequence/common'

module Bio

  autoload :AminoAcid, 'bio/data/aa'

class Sequence

# = DESCRIPTION
# Bio::Sequence::AA represents a bare Amino Acid sequence in bioruby.
#
# = USAGE
#   # Create an Amino Acid sequence.
#   aa = Bio::Sequence::AA.new('ACDEFGHIKLMNPQRSTVWYU')
#
#   # What are the three-letter codes for all the residues?
#   puts aa.codes
#
#   # What are the names of all the residues?
#   puts aa.names
#
#   # What is the molecular weight of this peptide?
#   puts aa.molecular_weight
class AA < String

  include Bio::Sequence::Common

  # Generate an amino acid sequence object from a string.
  #
  #   s = Bio::Sequence::AA.new("RRLEHTFVFLRNFSLMLLRY")
  #
  # or maybe (if you have an amino acid sequence in a file)
  #
  #   s = Bio::Sequence:AA.new(File.open('aa.txt').read)
  #
  # Amino Acid sequences are *always* all uppercase in bioruby
  #
  #   s = Bio::Sequence::AA.new("rrLeHtfV")
  #   puts s                                  #=> "RRLEHTFVF"
  #
  # Whitespace is stripped from the sequence
  #
  #   s = Bio::Sequence::AA.new("RRL\nELA\tRG\r  RL")
  #   puts s                                  #=> "RRLELARGRL"
  # ---
  # *Arguments*:
  # * (required) _str_: String
  # *Returns*:: Bio::Sequence::AA object
  def initialize(str)
    super
    self.upcase!
    self.tr!(" \t\n\r",'')
  end


  # Estimate molecular weight based on 
  # Fasman1976[http://www.genome.ad.jp/dbget-bin/www_bget?aaindex+FASG760101]
  #
  #   s = Bio::Sequence::AA.new("RRLE")
  #   puts s.molecular_weight             #=> 572.655
  # ---
  # *Returns*:: Float object
  def molecular_weight
    Bio::AminoAcid.weight(self)
  end

  # Create a ruby regular expression instance 
  # (Regexp)[http://corelib.rubyonrails.org/classes/Regexp.html]  
  #
  #   s = Bio::Sequence::AA.new("RRLE")
  #   puts s.to_re                        #=> /RRLE/
  # ---
  # *Returns*:: Regexp object
  def to_re
    Bio::AminoAcid.to_re(self)
  end

  # Generate the list of the names of each residue along with the
  # sequence (3 letters code).  Codes used in bioruby are found in the
  # Bio::AminoAcid::NAMES hash.
  #
  #   s = Bio::Sequence::AA.new("RRLE")
  #   puts s.codes                        #=> ["Arg", "Arg", "Leu", "Glu"]
  # ---
  # *Returns*:: Array object
  def codes
    array = []
    self.each_byte do |x|
      array.push(Bio::AminoAcid.names[x.chr])
    end
    return array
  end

  # Generate the list of the names of each residue along with the
  # sequence (full name).  Names used in bioruby are found in the
  # Bio::AminoAcid::NAMES hash.
  #
  #   s = Bio::Sequence::AA.new("RRLE")
  #   puts s.names  
  #               #=> ["arginine", "arginine", "leucine", "glutamic acid"]
  # ---
  # *Returns*:: Array object
  def names
    self.codes.map do |x|
      Bio::AminoAcid.names[x]
    end
  end

end # AA

end # Sequence

end # Bio

