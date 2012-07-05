#
# bio/util/restriction_enzyme/sorted_num_array.rb - Internal data storage for Bio::RestrictionEnzyme::Range::SequenceRange
#
# Copyright::   Copyright (C) 2011
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#

module Bio

require 'bio/util/restriction_enzyme' unless const_defined?(:RestrictionEnzyme)

class RestrictionEnzyme

  # a class to store sorted numerics.
  #
  # Bio::RestrictionEnzyme internal use only.
  # Please do not create the instance outside Bio::RestrictionEnzyme.
  class SortedNumArray

    # Same usage as Array.[]
    def self.[](*args)
      a = self.new
      args.each do |elem|
        a.push elem
      end
      a
    end

    # Creates a new object
    def initialize
      @hash = {}
      #clear_cache
    end

    # initialize copy
    def initialize_copy(other)
      super(other)
      @hash = @hash.dup
    end

    # sets internal hash object
    def internal_data_hash=(h)
      #clear_cache
      @hash = h
      self
    end
    protected :internal_data_hash=

    # gets internal hash object
    def internal_data_hash
      @hash
    end
    protected :internal_data_hash

    #---
    ## clear the internal cache
    #def clear_cache
    #  @sorted_keys = nil
    #end
    #protected :clear_cache
    #+++

    # sorted keys
    def sorted_keys
      #@sorted_keys ||= @hash.keys.sort
      #@sorted_keys
      @hash.keys.sort
    end
    private :sorted_keys

    # adds a new element
    def push_element(n)
      #return if @hash.has_key?(n) #already existed; do nothing
      @hash.store(n, true)
      #if @sorted_keys then
      #  if thelast = @sorted_keys[-1] and n > thelast then
      #    @sorted_keys.push n
      #  else
      #    clear_cache
      #  end
      #end
      nil
    end
    private :push_element

    # adds a new element in the beginning of the array 
    def unshift_element(n)
      #return if @hash.has_key?(n) #already existed; do nothing
      @hash.store(n, true)
      #if @sorted_keys then
      #  if thefirst = @sorted_keys[0] and n < thefirst then
      #    @sorted_keys.unshift n
      #  else
      #    clear_cache
      #  end
      #end
      nil
    end
    private :unshift_element

    # Same usage as Array#[]
    def [](*arg)
      #$stderr.puts "SortedNumArray#[]"
      sorted_keys[*arg]
    end

    # Not implemented
    def []=(*arg)
      raise NotImplementedError, 'SortedNumArray#[]= is not implemented.'
    end

    # Same usage as Array#each
    def each(&block)
      sorted_keys.each(&block)
    end

    # Same usage as Array#reverse_each
    def reverse_each(&block)
      sorted_keys.reverse_each(&block)
    end

    # Same usage as Array#+, but accepts only the same classes instance.
    def +(other)
      unless other.is_a?(self.class) then
        raise TypeError, 'unsupported data type'
      end
      new_hash = @hash.merge(other.internal_data_hash)
      result = self.class.new
      result.internal_data_hash = new_hash
      result
    end

    # Same usage as Array#==
    def ==(other)
      if r = super(other) then
        r
      elsif other.is_a?(self.class) then
        other.internal_data_hash == @hash
      else
        false
      end
    end

    # Same usage as Array#concat
    def concat(ary)
      ary.each { |elem| push_element(elem) }
      self
    end

    # Same usage as Array#push
    def push(*args)
      args.each do |elem|
        push_element(elem)
      end
      self
    end

    # Same usage as Array#unshift
    def unshift(*arg)
      arg.reverse_each do |elem|
        unshift_element(elem)
      end
      self
    end

    # Same usage as Array#<<
    def <<(elem)
      push_element(elem)
      self
    end

    # Same usage as Array#include?
    def include?(elem)
      @hash.has_key?(elem)
    end

    # Same usage as Array#first
    def first
      sorted_keys.first
    end

    # Same usage as Array#last
    def last
      sorted_keys.last
    end

    # Same usage as Array#size
    def size
      @hash.size
    end
    alias length size

    # Same usage as Array#delete
    def delete(elem)
      #clear_cache
      @hash.delete(elem) ? elem : nil
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

    # Converts to an array
    def to_a
      #sorted_keys.dup
      sorted_keys
    end
  end #class SortedNumArray

end #class RestrictionEnzyme
end #module Bio


