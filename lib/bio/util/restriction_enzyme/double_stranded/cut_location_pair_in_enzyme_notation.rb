#
# bio/util/restrction_enzyme/double_stranded/cut_location_pair_in_enzyme_notation.rb - Inherits from DoubleStranded::CutLocationPair
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: cut_location_pair_in_enzyme_notation.rb,v 1.4 2007/04/04 18:07:44 trevor Exp $
#

require 'bio/util/restriction_enzyme/double_stranded/cut_location_pair'
require 'bio/util/restriction_enzyme/integer'

module Bio; end
class Bio::RestrictionEnzyme
class DoubleStranded

#
# bio/util/restrction_enzyme/double_stranded/cut_location_pair_in_enzyme_notation.rb - Inherits from DoubleStranded::CutLocationPair
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
# Inherits from DoubleStranded::CutLocationPair , stores the cut location pair in
# enzyme notation instead of 0-based.
#
class CutLocationPairInEnzymeNotation < CutLocationPair

  #########
  protected
  #########

  def validate_2( a, b )
    if (a == 0) or (b == 0)
      raise ArgumentError, "Enzyme index notation only.  0 values are illegal."
    end

    if a == nil and b == nil
      raise ArgumentError, "Neither strand has a cut.  Ambiguous."
    end
  end
end # CutLocationPair
end # DoubleStranded
end # Bio::RestrictionEnzyme
