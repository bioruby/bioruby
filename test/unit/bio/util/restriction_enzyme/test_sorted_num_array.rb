#
# test/unit/bio/util/restriction_enzyme/test_sorted_num_array.rb - Unit test for Bio::RestrictionEnzyme::SortedNumArray
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
require 'bio/util/restriction_enzyme/sorted_num_array'

module Bio
module TestRestrictionEnzyme

  class TestSortedNumArray < Test::Unit::TestCase

    def setup
      @klass = Bio::RestrictionEnzyme::SortedNumArray
      @obj = @klass[14, 265, 4626, -1, 358, 159, 979, 3238, 3]
    end

    def test_self_bracket
      assert_equal([ -1, 3, 14, 159, 265, 358, 979, 3238, 4626 ],
                   @obj.to_a)
    end

    def test_self_new
      a = @klass.new
      assert_instance_of(Bio::RestrictionEnzyme::SortedNumArray, a)
    end

    def test_dup
      assert_equal(@obj.to_a, @obj.dup.to_a)
      h_obj = @obj.instance_eval { internal_data_hash }
      h_dup = @obj.dup.instance_eval { internal_data_hash }
      assert(h_obj == h_dup)
      assert_not_equal(h_obj.__id__, h_dup.__id__)
    end

    def test_internal_data_hash
      h = @obj.instance_eval { internal_data_hash }
      expected = { -1 => true,
        3 => true, 14 => true, 159 => true, 265 => true,
        358 => true, 979 => true, 3238 => true, 4626 => true }
      assert_equal(expected, h)
    end

    def test_internal_data_hash_eq
      h = { 0 => true, 50 => true, 100 => true }
      @obj.last # creating cache (if exists)
      @obj.instance_eval { self.internal_data_hash = h }
      assert_equal(100, @obj.last)
      assert_equal([0, 50, 100], @obj.to_a)
    end

    #def test_private_clear_cache
    #  assert_nothing_raised {
    #    @obj.instance_eval { clear_cache }
    #  }
    #  @obj.last # creating cache
    #  @obj.instance_eval { clear_cache }
    #  assert_nil(@obj.instance_eval { @sorted_keys })
    #end

    def test_private_sorted_keys
      a = @obj.instance_eval { sorted_keys }
      assert_equal([ -1, 3, 14, 159, 265, 358, 979, 3238, 4626 ], a)
    end

    def test_private_push_element
      assert_equal(false, @obj.include?(50))
      @obj.instance_eval {
        push_element(50)
      }
      assert_equal(true, @obj.include?(50))
    end

    def test_private_push_element_noeffect
      assert_equal(true, @obj.include?(159))
      @obj.instance_eval {
        push_element(159)
      }
      assert_equal(true, @obj.include?(159))
    end

    def test_private_push_element_last
      @obj.last # creating cache (if exists)
      @obj.instance_eval {
        push_element(9999)
      }
      assert_equal(true, @obj.include?(9999))
      assert_equal(9999, @obj.last)
    end

    def test_private_push_element_intermediate
      @obj.last # creating cache (if exists)
      @obj.instance_eval {
        push_element(100)
      }
      assert_equal(true, @obj.include?(100))
      assert_equal(4626, @obj.last)
    end

    def test_private_unshift_element
      assert_equal(false, @obj.include?(50))
      @obj.instance_eval {
        unshift_element(50)
      }
      assert_equal(true, @obj.include?(50))
    end

    def test_private_unshift_element_noeffect
      assert_equal(true, @obj.include?(159))
      @obj.instance_eval {
        unshift_element(159)
      }
      assert_equal(true, @obj.include?(159))
    end

    def test_private_unshift_element_first
      @obj.last # creating cache (if exists)
      @obj.instance_eval {
        unshift_element(-999)
      }
      assert_equal(true, @obj.include?(-999))
      assert_equal(-999, @obj.first)
    end

    def test_private_unshift_element_intermediate
      @obj.last # creating cache (if exists)
      @obj.instance_eval {
        unshift_element(100)
      }
      assert_equal(true, @obj.include?(100))
      assert_equal(-1, @obj.first)
    end

    def test_bracket
      assert_equal(-1, @obj[0])
      assert_equal(159, @obj[3])
      assert_equal(4626, @obj[-1])
      assert_equal([14, 159, 265], @obj[2..4])
      assert_equal([14, 159, 265], @obj[2,3])
    end

    def test_bracket_eq
      assert_raise(NotImplementedError) {
        @obj[3] = 999
      }
    end

    def test_each
      expected_values = [ -1, 3, 14, 159, 265, 358, 979, 3238, 4626 ]
      @obj.each do |i|
        assert_equal(expected_values.shift, i)
      end
    end

    def test_reverse_each
      expected_values = [ -1, 3, 14, 159, 265, 358, 979, 3238, 4626 ]
      @obj.reverse_each do |i|
        assert_equal(expected_values.pop, i)
      end
    end

    def test_plus
      obj2 = @klass[ 2, 3, 14, 15 ]
      assert_equal([ -1, 2, 3, 14, 15, 159, 265, 358, 979, 3238, 4626 ],
                   (@obj + obj2).to_a)
    end

    def test_plus_error
      assert_raise(TypeError) {
        @obj + 2
      }
    end

    def test_eqeq
      obj2 = @klass[ -1, 3, 14, 159, 265, 358, 979, 3238, 4626 ]
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
      ary = [ 9999, -2, 14, 15 ]
      expected = [ -2, -1, 3, 14, 15, 159, 265, 358, 979, 3238, 4626, 9999 ]
      # checks if the method returns self
      assert_equal(@obj, @obj.concat(ary))
      # checks the value
      assert_equal(expected, @obj.to_a)
    end

    def test_push
      expected = [ -2, -1, 3, 14, 15, 159, 265, 358, 979, 3238, 4626, 9999 ]
      # checks if the method returns self
      assert_equal(@obj, @obj.push(15, 14, -2, 9999))
      # checks the value
      assert_equal(expected, @obj.to_a)
    end

    def test_unshift
      expected = [ -2, -1, 3, 14, 15, 159, 265, 358, 979, 3238, 4626, 9999 ]
      # checks if the method returns self
      assert_equal(@obj, @obj.unshift(15, 14, -2, 9999))
      # checks the value
      assert_equal(expected, @obj.to_a)
    end

    def test_ltlt
      expected = [ -1, 3, 14, 15, 159, 265, 358, 979, 3238, 4626 ]
      # checks if the method returns self
      assert_equal(@obj, @obj << 15)
      # checks the value
      assert_equal(expected, @obj.to_a)
    end

    def test_ltlt_noeffect
      expected = [ -1, 3, 14, 159, 265, 358, 979, 3238, 4626 ]
      # checks if the method returns self
      assert_equal(@obj, @obj << 159)
      # checks the value
      assert_equal(expected, @obj.to_a)
    end

    def test_include?
      assert_equal(true, @obj.include?(159))
      assert_equal(false, @obj.include?(999))
    end

    def test_size
      assert_equal(9, @obj.size)
    end

    def test_length
      assert_equal(9, @obj.length)
    end

    def test_delete
      assert_equal(nil, @obj.delete(100))
      assert_equal(159, @obj.delete(159))
    end

    def test_sort!
      assert_equal(@obj, @obj.sort!)
    end

    def test_uniq!
      assert_equal(@obj, @obj.uniq!)
    end

    def test_to_a
      expected = [ -1, 3, 14, 159, 265, 358, 979, 3238, 4626 ]
      assert_equal(expected, @obj.to_a)
    end

  end #class TestSortedNumArray

end #module TestRestrictionEnzyme
end #module Bio


