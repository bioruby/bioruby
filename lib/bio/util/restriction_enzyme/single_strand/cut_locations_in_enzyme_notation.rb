#
# bio/util/restriction_enzyme/single_strand/cut_locations_in_enzyme_notation.rb - The cut locations, in enzyme notation
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: cut_locations_in_enzyme_notation.rb,v 1.7 2007/07/16 19:28:48 k Exp $
#

require 'bio/util/restriction_enzyme'

module Bio
class RestrictionEnzyme
class SingleStrand

# Stores the cut location in thier enzyme index notation
# 
# May be initialized with a series of cuts or an enzyme pattern marked
# with cut symbols.
# 
# Enzyme index notation:: 1.._n_, value before 1 is -1
#
# example:: [-3][-2][-1][1][2][3][4][5]
#
# Negative values are used to indicate when a cut may occur at a specified
# distance before the sequence begins.  This would be padded with 'n'
# nucleotides to represent wildcards.
# 
# Notes:
# * <code>0</code> is invalid as it does not refer to any index 
# * +nil+ is not allowed here as it has no meaning
# * +nil+ values are kept track of in DoubleStranded::CutLocations as they
#   need a reference point on the correlating strand.  In 
#   DoubleStranded::CutLocations +nil+ represents no cut or a partial 
#   digestion.
# 
class CutLocationsInEnzymeNotation < Array
  include CutSymbol
  extend CutSymbol

  # First cut, in enzyme-index notation
  attr_reader :min
  
  # Last cut, in enzyme-index notation
  attr_reader :max

  # Constructor for CutLocationsInEnzymeNotation
  #
  # ---
  # *Arguments*
  # * +a+: Locations of cuts represented as a string with cuts or an array of values
  # Examples:
  # * n^ng^arraxt^n
  # * 2
  # * -1, 5
  # * [-1, 5]
  # *Returns*:: nothing
  def initialize(*a)
    a.flatten! # in case an array was passed as an argument

    if a.size == 1 and a[0].kind_of? String and a[0] =~ re_cut_symbol
      # Initialize with a cut symbol pattern such as 'n^ng^arraxt^n'
      s = a[0]
      a = []
      i = -( s.tr(cut_symbol, '') =~ %r{[^n]} )  # First character that's not 'n'
      s.each_byte { |c| (a << i; next) if c.chr == cut_symbol; i += 1 }
      a.collect! { |n| n <= 0 ? n-1 : n } # 0 is not a valid enzyme index, decrement from 0 and all negative
    else
      a.collect! { |n| n.to_i } # Cut locations are always integers
    end

    validate_cut_locations( a )
    super(a)
    self.sort!
    @min = self.first
    @max = self.last
    self.freeze
  end

  # Transform the cut locations from enzyme index notation to 0-based index
  # notation.
  #
  #   input -> output
  #   [  1, 2, 3 ] -> [ 0, 1, 2 ]
  #   [  1, 3, 5 ] -> [ 0, 2, 4 ]
  #   [ -1, 1, 2 ] -> [ 0, 1, 2 ]
  #   [ -2, 1, 3 ] -> [ 0, 2, 4 ]
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +Array+ of cuts in 0-based index notation
  def to_array_index
    return [] if @min == nil
    if @min < 0
      calc = lambda do |n| 
        n -= 1 unless n < 0
        n + @min.abs
      end
    else
      calc = lambda { |n| n - 1 }
    end
    self.collect(&calc)
  end

  #########
  protected
  #########

  def validate_cut_locations( input_cut_locations )
    unless input_cut_locations == input_cut_locations.uniq
      err = "The cut locations supplied contain duplicate values.  Redundant / undefined meaning.\n"
      err += "cuts: #{input_cut_locations.inspect}\n"
      err += "unique: #{input_cut_locations.uniq.inspect}"
      raise ArgumentError, err
    end

    if input_cut_locations.include?(nil)
      err = "The cut locations supplied contained a nil.  nil has no index for enzyme notation, alternative meaning is 'no cut'.\n"
      err += "cuts: #{input_cut_locations.inspect}"
      raise ArgumentError, err
    end

    if input_cut_locations.include?(0)
      err = "The cut locations supplied contained a '0'.  '0' has no index for enzyme notation, alternative meaning is 'no cut'.\n"
      err += "cuts: #{input_cut_locations.inspect}"
      raise ArgumentError, err
    end

  end
end # CutLocationsInEnzymeNotation
end # SingleStrand
end # RestrictionEnzyme
end # Bio
