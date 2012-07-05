#
# bio/util/restriction_enzyme/range/cut_ranges.rb - Container for many CutRange objects or CutRange child objects.
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#

module Bio

require 'bio/util/restriction_enzyme' unless const_defined?(:RestrictionEnzyme)

class RestrictionEnzyme
class Range
  
# Container for many CutRange objects or CutRange child objects.  Inherits from array.
#
class CutRanges < Array
  def min; self.collect{|a| a.min}.flatten.sort.first; end
  def max; self.collect{|a| a.max}.flatten.sort.last; end
  def include?(i); self.collect{|a| a.include?(i)}.include?(true); end
  
  def min_vertical
    vertical_min_max_helper( :min )
  end
  
  def max_vertical
    vertical_min_max_helper( :max )
  end
  
  protected
  
  def vertical_min_max_helper( sym_which )
    tmp = []
    self.each do |a|
      next unless a.class == Bio::RestrictionEnzyme::Range::VerticalCutRange
      tmp << a.send( sym_which )
    end
    z = (sym_which == :max) ? :last : :first
    tmp.flatten.sort.send(z)
  end
    
end # CutRanges
end # Range
end # RestrictionEnzyme
end # Bio
