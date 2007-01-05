#
# bio/util/restriction_enzyme.rb - Digests DNA based on restriction enzyme cut patterns
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: restriction_enzyme.rb,v 1.9 2007/01/05 06:03:22 trevor Exp $
#

require 'bio/db/rebase'
require 'bio/util/restriction_enzyme/double_stranded'
require 'bio/util/restriction_enzyme/single_strand'
require 'bio/util/restriction_enzyme/cut_symbol'
require 'bio/util/restriction_enzyme/analysis'

module Bio #:nodoc:

#
# bio/util/restriction_enzyme.rb - Digests DNA based on restriction enzyme cut patterns
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
# NOTE: This documentation and the module are still very much under
# development.  It has been released as it is relatively stable and
# comments would be appreciated.
# 
# FIXME needs better docs
#
# = Description
# 
# Bio::RestrictionEnzyme allows you to fragment a DNA strand using one
# or more restriction enzymes.  Bio::RestrictionEnzyme is aware that
# multiple enzymes may be competing for the same recognition site and
# returns the various possible fragmentation patterns that result in
# such circumstances.
# 
# When using Bio::RestrictionEnzyme you may simply use the name of common
# enzymes to cut your sequence or you may construct your own unique enzymes 
# to use.
# 
# 
# = Usage
# 
# == Basic
#
#   # EcoRI cut pattern:
#   #   G|A A T T C
#   #    +-------+
#   #   C T T A A|G
#   #
#   # This can also be written as:
#   #   G^AATTC
# 
#   require 'bio'
#   require 'pp'
# 
#   seq = Bio::Sequence::NA.new('gaattc')
#   cuts = seq.cut_with_enzyme('EcoRI')
#   p cuts.primary                        # ["aattc", "g"]
#   p cuts.complement                     # ["g", "cttaa"]
#   pp cuts                               # ==>
#     # [#<struct Bio::RestrictionEnzyme::Analysis::UniqueFragment primary="g    ", complement="cttaa">,
#     #  #<struct Bio::RestrictionEnzyme::Analysis::UniqueFragment primary="aattc", complement="    g">]
# 
#   seq = Bio::Sequence::NA.new('gaattc')
#   cuts = seq.cut_with_enzyme('g^aattc')
#   p cuts.primary                        # ["aattc", "g"]
#   p cuts.complement                     # ["g", "cttaa"]
# 
#   seq = Bio::Sequence::NA.new('gaattc')
#   cuts = seq.cut_with_enzyme('g^aattc', 'gaatt^c')
#   p cuts.primary                        # ["c", "aattc", "g", "gaatt"]
#   p cuts.complement                     # ["g", "c", "cttaa", "ttaag"]
# 
#   seq = Bio::Sequence::NA.new('gaattcgaattc')
#   cuts = seq.cut_with_enzyme('EcoRI')
#   p cuts.primary                        # ["aattc", "aattcg", "g"]
#   p cuts.complement                     # ["g", "gcttaa", "cttaa"]
# 
#   seq = Bio::Sequence::NA.new('gaattcgggaattc')
#   cuts = seq.cut_with_enzyme('EcoRI')
#   p cuts.primary                        # ["aattc", "aattcggg", "g"]
#   p cuts.complement                     # ["g", "gcccttaa", "cttaa"]
# 
# == Advanced
# 
#   require 'bio'
#   require 'pp'
#   enzyme_1 = Bio::RestrictionEnzyme.new('anna', [1,1], [3,3])
#   enzyme_2 = Bio::RestrictionEnzyme.new('gg', [1,1])
#   a = Bio::RestrictionEnzyme::Analysis.cut('agga', enzyme_1, enzyme_2)
#   p a.primary # ["a", "ag", "g", "ga"]
# 
#   b = Bio::RestrictionEnzyme::Analysis.cut_and_return_by_permutations('agga', enzyme_1, enzyme_2)
#   pp b
#   
# 
# Output (NOTE: to be cleaned):
# 
#   {[1, 0]=>
#     #<Bio::RestrictionEnzyme::Analysis::SequenceRange:0x2971d0
#      @__fragments=
#       [#<Bio::RestrictionEnzyme::Analysis::Fragment:0x296750
#         @complement_bin=[0, 1],
#         @primary_bin=[0, 1]>,
#        #<Bio::RestrictionEnzyme::Analysis::Fragment:0x296738
#         @complement_bin=[2, 3],
#         @primary_bin=[2, 3]>],
#      @__fragments_current=true,
#      @c_left=3,
#      @c_right=3,
#      @cut_ranges=
#       [#<Bio::RestrictionEnzyme::Analysis::VerticalCutRange:0x2973e0
#         @c_cut_left=nil,
#         @c_cut_right=1,
#         @max=1,
#         @min=1,
#         @p_cut_left=1,
#         @p_cut_right=nil,
#         @range=1..1>],
#      @left=0,
#      @p_left=0,
#      @p_right=0,
#      @right=3,
#      @size=4,
#      @tags={}>,
#    [0, 1]=>
#     #<Bio::RestrictionEnzyme::Analysis::SequenceRange:0x2973f8
#      @__fragments=
#       [#<Bio::RestrictionEnzyme::Analysis::Fragment:0x2958e0
#         @complement_bin=[0],
#         @primary_bin=[0]>,
#        #<Bio::RestrictionEnzyme::Analysis::Fragment:0x2958c8
#         @complement_bin=[1],
#         @primary_bin=[1]>,
#        #<Bio::RestrictionEnzyme::Analysis::Fragment:0x2958b0
#         @complement_bin=[2],
#         @primary_bin=[2]>,
#        #<Bio::RestrictionEnzyme::Analysis::Fragment:0x295898
#         @complement_bin=[3],
#         @primary_bin=[3]>],
#      @__fragments_current=true,
#      @c_left=3,
#      @c_right=3,
#      @cut_ranges=
#       [#<Bio::RestrictionEnzyme::Analysis::VerticalCutRange:0x297638
#         @c_cut_left=nil,
#         @c_cut_right=0,
#         @max=0,
#         @min=0,
#         @p_cut_left=0,
#         @p_cut_right=nil,
#         @range=0..0>,
#        #<Bio::RestrictionEnzyme::Analysis::VerticalCutRange:0x297620
#         @c_cut_left=nil,
#         @c_cut_right=2,
#         @max=2,
#         @min=2,
#         @p_cut_left=2,
#         @p_cut_right=nil,
#         @range=2..2>,
#        #<Bio::RestrictionEnzyme::Analysis::VerticalCutRange:0x2973e0
#         @c_cut_left=nil,
#         @c_cut_right=1,
#         @max=1,
#         @min=1,
#         @p_cut_left=1,
#         @p_cut_right=nil,
#         @range=1..1>],
#      @left=0,
#      @p_left=0,
#      @p_right=0,
#      @right=3,
#      @size=4,
#      @tags={}>}
# 
# 
# = Currently under development
# 
# * Circular DNA cutting
#
  
