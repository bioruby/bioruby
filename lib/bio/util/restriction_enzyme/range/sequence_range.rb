#
# bio/util/restriction_enzyme/range/sequence_range.rb - A defined range over a nucleotide sequence
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: sequence_range.rb,v 1.9 2007/07/16 19:28:48 k Exp $
#

require 'bio/util/restriction_enzyme'

module Bio
class RestrictionEnzyme
class Range

  autoload :CutRange,                'bio/util/restriction_enzyme/range/cut_range'
  autoload :CutRanges,               'bio/util/restriction_enzyme/range/cut_ranges'
  autoload :HorizontalCutRange,      'bio/util/restriction_enzyme/range/horizontal_cut_range'
  autoload :VerticalCutRange,        'bio/util/restriction_enzyme/range/vertical_cut_range'

# A defined range over a nucleotide sequence.
#
# This class accomadates having cuts defined on a sequence and returning the
# fragments made by those cuts.
class SequenceRange

  autoload :Fragment,                'bio/util/restriction_enzyme/range/sequence_range/fragment'
  autoload :Fragments,               'bio/util/restriction_enzyme/range/sequence_range/fragments'
  autoload :CalculatedCuts,          'bio/util/restriction_enzyme/range/sequence_range/calculated_cuts'

  # Left-most index of primary strand
  attr_reader :p_left
  
  # Right-most index of primary strand
  attr_reader :p_right
  
  # Left-most index of complementary strand
  attr_reader :c_left
  
  # Right-most index of complementary strand
  attr_reader :c_right

  # Left-most index of DNA sequence
  attr_reader :left
  
  # Right-most index of DNA sequence
  attr_reader :right
  
  # Size of DNA sequence
  attr_reader :size
  
  # CutRanges in this SequenceRange
  attr_reader :cut_ranges

  def initialize( p_left = nil, p_right = nil, c_left = nil, c_right = nil )
    raise ArgumentError if p_left == nil and c_left == nil
    raise ArgumentError if p_right == nil and c_right == nil
    (raise ArgumentError unless p_left <= p_right) unless p_left == nil or p_right == nil
    (raise ArgumentError unless c_left <= c_right) unless c_left == nil or c_right == nil

    @p_left, @p_right, @c_left, @c_right = p_left, p_right, c_left, c_right
    @left = [p_left, c_left].compact.sort.first
    @right = [p_right, c_right].compact.sort.last
    @size = (@right - @left) + 1 unless @left == nil or @right == nil
    @cut_ranges = CutRanges.new
    @__fragments_current = false
  end


  # If the first object is HorizontalCutRange or VerticalCutRange, that is
  # added to the SequenceRange.  Otherwise this method
  # builds a VerticalCutRange object and adds it to the SequenceRange.
  # 
  # Note:
  # Cut occurs immediately after the index supplied.
  # For example, a cut at '0' would mean a cut occurs between bases 0 and 1.
  #
  # ---
  # *Arguments*
  # * +p_cut_left+: (_optional_) Left-most cut on the primary strand *or* a CutRange object.  +nil+ to skip
  # * +p_cut_right+: (_optional_) Right-most cut on the primary strand.  +nil+ to skip
  # * +c_cut_left+: (_optional_) Left-most cut on the complementary strand.  +nil+ to skip
  # * +c_cut_right+: (_optional_) Right-most cut on the complementary strand.  +nil+ to skip
  # *Returns*:: nothing
  def add_cut_range( p_cut_left=nil, p_cut_right=nil, c_cut_left=nil, c_cut_right=nil )
    @__fragments_current = false
    if p_cut_left.kind_of? CutRange # shortcut
      @cut_ranges << p_cut_left
    else
      [p_cut_left, p_cut_right, c_cut_left, c_cut_right].each { |n| (raise IndexError unless n >= @left and n <= @right) unless n == nil }
      @cut_ranges << VerticalCutRange.new( p_cut_left, p_cut_right, c_cut_left, c_cut_right )
    end
  end

  # Add a series of CutRange objects (HorizontalCutRange or VerticalCutRange).
  #
  # ---
  # *Arguments*
  # * +cut_ranges+: A series of CutRange objects
  # *Returns*:: nothing
  def add_cut_ranges(*cut_ranges)
    cut_ranges.flatten.each do |cut_range|
      raise TypeError, "Not of type CutRange" unless cut_range.kind_of? CutRange
      self.add_cut_range( cut_range )
    end
  end

  # Builds a HorizontalCutRange object and adds it to the SequenceRange.
  #
  # ---
  # *Arguments*
  # * +left+: Left-most cut
  # * +right+: (_optional_) Right side - by default this equals the left side, default is recommended.
  # *Returns*:: nothing
  def add_horizontal_cut_range( left, right=left )
    @__fragments_current = false
    @cut_ranges << HorizontalCutRange.new( left, right )
  end
  
  # A Bio::RestrictionEnzyme::Range::SequenceRange::Bin holds an +Array+ of 
  # indexes for the primary and complement strands (+p+ and +c+ accessors).
  # 
  # Example hash with Bin values:
  #   {0=>#<struct Bio::RestrictionEnzyme::Range::SequenceRange::Bin c=[0, 1], p=[0]>,
  #    2=>#<struct Bio::RestrictionEnzyme::Range::SequenceRange::Bin c=[], p=[1, 2]>,
  #    3=>#<struct Bio::RestrictionEnzyme::Range::SequenceRange::Bin c=[2, 3], p=[]>,
  #    4=>#<struct Bio::RestrictionEnzyme::Range::SequenceRange::Bin c=[4, 5], p=[3, 4, 5]>}
  #
  # Note that the bin cannot be easily stored as a range since there may be
  # nucleotides excised in the middle of a range.
  #
  # TODO: Perhaps store the bins as one-or-many ranges since missing
  # nucleotides due to enzyme cutting is a special case.
  Bin = Struct.new(:c, :p)

  # Calculates the fragments over this sequence range as defined after using
  # the methods add_cut_range, add_cut_ranges, and/or add_horizontal_cut_range
  #
  # Example return value:
  #   [#<Bio::RestrictionEnzyme::Range::SequenceRange::Fragment:0x277bdc
  #     @complement_bin=[0, 1],
  #     @primary_bin=[0]>,
  #    #<Bio::RestrictionEnzyme::Range::SequenceRange::Fragment:0x277bc8
  #     @complement_bin=[],
  #     @primary_bin=[1, 2]>,
  #    #<Bio::RestrictionEnzyme::Range::SequenceRange::Fragment:0x277bb4
  #     @complement_bin=[2, 3],
  #     @primary_bin=[]>,
  #    #<Bio::RestrictionEnzyme::Range::SequenceRange::Fragment:0x277ba0
  #     @complement_bin=[4, 5],
  #     @primary_bin=[3, 4, 5]>]
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: Bio::RestrictionEnzyme::Range::SequenceRange::Fragments
  def fragments
    return @__fragments if @__fragments_current == true
    @__fragments_current = true
    
    num_txt = '0123456789'
    num_txt_repeat = (num_txt * ( @size / num_txt.size.to_f ).ceil)[0..@size-1]
    fragments = Fragments.new(num_txt_repeat, num_txt_repeat)

    cc = Bio::RestrictionEnzyme::Range::SequenceRange::CalculatedCuts.new(@size)
    cc.add_cuts_from_cut_ranges(@cut_ranges)
    cc.remove_incomplete_cuts
    
    create_bins(cc).sort.each { |k, bin| fragments << Fragment.new( bin.p, bin.c ) }
    @__fragments = fragments
    return fragments
  end
  
  #########
  protected
  #########
  
  # Example:
  #   cc = Bio::RestrictionEnzyme::Range::SequenceRange::CalculatedCuts.new(@size)
  #   cc.add_cuts_from_cut_ranges(@cut_ranges)
  #   cc.remove_incomplete_cuts
  #   bins = create_bins(cc)
  # 
  # Example return value:
  #   {0=>#<struct Bio::RestrictionEnzyme::Range::SequenceRange::Bin c=[0, 1], p=[0]>,
  #    2=>#<struct Bio::RestrictionEnzyme::Range::SequenceRange::Bin c=[], p=[1, 2]>,
  #    3=>#<struct Bio::RestrictionEnzyme::Range::SequenceRange::Bin c=[2, 3], p=[]>,
  #    4=>#<struct Bio::RestrictionEnzyme::Range::SequenceRange::Bin c=[4, 5], p=[3, 4, 5]>}
  #
  # ---
  # *Arguments*
  # * +cc+: Bio::RestrictionEnzyme::Range::SequenceRange::CalculatedCuts
  # *Returns*:: +Hash+ Keys are unique, values are Bio::RestrictionEnzyme::Range::SequenceRange::Bin objects filled with indexes of the sequence locations they represent.
  def create_bins(cc)
    p_cut = cc.vc_primary
    c_cut = cc.vc_complement
    h_cut = cc.hc_between_strands
    
    if @circular
      # NOTE
      # if it's circular we should start at the beginning of a cut for orientation
      # scan for it, hack off the first set of hcuts and move them to the back
  
      unique_id = 0
    else
      p_cut.unshift(-1) unless p_cut.include?(-1)
      c_cut.unshift(-1) unless c_cut.include?(-1)
      unique_id = -1
    end

    p_bin_id = c_bin_id = unique_id
    bins = {}
    setup_new_bin(bins, unique_id)

    -1.upto(@size-1) do |idx| # NOTE - circular, for the future - should '-1' be replace with 'unique_id'?
      
      # if bin_ids are out of sync but the strands are attached
      if (p_bin_id != c_bin_id) and !h_cut.include?(idx)
        min_id, max_id = [p_bin_id, c_bin_id].sort
        bins.delete(max_id)
        p_bin_id = c_bin_id = min_id
      end

      bins[ p_bin_id ].p << idx
      bins[ c_bin_id ].c << idx
      
      if p_cut.include? idx
        p_bin_id = (unique_id += 1)
        setup_new_bin(bins, p_bin_id)
      end

      if c_cut.include? idx             # repetition
        c_bin_id = (unique_id += 1)     # repetition
        setup_new_bin(bins, c_bin_id)   # repetition
      end                               # repetition
       
    end
  
    # Bin "-1" is an easy way to indicate the start of a strand just in case
    # there is a horizontal cut at position 0
    bins.delete(-1) unless @circular
    bins
  end
  
  # Modifies bins in place by creating a new element with key bin_id and
  # initializing the bin.
  def setup_new_bin(bins, bin_id)
    bins[ bin_id ] = Bin.new
    bins[ bin_id ].p = []
    bins[ bin_id ].c = []
  end
  
end # SequenceRange
end # Range
end # RestrictionEnzyme
end # Bio
