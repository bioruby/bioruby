#
# = bio/util/restriction_enzyme.rb - Digests DNA based on restriction enzyme cut patterns
#
# Copyright::  Copyright (C) 2006 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: restriction_enzyme.rb,v 1.3 2006/02/27 13:11:28 k Exp $
#
#
# NOTE: This documentation and the module are still very much under
# development.  It has been released as it is relatively stable and
# comments would be appreciated.
# 
# == Synopsis
# 
# Bio::RestrictionEnzyme allows you to fragment a DNA strand using one
# or more restriction enzymes.  Bio::RestrictionEnzyme is aware that
# multiple enzymes may be competing for the same recognition site and
# returns the various possible fragmentation patterns that result in
# such circumstances.
# 

# Using Bio::RestrictionEnzyme you may simply use the name of common
# enzymes to cut with or you may construct your own unique enzymes to use.
# 
# 
# == Basic Usage
# 
#   # EcoRI cut pattern:
#   #   G|A A T T C
#   #    +-------+
#   #   C T T A A|G
#   #
#   # This can also be written as:
#   #   G^AATTC
# 
#   require 'bio/restriction_enzyme'
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
# 
# == Advanced Usage
# 
#   require 'bio/restriction_enzyme'
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
# == Todo
# 
# Currently under development:
# 
# * Optimizations in restriction_enzyme/analysis.rb to cut down on
#   factorial growth of computation space.
# * Circular DNA cutting
# * Tagging of sequence data
# * Much more documentation
# 
# 
#--
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#++
#
#


require 'bio/db/rebase'
require 'bio/util/restriction_enzyme/double_stranded'
require 'bio/util/restriction_enzyme/single_strand'
require 'bio/util/restriction_enzyme/cut_symbol'
require 'bio/util/restriction_enzyme/analysis'


module Bio

class Bio::RestrictionEnzyme
    include CutSymbol
    extend CutSymbol

    # Factory for DoubleStranded
    def self.new(users_enzyme_or_rebase_or_pattern, *cut_locations)
      DoubleStranded.new(users_enzyme_or_rebase_or_pattern, *cut_locations)
    end

    # REBASE enzyme data information
    #
    # Returns a Bio::REBASE object loaded with all of the enzyme data on file.
    #
    def self.rebase(enzymes_yaml)
      @@rebase_enzymes ||= Bio::REBASE.load_yaml(enzymes_yaml)
      @@rebase_enzymes
    end

    # Primitive way of determining if a string is an enzyme name.
    #
    # Should work just fine thanks to dumb luck.  A nucleotide or nucleotide
    # set can't ever contain an 'i'.  Restriction enzymes always end in 'i'.
    #
    #--
    # Could also look for cut symbols.
    #++
    #
    def self.enzyme_name?( str )
      str[-1].chr.downcase == 'i'
    end

    # See Bio::RestrictionEnzyme::Analysis.cut
    def self.cut( sequence, enzymes )
      Bio::RestrictionEnzyme::Analysis.cut( sequence, enzymes )
    end

end

end # Bio
