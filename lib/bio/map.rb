#
# = bio/map.rb - biological mapping class
#
# Copyright::   Copyright (C) 2006
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     Ruby's
require 'bio/location'

module Bio
  # = DESCRIPTION
  # The Bio::Module contains classes that describe mapping information and can
  # be used to contain linkage maps, radiation-hybrid maps, etc.
  # As the same marker can be mapped to more than one map, and a single map
  # typically contains more than one marker, the link between the markers and
  # maps is handled by Bio::Map::Mapping objects. Therefore, to link a map to
  # a marker, a Bio::Mapping object is added to that Bio::Map. See usage below.
  #
  # Not only maps in the strict sense have map-like features (and similarly
  # not only markers in the strict sense have marker-like features). For example,
  # a microsatellite is something that can be mapped on a linkage map (and
  # hence becomes a 'marker'), but a clone can also be mapped to a cytogenetic
  # map. In that case, the clone acts as a marker and has marker-like properties.
  # That same clone can also be considered a 'map' when BAC-end sequences are
  # mapped to it. To reflect this flexibility, the modules Bio::Map::ActsLikeMap
  # and Bio::Map::ActsLikeMarker define methods that are typical for maps and
  # markers.
  # 
  #--
  # In a certain sense, a biological sequence also has map- and marker-like
  # properties: things can be mapped to it at certain locations, and the sequence
  # itself can be mapped to something else (e.g. the BAC-end sequence example
  # above, or a BLAST-result).
  #++
  # 
  # = USAGE
  #  my_marker1 = Bio::Map::Marker.new('marker1')
  #  my_marker2 = Bio::Map::Marker.new('marker2')
  #  my_marker3 = Bio::Map::Marker.new('marker3')
  #  
  #  my_map1 = Bio::Map::SimpleMap.new('RH_map_ABC (2006)', 'RH', 'cR')
  #  my_map2 = Bio::Map::SimpleMap.new('consensus', 'linkage', 'cM')
  #  
  #  my_map1.add_mapping_to_marker(my_marker1, '17')
  #  my_map1.add_mapping_to_marker(Bio::Map::Marker.new('marker2'), '5')
  #  my_marker3.add_mapping_to_marker(my_map1, '9')
  #  
  #  puts "Does my_map1 contain marker3? => " + my_map1.contains_marker?(my_marker3).to_s
  #  puts "Does my_map2 contain marker3? => " + my_map2.contains_marker?(my_marker3).to_s
  #  
  #  my_map1.sort.each do |mapping|
  #    puts mapping.map.name + "\t" + mapping.marker.name + "\t" + mapping.location.from.to_s + ".." + mapping.location.to.to_s
  #  end
  #  puts my_map1.min.marker.name
  #  my_map2.each do |mapping|
  #    puts mapping.map.name + "\t" + mapping.marker.name + "\t" + mapping.location.from.to_s + ".." + mapping.location.to.to_s
  #  end
  #
  # = TODO
  # Check if initialization of @mappings can be done in ActsLikeMap and
  # ActsLikeMarker, instead of in the classes that include these modules.
  module Map
  # = DESCRIPTION
  # The Bio::Map::ActsLikeMap module contains methods that are typical for
  # map-like things:
  # * add markers with their locations (through Bio::Map::Mappings)
  # * check if a given marker is mapped to it
  # , and can be mixed into other classes (e.g. Bio::Map::SimpleMap)
    module ActsLikeMap
      include Enumerable
      # = DESCRIPTION
      # Adds a Bio::Map::Mappings object to its array of mappings.
      # 
      # = USAGE
      #   # suppose we have a Bio::Map::SimpleMap object called my_map
      #   my_map.add_mapping_to_marker(Bio::Map::Marker.new('marker_a'), '5')
      # ---
      # *Arguments*:
      # * _marker_ (required): Bio::Map::Marker object
      # * _location_: location of mapping. Should be a _string_, not a _number_.
      # *Returns*:: itself
      def add_mapping_to_marker(marker, location = nil)
        unless marker.class.include?(Bio::Map::ActsLikeMarker)
          raise "[Error] marker is not object that implements Bio::Map::ActsLikeMarker"
        end
        my_mapping = Bio::Map::Mapping.new(self, marker, Bio::Location.new(location))
        @mappings.push(my_mapping)
        unless marker.mapped_to?(self)
          marker.mappings.push(my_mapping)
        end

        return self
      end
      
      # Checks whether a Bio::Map::Marker is mapped to this Bio::Map::SimpleMap.
      # ---
      # *Arguments*:
      # * _marker_: a Bio::Map::Marker object
      # *Returns*:: true or false
      def contains_marker?(marker)
        unless marker.class.include?(Bio::Map::ActsLikeMarker)
          raise "[Error] marker is not object that implements Bio::Map::ActsLikeMarker"
        end
        contains = false
        @mappings.each do |mapping|
          if mapping.marker == marker
            contains = true
            return contains
          end
        end
        return contains
      end
      
      # Go through all Bio::Map::Mapping objects linked to this Bio::Map::SimpleMap.
      def each
        @mappings.each do |mapping|
          yield mapping
        end
      end
    end #ActsLikeMap

    # = DESCRIPTION
    # The Bio::Map::ActsLikeMarker module contains methods that are typical for
    # marker-like things:
    # * map it to one or more maps
    # * check if it's mapped to a given map
    # , and can be mixed into other classes (e.g. Bio::Map::Marker)
    module ActsLikeMarker
      include Enumerable
      
      # = DESCRIPTION
      # Adds a Bio::Map::Mappings object to its array of mappings.
      # 
      # = USAGE
      #   # suppose we have a Bio::Map::Marker object called marker_a
      #   marker_a.add_mapping_to_map(Bio::Map::SimpleMap.new('my_map'), '5')
      # ---
      # *Arguments*:
      # * _map_ (required): Bio::Map::SimpleMap object
      # * _location_: location of mapping. Should be a _string_, not a _number_.
      # *Returns*:: itself
      def add_mapping_to_map(map, location = nil)
        unless map.class.include?(Bio::Map::ActsLikeMap)
          raise "[Error] map is not object that implements Bio::Map::ActsLikeMap"
        end
        my_mapping = Bio::Map::Mapping.new(map, self, Bio::Location.new(location))
        @mappings.push(my_mapping)
        unless map.contains_marker?(self)
          map.mappings.push(my_mapping)
        end
      end
      
      # Check whether this marker is mapped to a given Bio::Map::SimpleMap.
      # ---
      # *Arguments*:
      # * _map_: a Bio::Map::SimpleMap object
      # *Returns*:: true or false
      def mapped_to?(map)
        unless map.class.include?(Bio::Map::ActsLikeMap)
          raise "[Error] map is not object that implements Bio::Map::ActsLikeMap"
        end
				
        mapped = false
        @mappings.each do |mapping|
          if mapping.map == map
            mapped = true
            return mapped
          end
        end
        return mapped
      end
      
      # Go through all Mapping objects linked to this marker.
      def each
        @mappings.each do |mapping|
          yield mapping
        end
      end
    end #ActsLikeMarker
	  
    # = DESCRIPTION
    # Creates a new Bio::Map::Mapping object, which links Bio::Map::ActsAsMap-
    # and Bio::Map::ActsAsMarker-like objects. This class is typically not
    # accessed directly, but through map- or marker-like objects.
    class Mapping
      include Comparable
      
      # Creates a new Bio::Map::Mapping object
      # ---
      # *Arguments*:
      # * _map_: a Bio::Map::SimpleMap object
      # * _marker_: a Bio::Map::Marker object
      # * _location_: a Bio::Location object
      def initialize (map, marker, location = nil)
        @map, @marker, @location = map, marker, location
      end
      attr_accessor :map, :marker, :location
      
      # Compares the location of this mapping to another mapping.
      # ---
      # *Arguments*:
      # * other_mapping: Bio::Map::Mapping object
      # *Returns*::
      # * 1 if self < other location
      # * -1 if self > other location
      # * 0 if both location are the same
      # * nil if the argument is not a Bio::Location object
      def <=>(other)
        unless other.kind_of?(Bio::Map::Mapping)
          raise "[Error] markers are not comparable"
        end
        return self.location.<=>(other.location)
      end
    end # Mapping
    
    # = DESCRIPTION
    # This class handles the essential storage of name, type and units of a map.
    # It includes Bio::Map::ActsLikeMap, and therefore supports the methods of
    # that module.
    # 
    # = USAGE
    #   my_map1 = Bio::Map::SimpleMap.new('RH_map_ABC (2006)', 'RH', 'cR')
    #   my_map1.add_marker(Bio::Map::Marker.new('marker_a', '17')
    #   my_map1.add_marker(Bio::Map::Marker.new('marker_b', '5')
    class SimpleMap
    include ActsLikeMap
    
      # Builds a new Bio::Map::SimpleMap object
      # ---
      # *Arguments*:
      # * name: name of the map
      # * type: type of the map (e.g. linkage, radiation_hybrid, cytogenetic, ...)
      # * units: unit of the map (e.g. cM, cR, ...)
      # *Returns*:: new Bio::Map::SimpleMap object
      def initialize (name = nil, type = nil, units = nil)
        @name, @type, @units = name, type, units
        @mappings = Array.new
      end
      
      # Name of the map
      attr_accessor :name
			
      # Type of the map
      attr_accessor :type
			
      # Units of the map
      attr_accessor :units
      
      # Array of mappings for the map
      attr_accessor :mappings
    end # SimpleMap
    
    # = DESCRIPTION
    # This class handles markers that are anchored to a Bio::Map::SimpleMap. It
    # includes Bio::Map::ActsLikeMarker, and therefore supports the methods of
    # that module.
    # 
    # = USAGE
    #   marker_a = Bio::Map::Marker.new('marker_a')
    #   marker_b = Bio::Map::Marker.new('marker_b')
    class Marker
      include ActsLikeMarker
      
      # Builds a new Bio::Map::Marker object
      # ---
      # *Arguments*:
      # * name: name of the marker
      # *Returns*:: new Bio::Map::Marker object
      def initialize(name)
        @name = name
        @mappings = Array.new
      end

      # Name of the marker
      attr_accessor :name
			
      # Array of mappings for the marker
      attr_accessor :mappings
    end # Marker
  end # Map
