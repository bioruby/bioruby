#
# bio/util/restrction_enzyme/double_stranded/cut_locations.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: cut_locations.rb,v 1.2 2006/12/31 21:50:31 trevor Exp $
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/double_stranded/cut_location_pair'

module Bio; end
class Bio::RestrictionEnzyme
class DoubleStranded

#
# bio/util/restrction_enzyme/double_stranded/cut_locations.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
class CutLocations < Array

  def initialize(*args)
    validate_args(args)
    super(args)
  end

  def primary
    self.collect {|a| a[0]}
  end

  def complement
    self.collect {|a| a[1]}
  end

  #########
  protected
  #########

  def validate_args(args)
    args.each do |a|
      unless a.class == Bio::RestrictionEnzyme::DoubleStranded::CutLocationPair
        err = "Not a CutLocationPair\n"
        err += "class: #{a.class}\n"
        err += "inspect: #{a.inspect}"
        raise ArgumentError, err
      end
    end
  end
end # CutLocations
end # DoubleStranded
end # Bio::RestrictionEnzyme
