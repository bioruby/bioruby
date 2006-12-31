#
# bio/util/restrction_enzyme/double_stranded/cut_location_pair.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: cut_location_pair.rb,v 1.2 2006/12/31 21:50:31 trevor Exp $
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/cut_symbol'
require 'bio/util/restriction_enzyme/integer'

module Bio; end
class Bio::RestrictionEnzyme
class DoubleStranded
  
#
# bio/util/restrction_enzyme/double_stranded/cut_location_pair.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
# Stores a cut location pair in 0-based index notation
# 
# Input:
# +pair+:: May be two values represented as an Array, a Range, or a
#          combination of Integer and nil values.  The first value
#          represents a cut on the primary strand, the second represents
#          a cut on the complement strand.
# 
# Example:
#   clp = CutLocationPair.new(3,2)
#   clp.primary                    # 3
#   clp.complement                 # 2
# 
# Notes:
# * a value of +nil+ is an explicit representation of 'no cut'
#
class CutLocationPair < Array
  attr_reader :primary, :complement

  def initialize( *pair )
    a = b = nil

    if pair[0].kind_of? Array
      a,b = init_with_array( pair[0] )

    elsif pair[0].kind_of? Range
      a,b = init_with_array( [pair[0].first, pair[0].last] )

    elsif pair[0].kind_of? Integer or pair[0].kind_of? NilClass
      a,b = init_with_array( [pair[0], pair[1]] )

    else
      raise ArgumentError, "#{pair[0].class} is an invalid class type."
    end

    super( [a,b] )
    @primary = a
    @complement = b
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
    if a != nil and a.negative?
      raise ArgumentError, "0-based index notation only.  Negative values are illegal."
    end

    if b != nil and b.negative?
      raise ArgumentError, "0-based index notation only.  Negative values are illegal."
    end

    if a == nil and b == nil
      raise ArgumentError, "Neither strand has a cut.  Ambiguous."
    end
  end
end # CutLocationPair
end # DoubleStranded
end # Bio::RestrictionEnzyme