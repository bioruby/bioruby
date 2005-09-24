#
# test/unit/bio/test_feature.rb - Unit test for Features/Feature classes
#
#   Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
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
#  $Id: test_feature.rb,v 1.1 2005/09/24 14:20:18 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3 , 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/feature'


module Bio

  class TestQualifier < Test::Unit::TestCase
    def setup
      qualifier = 'gene'
      value = 'CDS'
      @obj = Bio::Feature::Qualifier.new(qualifier, value)
    end

    def test_qualifier
      assert_equal(@obj.qualifier, 'gene')
    end

    def test_value
      assert_equal(@obj.value, 'CDS')
    end
  end


  class TestFeature < Test::Unit::TestCase
    def setup
      @qualifier = Bio::Feature::Qualifier.new('organism', 'Arabidopsis thaliana')
      feature = "source"
      position = '1..615'
      qualifiers = [@qualifier]
      @obj = Bio::Feature.new(feature, position, qualifiers)
    end

    def test_new
      assert(Bio::Feature.new)
    end

    def test_feature
      assert_equal(@obj.feature, "source")
    end

    def test_position
      assert_equal(@obj.position, '1..615')
    end

    def test_qualifiers
      assert_equal(@obj.qualifiers, [@qualifier])
    end
    
    def test_locations
      assert_equal(@obj.locations.first.from, 1)
      assert_equal(@obj.locations.first.to, 615)
    end

    def test_append_nil
      assert(@obj.append(nil))
      assert_equal(@obj.qualifiers.size, 1)
    end

    def test_append
      qualifier = Bio::Feature::Qualifier.new('db_xref', 'taxon:3702')
      assert(@obj.append(qualifier))
      assert_equal(@obj.qualifiers.last.qualifier, 'db_xref')
    end

    def test_each
      @obj.each do |qua| 
        assert_equal(qua.value, 'Arabidopsis thaliana')
      end
    end

    def test_assoc
      @obj.append(Bio::Feature::Qualifier.new("organism", "Arabidopsis thaliana"))
      assert_equal(@obj.assoc, {"organism" => "Arabidopsis thaliana"})
    end
  end

  class TestFeatures < Test::Unit::TestCase
    def setup
      @obj = Bio::Features.new([Bio::Feature.new('gene', '1..615', [])])
    end
    
    def test_features
      assert_equal(@obj.features.size, 1)
    end

    def test_append
      assert(@obj.append(Bio::Feature.new('gene', '1..615', [])))
      assert_equal(@obj.features.size, 2)
    end

    def test_each
      @obj.each do |feature| 
        assert_equal(feature.feature, 'gene')
      end
    end

    def test_arg # def [](*arg)
      assert_equal(@obj[0].feature, 'gene')
    end
  end

end
