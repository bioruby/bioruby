#
# bio/feature.rb - Features/Feature class (GenBank Feature table)
#
#   Copyright (C) 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: feature.rb,v 1.5 2003/02/25 12:22:00 k Exp $
#

require 'bio/location'

module Bio

  class Feature

    def initialize(feature = '', position = '', qualifiers = [])
      @feature, @position, @qualifiers = feature, position, qualifiers
    end
    attr_accessor :feature, :position, :qualifiers

    def locations
      Locations.new(@position)
    end

    def append(a)
      @qualifiers.push(a) if a.is_a? Qualifier
      return self
    end

    def each
      @qualifiers.each do |x|
	yield x
      end
    end

    def assoc
      hash = Hash.new
      @qualifiers.each do |x|
        hash[x.qualifier] = x.value
      end
      return hash
    end


    class Qualifier

      def initialize(key, value)
	@qualifier, @value = key, value
      end
      attr_reader :qualifier, :value

    end

  end


  class Features

    def initialize(ary = [])
      @features = ary
    end
    attr_accessor :features

    def append(a)
      @features.push(a) if a.is_a? Feature
      return self
    end

    def each(arg = nil)
      @features.each do |x|
	next if arg and x.feature != arg
	yield x
      end
    end

    def [](*arg)
      @features[*arg]
    end

  end

end


=begin

= Bio::Feature

--- Bio::Feature.new(feature = '', position = '', qualifiers = [])

--- Bio::Feature#feature -> String
--- Bio::Feature#position -> String
--- Bio::Feature#qualifiers -> Array

--- Bio::Feature#locations -> Bio::Locations
--- Bio::Feature#append -> Bio::Feature
--- Bio::Feature#each -> Array

== Bio::Feature::Qualifier

--- Bio::Feature::Qualifier.new(key, value)

--- Bio::Feature::Qualifier#qualifier -> String
--- Bio::Feature::Qualifier#value -> String

= Bio::Features

--- Bio::Features.new(ary = [])

--- Bio::Features#features -> Array
--- Bio::Features#append(a) -> Bio::Features
--- Bio::Features#each -> Array

=end


