#
# = bio/feature.rb - Features/Feature class (GenBank Feature table)
#
# Copyright::	Copyright (c) 2002, 2005  Toshiaki Katayama <k@bioruby.org>
#                             2006        Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::	The Ruby License
#
# $Id: feature.rb,v 1.13 2007/04/05 23:35:39 trevor Exp $

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


# = DESCRIPTION
# Container for a list of Feature objects.
#
# = USAGE
#  # First, create some Bio::Feature objects
#  feature1 = Bio::Feature.new('intron','3627..4059')
#  feature2 = Bio::Feature.new('exon','4060..4236')
#  feature3 = Bio::Feature.new('intron','4237..4426')
#  feature4 = Bio::Feature.new('CDS','join(2538..3626,4060..4236)',
#                   [ Bio::Feature::Qualifier.new('gene', 'CYP2D6'),
#                     Bio::Feature::Qualifier.new('translation','MGXXTVMHLL...')
#                   ])
#
#  # And create a container for them
#  feature_container = Bio::Features.new([ feature1, feature2, feature3, feature4 ])
#
#  # Iterate over all features and print
#  feature_container.each do |feature|
#    puts feature.feature + "\t" + feature.position
#    feature.each do |qualifier|
#      puts "- " + qualifier.qualifier + ": " + qualifier.value
#    end
#  end
#
#  # Iterate only over CDS features and extract translated amino acid sequences
#  features.each("CDS") do |feature|
#    hash = feature.to_hash
#    name = hash["gene"] || hash["product"] || hash["note"] 
#    aaseq  = hash["translation"]
#    pos  = feature.position
#    if name and seq
#      puts ">#{gene} #{feature.position}"
#      puts aaseq
#    end
#  end
class Features
  # Create a new Bio::Features object.
  #
  # *Arguments*:
  # * (optional) _list of features_: list of Bio::Feature objects
  # *Returns*:: Bio::Features object
  def initialize(ary = [])
    @features = ary
  end

  # Returns an Array of Feature objects.
  attr_accessor :features

  # Appends a Feature object to Features.
  # 
  # *Arguments*:
  # * (required) _feature_: Bio::Feature object
  # *Returns*:: Bio::Features object
  def append(a)
    @features.push(a) if a.is_a? Feature
    return self
  end

  # Iterates on each feature object.
  #
  # *Arguments*:
  # * (optional) _key_: if specified, only iterates over features with this key
  def each(arg = nil)
    @features.each do |x|
      next if arg and x.feature != arg
      yield x
    end
  end

  # Short cut for the Features#features[n]
  def [](*arg)
    @features[*arg]
  end

  # Short cut for the Features#features.first
  def first
    @features.first
  end

  # Short cut for the Features#features.last
  def last
    @features.last
  end

end # Features

end # Bio

