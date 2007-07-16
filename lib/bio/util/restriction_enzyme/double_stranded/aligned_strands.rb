#
# bio/util/restriction_enzyme/double_stranded/aligned_strands.rb - Align two SingleStrand objects
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: aligned_strands.rb,v 1.6 2007/07/16 19:28:48 k Exp $
#

require 'bio/util/restriction_enzyme'

module Bio
class RestrictionEnzyme
class DoubleStranded

# Align two SingleStrand objects and return a Result
# object with +primary+ and +complement+ accessors.
#
class AlignedStrands
  extend CutSymbol
  extend StringFormatting

  # The object returned for alignments
  Result = Struct.new(:primary, :complement)

  # Pad and align two String objects without cut symbols.
  #
  # This will look for the sub-sequence without left and right 'n' padding
  # and re-apply 'n' padding to both strings on both sides equal to the 
  # maximum previous padding on that side.
  #
  # The sub-sequences stripped of left and right 'n' padding must be of equal
  # length.
  #
  # Example:
  #   AlignedStrands.align('nngattacannnnn', 'nnnnnctaatgtnn') # => 
  #    <struct Bio::RestrictionEnzyme::DoubleStranded::AlignedStrands::Result
  #      primary="nnnnngattacannnnn",
  #      complement="nnnnnctaatgtnnnnn">
  #
  # ---
  # *Arguments*
  # * +a+: Primary strand
  # * +b+: Complementary strand
  # *Returns*:: +Result+ object with equal padding on both strings
  def self.align(a, b)
    a = a.to_s
    b = b.to_s
    validate_input( strip_padding(a), strip_padding(b) )
    left = [left_padding(a), left_padding(b)].sort.last
    right = [right_padding(a), right_padding(b)].sort.last

    p = left + strip_padding(a) + right
    c = left + strip_padding(b) + right
    Result.new(p,c)
  end

  # Pad and align two String objects with cut symbols.
  #
  # Example:
  #   AlignedStrands.with_cuts('nngattacannnnn', 'nnnnnctaatgtnn', [0, 10, 12], [0, 2, 12]) # => 
  #     <struct Bio::RestrictionEnzyme::DoubleStranded::AlignedStrands::Result
  #       primary="n n n n^n g a t t a c a n n^n n^n",
  #       complement="n^n n^n n c t a a t g t n^n n n n">
  #
  # Notes:
  # * To make room for the cut symbols each nucleotide is spaced out.
  # * This is meant to be able to handle multiple cuts and completely
  #   unrelated cutsites on the two strands, therefore no biological
  #   algorithm assumptions (shortcuts) are made.
  #
  # The sequences stripped of left and right 'n' padding must be of equal
  # length.
  #
  # ---
  # *Arguments*
  # * +a+: Primary sequence
  # * +b+: Complementary sequence
  # * +a_cuts+: Primary strand cut locations in 0-based index notation
  # * +b_cuts+: Complementary strand cut locations in 0-based index notation
  # *Returns*:: +Result+ object with equal padding on both strings and spacing between bases
  def self.align_with_cuts(a,b,a_cuts,b_cuts)
    a = a.to_s
    b = b.to_s
    validate_input( strip_padding(a), strip_padding(b) )

    a_left, a_right = left_padding(a), right_padding(a)
    b_left, b_right = left_padding(b), right_padding(b)

    left_diff = a_left.length - b_left.length
    right_diff = a_right.length - b_right.length

    (right_diff > 0) ? (b_right += 'n' * right_diff) : (a_right += 'n' * right_diff.abs)

    a_adjust = b_adjust = 0

    if left_diff > 0
      b_left += 'n' * left_diff
      b_adjust = left_diff
    else
      a_left += 'n' * left_diff.abs
      a_adjust = left_diff.abs
    end

    a = a_left + strip_padding(a) + a_right
    b = b_left + strip_padding(b) + b_right

    a_cuts.sort.reverse.each { |c| a.insert(c+1+a_adjust, cut_symbol) }
    b_cuts.sort.reverse.each { |c| b.insert(c+1+b_adjust, cut_symbol) }

    Result.new( add_spacing(a), add_spacing(b) )
  end

  #########
  protected
  #########

  def self.validate_input(a,b)
    unless a.size == b.size
      err = "Result sequences are not the same size.  Does not align sequences with differing lengths after strip_padding.\n"
      err += "#{a.size}, #{a.inspect}\n"
      err += "#{b.size}, #{b.inspect}"
      raise ArgumentError, err
    end
  end
end # AlignedStrands
end # DoubleStranded
end # RestrictionEnzyme
end # Bio
