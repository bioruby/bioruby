#
# bio/util/restriction_enzyme/dense_int_array.rb - Internal data storage for Bio::RestrictionEnzyme::Range::SequenceRange
#
# Copyright::   Copyright (C) 2011
#               Naohisa Goto <ng@bioruby.org>
#               Tomoaki NISHIYAMA
# License::     The Ruby License
#

module Bio

require 'bio/util/restriction_enzyme' unless const_defined?(:RestrictionEnzyme)

class RestrictionEnzyme

  # a class to store integer numbers, containing many contiguous
  # integral numbers.
  #
  # Bio::RestrictionEnzyme internal use only.
  # Please do not create the instance outside Bio::RestrictionEnzyme.
  class DenseIntArray
    MutableRange = Struct.new(:first, :last)

    include Enumerable

    # Same usage as Array.[]
    def self.[](*args)
      a = self.new
      args.each do |elem|
        a.push elem
      end
      a
    end

    # creates a new object
    def initialize
      @data = []
    end

    # initialize copy
    def initialize_copy(other)
      super(other)
      @data = @data.collect { |elem| elem.dup }
    end

    # sets internal data object
    def internal_data=(a)
      #clear_cache
      @data = a
      self
    end
    protected :internal_data=

    # gets internal data object
    def internal_data
      @data
    end
    protected :internal_data

    # Same usage as Array#[]
    def [](*arg)
      #$stderr.puts "SortedIntArray#[]"
      to_a[*arg]
    end

    # Not implemented
    def []=(*arg)
      raise NotImplementedError, 'DenseIntArray#[]= is not implemented.'
    end

    # Same usage as Array#each
    def each
      @data.each do |elem|
        elem.first.upto(elem.last) { |num| yield num }
      end
      self
    end

    # Same usage as Array#reverse_each
    def reverse_each
      @data.reverse_each do |elem|
        elem.last.downto(elem.first) { |num| yield num }
      end
      self
    end

    # Same usage as Array#+, but accepts only the same classes instance.
    def +(other)
      unless other.is_a?(self.class) then
        raise TypeError, 'unsupported data type'
      end
      tmpdata = @data + other.internal_data
      tmpdata.sort! { |a,b| a.first <=> b.first }
      result = self.class.new
      return result if tmpdata.empty?
      newdata = result.internal_data
      newdata.push tmpdata[0].dup
      (1...(tmpdata.size)).each do |i|
        if (x = newdata[-1].last) >= tmpdata[i].first then
          newdata[-1].last = tmpdata[i].last if tmpdata[i].last > x
        else
          newdata.push tmpdata[i].dup
        end
      end
      result
    end

    # Same usage as Array#==
    def ==(other)
      if r = super(other) then
        r
      elsif other.is_a?(self.class) then
        other.internal_data == @data
      else
        false
      end
    end

    # Same usage as Array#concat
    def concat(ary)
      ary.each { |elem| self.<<(elem) }
      self
    end

    # Same usage as Array#push
    def push(*args)
      args.each do |elem|
        self.<<(elem)
      end
      self
    end

    # Same usage as Array#unshift
    def unshift(*arg)
      raise NotImplementedError, 'DenseIntArray#unshift is not implemented.'
    end

    # Same usage as Array#<<
    def <<(elem)
      if !@data.empty? and
          @data[-1].last + 1 == elem then
        @data[-1].last = elem
      else
        @data << MutableRange.new(elem, elem)
      end
      self
    end

    # Same usage as Array#include?
    def include?(elem)
      return false if @data.empty? or elem < self.first or self.last < elem
      @data.any? do |range|
        range.first <= elem && elem <= range.last
      end
    end

    # Same usage as Array#first
    def first
      elem = @data.first
      elem ? elem.first : nil
    end

    # Same usage as Array#last
    def last
      elem = @data.last
      elem ? elem.last : nil
    end

    # Same usage as Array#size
    def size
      sum = 0
      @data.each do |range|
        sum += (range.last - range.first + 1)
      end
      sum
    end
    alias length size

    # Same usage as Array#delete
    def delete(elem)
      raise NotImplementedError, 'DenseIntArray#delete is not implemented.'
    end

    # Does nothing
    def sort!(&block)
      # does nothing
      self
    end

    # Does nothing
    def uniq!
      # does nothing
      self
    end
  end #class DenseIntArray

end #class RestrictionEnzyme
end #module Bio
