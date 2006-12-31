#
# bio/util/restrction_enzyme/double_stranded/cut_location_pair_in_enzyme_notation.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: cut_location_pair_in_enzyme_notation.rb,v 1.2 2006/12/31 21:50:31 trevor Exp $
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/double_stranded/cut_location_pair'
require 'bio/util/restriction_enzyme/integer'

module Bio; end
class Bio::RestrictionEnzyme
class DoubleStranded

#
# bio/util/restrction_enzyme/double_stranded/cut_location_pair_in_enzyme_notation.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
# See CutLocationPair
#
class CutLocationPairInEnzymeNotation < CutLocationPair

  #########
  protected
  #########

  def validate_2( a, b )
    if a == 0
      raise ArgumentError, "Enzyme index notation only.  0 values are illegal."
    end

    if b == 0
      raise ArgumentError, "Enzyme index notation only.  0 values are illegal."
    end

    if a == nil and b == nil
      raise ArgumentError, "Neither strand has a cut.  Ambiguous."
    end
  end
end # CutLocationPair
end # DoubleStranded
end # Bio::RestrictionEnzyme
