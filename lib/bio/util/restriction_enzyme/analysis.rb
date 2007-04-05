#
# bio/util/restrction_enzyme/analysis.rb - Does the work of fragmenting the DNA from the enzymes
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: analysis.rb,v 1.17 2007/04/05 23:35:42 trevor Exp $
#

require 'bio/util/restriction_enzyme/analysis_basic'

class Bio::RestrictionEnzyme

#
# bio/util/restrction_enzyme/analysis.rb - Does the work of fragmenting the DNA from the enzymes
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
class Analysis

  # See cut instance method
  def self.cut( sequence, *args )
    self.new.cut( sequence, *args )
  end

  # See main documentation for Bio::RestrictionEnzyme
  #
  #
  # +cut+ takes into account
  # permutations of cut variations based on competitiveness of enzymes for an
  # enzyme cutsite or enzyme bindsite on a sequence.
  #
  # Example:
  #
  # FIXME add output
  #
  #   Bio::RestrictionEnzyme::Analysis.cut('gaattc', 'EcoRI')
  #
  # _same as:_
  #
  #   Bio::RestrictionEnzyme::Analysis.cut('gaattc', 'g^aattc')
  # ---
  # *Arguments*
  # * +sequence+: +String+ kind of object that will be used as a nucleic acid sequence.
  # * +args+: Series of enzyme names, enzymes sequences with cut marks, or RestrictionEnzyme objects.
  # *Returns*:: Bio::RestrictionEnzyme::Fragments object populated with Bio::RestrictionEnzyme::Fragment objects.   (Note: unrelated to Bio::RestrictionEnzyme::Range::SequenceRange::Fragments)
  def cut( sequence, *args )
    return fragments_for_display( {} ) if !sequence.kind_of?(String) or sequence.empty?
    # Format the fragments for the user
    fragments_for_display( cut_and_return_by_permutations( sequence, *args ) )
  end

  #########
  protected
  #########
  
  # See cut instance method
  #
  # ---
  # *Arguments*
  # * +sequence+: +String+ kind of object that will be used as a nucleic acid sequence.
  # * +args+: Series of enzyme names, enzymes sequences with cut marks, or RestrictionEnzyme objects.
  # *Returns*:: +Hash+ Keys are a permutation ID, values are SequenceRange objects that have cuts applied.
  def cut_and_return_by_permutations( sequence, *args )
    my_hash = {}
    
    return my_hash if !sequence.kind_of?(String) or sequence.empty?
    sequence = Bio::Sequence::NA.new( sequence )
    
    enzyme_actions, initial_cuts = create_enzyme_actions( sequence, *args )
    return my_hash if enzyme_actions.empty? and initial_cuts.empty?
    
    if enzyme_actions.size > 1
      permutations = permute(enzyme_actions.size)
      
      permutations.each do |permutation|
        previous_cut_ranges = []
        # Primary and complement strands are both measured from '0' to 'sequence.size-1' here
        sequence_range = Bio::RestrictionEnzyme::Range::SequenceRange.new( 0, 0, sequence.size-1, sequence.size-1 )

        # Add the cuts to the sequence_range from each enzyme_action contained
        # in initial_cuts.  These are the cuts that have no competition so are
        # not subject to permutations.
        initial_cuts.each do |enzyme_action|
          enzyme_action.cut_ranges.each do |cut_range|
            sequence_range.add_cut_range(cut_range)
          end
        end

        permutation.each do |id|
          enzyme_action = enzyme_actions[id]

          # conflict is false if the current enzyme action may cut in it's range.
          # conflict is true if it cannot due to a previous enzyme action making
          # a cut where this enzyme action needs a whole recognition site.
          conflict = false

          # If current size of enzyme_action overlaps with previous cut_range, don't cut
          # note that the enzyme action may fall in the middle of a previous enzyme action
          # so all cut locations must be checked that would fall underneath.
          previous_cut_ranges.each do |cut_range|
            next unless cut_range.class == Bio::RestrictionEnzyme::Range::VerticalCutRange  # we aren't concerned with horizontal cuts
            previous_cut_left = cut_range.range.first 
            previous_cut_right = cut_range.range.last

            # Keep in mind: 
            # * The cut location is to the immediate right of the base located at the index.
            #   ex: at^gc -- the cut location is at index 1
            # * The enzyme action location is located at the base of the index.
            #   ex: atgc -- 0 => 'a', 1 => 't', 2 => 'g', 3 => 'c'
            # method create_enzyme_actions has similar commentary if interested
            if (enzyme_action.right <= previous_cut_left) or
               (enzyme_action.left > previous_cut_right) or
               (enzyme_action.left > previous_cut_left and enzyme_action.right <= previous_cut_right) # in between cuts
              # no conflict
            else
              conflict = true
            end
          end

          next if conflict == true
          enzyme_action.cut_ranges.each { |cut_range| sequence_range.add_cut_range(cut_range) }
          previous_cut_ranges += enzyme_action.cut_ranges        
        end # permutation.each

        # Fill in the source sequence for sequence_range so it knows what bases
        # to use
        sequence_range.fragments.primary = sequence
        sequence_range.fragments.complement = sequence.forward_complement
        my_hash[permutation] = sequence_range
      end # permutations.each
      
    else # if enzyme_actions.size == 1
      # no permutations, just do it
      sequence_range = Bio::RestrictionEnzyme::Range::SequenceRange.new( 0, 0, sequence.size-1, sequence.size-1 )
      initial_cuts.each { |enzyme_action| enzyme_action.cut_ranges.each { |cut_range| sequence_range.add_cut_range(cut_range) } }
      sequence_range.fragments.primary = sequence
      sequence_range.fragments.complement = sequence.forward_complement
      my_hash[0] = sequence_range
    end

    my_hash
  end


  # Returns permutation orders for a given number of elements.
  #
  # Examples:
  #   permute(0) # => [[0]]
  #   permute(1) # => [[0]]
  #   permute(2) # => [[1, 0], [0, 1]]
  #   permute(3) # => [[2, 1, 0], [2, 0, 1], [1, 2, 0], [0, 2, 1], [1, 0, 2], [0, 1, 2]]
  #   permute(4) # => [[3, 2, 1, 0],
  #                    [3, 2, 0, 1],
  #                    [3, 1, 2, 0],
  #                    [3, 0, 2, 1],
  #                    [3, 1, 0, 2],
  #                    [3, 0, 1, 2],
  #                    [2, 3, 1, 0],
  #                    [2, 3, 0, 1],
  #                    [1, 3, 2, 0],
  #                    [0, 3, 2, 1],
  #                    [1, 3, 0, 2],
  #                    [0, 3, 1, 2],
  #                    [2, 1, 3, 0],
  #                    [2, 0, 3, 1],
  #                    [1, 2, 3, 0],
  #                    [0, 2, 3, 1],
  #                    [1, 0, 3, 2],
  #                    [0, 1, 3, 2],
  #                    [2, 1, 0, 3],
  #                    [2, 0, 1, 3],
  #                    [1, 2, 0, 3],
  #                    [0, 2, 1, 3],
  #                    [1, 0, 2, 3],
  #                    [0, 1, 2, 3]]
  #   
  # ---
  # *Arguments*
  # * +count+: +Number+ of different elements to be permuted
  # * +permutations+: ignore - for the recursive algorithm
  # *Returns*:: +Array+ of +Array+ objects with different possible permutation orders.  See examples.
  def permute(count, permutations = [[0]])
    return permutations if count <= 1
    new_arrays = []
    new_array = []

    (permutations[0].size + 1).times do |n|
      new_array.clear
      permutations.each { |a| new_array << a.dup }
      new_array.each { |e| e.insert(n, permutations[0].size) }
      new_arrays += new_array
    end

    permute(count-1, new_arrays)
  end

end # Analysis
end # Bio::RestrictionEnzyme