end # Bio

if __FILE__ == $0
  my_marker1 = Bio::Map::Marker.new('marker1')
#  my_marker2 = Bio::Map::Marker.new('marker2')
  my_marker3 = Bio::Map::Marker.new('marker3')

  my_map1 = Bio::Map::SimpleMap.new('RH_map_ABC (2006)', 'RH', 'cR')
  my_map2 = Bio::Map::SimpleMap.new('consensus', 'linkage', 'cM')

  my_map1.add_mapping_to_marker(my_marker1, '17')
  my_map1.add_mapping_to_marker(Bio::Map::Marker.new('marker2'), '5')
  my_marker3.add_mapping_to_map(my_map1, '9')


  puts "Does my_map1 contain marker3? => " + my_map1.contains_marker?(my_marker3).to_s
  puts "Does my_map2 contain marker3? => " + my_map2.contains_marker?(my_marker3).to_s
	
  my_map1.sort.each do |mapping|
    puts mapping.map.name + "\t" + mapping.marker.name + "\t" + mapping.location.from.to_s + ".." + mapping.location.to.to_s
  end
  puts my_map1.min.marker.name
  my_map2.each do |mapping|
    puts mapping.map.name + "\t" + mapping.marker.name + "\t" + mapping.location.from.to_s + ".." + mapping.location.to.to_s
  end

#  p my_map1.between?(my_mappable2,my_mappable3)
#  p my_map1.between?(my_mappable,my_mappable2)
end
