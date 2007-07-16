#
# bio/util/restriction_enzyme/analysis.rb - Does the work of fragmenting the DNA from the enzymes
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: analysis.rb,v 1.20 2007/07/16 19:28:48 k Exp $
#

require 'bio/util/restriction_enzyme'
require 'bio/util/restriction_enzyme/analysis_basic'

module Bio
class RestrictionEnzyme

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
  # *Returns*:: Bio::RestrictionEnzyme::Fragments object populated with Bio::RestrictionEnzyme::Fragment objects.   (Note: unrelated to Bio::RestrictionEnzyme::Range::SequenceRange::Fragments) or a +Symbol+ containing an error code
  def cut( sequence, *args )
    view_ranges = false
    
    args.select { |i| i.class == Hash }.each do |hsh|
      hsh.each do |key, value|
        if key == :view_ranges
          unless ( value.kind_of?(TrueClass) or value.kind_of?(FalseClass) )
            raise ArgumentError, "view_ranges must be set to true or false, currently #{value.inspect}."
          end
          view_ranges = value
        end
      end
    end
    
    res = cut_and_return_by_permutations( sequence, *args )
    return res if res.class == Symbol
    # Format the fragments for the user
    fragments_for_display( res, view_ranges )
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
  # May also supply a +Hash+ with the key ":max_permutations" to specificy how many permutations are allowed - a value of 0 indicates no permutations are allowed.
  # *Returns*:: +Hash+ Keys are a permutation ID, values are SequenceRange objects that have cuts applied.
  # _also_ may return the +Symbol+ ':sequence_empty', ':no_cuts_found', or ':too_many_permutations'
  def cut_and_return_by_permutations( sequence, *args )
    my_hash = {}
    maximum_permutations = nil

    hashes_in_args = args.select { |i| i.class == Hash }
    args.delete_if { |i| i.class == Hash }
    hashes_in_args.each do |hsh|
      hsh.each do |key, value|
        case key
        when :max_permutations, 'max_permutations', :maximum_permutations, 'maximum_permutations'
          maximum_permutations = value.to_i unless value == nil
        when :view_ranges
        else
          raise ArgumentError, "Received key #{key.inspect} in argument - I only know the key ':max_permutations' and ':view_ranges' currently.  Hash passed: #{hsh.inspect}"
        end
      end
    end
    
    if !sequence.kind_of?(String) or sequence.empty?
      logger.warn "The supplied sequence is empty." if defined?(logger)
      return :sequence_empty
    end
    sequence = Bio::Sequence::NA.new( sequence )
    
    enzyme_actions, initial_cuts = create_enzyme_actions( sequence, *args )

    if enzyme_actions.empty? and initial_cuts.empty?
      logger.warn "This enzyme does not make any cuts on this sequence." if defined?(logger)
      return :no_cuts_found
    end

    # * When enzyme_actions.size is equal to '1' that means there are no permutations.
    # * If enzyme_actions.size is equal to '2' there is one
    #   permutation ("[0, 1]")
    # * If enzyme_actions.size is equal to '3' there are two
    #   permutations ("[0, 1, 2]")
    # * and so on..
    if maximum_permutations and enzyme_actions.size > 1
      if (enzyme_actions.size - 1) > maximum_permutations.to_i
        logger.warn "More permutations than maximum, skipping.  Found: #{enzyme_actions.size-1}  Max: #{maximum_permutations.to_i}" if defined?(logger)
        return :too_many_permutations
      end
    end
    
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
end # RestrictionEnzyme
end # Bio
