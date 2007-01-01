#
# bio/util/restrction_enzyme/analysis_basic.rb - Does the work of fragmenting the DNA from the enzymes
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: analysis_basic.rb,v 1.1 2007/01/01 23:47:27 trevor Exp $
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
  # Example:
  #
  #   seq = Bio::Sequence::NA.new('gaattc')
  #   cuts = seq.cut_with_enzyme('EcoRI')
  #
  # _or_
  #
  #   seq = Bio::Sequence::NA.new('gaattc')
  #   cuts = seq.cut_with_enzyme('g^aattc')
  # ---
  # See Bio::RestrictionEnzyme::Analysis.cut
  def cut_with_enzyme(*args)
    Bio::RestrictionEnzyme::Analysis.cut(self, *args)
  end
  alias cut_with_enzymes cut_with_enzyme
end

require 'pp'

require 'bio/util/restriction_enzyme'
require 'bio/util/restriction_enzyme/analysis/sequence_range'

class Bio::RestrictionEnzyme

#
# bio/util/restrction_enzyme/analysis_basic.rb - Does the work of fragmenting the DNA from the enzymes
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
class Analysis

  def self.cut( sequence, *args )
#    self.new.cut( sequence, *args )
  end

  def self.cut_without_permutations( sequence, *args )
    self.new.cut_without_permutations( sequence, *args )
  end

  # Example:
  #
  #   Analysis.cut_without_permutations('gaattc', 'EcoRI')
  #
  # _same as:_
  #
  #   Analysis.cut_without_permutations('gaattc', 'g^aattc')
  # ---
  # *Arguments*
  # * +sequence+: +String+ kind of object that will be used as a nucleic acid sequence
  # * +args+: Series of 
  # *Returns*:: +Hash+ ?(array?) of Bio::RestrictionEnzyme::Analysis::UniqueFragment objects
  def cut_without_permutations( sequence, *args )
    return {} if !sequence.kind_of?(String) or sequence.empty?
    sequence = Bio::Sequence::NA.new( sequence )

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
    unique_fragments_for_display( {0 => sr_with_cuts} )
  end

  #########
  protected
  #########
  
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
        #enzyme_actions_that_always_cut[id] = enzyme_to_enzyme_action( enzyme, offset )
        enzyme_actions_that_always_cut[id] = enzyme.create_action_at( offset )
        id += 1
      end
    end

    # enzyme_actions_that_always_cut may lose members, the members to be lost are recorded in indicies_of_sometimes_cut

    max = enzyme_actions_that_always_cut.size - 1
    0.upto(max) do |i|
      enzyme_action = enzyme_actions_that_always_cut[i]
      conflict = false
      other_cut_ranges = {}
      enzyme_actions_that_always_cut.each { |key,i_ea| next if i == key; other_cut_ranges[key] = i_ea.cut_ranges }

      other_cut_ranges.each do |key, cut_ranges|
        cut_ranges.each do |cut_range|
          next unless cut_range.class == VerticalCutRange  # we aren't concerned with horizontal cuts
          previous_cut_left = cut_range.range.first 
          previous_cut_right = cut_range.range.last

          if (enzyme_action.right <= previous_cut_left) or
             (enzyme_action.left > previous_cut_right) or
             (enzyme_action.left > previous_cut_left and enzyme_action.right <= previous_cut_right) # in between cuts
            # no conflict
          else
            conflict = true
          end

          indicies_of_sometimes_cut += [i, key] if conflict == true
        end
      end
    end

    indicies_of_sometimes_cut.uniq.each do |i|
      enzyme_actions_that_sometimes_cut[i] = enzyme_actions_that_always_cut[i]
      enzyme_actions_that_always_cut.delete(i)
    end

    [enzyme_actions_that_sometimes_cut, enzyme_actions_that_always_cut]
  end

  # Returns an +Array+ of the match indicies of a RegExp to a string.
  #
  # ---
  # *Arguments*
  # * +string+: The string to scan
  # * +re+: A RegExp to use
  # *Returns*:: +Array+ with indicies of match locations
  def find_match_locations( string, re )
    md = string.match( re )
    locations = []
    counter = 0
    while md
      # save the match index relative to the original string
      locations << (counter += md.begin(0))
      # find the next match
      md = string[ (counter += 1)..-1 ].match( re )
    end
    locations
  end
  
end # Analysis
end # Bio::RestrictionEnzyme
