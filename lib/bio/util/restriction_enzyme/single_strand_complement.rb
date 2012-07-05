#
# bio/util/restriction_enzyme/single_strand_complement.rb - Single strand restriction enzyme sequence in complement orientation
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#

module Bio

require 'bio/util/restriction_enzyme' unless const_defined?(:RestrictionEnzyme)

class RestrictionEnzyme

# A single strand of restriction enzyme sequence pattern with a 3' to 5' orientation.
#
class SingleStrandComplement < SingleStrand
  # Orientation of the strand, 3' to 5'
  def orientation; [3, 5]; end
end # SingleStrandComplement
end # RestrictionEnzyme
end # Bio
