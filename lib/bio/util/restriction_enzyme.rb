#
# bio/util/restriction_enzyme.rb - Digests DNA based on restriction enzyme cut patterns
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: restriction_enzyme.rb,v 1.16 2007/07/16 19:28:48 k Exp $
#

module Bio #:nodoc:

  autoload :REBASE, 'bio/db/rebase'

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
# Visit the documentaion for individual classes for more information.
#
# An examination of the unit tests will also reveal several interesting uses
# for the curious programmer.
# 
# = Usage
# 
# == Basic
#
# EcoRI cut pattern:
#   G|A A T T C
#    +-------+
#   C T T A A|G
# 
# This can also be written as:
#   G^AATTC
#
# Note that to use the method +cut_with_enzyme+ from a Bio::Sequence object 
# you currently must +require+ +bio/util/restriction_enzyme+ directly.  If
# instead you're going to directly call Bio::RestrictionEnzyme::Analysis
# then only +bio+ needs to be +required+.
# 
#   require 'bio'
#   require 'bio/util/restriction_enzyme'
#   
#   seq = Bio::Sequence::NA.new('gaattc')
#   cuts = seq.cut_with_enzyme('EcoRI')
#   cuts.primary                        # => ["aattc", "g"]
#   cuts.complement                     # => ["cttaa", "g"]
#   cuts.inspect                        # => "[#<struct Bio::RestrictionEnzyme::Fragment primary=\"g    \", complement=\"cttaa\">, #<struct Bio::RestrictionEnzyme::Fragment primary=\"aattc\", complement=\"    g\">]"
#   
#   seq = Bio::Sequence::NA.new('gaattc')
#   cuts = seq.cut_with_enzyme('g^aattc')
#   cuts.primary                        # => ["aattc", "g"]
#   cuts.complement                     # => ["cttaa", "g"]
#   
#   seq = Bio::Sequence::NA.new('gaattc')
#   cuts = seq.cut_with_enzyme('g^aattc', 'gaatt^c')
#   cuts.primary                        # => ["aattc", "c", "g", "gaatt"]
#   cuts.complement                     # => ["c", "cttaa", "g", "ttaag"]
#   
#   seq = Bio::Sequence::NA.new('gaattcgaattc')
#   cuts = seq.cut_with_enzyme('EcoRI')
#   cuts.primary                        # => ["aattc", "aattcg", "g"]
#   cuts.complement                     # => ["cttaa", "g", "gcttaa"]
#   
#   seq = Bio::Sequence::NA.new('gaattcgggaattc')
#   cuts = seq.cut_with_enzyme('EcoRI')
#   cuts.primary                        # => ["aattc", "aattcggg", "g"]
#   cuts.complement                     # => ["cttaa", "g", "gcccttaa"]
#   
#   cuts[0].inspect                     # => "#<struct Bio::RestrictionEnzyme::Fragment primary=\"g    \", complement=\"cttaa\">"
#   
#   cuts[0].primary                     # => "g    "
#   cuts[0].complement                  # => "cttaa"
#   
#   cuts[1].primary                     # => "aattcggg    "
#   cuts[1].complement                  # => "    gcccttaa"
#   
#   cuts[2].primary                     # => "aattc"
#   cuts[2].complement                  # => "    g"
#   
# == Advanced
#
#   require 'bio'
#   
#   enzyme_1 = Bio::RestrictionEnzyme.new('anna', [1,1], [3,3])
#   enzyme_2 = Bio::RestrictionEnzyme.new('gg', [1,1])
#   a = Bio::RestrictionEnzyme::Analysis.cut('agga', enzyme_1, enzyme_2)
#   a.primary                           # => ["a", "ag", "g", "ga"]
#   a.complement                        # => ["c", "ct", "t", "tc"]
#   
#   a[0].primary                        # => "ag"
#   a[0].complement                     # => "tc"
#   
#   a[1].primary                        # => "ga"
#   a[1].complement                     # => "ct"
#   
#   a[2].primary                        # => "a"
#   a[2].complement                     # => "t"
#   
#   a[3].primary                        # => "g"
#   a[3].complement                     # => "c"
# 
# = Todo / under development
# 
# * Circular DNA cutting
#

class RestrictionEnzyme

  #require 'bio/util/restriction_enzyme/cut_symbol'

  autoload :CutSymbol,               'bio/util/restriction_enzyme/cut_symbol'
  autoload :StringFormatting,        'bio/util/restriction_enzyme/string_formatting'
  autoload :SingleStrand,            'bio/util/restriction_enzyme/single_strand'
  autoload :SingleStrandComplement,  'bio/util/restriction_enzyme/single_strand_complement'
  autoload :DoubleStranded,          'bio/util/restriction_enzyme/double_stranded'
  autoload :Analysis,                'bio/util/restriction_enzyme/analysis'
  autoload :Range,                   'bio/util/restriction_enzyme/range/sequence_range'

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

  # A Bio::RestrictionEnzyme::Fragment is a DNA fragment composed of fused primary and 
  # complementary strands that would be found floating in solution after a full
  # sequence is digested by one or more RestrictionEnzymes.
  #
  # You will notice that either the primary or complement strand will be
  # padded with spaces to make them line up according to the original DNA
  # configuration before they were cut.
  #
  # Example:
  #
  # Fragment 1:
  #   primary =    "attaca"
  #   complement = "  atga"
  # 
  # Fragment 2:
  #   primary =    "g  "
  #   complement = "cta"
  # 
  # View these with the +primary+ and +complement+ methods.
  # 
  # Bio::RestrictionEnzyme::Fragment is a simple +Struct+ object.
  # 
  # Note: unrelated to Bio::RestrictionEnzyme::Range::SequenceRange::Fragment
  Fragment = Struct.new(:primary, :complement, :p_left, :p_right, :c_left, :c_right)

  # Bio::RestrictionEnzyme::Fragments inherits from +Array+.
  #
  # Bio::RestrictionEnzyme::Fragments is a container for Fragment objects.  It adds the
  # methods +primary+ and +complement+ which returns an +Array+ of all
  # respective strands from it's Fragment members in alphabetically sorted 
  # order.  Note that it will
  # not return duplicate items and does not return the spacing/padding 
  # that you would
  # find by accessing the members directly.
  # 
  # Example:
  #
  #   primary = ['attaca', 'g']
  #   complement = ['atga', 'cta']
  #
  # Note: unrelated to Bio::RestrictionEnzyme::Range::SequenceRange::Fragments
  class Fragments < Array
    def primary; strip_and_sort(:primary); end
    def complement; strip_and_sort(:complement); end

    protected

    def strip_and_sort( sym_strand )
      self.map {|uf| uf.send( sym_strand ).tr(' ', '') }.sort
    end
  end
end # RestrictionEnzyme
end # Bio
