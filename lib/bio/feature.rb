#
# = bio/feature.rb - Features/Feature class (GenBank Feature table)
#
# Copyright::	Copyright (c) 2002, 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	Ruby's
#
# $Id: feature.rb,v 1.10 2006/02/27 09:13:46 k Exp $
#
# == INSD Feature table definition
#
# See http://www.ddbj.nig.ac.jp/FT/full_index.html for the INSD
# (GenBank/EMBL/DDBJ) Feature table definition.
#
# === Example
#
#  # suppose features is a Bio::Features object
#  features.each do |feature|
#    f_name = feature.feature
#    f_pos  = feature.position
#    puts "#{f_name}:\t#{f_pos}"
#    feature.each do |qualifier|
#      q_name = qualifier.qualifier
#      q_val  = qualifier.value
#      puts "- #{q_name}:\t#{q_val}"
#    end
#  end
#
#  # Iterates only on CDS features and extract translated amino acid sequences
#  features.each("CDS") do |feature|
#    hash = feature.assoc
#    name = hash["gene"] || hash["product"] || hash["note"] 
#    seq  = hash["translation"]
#    pos  = feature.position
#    if gene and seq
#      puts ">#{gene} #{feature.position}"
#      puts aaseq
#    end
#  end
#

require 'bio/location'

module Bio

# Container for the sequence annotation.
class Feature

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
  # * Returns an Array of Qualifier objects.
  # * If the argument is not a Qualifier object, returns nil.
  #
  def append(a)
    @qualifiers.push(a) if a.is_a? Qualifier
    return self
  end

  # Iterates on each qualifier.
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

  # Container for the qualifier-value pair.
  class Qualifier

    def initialize(key, value)
      @qualifier, @value = key, value
    end

    # Qualifier name in String
    attr_reader :qualifier

    # Qualifier value in String
    attr_reader :value

  end

end


# Container for the list of Feature objects.
class Features

  def initialize(ary = [])
    @features = ary
  end

  # Returns an Array of Feature objects.
  attr_accessor :features

  # Appends a Feature object to Features.
  def append(a)
    @features.push(a) if a.is_a? Feature
    return self
  end

  # Iterates on each feature.  If a feature name is given as an argument,
  # only iterates on each feature belongs to the name (e.g. 'CDS' etc.)
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

end

end # Bio


