#
# test/unit/bio/util/restriction_enzyme/test_dense_int_array.rb - Unit test for Bio::RestrictionEnzyme::DenseIntArray
#
# Copyright::   Copyright (C) 2011
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/util/restriction_enzyme'
require 'bio/util/restriction_enzyme/dense_int_array'

module Bio
module TestRestrictionEnzyme

  class TestDenseIntArray < Test::Unit::TestCase

    def setup
      @klass = Bio::RestrictionEnzyme::DenseIntArray
      @obj = @klass[ -1, 11, 12, 13, 14, 15, 50, 60 ]
    end

    def test_self_bracket
      assert_equal([ -1, 11, 12, 13, 14, 15, 50, 60 ], @obj.to_a)
    end

    def test_self_new
      a = @klass.new
      assert_instance_of(Bio::RestrictionEnzyme::DenseIntArray, a)
    end

    def test_dup
      assert_equal(@obj.to_a, @obj.dup.to_a)
      d_obj = @obj.instance_eval { internal_data }
      d_dup = @obj.dup.instance_eval { internal_data }
      assert(d_obj == d_dup)
      assert_not_equal(d_obj.__id__, d_dup.__id__)
    end

    def test_internal_data
      d = @obj.instance_eval { internal_data }
      r = @klass::MutableRange
      expected = [ r.new(-1, -1), r.new(11, 15),
                   r.new(50, 50), r.new(60, 60) ]
      assert_equal(expected, d)
    end

    def test_internal_data_eq
      r = @klass::MutableRange
      d = [ r.new(-2, -2), r.new(50, 50), r.new(65, 70) ]
      @obj.instance_eval { self.internal_data = d }
      assert_equal(70, @obj.last)
      assert_equal([-2, 50, 65, 66, 67, 68, 69, 70], @obj.to_a)
    end

    def test_bracket
      assert_equal(-1, @obj[0])
      assert_equal(13, @obj[3])
      assert_equal(60, @obj[-1])
      assert_equal([-1, 11, 12], @obj[0..2])
      assert_equal([14, 15, 50], @obj[4,3])
    end

    def test_bracket_eq
      assert_raise(NotImplementedError) {
        @obj[3] = 999
      }
    end

    def test_each
      expected_values = [ -1, 11, 12, 13, 14, 15, 50, 60 ]
      @obj.each do |i|
        assert_equal(expected_values.shift, i)
      end
    end

    def test_reverse_each
      expected_values = [ -1, 11, 12, 13, 14, 15, 50, 60 ]
      @obj.reverse_each do |i|
        assert_equal(expected_values.pop, i)
      end
    end

    def test_plus
      obj2 = @klass[ 9, 10, 11, 12, 30 ]
      assert_equal([ -1, 9, 10, 11, 12, 13, 14, 15, 30, 50, 60 ],
                   (@obj + obj2).to_a)
    end

    def test_plus_error
      assert_raise(TypeError) {
        @obj + 2
      }
    end

    def test_eqeq
      obj2 = @klass[ -1, 11, 12, 13, 14, 15, 50, 60 ]
      assert_equal(true, @obj == obj2)
    end

    def test_eqeq_self
      assert_equal(true, @obj == @obj)
    end

    def test_eqeq_false
      obj2 = @klass[ 2, 3, 14, 15 ]
      assert_equal(false, @obj == obj2)
    end

    def test_eqeq_other
      obj2 = 'test'
      assert_equal(false, @obj == obj2)
    end

    def test_concat
      ary = [ 61, 62, -2, 14, 15 ]
      expected = [ -1, 11, 12, 13, 14, 15, 50, 60, 61, 62, -2, 14, 15 ]
      # checks if the method returns self
      assert_equal(@obj, @obj.concat(ary))
      # checks the value
      assert_equal(expected, @obj.to_a)
    end

    def test_push
      expected = [ -1, 11, 12, 13, 14, 15, 50, 60, 61, 62, -2, 14, 15 ]
      # checks if the method returns self
      assert_equal(@obj, @obj.push(61, 62, -2, 14, 15))
      # checks the value
      assert_equal(expected, @obj.to_a)
    end

    def test_unshift
      assert_raise(NotImplementedError) { @obj.unshift(-5, -2) }
    end

    def test_ltlt
      expected = [ -1, 11, 12, 13, 14, 15, 50, 60, 61 ]
      # checks if the method returns self
      assert_equal(@obj, @obj << 61)
      # checks the value
      assert_equal(expected, @obj.to_a)
    end

    def test_ltlt_larger
      expected = [ -1, 11, 12, 13, 14, 15, 50, 60, 70 ]
      # checks if the method returns self
      assert_equal(@obj, @obj << 70)
      # checks the value
      assert_equal(expected, @obj.to_a)
    end

    def test_ltlt_middle
      expected = [ -1, 11, 12, 13, 14, 15, 50, 60, 30 ]
      # checks if the method returns self
      assert_equal(@obj, @obj << 30)
      # checks the value
      assert_equal(expected, @obj.to_a)
    end

    def test_include?
      assert_equal(true, @obj.include?(13))
      assert_equal(false, @obj.include?(999))
    end

    def test_size
      assert_equal(8, @obj.size)
    end

    def test_length
      assert_equal(8, @obj.length)
    end

    def test_delete
      assert_raise(NotImplementedError) { @obj.delete(11) }
    end

    def test_sort!
      assert_equal(@obj, @obj.sort!)
    end

    def test_uniq!
      assert_equal(@obj, @obj.uniq!)
    end

    def test_to_a
      expected = [ -1, 11, 12, 13, 14, 15, 50, 60 ]
      assert_equal(expected, @obj.to_a)
    end

  end #class TestDenseIntArray

end #module TestRestrictionEnzyme
end #module Bio


