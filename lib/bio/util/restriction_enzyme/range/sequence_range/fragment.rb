#
# bio/util/restriction_enzyme/range/sequence_range/fragment.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: fragment.rb,v 1.6 2007/07/16 19:28:48 k Exp $
#

require 'bio/util/restriction_enzyme'

module Bio
class RestrictionEnzyme
class Range
class SequenceRange

class Fragment

  attr_reader :size

  def initialize( primary_bin, complement_bin )
    @primary_bin = primary_bin
    @complement_bin = complement_bin
  end

  DisplayFragment = Struct.new(:primary, :complement, :p_left, :p_right, :c_left, :c_right)

  def for_display(p_str=nil, c_str=nil)
    df = DisplayFragment.new
    df.primary = ''
    df.complement = ''

    both_bins = (@primary_bin + @complement_bin).sort.uniq
    both_bins.each do |item|
      @primary_bin.include?(item) ? df.primary << p_str[item] : df.primary << ' '
      @complement_bin.include?(item) ? df.complement << c_str[item] : df.complement << ' '
    end
    
    df.p_left  = @primary_bin.first
    df.p_right = @primary_bin.last
    df.c_left  = @complement_bin.first
    df.c_right = @complement_bin.last

    df
  end
end # Fragment
end # SequenceRange
end # Range
end # RestrictionEnzyme
end # Bio
