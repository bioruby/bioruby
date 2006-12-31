#
# bio/util/restrction_enzyme/analysis.rb - Does the work of fragmenting the DNA from the enzymes
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: analysis.rb,v 1.6 2006/12/31 21:50:31 trevor Exp $
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

require 'bio'
class Bio::Sequence::NA
  # See Bio::RestrictionEnzyme::Analysis.cut
  def cut_with_enzyme(*args)
    Bio::RestrictionEnzyme::Analysis.cut(self, *args)
  end
  alias cut_with_enzymes cut_with_enzyme
end

require 'pp'

require 'bio/util/restriction_enzyme'
require 'bio/util/restriction_enzyme/analysis/sequence_range.rb'

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

  def self.cut_without_permutations( sequence, *args )
    self.new.cut_without_permutations( sequence, *args )
  end

  def self.cut_and_return_by_permutations( sequence, *args )
    self.new.cut_and_return_by_permutations( sequence, *args )
  end

  def cut_without_permutations( sequence, *args )
    return {} if !sequence.kind_of?(String) or sequence.empty?
    sequence = Bio::Sequence::NA.new( sequence )

    #enzyme_actions = create_enzyme_actions( sequence, *args )
    tmp = create_enzyme_actions( sequence, *args )
    enzyme_actions = tmp[0].merge(tmp[1])

    sr_with_cuts = SequenceRange.new( 0, 0, sequence.size-1, sequence.size-1 )
    enzyme_actions.each do |id, enzyme_action|
      enzyme_action.cut_ranges.each do |cut_range|
        sr_with_cuts.add_cut_range(cut_range)
      end
    end

    sr_with_cuts.fragments.primary = sequence
    sr_with_cuts.fragments.complement = sequence.forward_complement

    tmp = {}
    tmp[0] = sr_with_cuts
    unique_fragments_for_display( tmp )
  end

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
      sr_with_cuts = SequenceRange.new( 0, 0, sequence.size-1, sequence.size-1 )
      initial_cuts.each { |key, enzyme_action| enzyme_action.cut_ranges.each { |cut_range| sr_with_cuts.add_cut_range(cut_range) } }
      hash_of_sequence_ranges_with_cuts[0] = sr_with_cuts
    end

    permutations.each do |permutation|
      previous_cut_ranges = []
      sr_with_cuts = SequenceRange.new( 0, 0, sequence.size-1, sequence.size-1 )
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
          next unless cut_range.class == VerticalCutRange  # we aren't concerned with horizontal cuts
          previous_cut_left = cut_range.range.first 
          previous_cut_right = cut_range.range.last

=begin
puts "--- #{permutation.inspect} ---"
puts "Previous cut left: #{previous_cut_left}"
puts "EA.left #{enzyme_action.left}"
puts "Previous cut right: #{previous_cut_right}"
puts "EA.right: #{enzyme_action.right}"
=end

          # Keep in mind: 
          # * The cut location is to the immediate right of the base located at the index.
          #   ex: at^gc -- the cut location is at index 1
          # * The enzyme action location is located at the base of the index.
          #   ex: atgc -- 0 => 'a', 1 => 't', 2 => 'g', 3 => 'c'
          if (enzyme_action.right <= previous_cut_left) or
             (enzyme_action.left > previous_cut_right) or
             (enzyme_action.left > previous_cut_left and enzyme_action.right <= previous_cut_right) # in between cuts
            # no conflict
#puts "no conflict"

          else
            conflict = true
#puts "conflict"
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

#pp    hash_of_sequence_ranges_with_cuts
    hash_of_sequence_ranges_with_cuts
  end

  def cut( sequence, *args )
    return nil if !sequence.kind_of?(String) or sequence.empty?
    hash_of_sequence_ranges_with_cuts = cut_and_return_by_permutations( sequence, *args )
    unique_fragments_for_display( hash_of_sequence_ranges_with_cuts )
  end

  #########
  protected
  #########

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

  UniqueFragment = Struct.new(:primary, :complement)
  class UniqueFragments < Array
    def primary
      tmp = []
      self.each { |uf| tmp << uf.primary }
      tmp.sort.map { |e| e.tr(' ', '') }
    end
    def complement
      tmp = []
      self.each { |uf| tmp << uf.complement }
      tmp.sort.map { |e| e.tr(' ', '') }
    end
  end

  def unique_fragments_for_display( hash_of_sequence_ranges_with_cuts )
    uf_ary = UniqueFragments.new
    return uf_ary if hash_of_sequence_ranges_with_cuts == nil or hash_of_sequence_ranges_with_cuts.empty?

    hash_of_sequence_ranges_with_cuts.each do |permutation, sr_with_cuts|
      sr_with_cuts.fragments.for_display.each do |fragment|
        uf = UniqueFragment.new
        uf.primary = fragment.primary
        uf.complement = fragment.complement

        duplicate = false
        uf_ary.each do |element|
          if (uf.primary == element.primary) and (uf.complement == element.complement)
            duplicate = true
            break
          end
        end

        uf_ary << uf unless duplicate
      end
    end
    uf_ary
  end
  

