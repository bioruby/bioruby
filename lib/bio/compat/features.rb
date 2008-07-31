#
# = bio/compat/features.rb - Obsoleted Features class
#
# Copyright::	Copyright (c) 2002, 2005  Toshiaki Katayama <k@bioruby.org>
#                             2006        Jan Aerts <jan.aerts@bbsrc.ac.uk>
#                             2008        Naohisa Goto <ng@bioruby.org>
# License::	The Ruby License
#
# $Id: features.rb,v 1.1.2.2 2008/03/10 13:42:26 ngoto Exp $
#
# == Description
#
# The Bio::Features class was obsoleted after BioRuby 1.2.1.
# To keep compatibility, some wrapper methods are provided in this file.
# As the compatibility methods (and Bio::Features) will soon be removed,
# Please change your code not to use Bio::Features.
#
# Note that Bio::Feature is different from the Bio::Features.
# Bio::Feature still exists to store DDBJ/GenBank/EMBL feature information.

require 'bio/location'

module Bio

# = DESCRIPTION
#
# This class is OBSOLETED, and will soon be removed.
# Instead of this class, an array is to be used.
#
#
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

  # module to keep backward compatibility with obsoleted Bio::Features
  module BackwardCompatibility #:nodoc:

    # Backward compatibility with Bio::Features#features.
    # Now, features are stored in an array, and
    # you should change your code not to use this method.
    def features
      warn 'Bio::Features is obsoleted. Now, features are stored in an array.'
      self
    end

    # Backward compatibility with Bio::Features#append.
    # Now, references are stored in an array, and
    # you should change your code not to use this method.
    def append(feature)
      warn 'Bio::Features is obsoleted. Now, features are stored in an array.'
      self.push(feature) if feature.is_a? Feature
      self
    end
  end #module BackwardCompatibility

  # This method should not be used.
  # Only for backward compatibility of existing code.
  #
  # Since Bio::Features is obsoleted,
  # Bio::Features.new not returns Bio::Features object,
  # but modifies given _ary_ and returns the _ary_.
  #
  # *Arguments*:
  # * (optional) __: Array of Bio::Feature objects
  # *Returns*:: the given array
  def self.new(ary = [])
    warn 'Bio::Features is obsoleted. Some methods are added to given array to keep backward compatibility.'
    ary.extend(BackwardCompatibility)
    ary
  end

  # Normally, users can not call this method.
  #
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

