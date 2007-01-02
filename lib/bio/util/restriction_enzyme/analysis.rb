#
# bio/util/restrction_enzyme/analysis.rb - Does the work of fragmenting the DNA from the enzymes
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: analysis.rb,v 1.9 2007/01/02 00:13:07 trevor Exp $
#

#--
#if RUBY_VERSION[0..2] == '1.9' or RUBY_VERSION == '2.0'
#  err = "This class makes use of 'include' on ranges quite a bit.  Possibly unstable in development Ruby.  2005/12/20."
#  err += "http://blade.nagaokaut.ac.jp/cgi-bin/vframe.rb/ruby/ruby-talk/167182?167051-169742"
#  raise err
#end
#++

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/analysis_basic'

class Bio::RestrictionEnzyme

#
# bio/util/restrction_enzyme/analysis.rb - Does the work of fragmenting the DNA from the enzymes
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
class Analysis

  def self.cut( sequence, *args )
    self.new.cut( sequence, *args )
  end

  def cut( sequence, *args )
    return nil if !sequence.kind_of?(String) or sequence.empty?
    hash_of_sequence_ranges_with_cuts = cut_and_return_by_permutations( sequence, *args )
    unique_fragments_for_display( hash_of_sequence_ranges_with_cuts )
  end

  #########
  protected
  #########
  
  def cut_and_return_by_permutations( sequence, *args )
    return {} if !sequence.kind_of?(String) or sequence.empty?
    sequence = Bio::Sequence::NA.new( sequence )
    enzyme_actions, initial_cuts = create_enzyme_actions( sequence, *args )
    return {} if enzyme_actions.empty? and initial_cuts.empty?

    if enzyme_actions.size > 1
      permutations = permute(enzyme_actions.size)
    else
      permutations = []
    end

    # Indexed by permutation.
    hash_of_sequence_ranges_with_cuts = {}

    if permutations.empty?
      sr_with_cuts = Bio::RestrictionEnzyme::Range::SequenceRange.new( 0, 0, sequence.size-1, sequence.size-1 )
      initial_cuts.each { |key, enzyme_action| enzyme_action.cut_ranges.each { |cut_range| sr_with_cuts.add_cut_range(cut_range) } }
      hash_of_sequence_ranges_with_cuts[0] = sr_with_cuts
    end

    permutations.each do |permutation|
      previous_cut_ranges = []
      sr_with_cuts = Bio::RestrictionEnzyme::Range::SequenceRange.new( 0, 0, sequence.size-1, sequence.size-1 )
      initial_cuts.each { |enzyme_action| enzyme_action.cut_ranges.each { |cut_range| sr_with_cuts.add_cut_range(cut_range) } }

      permutation.each do |id|
        enzyme_action = enzyme_actions[id]

        # conflict is false if the current enzyme action may cut in it's range.
        # conflict is true if it cannot do to a previous enzyme action making
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
          if (enzyme_action.right <= previous_cut_left) or
             (enzyme_action.left > previous_cut_right) or
             (enzyme_action.left > previous_cut_left and enzyme_action.right <= previous_cut_right) # in between cuts
            # no conflict
          else
            conflict = true
          end
        end

        next if conflict == true
        enzyme_action.cut_ranges.each { |cut_range| sr_with_cuts.add_cut_range(cut_range) }
        previous_cut_ranges += enzyme_action.cut_ranges
      end

      hash_of_sequence_ranges_with_cuts[permutation] = sr_with_cuts
    end

    hash_of_sequence_ranges_with_cuts.each do |permutation, sr_with_cuts|
      sr_with_cuts.fragments.primary = sequence
      sr_with_cuts.fragments.complement = sequence.forward_complement
    end

    hash_of_sequence_ranges_with_cuts
  end

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
