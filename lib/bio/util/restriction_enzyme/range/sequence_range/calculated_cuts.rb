#
# bio/util/restriction_enzyme/range/sequence_range/calculated_cuts.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#

module Bio

require 'bio/util/restriction_enzyme' unless const_defined?(:RestrictionEnzyme)

class RestrictionEnzyme
class Range
class SequenceRange

# cc = CalculatedCuts.new(@size)
# cc.add_cuts_from_cut_ranges(@cut_ranges)
# cc.remove_incomplete_cuts
#
#    1 2 3 4 5 6 7
#    G A|T T A C A
#       +-----+
#    C T A A T|G T
#    1 2 3 4 5 6 7
# 
# Primary cut = 2
# Complement cut = 5
# Horizontal cuts = 3, 4, 5
#
class CalculatedCuts
  include CutSymbol
  include StringFormatting

  # +Array+ of vertical cuts on the primary strand in 0-based index notation
  def vc_primary
    #$stderr.puts caller[0].inspect ###DEBUG
    @vc_primary.to_a
  end

  # Returns the same contents as vc_primary, but returns original data
  # structure used in the class.
  def vc_primary_as_original_class
    @vc_primary
  end
  
  # +Array+ of vertical cuts on the complementary strand in 0-based index notation
  def vc_complement
    #$stderr.puts caller[0].inspect ###DEBUG
    @vc_complement.to_a
  end

  # Returns the same contents as vc_complement, but returns original data
  # structure used in the class.
  def vc_complement_as_original_class
    @vc_complement
  end

  # +Array+ of horizontal cuts between strands in 0-based index notation
  def hc_between_strands
    #$stderr.puts caller[0].inspect ###DEBUG
    @hc_between_strands.to_a
  end

  # Returns the same contents as hc_between_strands, but returns original data
  # structure used in the class.
  def hc_between_strands_as_original_class
    @hc_between_strands
  end

  # Set to +true+ if the fragment CalculatedCuts is working on is circular
  attr_accessor :circular

  #--
  ## An +Array+ with the primary strand with vertical cuts, the horizontal cuts, and the complementary strand with vertical cuts.
  #attr_reader :strands_for_display
  #++
  
  # If +false+ the strands_for_display method needs to be called to update the contents
  # of @strands_for_display.  Becomes out of date whenever add_cuts_from_cut_ranges is called.
  attr_reader :strands_for_display_current

  # Size of the sequence being digested.
  attr_reader :size

  def initialize(size=nil, circular=false)
    @size = size
    @circular = circular
    @vc_primary = SortedNumArray[]
    @vc_complement = SortedNumArray[]
    @hc_between_strands = SortedNumArray[]
  end

  # Accepts an +Array+ of CutRange type objects and applies them to 
  # @vc_complement, @vc_primary, and @hc_between_strands.
  #
  # ---
  # *Arguments*
  # * +cut_ranges+: An +Array+ of HorizontalCutRange or VerticalCutRange objects
  # *Returns*:: nothing
  def add_cuts_from_cut_ranges(cut_ranges)
    @strands_for_display_current = false

    @vc_primary = @vc_primary.dup
    @vc_complement = @vc_complement.dup

    cut_ranges.each do |cut_range|
      @vc_primary.concat [cut_range.p_cut_left, cut_range.p_cut_right]
      @vc_complement.concat [cut_range.c_cut_left, cut_range.c_cut_right]

      # Add horizontal cut ranges.  This may happen from cuts made inbetween a
      # VerticalCutRange or may be specifically defined by a HorizontalCutRange.
      if cut_range.class == VerticalCutRange
        ( cut_range.min + 1 ).upto( cut_range.max ){|i| @hc_between_strands << i} if cut_range.min < cut_range.max
      elsif cut_range.class == HorizontalCutRange
        ( cut_range.hcuts.first ).upto( cut_range.hcuts.last ){|i| @hc_between_strands << i}
      end
    end
    clean_all
    #return
  end

  # There may be incomplete cuts made, this method removes the cuts that don't
  # create sub-sequences for easier processing.
  #
  # For example, stray horizontal cuts that do not end with a left 
  # and right separation:
  #
  #   G A T T A C A
  #      +--  ---
  #   C T|A A T G T
  #
  # Or stray vertical cuts:
  #
  #   G A T T A C A
  #      +--   +
  #   C T|A A T|G T
  #
  # However note that for non-circular sequences this would be a successful 
  # cut which would result in a floating 'GT' sub-sequence:
  #
  #   G A T T A C A
  #            +---
  #   C T A A T|G T
  #
  # Blunt cuts are also complete cuts.
  # ---
  # *Arguments*
  # * +size+: (_optional_) Size of the sequence being digested.  Defined here or during initalization of CalculatedCuts.
  # *Returns*:: nothing
  def remove_incomplete_cuts(size=nil)
    @strands_for_display_current = false
    @size = size if size
    raise IndexError, "Size of the strand must be provided here or during initalization." if !@size.kind_of?(Fixnum) and not @circular

    vcuts = @vc_primary + @vc_complement
    hcuts = @hc_between_strands
    last_index = @size - 1
    good_hcuts = SortedNumArray[]
    potential_hcuts = []

    if @circular
    # NOTE
    # if it's circular we should start at the beginning of a cut for orientation,
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
          good_hcuts << hcut
        elsif vcuts.include?( hcut - 1 )
          potential_hcuts << hcut
        end
      else
        if vcuts.include?( hcut )
          good_hcuts.concat(potential_hcuts)
          good_hcuts << hcut
          potential_hcuts.clear
        else
          potential_hcuts << hcut
        end
      end
    end

    check_vc = lambda do |vertical_cuts, opposing_vcuts|
      # opposing_vcuts is here only to check for blunt cuts, so there shouldn't
      # be any out-of-order problems with this
      good_vc = SortedNumArray[]
      vertical_cuts.each { |vc| good_vc << vc if good_hcuts.include?( vc ) or good_hcuts.include?( vc + 1 ) or opposing_vcuts.include?( vc ) }
      good_vc
    end

    @vc_primary = check_vc.call(@vc_primary, @vc_complement)
    @vc_complement = check_vc.call(@vc_complement, @vc_primary)
    @hc_between_strands = good_hcuts

    clean_all
  end

  # Sets @strands_for_display_current to +true+ and populates @strands_for_display.
  #
  # ---
  # *Arguments*
  # * +str1+: (_optional_) For displaying a primary strand.  If +nil+ a numbered sequence will be used in place.
  # * +str2+: (_optional_) For displaying a complementary strand.  If +nil+ a numbered sequence will be used in place.
  # * +vcp+: (_optional_) An array of vertical cut locations on the primary strand.  If +nil+ the contents of @vc_primary is used.
  # * +vcc+: (_optional_) An array of vertical cut locations on the complementary strand.  If +nil+ the contents of @vc_complementary is used.
  # * +hc+: (_optional_) An array of horizontal cut locations between strands.  If +nil+ the contents of @hc_between_strands is used.
  # *Returns*:: +Array+ An array with the primary strand with vertical cuts, the horizontal cuts, and the complementary strand with vertical cuts.
  #
  def strands_for_display(str1 = nil, str2 = nil, vcp=nil, vcc=nil, hc=nil)
    return @strands_for_display if @strands_for_display_current
    vcs = '|'   # Vertical cut symbol
    hcs = '-'   # Horizontal cut symbol
    vhcs = '+'  # Intersection of vertical and horizontal cut symbol
      
    num_txt_repeat = lambda { num_txt = '0123456789'; (num_txt * (@size.div(num_txt.size) + 1))[0..@size-1] }
    (str1 == nil) ? a = num_txt_repeat.call : a = str1.dup
    (str2 == nil) ? b = num_txt_repeat.call : b = str2.dup

    if vcp and !vcp.is_a?(SortedNumArray) then
      vcp = SortedNumArray.new.concat(vcp)
    end
    if vcc and !vcc.is_a?(SortedNumArray) then
      vcc = SortedNumArray.new.concat(vcc)
    end
    if hc and !hc.is_a?(SortedNumArray) then
      hc = SortedNumArray.new.concat(hc)
    end

    vcp = @vc_primary if vcp==nil
    vcc = @vc_complement if vcc==nil
    hc = @hc_between_strands if hc==nil

    vcp.reverse_each { |c| a.insert(c+1, vcs) }
    vcc.reverse_each { |c| b.insert(c+1, vcs) }

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

  #########
  protected
  #########

  # remove nil values, remove duplicate values, and 
  # sort @vc_primary, @vc_complement, and @hc_between_strands
  def clean_all
    [@vc_primary, @vc_complement, @hc_between_strands].collect { |a| a.delete(nil); a.uniq!; a.sort! }
  end

end # CalculatedCuts
end # SequenceRange
end # Range
end # RestrictionEnzyme
end # Bio
