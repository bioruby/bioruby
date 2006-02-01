require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/cut_symbol'
require 'bio/util/restriction_enzyme/string_formatting'

module Bio; end
class Bio::RestrictionEnzyme
class Analysis

#
# bio/util/restriction_enzyme/analysis/calculated_cuts.rb - 
#
# Copyright::  Copyright (C) 2006 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: calculated_cuts.rb,v 1.1 2006/02/01 07:34:11 trevor Exp $
#
#
#--
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#++
#
#

=begin rdoc
bio/util/restriction_enzyme/analysis/calculated_cuts.rb - 


   1 2 3 4 5 6 7
   G A|T T A C A
      +-----+
   C T A A T|G T
   1 2 3 4 5 6 7

Primary cut = 2
Complement cut = 5
Horizontal cuts = 3, 4, 5
=end
class CalculatedCuts
  include CutSymbol
  include StringFormatting

  # Vertical cuts on the primary strand
  attr_reader :vc_primary
  
  # Vertical cuts on the complement strand
  attr_reader :vc_complement

  # Horizontal cuts
  attr_reader :hc_between_strands

  # Set to +true+ if the fragment CalculatedCuts is working on is circular
  attr_accessor :circular

  def initialize(size=nil, circular=false)
    @size = size
    @circular = circular
    @vc_primary = []
    @vc_complement = []
    @hc_between_strands = []
  end

  def add_cuts_from_cut_ranges(cut_ranges)
    @strands_for_display_current = false

    cut_ranges.each do |cut_range|
      @vc_primary += [cut_range.p_cut_left, cut_range.p_cut_right]
      @vc_complement += [cut_range.c_cut_left, cut_range.c_cut_right]

      if cut_range.class == VerticalCutRange
        ( cut_range.min + 1 ).upto( cut_range.max ){|i| @hc_between_strands << i} if cut_range.min < cut_range.max
      elsif cut_range.class == HorizontalCutRange
        ( cut_range.hcuts.first ).upto( cut_range.hcuts.last ){|i| @hc_between_strands << i}
      end
    end
    clean_all
  end

  def remove_incomplete_cuts(size=nil)
    @strands_for_display_current = false
    @size = size if size
    raise IndexError, "Size of the strand must be provided here or during initalization." if !@size.kind_of?(Fixnum) and not @circular

    vcuts = (@vc_primary + @vc_complement).uniq.sort
    hcuts = @hc_between_strands
    last_index = @size - 1
    good_hcuts = []
    potential_hcuts = []

    if @circular
    # NOTE
    # if it's circular we should start at the beginning of a cut for orientation
    # scan for it, hack off the first set of hcuts and move them to the back
    else
      vcuts.unshift(-1) unless vcuts.include?(-1)
      vcuts.push(last_index) unless vcuts.include?(last_index)
    end

    hcuts.each do |hcut|
      raise IndexError if hcut < -1 or hcut > last_index
      # skipped a nucleotide
      potential_hcuts.clear if !potential_hcuts.empty? and (hcut - potential_hcuts.last).abs > 1

      if potential_hcuts.empty?
        if vcuts.include?( hcut ) and vcuts.include?( hcut - 1 )
          good_hcuts += [hcut]
        elsif vcuts.include?( hcut - 1 )
          potential_hcuts << hcut
        end
      else
        if vcuts.include?( hcut )
          good_hcuts += potential_hcuts + [hcut]
          potential_hcuts.clear
        else
          potential_hcuts << hcut
        end
      end
    end

    check_vc = lambda do |vertical_cuts, opposing_vcuts|
      # opposing_vcuts is here only to check for blunt cuts, so there shouldn't
      # be any out-of-order problems with this
      good_vc = []
      vertical_cuts.each { |vc| good_vc << vc if good_hcuts.include?( vc ) or good_hcuts.include?( vc + 1 ) or opposing_vcuts.include?( vc ) }
      good_vc
    end

    @vc_primary = check_vc.call(@vc_primary, @vc_complement)
    @vc_complement = check_vc.call(@vc_complement, @vc_primary)
    @hc_between_strands = good_hcuts

    clean_all
  end

  def strands_for_display(str1 = nil, str2 = nil, vcp=nil, vcc=nil, hc=nil)
    return @strands_for_display if @strands_for_display_current
    vcs = '|'
    hcs = '-'
    vhcs = '+'
      
    num_txt_repeat = lambda { num_txt = '0123456789'; (num_txt * ( @size / num_txt.size.to_f ).ceil)[0..@size-1] }
    (str1 == nil) ? a = num_txt_repeat.call : a = str1.dup
    (str2 == nil) ? b = num_txt_repeat.call : b = str2.dup

    vcp = @vc_primary if vcp==nil
    vcc = @vc_complement if vcc==nil
    hc = @hc_between_strands if hc==nil

    vcuts = (vcp + vcc).uniq.sort

    vcp.reverse.each { |c| a.insert(c+1, vcs) }
    vcc.reverse.each { |c| b.insert(c+1, vcs) }

    between = ' ' * @size
    hc.each {|hcut| between[hcut,1] = hcs }

    s_a = add_spacing(a, vcs)
    s_b = add_spacing(b, vcs)
    s_bet = add_spacing(between)

    # NOTE watch this for circular
    i = 0
    0.upto( s_a.size-1 ) do
      if (s_a[i,1] == vcs) or (s_b[i,1] == vcs)
        s_bet[i] = vhcs 
      elsif i != 0 and s_bet[i-1,1] == hcs and s_bet[i+1,1] == hcs
        s_bet[i] = hcs 
      end
      i+=1
    end

    @strands_for_display_current = true
    @strands_for_display = [s_a, s_bet, s_b]
  end

=begin
  def vc_primary_add(c)
    @vc_primary << c
    @current = false
  end

  def vc_complement_add(c)
    @vc_complement << c
    @current = false
  end

  def hc_between_strands_add(c)
    @hc_between_strands << c
    @current = false
  end
=end
  #########
  protected
  #########

  def clean_all
    [@vc_primary, @vc_complement, @hc_between_strands].collect { |a| a.delete(nil); a.uniq!; a.sort! }
  end


end

end
end
