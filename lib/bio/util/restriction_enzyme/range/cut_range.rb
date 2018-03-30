#
# bio/util/restriction_enzyme/range/cut_range.rb - Abstract base class for HorizontalCutRange and VerticalCutRange
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#

module Bio

require 'bio/util/restriction_enzyme' unless const_defined?(:RestrictionEnzyme)

class RestrictionEnzyme
class Range

# Abstract base class for HorizontalCutRange and VerticalCutRange
#
class CutRange
end # CutRange

end # Range
end # RestrictionEnzyme
end # Bio
