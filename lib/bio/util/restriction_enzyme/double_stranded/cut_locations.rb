#
# bio/util/restriction_enzyme/double_stranded/cut_locations.rb - Contains an Array of CutLocationPair objects
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: cut_locations.rb,v 1.6 2007/07/16 19:28:48 k Exp $
#

require 'bio/util/restriction_enzyme'

module Bio
class RestrictionEnzyme
class DoubleStranded

# Contains an +Array+ of CutLocationPair objects.
#
class CutLocations < Array

  # CutLocations constructor.
  #
  # Contains an +Array+ of CutLocationPair objects.
  #
  # Example:
  #   clp1 = CutLocationPair.new(3,2)
  #   clp2 = CutLocationPair.new(7,9)
  #   pairs = CutLocations.new(clp1, clp2)
  #
  # ---
  # *Arguments*
  # * +args+: Any number of +CutLocationPair+ objects
  # *Returns*:: nothing
  def initialize(*args)
    validate_args(args)
    super(args)
  end

  # Returns an +Array+ of locations of cuts on the primary strand
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +Array+ of locations of cuts on the primary strand
  def primary
    self.collect {|a| a[0]}
  end

  # Returns an +Array+ of locations of cuts on the complementary strand
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +Array+ of locations of cuts on the complementary strand
  def complement
    self.collect {|a| a[1]}
  end

  #########
  protected
  #########

  def validate_args(args)
    args.each do |a|
      unless a.class == Bio::RestrictionEnzyme::DoubleStranded::CutLocationPair
        err = "Not a CutLocationPair\n"
        err += "class: #{a.class}\n"
        err += "inspect: #{a.inspect}"
        raise ArgumentError, err
      end
    end
  end
end # CutLocations
end # DoubleStranded
end # RestrictionEnzyme
end # Bio
