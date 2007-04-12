#
# = test/unit/bio/test_map.rb - Unit test for Bio::Map
#
# Copyright::   Copyright (C) 2006
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#
# $Id:

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/map'

module Bio
  class TestMapSimple < Test::Unit::TestCase
    def setup
      @marker1 = Bio::Map::Marker.new('marker1')
      @marker2 = Bio::Map::Marker.new('marker2')
      @map1 = Bio::Map::SimpleMap.new('map1', 'some_type', 500, 'some_unit')
    end

    def test_attributes
      assert_equal("marker1", @marker1.name)
      assert_equal("marker2", @marker2.name)
      assert_equal([], @marker1.mappings_as_marker)
      assert_equal([], @marker2.mappings_as_marker)
      assert_equal("map1", @map1.name)
      assert_equal("some_unit", @map1.units)
      assert_equal("some_type", @map1.type)
      assert_equal([], @map1.mappings_as_map)
    end
  end

  class TestMapping < Test::Unit::TestCase
    def setup
      @marker1 = Bio::Map::Marker.new('marker1')
      @marker2 = Bio::Map::Marker.new('marker2')
      @marker3 = Bio::Map::Marker.new('marker3')
      @map1 = Bio::Map::SimpleMap.new('map1', 'some_type', 'some_unit')
      @map2 = Bio::Map::SimpleMap.new('map2', 'some_other_type', 'some_other_unit')
    end

    def test_add_mapping_as_map
      @map1.add_mapping_as_map(@marker2, '5')
      assert_equal(1, @map1.mappings_as_map.length)
      assert_equal(1, @marker2.mappings_as_marker.length)
      assert_equal(0, @marker1.mappings_as_marker.length)
      assert_kind_of(Bio::Locations, @map1.mappings_as_map[0].location)
      assert_kind_of(Bio::Locations, @marker2.mappings_as_marker[0].location)
    end

    def test_add_mapping_as_marker
      @marker1.add_mapping_as_marker(@map1, '5')
      assert_equal(1, @map1.mappings_as_map.length, 'Mapping as map')
      assert_equal(1, @marker1.mappings_as_marker.length, 'Mapping as marker')
      assert_kind_of(Bio::Locations, @map1.mappings_as_map[0].location)
      assert_kind_of(Bio::Locations, @marker1.mappings_as_marker[0].location)
    end
    
    def test_mapped_to?
      @marker1.add_mapping_as_marker(@map1, '5')
      assert_equal(true, @marker1.mapped_to?(@map1))
      assert_equal(false, @marker3.mapped_to?(@map1))
    end
    
    def test_contains_marker?
      @marker1.add_mapping_as_marker(@map1, '5')
      assert_equal(true, @map1.contains_marker?(@marker1))
      assert_equal(false, @map1.contains_marker?(@marker3))
    end
    
    def test_mappings_as_map_each
      @map1.add_mapping_as_map(@marker1, '5')
      @marker2.add_mapping_as_marker(@map1, '7')
      mappings = 0
      @map1.mappings_as_map.each do |mapping|
        mappings += 1
      end
      assert_equal(2, mappings)
    end

    def test_mappings_as_marker_each
      @map1.add_mapping_as_map(@marker1, '5')
      @marker1.add_mapping_as_marker(@map1, '7')
      mappings = 0
      @marker1.mappings_as_marker.each do |mapping|
        mappings += 1
      end
      assert_equal(2, mappings)
      
    end
    
    def test_multiple_mappings_between_same_marker_and_map
      @map1.add_mapping_as_map(@marker1, '5')
      @map1.add_mapping_as_map(@marker1, '37')
      @marker1.add_mapping_as_marker(@map1, '53')
      assert_equal(3, @marker1.mappings_as_marker.length)

      @marker1.add_mapping_as_marker(@map1, '53')  # This mapping should _not_ be added, because it's already defined.
      assert_equal(3, @marker1.mappings_as_marker.length)
      
      @map1.add_mapping_as_map(@marker1, '53')
      assert_equal(3, @marker1.mappings_as_marker.length)
    end
    
    def test_positions_on
      @map1.add_mapping_as_map(@marker1, '5')
      assert_equal(1, @marker1.mappings_as_marker.length)
      assert_equal('5', @marker1.positions_on(@map1).collect{|p| p.first.from.to_s}.join(',')) # FIXME: Test is not correct (uses Location.first)
      @map1.add_mapping_as_map(@marker1, '37')
      assert_equal('5,37', @marker1.positions_on(@map1).collect{|p| p.first.from.to_s}.sort{|a,b| a.to_i <=> b.to_i}.join(',')) # FIXME: Test is not correct (uses Location.first)
    end
    
    def test_mappings_on
      @map1.add_mapping_as_map(@marker1, '5')
      @map1.add_mapping_as_map(@marker1, '37')
      assert_equal('5,37', @marker1.mappings_on(@map1).sort{|a,b| a.location[0].from.to_i <=> b.location[0].from.to_i}.collect{|m| m.location[0].from}.join(',')) # FIXME: Test is not correct (uses Location.first)
    end    
    
    def test_mapping_location_comparison
      @map1.add_mapping_as_map(@marker1, '5')
      @map1.add_mapping_as_map(@marker2, '5')
      @map1.add_mapping_as_map(@marker3, '17')
      
      mapping1 = @marker1.mappings_on(@map1)[0]
      mapping2 = @marker2.mappings_on(@map1)[0]
      mapping3 = @marker3.mappings_on(@map1)[0]
      assert_equal(true, mapping1 == mapping2)
      assert_equal(false, mapping1 < mapping2)
      assert_equal(false, mapping1 > mapping2)
      assert_equal(false, mapping1 == mapping3)
      assert_equal(true, mapping1 < mapping3)
      assert_equal(false, mapping1 > mapping3)
      
      @map2.add_mapping_as_map(@marker1, '23')
      mapping4 = @marker1.mappings_on(@map2)[0]
      assert_raise(RuntimeError) { mapping2 < mapping4 }
    end
    
    def test_raise_error_kind_of
      marker_without_class = 'marker1'
      assert_raise(RuntimeError) { @map1.add_mapping_as_map(marker_without_class, '5') }
      assert_raise(RuntimeError) { @map1.contains_marker?(marker_without_class) }
      
      map_without_class = 'map1'
      assert_raise(RuntimeError) { @marker1.add_mapping_as_marker(map_without_class, '5') }
      assert_raise(RuntimeError) { @marker1.mapped_to?(map_without_class) }
      assert_raise(RuntimeError) { @marker1.positions_on(map_without_class) }
      assert_raise(RuntimeError) { @marker1.mappings_on(map_without_class) }
      
      @map1.add_mapping_as_map(@marker1, '5')
      mapping1 = @marker1.mappings_on(@map1)[0]
      assert_raise(RuntimeError) { mapping1 > 'some_mapping' }
    end
  end
	
  class CloneToActLikeMap
    include Bio::Map::ActsLikeMap
    def initialize
      @mappings_as_map = Array.new
    end
    attr_accessor :mappings_as_map
  end
	
  class TestActsLikeMap < Test::Unit::TestCase
    def setup
      @clone = CloneToActLikeMap.new
    end
    def test_mixin
      assert_instance_of(CloneToActLikeMap, @clone)
      assert_respond_to(@clone, 'contains_marker?')
      assert_respond_to(@clone, 'add_mapping_as_map')
      assert_equal(0, @clone.mappings_as_map.length)
    end
  end

  class CloneToActLikeMarker
    include Bio::Map::ActsLikeMarker
    def initialize
      @mappings_as_marker = Array.new
    end
    attr_accessor :mappings_as_marker
  end

  class TestActsLikeMarker < Test::Unit::TestCase
    def setup
      @clone = CloneToActLikeMarker.new
    end
    
    def test_mixin
      assert_instance_of(CloneToActLikeMarker, @clone)
      assert_respond_to(@clone, 'mapped_to?')
      assert_respond_to(@clone, 'add_mapping_as_marker')
    end
  end

  class CloneToActLikeMapAndMarker
    include Bio::Map::ActsLikeMap
    include Bio::Map::ActsLikeMarker
    def initialize
      @mappings_as_map = Array.new
      @mappings_as_marker = Array.new
    end
    attr_accessor :mappings_as_map, :mappings_as_marker
  end

  class TestActsLikeMapAndMarker < Test::Unit::TestCase
    def setup
      @clone_a = CloneToActLikeMapAndMarker.new
      @clone_b = CloneToActLikeMapAndMarker.new
      @clone_a.add_mapping_as_map(@clone_b, nil)
    end
    
    def test_mixin
      assert_instance_of(CloneToActLikeMapAndMarker, @clone_a)
      assert_respond_to(@clone_a, 'contains_marker?')
      assert_respond_to(@clone_a, 'add_mapping_as_map')
      assert_respond_to(@clone_a, 'mapped_to?')
      assert_respond_to(@clone_a, 'add_mapping_as_marker')
      
      assert_equal(1, @clone_a.mappings_as_map.length)
      assert_equal(0, @clone_a.mappings_as_marker.length)
      assert_equal(0, @clone_b.mappings_as_map.length)
      assert_equal(1, @clone_b.mappings_as_marker.length)
    end
  end
end
