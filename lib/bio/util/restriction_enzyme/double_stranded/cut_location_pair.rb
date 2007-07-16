#
# bio/util/restriction_enzyme/double_stranded/cut_location_pair.rb - Stores a cut location pair in 0-based index notation
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: cut_location_pair.rb,v 1.9 2007/07/16 19:28:48 k Exp $
#

require 'bio/util/restriction_enzyme'

module Bio
class RestrictionEnzyme
class DoubleStranded
  
# Stores a single cut location pair in 0-based index notation for use with
# DoubleStranded enzyme sequences.
#
class CutLocationPair < Array
  # Location of the cut on the primary strand.
  # Corresponds - or 'pairs' - to the complement cut.
  # A value of +nil+ is an explicit representation of 'no cut'.
  attr_reader :primary
  
  # Location of the cut on the complementary strand.
  # Corresponds - or 'pairs' - to the primary cut.
  # A value of +nil+ is an explicit representation of 'no cut'.
  attr_reader :complement

  # CutLocationPair constructor.
  #
  # Stores a single cut location pair in 0-based index notation for use with
  # DoubleStranded enzyme sequences.
  # 
  # Example:
  #   clp = CutLocationPair.new(3,2)
  #   clp.primary                    # 3
  #   clp.complement                 # 2
  #
  # ---
  # *Arguments*
  # * +pair+: May be two values represented as an Array, a Range, or a
  #   combination of Integer and nil values.  The first value
  #   represents a cut on the primary strand, the second represents
  #   a cut on the complement strand.
  # *Returns*:: nothing
  def initialize( *pair )
    a = b = nil

    if pair[0].kind_of? Array
      a,b = init_with_array( pair[0] )

    # no idea why this barfs without the second half during test/runner.rb
    # are there two Range objects running around?
    elsif pair[0].kind_of? Range or (pair[0].class.to_s == 'Range')
    #elsif pair[0].kind_of? Range
      a,b = init_with_array( [pair[0].first, pair[0].last] )

    elsif pair[0].kind_of? Integer or pair[0].kind_of? NilClass
      a,b = init_with_array( [pair[0], pair[1]] )

    else
      raise ArgumentError, "#{pair[0].class} is an invalid class type to initalize CutLocationPair."
    end

    super( [a,b] )
    @primary = a
    @complement = b
    return
  end

  #########
  protected
  #########

  def init_with_array( ary )
    validate_1(ary)
    a = ary.shift
    ary.empty? ? b = nil : b = ary.shift
    validate_2(a,b)
    [a,b]
  end

  def validate_1( ary )
    unless ary.size == 1 or ary.size == 2
      raise ArgumentError, "Must be one or two elements."
    end
  end

  def validate_2( a, b )
    if (a != nil and a < 0) or (b != nil and b < 0)
      raise ArgumentError, "0-based index notation only.  Negative values are illegal."
    end

    if a == nil and b == nil
      raise ArgumentError, "Neither strand has a cut.  Ambiguous."
    end
  end
end # CutLocationPair
end # DoubleStranded
end # RestrictionEnzyme
end # Bio
