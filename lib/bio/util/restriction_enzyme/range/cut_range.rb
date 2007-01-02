#
# bio/util/restrction_enzyme/range/cut_range.rb - Abstract base class for HorizontalCutRange and VerticalCutRange
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: cut_range.rb,v 1.1 2007/01/02 00:13:07 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio'

module Bio; end
class Bio::RestrictionEnzyme
class Range

#
# bio/util/restrction_enzyme/range/cut_range.rb - Abstract base class for HorizontalCutRange and VerticalCutRange
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
# Abstract base class for HorizontalCutRange and VerticalCutRange
#
class CutRange
end # CutRange
end # Range
end # Bio::RestrictionEnzyme