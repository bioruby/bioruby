#
# bio/util/restrction_enzyme/analysis/cut_ranges.rb - Container for many CutRange objects or CutRange child objects.
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: cut_ranges.rb,v 1.4 2007/01/01 23:47:28 trevor Exp $
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

module Bio; end
class Bio::RestrictionEnzyme
class Analysis
  
#
# bio/util/restrction_enzyme/analysis/cut_ranges.rb - Container for many CutRange objects or CutRange child objects.
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
# Container for many CutRange objects or CutRange child objects.  Inherits from array.
#
class CutRanges < Array
  def min; self.collect{|a| a.min}.flatten.sort.first; end
  def max; self.collect{|a| a.max}.flatten.sort.last; end
  def include?(i); self.collect{|a| a.include?(i)}.include?(true); end
end # CutRanges
end # Analysis
end # Bio::RestrictionEnzyme
