#
# bio/util/restrction_enzyme/analysis_basic.rb - Does the work of fragmenting the DNA from the enzymes
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: analysis_basic.rb,v 1.4 2007/01/02 07:33:46 trevor Exp $
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
    #enzyme_actions = tmp[0].merge(tmp[1])
    enzyme_actions = tmp[0] + tmp[1]

    sequence_range = Bio::RestrictionEnzyme::Range::SequenceRange.new( 0, 0, sequence.size-1, sequence.size-1 )
    enzyme_actions.each do |enzyme_action|
      enzyme_action.cut_ranges.each do |cut_range|
        sequence_range.add_cut_range(cut_range)
      end
    end

    sequence_range.fragments.primary = sequence
    sequence_range.fragments.complement = sequence.forward_complement
    unique_fragments_for_display( {0 => sequence_range} )
  end

  UniqueFragment = Struct.new(:primary, :complement)
  
  class UniqueFragments < Array
    def primary; strip_and_sort(:primary); end
    def complement; strip_and_sort(:complement); end
    
    protected
    
    def strip_and_sort( sym_strand )
      self.map {|uf| uf.send( sym_strand ).tr(' ', '') }.sort
    end
  end
  
  #########
  protected
  #########


  # * +hsh+: +Hash+  Key is a permutation ID, if any.  Value is SequenceRange object that has cuts.
  # 
  def unique_fragments_for_display( hsh )
    uf_ary = UniqueFragments.new
    return uf_ary if hsh == nil

    hsh.each do |permutation_id, sequence_range|
      sequence_range.fragments.for_display.each do |fragment|
        uf_ary << UniqueFragment.new(fragment.primary, fragment.complement)
      end
    end
    uf_ary.uniq!
    uf_ary
  end

  # Creates an array of EnzymeActions based on the DNA sequence and supplied enzymes.
  #
  # +sequence+:: The string of DNA to match the enzyme recognition sites against
  # +args+:: The enzymes to use.
  def create_enzyme_actions( sequence, *args )
    require 'set'
    all_enzyme_actions = []
    
    args.each do |enzyme|
      enzyme = Bio::RestrictionEnzyme.new(enzyme) unless enzyme.class == Bio::RestrictionEnzyme::DoubleStranded

      find_match_locations( sequence, enzyme.primary.to_re ).each do |offset|
        all_enzyme_actions << enzyme.create_action_at( offset )
      end
    end
    
    # VerticalCutRange should really be called VerticalAndHorizontalCutRange
    
    # * all_enzyme_actions is now full of EnzymeActions at specific locations across 
    #   the sequence.
    # * all_enzyme_actions will now be examined to see if any EnzymeActions may
    #   conflict with one another, and if they do they'll be made note of in
    #   indicies_of_sometimes_cut.  They will then be remove FIXME
    # * a conflict occurs if another enzyme's bind site is compromised do due
    #   to another enzyme's cut.  Enzyme's bind sites may overlap and not be
    #   competitive, however neither bind site may be part of the other
    #   enzyme's cut or else they do become competitive.
    # * note that a small enzyme may possibly cut inbetween two cuts far apart
    #   made by a larger enzyme, this would be a "sometimes" cut since it's
    #   not guaranteed that the larger enzyme will cut first, therefore there
    #   is competition.
    
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
    # right side to be 2 or less, or it's left side to be 6 or greater.
    
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
