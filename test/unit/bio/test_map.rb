#
# = test/unit/bio/test_map.rb - Unit test for Bio::Map
#
# Copyright::   Copyright (C) 2006
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     Ruby's

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
			@map1 = Bio::Map::SimpleMap.new('map1', 'some_type', 'some_unit')
		end

		def test_attributes
			assert_equal("marker1", @marker1.name)
			assert_equal("marker2", @marker2.name)
			assert_equal([], @marker1.mappings)
			assert_equal([], @marker2.mappings)
			assert_equal("map1", @map1.name)
			assert_equal("some_unit", @map1.units)
			assert_equal("some_type", @map1.type)
			assert_equal([], @map1.mappings)
		end
	end

	class TestMapping < Test::Unit::TestCase
		def setup
			@marker1 = Bio::Map::Marker.new('marker1')
			@marker2 = Bio::Map::Marker.new('marker2')
			@map1 = Bio::Map::SimpleMap.new('map1', 'some_type', 'some_unit')
		end

		def test_add_mapping_to_marker
			@map1.add_mapping_to_marker(@marker2, '5')
			assert_equal(1, @map1.mappings.length)
			assert_equal(1, @marker2.mappings.length)
			assert_equal(0, @marker1.mappings.length)
			assert_kind_of(Bio::Location, @map1.mappings[0].location)
			assert_kind_of(Bio::Location, @marker2.mappings[0].location)
		end

    def test_add_mapping_to_map
			@marker1.add_mapping_to_map(@map1, '5')
			assert_equal(1, @map1.mappings.length)
			assert_equal(1, @marker1.mappings.length)
			assert_kind_of(Bio::Location, @map1.mappings[0].location)
			assert_kind_of(Bio::Location, @marker1.mappings[0].location)
    end
	end
	
	class CloneActsLikeMap
		include Bio::Map::ActsLikeMap
	end
	
	class TestActsLikeMap < Test::Unit::TestCase
		def test_mixin
      clone = CloneActsLikeMap.new
			assert_instance_of(CloneActsLikeMap, clone)
			assert_respond_to(clone, 'contains_marker?')
			assert_respond_to(clone, 'add_mapping_to_marker')
		end
	end

	class CloneActsLikeMarker
		include Bio::Map::ActsLikeMarker
	end

	class TestActsLikeMarker < Test::Unit::TestCase
		def test_mixin
			clone = CloneActsLikeMarker.new
			assert_instance_of(CloneActsLikeMarker, clone)
			assert_respond_to(clone, 'mapped_to?')
			assert_respond_to(clone, 'add_mapping_to_map')
		end
	end

	class CloneActsLikeMapAndMarker
		include Bio::Map::ActsLikeMap
		include Bio::Map::ActsLikeMarker
	end

	class TestActsLikeMapAndMarker < Test::Unit::TestCase
		def test_mixin
			clone = CloneActsLikeMapAndMarker.new
			assert_instance_of(CloneActsLikeMapAndMarker, clone)
			assert_respond_to(clone, 'contains_marker?')
			assert_respond_to(clone, 'add_mapping_to_marker')
			assert_respond_to(clone, 'mapped_to?')
			assert_respond_to(clone, 'add_mapping_to_map')
		end
	end

end
