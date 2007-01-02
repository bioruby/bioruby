#
# bio/util/restrction_enzyme/analysis/fragments.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: fragments.rb,v 1.1 2007/01/02 00:13:07 trevor Exp $
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 6, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

module Bio; end
class Bio::RestrictionEnzyme
class Range
class SequenceRange

#
# bio/util/restrction_enzyme/analysis/fragments.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
class Fragments < Array
  
  attr_accessor :primary
  attr_accessor :complement

  def initialize(primary, complement)
    @primary = primary
    @complement = complement
  end

  DisplayFragment = Struct.new(:primary, :complement)

  def for_display(p_str=nil, c_str=nil)
    p_str ||= @primary
    c_str ||= @complement
    pretty_fragments = []
    self.each { |fragment| pretty_fragments << fragment.for_display(p_str, c_str) }
    pretty_fragments
  end
end # Fragments
end # SequenceRange
end # Range
end # Bio::RestrictionEnzyme