class Bio::RestrictionEnzyme
    include CutSymbol
    extend CutSymbol

    # See Bio::RestrictionEnzyme::DoubleStranded.new for more information.
    #
    # ---
    # *Arguments*
    # * +users_enzyme_or_rebase_or_pattern+: One of three possible parameters:  The name of an enzyme, a REBASE::EnzymeEntry object, or a nucleotide pattern with a cut mark.
    # * +cut_locations+: The cut locations in enzyme index notation.
    # *Returns*:: Bio::RestrictionEnzyme::DoubleStranded
    #--
    # Factory for DoubleStranded
    #++
    def self.new(users_enzyme_or_rebase_or_pattern, *cut_locations)
      DoubleStranded.new(users_enzyme_or_rebase_or_pattern, *cut_locations)
    end

    # REBASE enzyme data information
    #
    # Returns a Bio::REBASE object loaded with all of the enzyme data on file.
    #
    # ---
    # *Arguments*
    # * _none_
    # *Returns*:: Bio::REBASE
    def self.rebase
      enzymes_yaml_file = File.join(File.dirname(File.expand_path(__FILE__)), 'restriction_enzyme', 'enzymes.yaml')
      @@rebase_enzymes ||= Bio::REBASE.load_yaml(enzymes_yaml_file)
      @@rebase_enzymes
    end

    # Check if supplied name is the name of an available enzyme
    #
    # See Bio::REBASE.enzyme_name?
    #
    # ---
    # *Arguments*
    # * +name+: Enzyme name
    # *Returns*:: +true+ _or_ +false+
    def self.enzyme_name?( name )
      self.rebase.enzyme_name?(name)
    end

    # See Bio::RestrictionEnzyme::Analysis.cut
    def self.cut( sequence, enzymes )
      Bio::RestrictionEnzyme::Analysis.cut( sequence, enzymes )
    end

end # RestrictionEnzyme
end # Bio