=begin
  Strand = Struct.new(:primary, :complement, :p_left, :p_right, :c_left, :c_right)

  def ts_fragments_to_strands( sequence, fragments )
    sequence = Bio::Sequence::NA.new( sequence )
    strands = []
    fragments.each do |f|
      p = sequence[f.p_left..f.p_right]
      c = sequence[f.c_left..f.c_right]
      strands << Strand.new(p, c, f.p_left, f.p_right, f.c_left, f.c_right)
    end
    strands
  end
=end

  # Defines a single enzyme action, in this case being a range that correlates
  # to the DNA sequence that may contain it's own internal cuts.
  class EnzymeAction < SequenceRange
  end

  # Creates an array of EnzymeActions based on the DNA sequence and supplied enzymes.
  #
  # +sequence+:: The string of DNA to match the enzyme recognition sites against
  # +args+:: The enzymes to use.
  def create_enzyme_actions( sequence, *args )
    id = 0
    enzyme_actions_that_sometimes_cut = {}
    enzyme_actions_that_always_cut = {}
    indicies_of_sometimes_cut = []

    args.each do |enzyme|
      enzyme = Bio::RestrictionEnzyme.new(enzyme) unless enzyme.class == Bio::RestrictionEnzyme::DoubleStranded
      find_match_locations( sequence, enzyme.primary.to_re ).each do |offset|
        enzyme_actions_that_always_cut[id] = enzyme_to_enzyme_action( enzyme, offset )
        id += 1
      end
    end

    # enzyme_actions_that_always_cut may lose members, the members to be lost are recorded in indicies_of_sometimes_cut

    max = enzyme_actions_that_always_cut.size - 1
    0.upto(max) do |i|
      enzyme_action = enzyme_actions_that_always_cut[i]
      conflict = false
      other_cut_ranges = {}
      #enzyme_actions.each { |key,enzyme_action| next if i == key; puts "i: #{i}, key: #{key}"; previous_cut_ranges += enzyme_action.cut_ranges }
#      enzyme_actions_that_always_cut.each { |key,i_ea|  next if i == key; puts "i: #{i}, key: #{key}"; other_cut_ranges[key] = i_ea.cut_ranges }
      enzyme_actions_that_always_cut.each { |key,i_ea| next if i == key; other_cut_ranges[key] = i_ea.cut_ranges }
#      puts "Enzyme action #{i}:"
#      pp enzyme_actions[i]
#      pp enzyme_action
#      puts "Previous cut ranges:"
#      pp previous_cut_ranges

      other_cut_ranges.each do |key, cut_ranges|
        cut_ranges.each do |cut_range|
          next unless cut_range.class == VerticalCutRange  # we aren't concerned with horizontal cuts
          previous_cut_left = cut_range.range.first 
          previous_cut_right = cut_range.range.last

          if (enzyme_action.right <= previous_cut_left) or
             (enzyme_action.left > previous_cut_right) or
             (enzyme_action.left > previous_cut_left and enzyme_action.right <= previous_cut_right) # in between cuts
            # no conflict
#  puts "no conflict"

          else
            conflict = true
#  puts "conflict"
  #puts "cut range:"
  #pp cut_range
  #puts "enzyme action:"
  #pp enzyme_action
          end

          indicies_of_sometimes_cut += [i, key] if conflict == true
        end
      end

      # We don't need to make permutations with this enzyme action if it always cuts
#      indicies << i if conflict == false
    end
#    pp indicies_of_sometimes_cut

    indicies_of_sometimes_cut.uniq.each do |i|
      enzyme_actions_that_sometimes_cut[i] = enzyme_actions_that_always_cut[i]
      enzyme_actions_that_always_cut.delete(i)
    end
#puts 'Always cut:'
#pp enzyme_actions_that_always_cut
#puts 'Permute:'
#pp enzyme_actions_that_sometimes_cut

    [enzyme_actions_that_sometimes_cut, enzyme_actions_that_always_cut]
  end

  # Returns the offsets of the match of a RegExp to a string.
  #
  # +string+:: The string to scan.
  # +re+:: A regexp to use.
  def find_match_locations( string, re )
    md = string.match( re )
    locations = []
    location = -1
    while md
      location += md.pre_match.size + 1
      locations << location
      # md[0] is the same as $&, or "the match" itself
      md = (md[0][1..-1] + md.post_match).match( re )
    end
    locations
  end

  # Takes a RestrictionEnzyme and a numerical offset to the sequence and 
  # returns an EnzymeAction
  #
  # +enzyme+:: RestrictionEnzyme
  # +offset+:: Numerical offset of where the enzyme action occurs on the seqeunce
  def enzyme_to_enzyme_action( enzyme, offset )
    enzyme_action = EnzymeAction.new(offset, offset + enzyme.primary.size-1, offset, offset + enzyme.complement.size-1)

    enzyme.cut_locations.each do |cut_pair|
      p = cut_pair[0]     
      c = cut_pair[1]
      if c >= p
        enzyme_action.add_cut_range(offset+p, nil, nil, offset+c)
      else
        enzyme_action.add_cut_range(nil, offset+p, offset+c, nil)
      end
    end

    enzyme_action
  end

end # Analysis
end # Bio::RestrictionEnzyme
