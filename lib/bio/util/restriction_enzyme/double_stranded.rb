#
# bio/util/restriction_enzyme/double_stranded.rb - DoubleStranded restriction enzyme sequence
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: double_stranded.rb,v 1.11 2007/07/16 19:28:48 k Exp $
#

require 'bio/util/restriction_enzyme'

module Bio
class RestrictionEnzyme

# A pair of SingleStrand and SingleStrandComplement objects with methods to
# add utility to their relation.
# 
# = Notes
# * This is created by Bio::RestrictionEnzyme.new for convenience.
# * The two strands accessible are +primary+ and +complement+.
# * SingleStrand methods may be used on DoubleStranded and they will be passed to +primary+.
# 
# 
# FIXME needs better docs
class DoubleStranded

  autoload :AlignedStrands,  'bio/util/restriction_enzyme/double_stranded/aligned_strands'
  autoload :CutLocations,    'bio/util/restriction_enzyme/double_stranded/cut_locations'
  autoload :CutLocationPair, 'bio/util/restriction_enzyme/double_stranded/cut_location_pair'
  autoload :CutLocationsInEnzymeNotation,    'bio/util/restriction_enzyme/double_stranded/cut_locations_in_enzyme_notation'
  autoload :CutLocationPairInEnzymeNotation, 'bio/util/restriction_enzyme/double_stranded/cut_location_pair_in_enzyme_notation'

  include CutSymbol
  extend CutSymbol
  include StringFormatting
  extend StringFormatting

  # The primary strand
  attr_reader :primary

  # The complement strand
  attr_reader :complement

  # Cut locations in 0-based index format, DoubleStranded::CutLocations object
  attr_reader :cut_locations

  # Cut locations in enzyme index notation, DoubleStranded::CutLocationsInEnzymeNotation object
  attr_reader :cut_locations_in_enzyme_notation

  # [+erp+] One of three possible parameters:  The name of an enzyme, a REBASE::EnzymeEntry object, or a nucleotide pattern with a cut mark.
  # [+raw_cut_pairs+] The cut locations in enzyme index notation.
  #
  # Enzyme index notation:: 1.._n_, value before 1 is -1
  #
  # Examples of the allowable cut locations for +raw_cut_pairs+ follows.  'p' and
  # 'c' refer to a cut location on the 'p'rimary and 'c'omplement strands.
  #
  #   1, [3,2], [20,22], 57
  #   p, [p,c], [p, c],  p
  #
  # Which is the same as:
  #
  #   1, (3..2), (20..22), 57
  #   p, (p..c), (p..c),   p
  #
  # Examples of partial cuts:
  #   1, [nil,2], [20,nil], 57
  #   p, [p,  c], [p, c],   p
  #
  def initialize(erp, *raw_cut_pairs)
    # 'erp' : 'E'nzyme / 'R'ebase / 'P'attern
    k = erp.class

    if k == Bio::REBASE::EnzymeEntry
      # Passed a Bio::REBASE::EnzymeEntry object

      unless raw_cut_pairs.empty?
        err = "A Bio::REBASE::EnzymeEntry object was passed, however the cut locations contained values.  Ambiguous or redundant.\n"
        err += "inspect = #{raw_cut_pairs.inspect}"
        raise ArgumentError, err
      end
      initialize_with_rebase( erp )

    elsif erp.kind_of? String
      # Passed something that could be an enzyme pattern or an anzyme name

      # Decide if this String is an enzyme name or a pattern
      if Bio::RestrictionEnzyme.enzyme_name?( erp )
        # FIXME we added this to rebase...
        # Check if it's a known name
        known_enzyme = false
        known_enzyme = true if Bio::RestrictionEnzyme.rebase[ erp ]

        # Try harder to find the enzyme
        unless known_enzyme
          re = %r"^#{erp}$"i
          Bio::RestrictionEnzyme.rebase.each { |name, v| (known_enzyme = true; erp = name; break) if name =~ re }
        end

        if known_enzyme
          initialize_with_rebase( Bio::RestrictionEnzyme.rebase[erp] )
        else
          raise IndexError, "No entry found for enzyme named '#{erp}'"
        end

      else
        # Not an enzyme name, so a pattern is assumed
        if erp =~ re_cut_symbol
          initialize_with_pattern_and_cut_symbols( erp )
        else
          initialize_with_pattern_and_cut_locations( erp, raw_cut_pairs )
        end
      end

    elsif k == NilClass
      err = "Passed a nil value.  Perhaps you tried to pass a Bio::REBASE::EnzymeEntry that does not exist?\n"
      err += "inspect = #{erp.inspect}"
      raise ArgumentError, err
    else
      err = "I don't know what to do with class #{k} for erp.\n"
      err += "inspect = #{erp.inspect}"
      raise ArgumentError, err
    end

  end

  # See AlignedStrands.align
  def aligned_strands
    AlignedStrands.align(@primary.pattern, @complement.pattern)
  end

  # See AlignedStrands.align_with_cuts
  def aligned_strands_with_cuts
    AlignedStrands.align_with_cuts(@primary.pattern, @complement.pattern, @primary.cut_locations, @complement.cut_locations)
  end

  # Returns +true+ if the cut pattern creates blunt fragments.
  # (opposite of sticky)
  def blunt?
    as = aligned_strands_with_cuts
    ary = [as.primary, as.complement]
    ary.collect! { |seq| seq.split( cut_symbol ) }
    # convert the cut sections to their lengths
    ary.each { |i| i.collect! { |c| c.length } }
    ary[0] == ary[1]
  end

  # Returns +true+ if the cut pattern creates sticky fragments.
  # (opposite of blunt)
  def sticky?
    !blunt?
  end
  
  # Takes a RestrictionEnzyme object and a numerical offset to the sequence and 
  # returns an EnzymeAction
  #
  # +restriction_enzyme+:: RestrictionEnzyme
  # +offset+:: Numerical offset of where the enzyme action occurs on the seqeunce
  def create_action_at( offset )
    # x is the size of the fully aligned sequence with maximum padding needed
    # to make a match on the primary and complement strand.
    #
    # For example -
    # Note how EcoRII needs extra padding on the beginning and ending of the
    # sequence 'ccagg' to make the match since the cut must occur between 
    # two nucleotides and can not occur on the very end of the sequence.
    #   
    #   EcoRII:
    #     :blunt: "0"
    #     :c2: "5"
    #     :c4: "0"
    #     :c1: "-1"
    #     :pattern: CCWGG
    #     :len: "5"
    #     :name: EcoRII
    #     :c3: "0"
    #     :ncuts: "2"
    #   
    #        -1 1 2 3 4 5
    #   5' - n^c c w g g n - 3'
    #   3' - n g g w c c^n - 5'
    #   
    #   (w == [at])
    
    x = aligned_strands.primary.size
    
    enzyme_action = EnzymeAction.new( offset,
                                      offset + x-1,
                                      offset,
                                      offset + x-1)

    @cut_locations.each do |cut_location_pair|
      # cut_pair is a DoubleStranded::CutLocationPair
      p, c = cut_location_pair.primary, cut_location_pair.complement
      if c >= p
        enzyme_action.add_cut_range(offset+p, nil, nil, offset+c)
      else
        enzyme_action.add_cut_range(nil, offset+p, offset+c, nil)
      end
    end

    enzyme_action
  end
  
  # An EnzymeAction is a way of representing a potential effect that a
  # RestrictionEnzyme may have on a nucleotide sequence, an 'action'.
  #
  # Multiple cuts in multiple locations on a sequence may occur in one
  # 'action' if it is done by a single enzyme.
  #
  # An EnzymeAction is a series of locations that represents where the restriction
  # enzyme will bind on the sequence, as well as what ranges are cut on the
  # sequence itself.  The complexity is due to the fact that our virtual
  # restriction enzyme may create multiple segments from its cutting action, 
  # on which another restriction enzyme may operate upon.
  #
  # For example, the DNA sequence:
  # 
  #   5' - G A A T A A A C G A - 3'
  #   3' - C T T A T T T G C T - 5'
  #
  # When mixed with the restriction enzyme with the following cut pattern:
  #
  #   5' -   A|A T A A A C|G   - 3'
  #           +-+         +  
  #   3' -   T T|A T T T G|C   - 5'
  #
  # And also mixed with the restriction enzyme of the following cut pattern:
  #
  #   5' -         A A|A C     - 3'
  #                 +-+  
  #   3' -         T|T T G     - 5'
  #
  # Would result in a DNA sequence with these cuts:
  # 
  #   5' - G A|A T A A|A C|G A - 3'
  #           +-+   +-+   +
  #   3' - C T T|A T|T T G|C T - 5'
  #
  # Or these separate "free-floating" sequences:
  #
  #   5' - G A   - 3'
  #   3' - C T T - 5'
  #
  #   5' - A T A A - 3'
  #   3' -   A T   - 5'
  #
  #   5' -   A C - 3'
  #   3' - T T G - 5'
  #  
  #   5' - G A - 3'
  #   3' - C T - 5'
  #
  # This would be represented by two EnzymeActions - one for each
  # RestrictionEnzyme.
  # 
  # This is, however, subject to competition.  If the second enzyme reaches
  # the target first, the the first enzyme will not be able to find the
  # appropriate bind site.
  # 
  # FIXME complete these docs
  #
  # To initialize an EnzymeAction you must first instantiate it with the
  # beginning and ending locations of where it will operate on a nucleotide
  # sequence.
  #
  # Next the ranges of cu
  #
  # An EnzymeAction is
  # Defines a single enzyme action, in this case being a range that correlates
  # to the DNA sequence that may contain it's own internal cuts.
  class EnzymeAction < Bio::RestrictionEnzyme::Range::SequenceRange
  end

  #########
  protected
  #########

  def initialize_with_pattern_and_cut_symbols( s )
    p_cl = SingleStrand::CutLocationsInEnzymeNotation.new( strip_padding(s) )
    s = Bio::Sequence::NA.new( strip_cuts_and_padding(s) )

    # * Reflect cuts that are in enzyme notation
    # * 0 is not a valid enzyme index, decrement 0 and all negative
    c_cl = p_cl.collect {|n| (n >= s.length or n < 1) ? ((s.length - n) - 1) : (s.length - n)}

    create_cut_locations( p_cl.zip(c_cl) )
    create_primary_and_complement( s, p_cl, c_cl )
  end

  def initialize_with_pattern_and_cut_locations( s, raw_cl )
    create_cut_locations(raw_cl)
    create_primary_and_complement( Bio::Sequence::NA.new(s), @cut_locations_in_enzyme_notation.primary, @cut_locations_in_enzyme_notation.complement )
  end

  def create_primary_and_complement(primary_seq, p_cuts, c_cuts)
    @primary = SingleStrand.new( primary_seq, p_cuts )
    @complement = SingleStrandComplement.new( primary_seq.forward_complement, c_cuts )
  end

  def create_cut_locations(raw_cl)
    @cut_locations_in_enzyme_notation = CutLocationsInEnzymeNotation.new( *raw_cl.collect {|cl| CutLocationPairInEnzymeNotation.new(cl)} )
    @cut_locations = @cut_locations_in_enzyme_notation.to_array_index
  end

  def initialize_with_rebase( e )
    p_cl = [e.primary_strand_cut1, e.primary_strand_cut2]
    c_cl = [e.complementary_strand_cut1, e.complementary_strand_cut2]

    # If there's no cut in REBASE it's represented as a 0.
    # 0 is an invalid index, it just means no cut.
    p_cl.delete(0)
    c_cl.delete(0)
    raise IndexError unless p_cl.size == c_cl.size
    initialize_with_pattern_and_cut_locations( e.pattern, p_cl.zip(c_cl) )
  end

end # DoubleStranded
end # RestrictionEnzyme
end # Bio
