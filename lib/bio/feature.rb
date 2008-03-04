#
# = bio/feature.rb - Features/Feature class (GenBank Feature table)
#
# Copyright::	Copyright (c) 2002, 2005  Toshiaki Katayama <k@bioruby.org>
#                             2006        Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::	The Ruby License
#
# $Id: feature.rb,v 1.13.2.1 2008/03/04 10:12:22 ngoto Exp $

require 'bio/location'

module Bio

# = DESCRIPTION
# Container for the sequence annotation.
#
# = USAGE
#  # Create a Bio::Feature object.
#  # For example: the GenBank-formatted entry in genbank for accession M33388
#  # contains the following feature:
#  #    exon     1532..1799
#  #             /gene="CYP2D6"
#  #             /note="cytochrome P450 IID6; GOO-132-127"
#  #             /number="1"
#  feature = Bio::Feature.new('exon','1532..1799')
#  feature.append(Bio::Feature::Qualifier.new('gene', 'CYP2D6'))
#  feature.append(Bio::Feature::Qualifier.new('note', 'cytochrome P450 IID6'))
#  feature.append(Bio::Feature::Qualifier.new('number', '1'))
#
#  # or all in one go:
#  feature2 = Bio::Feature.new('exon','1532..1799',
#    [ Bio::Feature::Qualifier.new('gene', 'CYP2D6'),
#      Bio::Feature::Qualifier.new('note', 'cytochrome P450 IID6; GOO-132-127'),
#      Bio::Feature::Qualifier.new('number', '1')
#    ])
#
#  # Print the feature
#  puts feature.feature + "\t" + feature.position
#  feature.each do |qualifier|
#    puts "- " + qualifier.qualifier + ": " + qualifier.value
#  end
#
# = REFERENCES
# INSD feature table definition:: http://www.ddbj.nig.ac.jp/FT/full_index.html
class Feature
  # Create a new Bio::Feature object.
  # *Arguments*:
  # * (required) _feature_: type of feature (e.g. "exon")
  # * (required) _position_: position of feature (e.g. "complement(1532..1799)")
  # * (opt) _qualifiers_: list of Bio::Feature::Qualifier objects (default: [])
  # *Returns*:: Bio::Feature object
  def initialize(feature = '', position = '', qualifiers = [])
    @feature, @position, @qualifiers = feature, position, qualifiers
  end

  # Returns type of feature in String (e.g 'CDS', 'gene')
  attr_accessor :feature

  # Returns position of the feature in String (e.g. 'complement(123..146)')
  attr_accessor :position

  # Returns an Array of Qualifier objects.
  attr_accessor :qualifiers

  # Returns a Bio::Locations object translated from the position string.
  def locations
    Locations.new(@position)
  end

  # Appends a Qualifier object to the Feature.
  # 
  # *Arguments*:
  # * (required) _qualifier_: Bio::Feature::Qualifier object
  # *Returns*:: Bio::Feature object
  def append(a)
    @qualifiers.push(a) if a.is_a? Qualifier
    return self
  end

  # Iterates on each qualifier object.
  #
  # *Arguments*:
  # * (optional) _key_: if specified, only iterates over qualifiers with this key
  def each(arg = nil)
    @qualifiers.each do |x|
      next if arg and x.qualifier != arg
      yield x
    end
  end

  # Returns a Hash constructed from qualifier objects.
  def assoc
    STDERR.puts "Bio::Feature#assoc is deprecated, use Bio::Feature#to_hash instead" if $DEBUG
    hash = Hash.new
    @qualifiers.each do |x|
      hash[x.qualifier] = x.value
    end
    return hash
  end

  # Returns a Hash constructed from qualifier objects.
  def to_hash
    hash = Hash.new
    @qualifiers.each do |x|
      hash[x.qualifier] ||= []
      hash[x.qualifier] << x.value
    end
    return hash
  end

  # Short cut for the Bio::Feature#to_hash[key]
  def [](key)
    self.to_hash[key]
  end

  # Container for qualifier-value pairs for sequence features.
  class Qualifier
    # Creates a new Bio::Feature::Qualifier object
    #
    # *Arguments*:
    # * (required) _key_: key of the qualifier (e.g. "gene")
    # * (required) _value_: value of the qualifier (e.g. "CYP2D6")
    # *Returns*:: Bio::Feature::Qualifier object
    def initialize(key, value)
      @qualifier, @value = key, value
    end

    # Qualifier name in String
    attr_reader :qualifier

    # Qualifier value in String
    attr_reader :value

  end #Qualifier

end #Feature

end # Bio

