#
# bio/util/restrction_enzyme/analysis/fragment.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: fragment.rb,v 1.2 2006/12/31 21:50:31 trevor Exp $
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/analysis/tags'
require 'bio/util/restriction_enzyme/analysis/cut_ranges'
require 'bio/util/restriction_enzyme/analysis/horizontal_cut_range'
require 'bio'

module Bio; end
class Bio::RestrictionEnzyme
class Analysis

#
# bio/util/restrction_enzyme/analysis/fragment.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
class Fragment

  attr_reader :size
#  attr_reader :tags

  def initialize( primary_bin, complement_bin )
#    @tags = []
    @primary_bin = primary_bin
    @complement_bin = complement_bin
  end

#  def add_tag( index, info=nil )
#    @tags[index] = info
#  end

  DisplayFragment = Struct.new(:primary, :complement)

  def for_display(p_str=nil, c_str=nil)
    df = DisplayFragment.new
    df.primary = ''
    df.complement = ''

    both_bins = (@primary_bin + @complement_bin).sort.uniq
    both_bins.each do |item|
      @primary_bin.include?(item) ? df.primary << p_str[item] : df.primary << ' '
      @complement_bin.include?(item) ? df.complement << c_str[item] : df.complement << ' '
    end

    df
  end
end # Fragment
end # Analysis
end # Bio::RestrictionEnzyme
