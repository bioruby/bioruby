#
# bio/util/restrction_enzyme/analysis_basic.rb - Does the work of fragmenting the DNA from the enzymes
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: analysis_basic.rb,v 1.8 2007/01/05 06:33:01 trevor Exp $
#

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
  # 
  # NOTE: move this into Bio::Sequence::NA
  def cut_with_enzyme(*args)
    Bio::RestrictionEnzyme::Analysis.cut(self, *args)
  end
  alias cut_with_enzymes cut_with_enzyme
end

require 'pp'

require 'set'  # for method create_enzyme_actions
require 'bio/util/restriction_enzyme'
require 'bio/util/restriction_enzyme/range/sequence_range'

class Bio::RestrictionEnzyme

#
# bio/util/restrction_enzyme/analysis_basic.rb - Does the work of fragmenting the DNA from the enzymes
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
class Analysis

  # See cut_without_permutations instance method
  def self.cut_without_permutations( sequence, *args )
    self.new.cut_without_permutations( sequence, *args )
  end

  # See main documentation for Bio::RestrictionEnzyme
  #
  # Bio::RestrictionEnzyme.cut is preferred over this!
  #
  # USE AT YOUR OWN RISK
  #
  # This is a simpler version of method +cut+.  +cut+ takes into account
  # permutations of cut variations based on competitiveness of enzymes for an
  # enzyme cutsite or enzyme bindsite on a sequence.  This does not take into
  # account those possibilities and is therefore faster, but less likely to be
  # accurate.
  #
  # This code is mainly included as an academic example
  # without having to wade through the extra layer of complexity added by the
  # permutations.
  # 
  # Example:
  #
  # FIXME add output
  #
  #   Bio::RestrictionEnzyme::Analysis.cut_without_permutations('gaattc', 'EcoRI')
  #
  # _same as:_
  #
  #   Bio::RestrictionEnzyme::Analysis.cut_without_permutations('gaattc', 'g^aattc')
  # ---
  # *Arguments*
  # * +sequence+: +String+ kind of object that will be used as a nucleic acid sequence.
  # * +args+: Series of enzyme names, enzymes sequences with cut marks, or RestrictionEnzyme objects.
  # *Returns*:: Bio::RestrictionEnzyme::Fragments object populated with Bio::RestrictionEnzyme::Fragment objects. (Note: unrelated to Bio::RestrictionEnzyme::Range::SequenceRange::Fragments)
  def cut_without_permutations( sequence, *args )
    return fragments_for_display( {} ) if !sequence.kind_of?(String) or sequence.empty?
    sequence = Bio::Sequence::NA.new( sequence )

    # create_enzyme_actions returns two seperate array elements, they're not
    # needed separated here so we put them into one array
    enzyme_actions = create_enzyme_actions( sequence, *args ).flatten
    return fragments_for_display( {} ) if enzyme_actions.empty?
    
    # Primary and complement strands are both measured from '0' to 'sequence.size-1' here
    sequence_range = Bio::RestrictionEnzyme::Range::SequenceRange.new( 0, 0, sequence.size-1, sequence.size-1 )
    
    # Add the cuts to the sequence_range from each enzyme_action
    enzyme_actions.each do |enzyme_action|
      enzyme_action.cut_ranges.each do |cut_range|
        sequence_range.add_cut_range(cut_range)
      end
    end

    # Fill in the source sequence for sequence_range so it knows what bases
    # to use
    sequence_range.fragments.primary = sequence
    sequence_range.fragments.complement = sequence.forward_complement
    
    # Format the fragments for the user
    fragments_for_display( {0 => sequence_range} )
  end
  
  #########
  protected
  #########

  # Take the fragments from SequenceRange objects generated from add_cut_range
  # and return unique results as a Bio::RestrictionEnzyme::Analysis::Fragment object.
  # 
  # ---
  # *Arguments*
  # * +hsh+: +Hash+  Keys are a permutation ID, if any.  Values are SequenceRange objects that have cuts applied.
  # *Returns*:: Bio::RestrictionEnzyme::Analysis::Fragments object populated with Bio::RestrictionEnzyme::Analysis::Fragment objects.
  def fragments_for_display( hsh )
    ary = Fragments.new
    return ary unless hsh

    hsh.each do |permutation_id, sequence_range|
      sequence_range.fragments.for_display.each do |fragment|
        ary << Bio::RestrictionEnzyme::Fragment.new(fragment.primary, fragment.complement)
      end
    end
    ary.uniq!
    ary
  end

  # Creates an array of EnzymeActions based on the DNA sequence and supplied enzymes.
  #
  # ---
  # *Arguments*
  # * +sequence+: The string of DNA to match the enzyme recognition sites against
  # * +args+:: The enzymes to use.
  # *Returns*:: +Array+ with the first element being an array of EnzymeAction objects that +sometimes_cut+, and are subject to competition.  The second is an array of EnzymeAction objects that +always_cut+ and are not subject to competition.
  def create_enzyme_actions( sequence, *args )
    all_enzyme_actions = []
    
    args.each do |enzyme|
      enzyme = Bio::RestrictionEnzyme.new(enzyme) unless enzyme.class == Bio::RestrictionEnzyme::DoubleStranded

      find_match_locations( sequence, enzyme.primary.to_re ).each do |offset|
        all_enzyme_actions << enzyme.create_action_at( offset )
      end
    end
    
    # FIXME VerticalCutRange should really be called VerticalAndHorizontalCutRange
    
    # * all_enzyme_actions is now full of EnzymeActions at specific locations across 
    #   the sequence.
    # * all_enzyme_actions will now be examined to see if any EnzymeActions may
    #   conflict with one another, and if they do they'll be made note of in
    #   indicies_of_sometimes_cut.  They will then be remove FIXME
    # * a conflict occurs if another enzyme's bind site is compromised do due
    #   to another enzyme's cut.  Enzyme's bind sites may overlap and not be
    #   competitive, however neither bind site may be part of the other
    #   enzyme's cut or else they do become competitive.
    #
    # Take current EnzymeAction's entire bind site and compare it to all other
    # EzymeAction's cut ranges.  Only look for vertical cuts as boundaries
    # since trailing horizontal cuts would have no influence on the bind site.
    #
    # If example Enzyme A makes this cut pattern (cut range 2..5):
    #
    # 0 1 2|3 4 5 6 7
    #      +-----+
    # 0 1 2 3 4 5|6 7
    #
    # Then the bind site (and EnzymeAction range) for Enzyme B would need it's
    # right side to be at index 2 or less, or it's left side to be 6 or greater.
    
    competition_indexes = Set.new

    all_enzyme_actions[0..-2].each_with_index do |current_enzyme_action, i|
      next if competition_indexes.include? i
      
      all_enzyme_actions[i+1..-1].each_with_index do |comparison_enzyme_action, j|
        j += (i + 1)
        next if competition_indexes.include? j

        if (current_enzyme_action.right <= comparison_enzyme_action.cut_ranges.min_vertical) or
           (current_enzyme_action.left > comparison_enzyme_action.cut_ranges.max_vertical)
          # no conflict
        else
          competition_indexes += [i, j] # merge both indexes into the flat set
        end
      end
    end
        
    sometimes_cut = all_enzyme_actions.values_at( *competition_indexes )
    always_cut = all_enzyme_actions
    always_cut.delete_if {|x| sometimes_cut.include? x }

    [sometimes_cut, always_cut]
  end

  # Returns an +Array+ of the match indicies of a +RegExp+ to a string.
  #
  # Example:
  #
  #   find_match_locations('abccdefeg', /[ce]/) # => [2,3,5,7]
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