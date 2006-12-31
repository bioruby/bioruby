#
# bio/util/restrction_enzyme/double_stranded/cut_locations_in_enzyme_notation.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: cut_locations_in_enzyme_notation.rb,v 1.2 2006/12/31 21:50:31 trevor Exp $
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/double_stranded/cut_locations'
require 'bio/util/restriction_enzyme/double_stranded/cut_location_pair_in_enzyme_notation'

module Bio; end
class Bio::RestrictionEnzyme
class DoubleStranded

#
# bio/util/restrction_enzyme/double_stranded/cut_locations_in_enzyme_notation.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
class CutLocationsInEnzymeNotation < CutLocations

  def primary_to_array_index
    helper_for_to_array_index(self.primary)
  end

  def complement_to_array_index
    helper_for_to_array_index(self.complement)
  end

  def to_array_index
    unless self.primary_to_array_index.size == self.complement_to_array_index.size
      err = "Primary and complement strand cut locations are not available in equal numbers.\n"
      err += "primary: #{self.primary_to_array_index.inspect}\n"
      err += "primary.size: #{self.primary_to_array_index.size}\n"
      err += "complement: #{self.complement_to_array_index.inspect}\n"
      err += "complement.size: #{self.complement_to_array_index.size}"
      raise IndexError, err
    end
    a = self.primary_to_array_index.zip(self.complement_to_array_index)
    CutLocations.new( *a.collect {|cl| CutLocationPair.new(cl)} )
  end

  #########
  protected
  #########

  def helper_for_to_array_index(a)
    minimum = (self.primary + self.complement).flatten
    minimum.delete(nil)
    minimum = minimum.sort.first

    return [] if minimum == nil  # no elements

    if minimum.negative?
      calc = lambda do |n|
        unless n == nil
          n -= 1 unless n.negative?
          n += minimum.abs
        end
        n
      end
    else
      calc = lambda do |n| 
        n -= 1 unless n == nil
        n
      end
    end

    a.collect(&calc)
  end

  def validate_args(args)
    args.each do |a|
      unless a.class == Bio::RestrictionEnzyme::DoubleStranded::CutLocationPairInEnzymeNotation
        err = "Not a CutLocationPairInEnzymeNotation\n"
        err += "class: #{a.class}\n"
        err += "inspect: #{a.inspect}"
        raise TypeError, err
      end
    end
  end
end # CutLocationsInEnzymeNotation
end # DoubleStranded
end # Bio::RestrictionEnzyme
