#
# bio/util/restriction_enzyme/single_strand_complement.rb - Single strand restriction enzyme sequence in complement orientation
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: single_strand_complement.rb,v 1.5 2007/07/16 19:28:48 k Exp $
#

require 'bio/util/restriction_enzyme'

module Bio
class RestrictionEnzyme

# A single strand of restriction enzyme sequence pattern with a 3' to 5' orientation.
#
class SingleStrandComplement < SingleStrand
  # Orientation of the strand, 3' to 5'
  def orientation; [3, 5]; end
end # SingleStrandComplement
end # RestrictionEnzyme
end # Bio
