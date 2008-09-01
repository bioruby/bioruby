#
# test/unit/bio/util/restriction_enzyme/double_stranded/test_cut_locations.rb - Unit test for Bio::RestrictionEnzyme::DoubleStranded::CutLocations
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id:$
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 6, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/util/restriction_enzyme/double_stranded/cut_locations'

module Bio; module TestRestrictionEnzyme #:nodoc:

class TestDoubleStrandedCutLocations < Test::Unit::TestCase #:nodoc:

  def setup
    @t = Bio::RestrictionEnzyme::DoubleStranded::CutLocationPair
    @tt = Bio::RestrictionEnzyme::DoubleStranded::CutLocations


    @obj_1 = @t.new([3,5])
    @obj_2 = @t.new(3, 5)
    @obj_3 = @t.new((3..5))
    @obj_4 = @t.new(3..5)
    @obj_5 = @t.new(3)
    @obj_6 = @t.new(nil,3)
    @obj_7 = @t.new(3,nil)

    @locations = @tt.new(@obj_1, @obj_2, @obj_3, @obj_4, @obj_5, @obj_6, @obj_7)
  end

  def test_contents
    assert_equal([3,5], @locations[0])
    assert_equal([3,nil], @locations[-1])
  end

  def test_primary
    assert_equal([3, 3, 3, 3, 3, nil, 3], @locations.primary)
  end

  def test_complement
    assert_equal([5, 5, 5, 5, nil, 3, nil], @locations.complement)
  end

end

end; end
