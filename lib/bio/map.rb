#
# = bio/map.rb - biological mapping class
#
# Copyright::   Copyright (C) 2006 Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#
# $Id: map.rb,v 1.11 2007/04/12 12:19:16 aerts Exp $

require 'bio/location'

module Bio

  # == Description
  #
  # The Bio::Map contains classes that describe mapping information
  # and can be used to contain linkage maps, radiation-hybrid maps,
  # etc.  As the same marker can be mapped to more than one map, and a
  # single map typically contains more than one marker, the link
  # between the markers and maps is handled by Bio::Map::Mapping
  # objects. Therefore, to link a map to a marker, a Bio::Map::Mapping
  # object is added to that Bio::Map. See usage below.
  #
  # Not only maps in the strict sense have map-like features (and
  # similarly not only markers in the strict sense have marker-like
  # features). For example, a microsatellite is something that can be
  # mapped on a linkage map (and hence becomes a 'marker'), but a
  # clone can also be mapped to a cytogenetic map. In that case, the
  # clone acts as a marker and has marker-like properties.  That same
  # clone can also be considered a 'map' when BAC-end sequences are
  # mapped to it. To reflect this flexibility, the modules
  # Bio::Map::ActsLikeMap and Bio::Map::ActsLikeMarker define methods
  # that are typical for maps and markers.
  # 
  #--
  # In a certain sense, a biological sequence also has map- and
  # marker-like properties: things can be mapped to it at certain
  # locations, and the sequence itself can be mapped to something else
  # (e.g. the BAC-end sequence example above, or a BLAST-result).
  #++
  # 
  # == Usage
  #
  #  my_marker1 = Bio::Map::Marker.new('marker1')
  #  my_marker2 = Bio::Map::Marker.new('marker2')
  #  my_marker3 = Bio::Map::Marker.new('marker3')
  #  
  #  my_map1 = Bio::Map::SimpleMap.new('RH_map_ABC (2006)', 'RH', 'cR')
  #  my_map2 = Bio::Map::SimpleMap.new('consensus', 'linkage', 'cM')
  #  
  #  my_map1.add_mapping_as_map(my_marker1, '17')
  #  my_map1.add_mapping_as_map(Bio::Map::Marker.new('marker2'), '5')
  #  my_marker3.add_mapping_as_marker(my_map1, '9')
  #  
  #  print "Does my_map1 contain marker3? => "
  #  puts my_map1.contains_marker?(my_marker3).to_s
  #  print "Does my_map2 contain marker3? => "
  #  puts my_map2.contains_marker?(my_marker3).to_s
  #  
  #  my_map1.mappings_as_map.sort.each do |mapping|
  #    puts [ mapping.map.name,
  #           mapping.marker.name,
  #           mapping.location.from.to_s,
  #           mapping.location.to.to_s ].join("\t")
  #  end
  #  puts my_map1.mappings_as_map.min.marker.name
  #
  #  my_map2.mappings_as_map.each do |mapping|
  #    puts [ mapping.map.name,
  #           mapping.marker.name,
  #           mapping.location.from.to_s,
  #           mapping.location.to.to_s ].join("\t")
  #  end
  #
  module Map

    # == Description
    #
    # The Bio::Map::ActsLikeMap module contains methods that are typical for
    # map-like things:
    #
    # * add markers with their locations (through Bio::Map::Mappings)
    # * check if a given marker is mapped to it,
    #   and can be mixed into other classes (e.g. Bio::Map::SimpleMap)
    # 
    # Classes that include this mixin should provide an array property
    # called mappings_as_map.
    #
    # For example:
    #
    #   class MyMapThing
    #     include Bio::Map::ActsLikeMap
    #     
    #     def initialize (name)
    #       @name = name
    #       @mappings_as_maps = Array.new
    #     end
    #     attr_accessor :name, :mappings_as_map
    #    end
    #
    module ActsLikeMap

      # == Description
      #
      # Adds a Bio::Map::Mappings object to its array of mappings.
      # 
      # == Usage
      #
      #   # suppose we have a Bio::Map::SimpleMap object called my_map
      #   my_map.add_mapping_as_map(Bio::Map::Marker.new('marker_a'), '5')
      #
      # ---
      # *Arguments*:
      # * _marker_ (required): Bio::Map::Marker object
      # * _location_: location of mapping. Should be a _string_, not a _number_.
      # *Returns*:: itself
      def add_mapping_as_map(marker, location = nil)
        unless marker.class.include?(Bio::Map::ActsLikeMarker)
          raise "[Error] marker is not object that implements Bio::Map::ActsLikeMarker"
        end
        my_mapping = ( location.nil? ) ? Bio::Map::Mapping.new(self, marker, nil) : Bio::Map::Mapping.new(self, marker, Bio::Locations.new(location))
        if ! marker.mapped_to?(self)
          self.mappings_as_map.push(my_mapping)
          marker.mappings_as_marker.push(my_mapping)
        else
          already_mapped = false
          marker.positions_on(self).each do |loc|
            if loc.equals?(Bio::Locations.new(location))
              already_mapped = true
            end
          end
          if ! already_mapped
            self.mappings_as_map.push(my_mapping)
            marker.mappings_as_marker.push(my_mapping)
          end
        end

        return self
      end

      # Checks whether a Bio::Map::Marker is mapped to this
      # Bio::Map::SimpleMap.
      #
      # ---
      # *Arguments*:
      # * _marker_: a Bio::Map::Marker object
      # *Returns*:: true or false
      def contains_marker?(marker)
        unless marker.class.include?(Bio::Map::ActsLikeMarker)
          raise "[Error] marker is not object that implements Bio::Map::ActsLikeMarker"
        end
        contains = false
        self.mappings_as_map.each do |mapping|
          if mapping.marker == marker
            contains = true
            return contains
          end
        end
        return contains
      end
      
    end # ActsLikeMap

    # == Description
    #
    # The Bio::Map::ActsLikeMarker module contains methods that are
    # typical for marker-like things:
    #
    # * map it to one or more maps
    # * check if it's mapped to a given map
    #   and can be mixed into other classes (e.g. Bio::Map::Marker)
    # 
    # Classes that include this mixin should provide an array property
    # called mappings_as_marker.
    #
    # For example:
    #
    #   class MyMarkerThing
    #     include Bio::Map::ActsLikeMarker
    #     
    #     def initialize (name)
    #       @name = name
    #       @mappings_as_marker = Array.new
    #     end
    #     attr_accessor :name, :mappings_as_marker
    #    end
    #
    module ActsLikeMarker

      # == Description
      #
      # Adds a Bio::Map::Mappings object to its array of mappings.
      # 
      # == Usage
      #
      #   # suppose we have a Bio::Map::Marker object called marker_a
      #   marker_a.add_mapping_as_marker(Bio::Map::SimpleMap.new('my_map'), '5')
      #
      # ---
      # *Arguments*:
      # * _map_ (required): Bio::Map::SimpleMap object
      # * _location_: location of mapping. Should be a _string_, not a _number_.
      # *Returns*:: itself
      def add_mapping_as_marker(map, location = nil)
        unless map.class.include?(Bio::Map::ActsLikeMap)
          raise "[Error] map is not object that implements Bio::Map::ActsLikeMap"
        end
        my_mapping = (location.nil?) ? Bio::Map::Mappings.new(map, self, nil) : Bio::Map::Mapping.new(map, self, Bio::Locations.new(location))
        if ! self.mapped_to?(map)
          self.mappings_as_marker.push(my_mapping)
          map.mappings_as_map.push(my_mapping)
        else
          already_mapped = false
          self.positions_on(map).each do |loc|
            if loc.equals?(Bio::Locations.new(location))
              already_mapped = true
            end
          end
          if ! already_mapped
            self.mappings_as_marker.push(my_mapping)
            map.mappings_as_map.push(my_mapping)
          end
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
        self.mappings_as_marker.each do |mapping|
          if mapping.map == map
            mapped = true
            return mapped
          end
        end

        return mapped
      end

      # Return all positions of this marker on a given map.
      # ---
      # *Arguments*:
      # * _map_: an object that mixes in Bio::Map::ActsLikeMap
      # *Returns*:: array of Bio::Location objects
      def positions_on(map)
        unless map.class.include?(Bio::Map::ActsLikeMap)
          raise "[Error] map is not object that implements Bio::Map::ActsLikeMap"
        end
        
        positions = Array.new
        self.mappings_as_marker.each do |mapping|
          if mapping.map == map
            positions.push(mapping.location)
          end
        end
        
        return positions
      end

      # Return all mappings of this marker on a given map.
      # ---
      # *Arguments*:
      # * _map_: an object that mixes in Bio::Map::ActsLikeMap
      # *Returns*:: array of Bio::Map::Mapping objects
      def mappings_on(map)
        unless map.class.include?(Bio::Map::ActsLikeMap)
          raise "[Error] map is not object that implements Bio::Map::ActsLikeMap"
        end
        
        m = Array.new
        self.mappings_as_marker.each do |mapping|
          if mapping.map == map
            m.push(mapping)
          end
        end
        
        return m
      end
      

    end # ActsLikeMarker
	  
    # == Description
    #
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
      # * _location_: a Bio::Locations object
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
	    unless @map.equal?(other.map)
          raise "[Error] maps have to be the same"
        end

        return self.location[0].<=>(other.location[0])
      end
    end # Mapping
    
    # == Description
    #
    # This class handles the essential storage of name, type and units
    # of a map.  It includes Bio::Map::ActsLikeMap, and therefore
    # supports the methods of that module.
    # 
    # == Usage
    #
    #   my_map1 = Bio::Map::SimpleMap.new('RH_map_ABC (2006)', 'RH', 'cR')
    #   my_map1.add_marker(Bio::Map::Marker.new('marker_a', '17')
    #   my_map1.add_marker(Bio::Map::Marker.new('marker_b', '5')
    #
    class SimpleMap

      include Bio::Map::ActsLikeMap
    
      # Builds a new Bio::Map::SimpleMap object
      # ---
      # *Arguments*:
      # * name: name of the map
      # * type: type of the map (e.g. linkage, radiation_hybrid, cytogenetic, ...)
      # * units: unit of the map (e.g. cM, cR, ...)
      # *Returns*:: new Bio::Map::SimpleMap object
      def initialize (name = nil, type = nil, length = nil, units = nil)
        @name, @type, @length, @units = name, type, length, units
        @mappings_as_map = Array.new
      end
      
      # Name of the map
      attr_accessor :name
			
      # Type of the map
      attr_accessor :type
	
      # Length of the map
      attr_accessor :length
      		
      # Units of the map
      attr_accessor :units
      
      # Mappings
      attr_accessor :mappings_as_map
      
    end # SimpleMap
    
    # == Description
    #
    # This class handles markers that are anchored to a Bio::Map::SimpleMap.
    # It includes Bio::Map::ActsLikeMarker, and therefore supports the
    # methods of that module.
    # 
    # == Usage
    #
    #   marker_a = Bio::Map::Marker.new('marker_a')
    #   marker_b = Bio::Map::Marker.new('marker_b')
    #
    class Marker

      include Bio::Map::ActsLikeMarker
      
      # Builds a new Bio::Map::Marker object
      # ---
      # *Arguments*:
      # * name: name of the marker
      # *Returns*:: new Bio::Map::Marker object
      def initialize(name)
        @name = name
        @mappings_as_marker = Array.new
      end

      # Name of the marker
      attr_accessor :name
      
      # Mappings
      attr_accessor :mappings_as_marker
      
    end # Marker

  end # Map

end # Bio
