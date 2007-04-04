#
# bio/util/restriction_enzyme/single_strand_complement.rb - Single strand restriction enzyme sequence in complement orientation
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: single_strand_complement.rb,v 1.3 2007/04/04 18:07:43 trevor Exp $
#

require 'bio/util/restriction_enzyme/single_strand'

module Bio; end
class Bio::RestrictionEnzyme

#
# bio/util/restriction_enzyme/single_strand_complement.rb - Single strand restriction enzyme sequence in complement orientation
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
# A single strand of restriction enzyme sequence pattern with a 3' to 5' orientation.
#
class SingleStrandComplement < SingleStrand
  # Orientation of the strand, 3' to 5'
  def orientation; [3, 5]; end
end # SingleStrandComplement
end # Bio::RestrictionEnzyme
