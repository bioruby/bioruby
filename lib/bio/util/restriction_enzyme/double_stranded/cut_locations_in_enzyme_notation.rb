#
# bio/util/restriction_enzyme/double_stranded/cut_locations_in_enzyme_notation.rb - Inherits from DoubleStrand::CutLocations
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
class DoubleStranded

# Inherits from DoubleStranded::CutLocations.  Contains CutLocationPairInEnzymeNotation objects.
# Adds helper methods to convert from enzyme index notation to 0-based array index notation.
#
class CutLocationsInEnzymeNotation < CutLocations

  # Returns +Array+ of locations of cuts on the primary 
  # strand in 0-based array index notation.
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +Array+ of locations of cuts on the primary strand in 0-based array index notation.
  def primary_to_array_index
    helper_for_to_array_index(self.primary)
  end

  # Returns +Array+ of locations of cuts on the complementary 
  # strand in 0-based array index notation.
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +Array+ of locations of cuts on the complementary strand in 0-based array index notation.
  def complement_to_array_index
    helper_for_to_array_index(self.complement)
  end

  # Returns the contents of the present CutLocationsInEnzymeNotation object as
  # a CutLocations object with the contents converted from enzyme notation 
  # to 0-based array index notation.
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +CutLocations+
  def to_array_index
    unless self.primary_to_array_index.size == self.complement_to_array_index.size
      err = "Primary and complement strand cut locations are not available in equal numbers.\n"
      err += "primary: #{self.primary_to_array_index.inspect}\n"
      err += "primary.size: #{self.primary_to_array_index.size}\n"
      err += "complement: #{self.complement_to_array_index.inspect}\n"
      err += "complement.size: #{self.complement_to_array_index.size}"
      raise IndexError, err
    end
    a = self.primary_to_array_index.zip(self.complement_to_array_index)
    CutLocations.new( *a.collect {|cl| CutLocationPair.new(cl)} )
  end

  #########
  protected
  #########

  def helper_for_to_array_index(a)
    minimum = (self.primary + self.complement).flatten
    minimum.delete(nil)
    minimum = minimum.sort.first

    return [] if minimum == nil  # no elements

    if minimum < 0
      calc = lambda do |n|
        unless n == nil
          n -= 1 unless n < 0
          n += minimum.abs
        end
        n
      end
    else
      calc = lambda do |n| 
        n -= 1 unless n == nil
        n
      end
    end

    a.collect(&calc)
  end

  def validate_args(args)
    args.each do |a|
      unless a.class == Bio::RestrictionEnzyme::DoubleStranded::CutLocationPairInEnzymeNotation
        err = "Not a CutLocationPairInEnzymeNotation\n"
        err += "class: #{a.class}\n"
        err += "inspect: #{a.inspect}"
        raise TypeError, err
      end
    end
  end
end # CutLocationsInEnzymeNotation
end # DoubleStranded
end # RestrictionEnzyme
end # Bio
