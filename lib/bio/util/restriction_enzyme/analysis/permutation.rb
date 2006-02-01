# = permutation.rb - Permutation class for Ruby
#
# == Author
#
# Florian Frank mailto:flori@ping.de
#
# == License
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License Version 2 as published by the Free
# Software Foundation: www.gnu.org/copyleft/gpl.html
#
# == Download
#
# The latest version of <b>permutation</b> can be found at
#
# * http://rubyforge.org/frs/?group_id=291
#
# The homepage of this library is located at
#
# * http://permutation.rubyforge.org
#
# == Description
#
# This class has a dual purpose: It can be used to create permutations
# of a given size and to do some simple computations with/on
# permutations. The instances of this class don't require much memory
# because they don't include the permutation as a data structure. They
# only save the information necessary to create the permutation if asked
# to do so.
#
# To generate permutations the ranking/unranking method described in [SS97]
# is used. Because of Ruby's Bignum arithmetic it is useful also
# for permutations of very large size.
# 
# == Examples
#
# In this section some examples show what can be done with this class.
#
# Creating all permutations and project them on data:
#
#  perm = Permutation.new(3)
#  # => #<Permutation:0x57dc94 @last=5, @rank=0, @size=3>
#  perm.map { |p| p.value }
#  # => [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]
#  colors = [:r, :g, :b]
#  # => [:r, :g, :b]
#  perm.map { |p| p.project(colors) }
#  # => [[:r, :g, :b], [:r, :b, :g], [:g, :r, :b], [:g, :b, :r], [:b, :r, :g],
#  #    [:b, :g, :r]]
#  string = "abc"# => "abc"
#  perm.map { |p| p.project(string) }
#  # => ["abc", "acb", "bac", "bca", "cab", "cba"]
#
# Or perhaps more convenient to use:
#
#  perm = Permutation.for("abc")
#  perm.map { |p| p.project }
#  # => ["abc", "acb", "bac", "bca", "cab", "cba"]
#
# Finding the successor and predecessor of Permutations or a
# certain Permutation for a given rank:
#
#  perm = Permutation.new(7)
#  # => #<Permutation:0x8453c @rank=0, @size=7, @last=5039>
#  perm.succ!
#  # => #<Permutation:0x8453c @rank=1, @size=7, @last=5039>
#  perm.succ!
#  # => #<Permutation:0x8453c @rank=2, @size=7, @last=5039>
#  perm.succ!
#  # => #<Permutation:0x8453c @rank=3, @size=7, @last=5039>
#  perm.pred!
#  # => #<Permutation:0x8453c @rank=2, @size=7, @last=5039>
#  perm.rank = 3200
#  # => 3200
#  perm
#  # => #<Permutation:0x8453c @rank=3200, @size=7, @last=5039>
#  perm.value
#  # => [4, 2, 5, 1, 3, 0, 6]
#
# Generating random Permutations
#
#  perm = Permutation.new(10)
#  # => #<Permutation:0x59f4c0 @rank=0, @size=10, @last=3628799>
#  perm.random!.value
#  # => [6, 4, 9, 7, 3, 5, 8, 1, 2, 0]
#  perm.random!.value
#  # => [3, 7, 6, 1, 4, 8, 9, 2, 5, 0]
#  perm.random!.value
#  # => [2, 8, 4, 9, 3, 5, 6, 7, 0, 1]
#  perm.random!.project("ABCDEFGHIJ")
#  # => "DFJGAEBCIH"
#  perm.random!.project("ABCDEFGHIJ")
#  # => "BFADEGHJCI"
#
# Performing some mathematical operations on/with Permutations
#
#  p1 = Permutation.from_cycles([[1, 3, 2], [5, 7]], 10)
#  # => #<Permutation:0x593594 @rank=80694, @size=10, @last=3628799>
#  p2 = Permutation.from_value [3, 2, 0, 5, 6, 8, 9, 1, 4, 7]
#  # => #<Permutation:0x5897b0 @rank=1171050, @size=10, @last=3628799>
#  p3 = p1 * p2
#  # => #<Permutation:0x586a88 @rank=769410, @size=10, @last=3628799>
#  p3.value
#  # => [2, 1, 0, 7, 6, 8, 9, 3, 4, 5]
#  p3.cycles
#  # => [[0, 2], [3, 7], [4, 6, 9, 5, 8]]
#  p4 = p1 * -p2
#  # => #<Permutation:0x581a10 @rank=534725, @size=10, @last=3628799>
#  p4.value
#  # => [1, 5, 3, 0, 8, 2, 4, 9, 7, 6]
#  p4.cycles
#  # => [[0, 1, 5, 2, 3], [4, 8, 7, 9, 6]]
#  id = p1 * -p1
#  # => #<Permutation:0x583a7c @rank=0, @size=10, @last=3628799>
#
# == References
#
#  [SS97] The Algorithm Design Manual, Steven S. Skiena, Telos/Springer, 1997.
# 

class Permutation

    include Enumerable
    include Comparable

    # Creates a new Permutation instance of <code>size</code>
    # (and ranked with <code>rank</code>).
    def initialize(size, rank = 0)
        @size, @rank = size, rank
        @last = factorial(size) - 1
    end

    # Creates a new Permutation instance from the Array
    # <code>indices</code>, that should consist of a permutation of Fixnums
    # in the range of <code>0</code> and <code>indices.size - 1</code>. This is
    # for example the result of a call to the Permutation#value method.
    def self.from_value(indices)
        obj = new(indices.size)
        obj.instance_eval do
            self.rank = rank_indices(indices)
        end
        obj
    end

    # Creates a new Permutation instance from the Array of Arrays
    # <code>cycles</code>. This is for example the result of a
    # call to the Permutation#cycles method .
    def self.from_cycles(cycles, max = 0)
        indices = Array.new(max)
        cycles.each do |cycle|
            cycle.empty? and next
            for i in 0...cycle.size
                indices[ cycle[i - 1] ] = cycle[i]
            end
        end
        indices.each_with_index { |r, i| r or indices[i] = i }
        from_value(indices)
    end

  # A permutation instance of size collection.size is created with
  # collection as the default Permutation#project data object. A
  # collection should respond to size, [], and []=. The Permutation
  # instance will default to rank 0 if none is given.
  def self.for(collection, rank = 0)
    perm = new(collection.size, rank)
    perm.instance_variable_set(:@collection, collection)
    perm
  end

    # Returns the size of this permutation, a Fixnum.
    attr_reader :size

    # Returns the size of this permutation, a Fixnum in the range
    # of 0 and Permutation#last.
    attr_reader :rank

    # Returns the rank of the last ranked Permutation of size
    # Permutation#size .
    attr_reader :last

    # Assigns <code>m</code> to the rank attribute of this Permutation
    # instance. That implies that the indices produced by a call to the
    # Permutation#value method of this instance is the permutation ranked with
    # this new <code>rank</code>.
    def rank=(m)
        last = factorial(size) - 1
        while m > last do m -= last end
        while m < 0 do m += last end
        @rank = m
    end

    # Returns the indices in the range of 0    to Permutation#size - 1
    # of this permutation that is ranked with Permutation#rank.
    #
    # <b>Example:</b>
    #  perm = Permutation.new(6, 312)
    #  # => #<Permutation:0x6ae34 @last=719, @rank=312, @size=6>
    #  perm.value            
    #  # => [2, 4, 0, 1, 3, 5]
    def value
        unrank_indices(@rank)
    end

    # Returns the projection of this instance's Permutation#value
    # into the <code>data</code> object that should respond to
    # the #[] method. If this Permutation inbstance was created
    # with Permutation.for the collection used to create
    # it is used as a data object.
    #
    # <b>Example:</b>
    #  perm = Permutation.new(6, 312)
    #  # => #<Permutation:0x6ae34 @last=719, @rank=312, @size=6>
    #  perm.project("abcdef")
    #  # => "ceabdf"
    def project(data = @collection)
        data or raise ArgumentError.new("a collection is required to project")
        raise ArgumentError.new("data size is != #{size}!") if data.size != size
        projection = data.clone
        value.each_with_index { |i, j| projection[j] = data[i] }
        projection
    end

    # Switches this instances to the next ranked Permutation.
    # If this was the Permutation#last permutation it wraps around
    # the first (<code>rank == 0</code>) permutation.
    def next!
        @rank += 1
        last = factorial(size) - 1
        @rank = 0 if @rank > last
        self
    end

    alias succ! next!

    # Returns the next ranked Permutation instance.
    # If this instance is the Permutation#last permutation it returns the first
    # (<code>rank == 0</code>) permutation.
    def next
        clone.next!
    end

    alias succ next

    # Switches this instances to the previously ranked Permutation.
    # If this was the first permutation it returns the last (<code>rank ==
    # Permutation#last</code>) permutation.
    def pred!
        @rank -= 1
        last = factorial(size) - 1
        @rank = last if @rank < 0
        self
    end

    # Returns the previously ranked Permutation. If this was the first
    # permutation it returns the last (<code>rank == Permutation#last</code>)
    # permutation.
    def pred
        clone.pred!
    end

    # Switches this Permutation instance to random permutation
    # of size Permutation#size.
    def random!
        new_rank = rand(last).to_i
        self.rank = new_rank
        self
    end

    # Returns a random Permutation instance # of size Permutation#size.
    def random
        clone.random!
    end

    # Iterates over all permutations of size Permutation#size starting with the
    # first (<code>rank == 0</code>) ranked permutation and ending with the
    # last (<code>rank == Permutation#last</code>) ranked permutation while
    # yielding to a freshly created Permutation instance for every iteration
    # step.
    #
    # The mixed in methods from the Enumerable module rely on this method.
    def each # :yields: perm
        0.upto(last) do |r|
            klon = clone
            klon.rank = r
            yield klon
        end
    end

    # Does something similar to Permutation#each. It doesn't create new
    # instances (less overhead) for every iteration step, but yields to a
    # modified self instead. This is useful if one only wants to call a
    # method on the yielded value and work with the result of this call. It's
    # not a good idea to put the yielded values in a data structure because the
    # will all reference the same (this!) instance. If you want to do this
    # use Permutation#each.
    def each!
        old_rank = rank
        0.upto(last) do |r|
            self.rank = r
            yield self
        end
        self.rank = old_rank
    end

    # Compares to Permutation instances according to their Permutation#size
    # and the Permutation#rank.
    #
    # The mixed in methods from the Comparable module rely on this method.
    def <=>(other)
        size <=> other.size.zero? || rank <=> other.rank
    end

    # Returns true if this Permutation instance and the other have the same
    # value, that is both Permutation instances have the same Permutation#size
    # and the same Permutation#rank.
    def eql?(other)
        self.class == other.class && size == other.size && rank == other.rank
    end

    alias == eql?

    # Computes a unique hash value for this Permutation instance.
    def hash
        size.hash ^ rank.hash
    end

    # Switchtes this Permutation instance to the inverted permutation.
    # (See Permutation#compose for an example.)
    def invert!
        indices = unrank_indices(rank)
        inverted = Array.new(size)
        for i in 0...size
            inverted[indices[i]] = i
        end
        self.rank = rank_indices(inverted)
        self
    end

    # Returns the inverted Permutation of this Permutation instance.
    # (See Permutation#compose for an example.)
    def invert
        clone.invert!
    end

    alias -@ invert

    # Compose this Permutation instance and the other to
    # a new Permutation. Note that a permutation
    # composed with it's inverted permutation yields
    # the identity permutation, the permutation with rank 0.
    #
    # <b>Example:</b>
    #  p1 = Permutation.new(5, 42)
    #  # => #<Permutation:0x75370 @last=119, @rank=42, @size=5>
    #  p2 = p1.invert
    #  # => #<Permutation:0x653d0 @last=119, @rank=51, @size=5>
    #  p1.compose(p2)
    #  => #<Permutation:0x639a4 @last=119, @rank=0, @size=5>
    # Or a little nicer to look at:
    #  p1 * -p1
    #  # => #<Permutation:0x62004 @last=119, @rank=0, @size=5>
    def compose(other)
        size == other.size or raise ArgumentError.new(
            "permutations of unequal sizes cannot be composed!")
        indices = self.value
        composed = other.value.map { |i| indices[i] }
        klon = clone
        klon.rank = rank_indices(composed)
        klon
    end

    alias * compose

    # Returns the cycles representation of this Permutation instance.
    # The return value of this method can be used to create a
    # new Permutation instance with the Permutation.from_cycles method.
    #
    # <b>Example:</b>
    #  perm = Permutation.new(7, 23)
    #  # => #<Permutation:0x58541c @last=5039, @rank=23, @size=7>
    #  perm.cycles
    #  # => [[3, 6], [4, 5]]
    def cycles
        perm = value
        result = [[]]
        seen = {}
        current = nil
        until seen == perm.size
            current or current = perm.find { |x| !seen[x] }
            break unless current
            if seen[current]
                current = nil
                result << []
            else
                seen[current] = true
                result[-1] << current
                current = perm[current]
            end
        end
        result.pop
        result.select { |c| c.size > 1 }.map do |c|
            min_index = c.index(c.min)
            c[min_index..-1] + c[0...min_index]
        end
    end

    # Returns the signum of this Permutation instance.
    # It's -1 if this permutation is odd and 1 if it's
    # an even permutation.
    #
    # A permutation is odd if it can be represented by an odd number of
    # transpositions (cycles of length 2), or even if it can be represented of
    # an even number of transpositions.
    def signum
        s = 1
        cycles.each do |c|
            c.size % 2 == 0 and s *= -1
        end
        s
    end

    alias sgn signum

    # Returns true if this permutation is even, false otherwise.
    def even?
        signum == 1
    end

    # Returns true if this permutation is odd, false otherwise.
    def odd?
        signum == -1
    end

    private

    @@factorial_cache = {}

    def factorial(n)
        f = @@factorial_cache[n] and return f
        f = 1
        for i in 2..n do f *= i end
        @@factorial_cache[n] = f
    end

    def rank_indices(p)
        result = 0
        for i in 0...size
            result += p[i] * factorial(size - i - 1)
            for j in (i + 1)...size
                p[j] -= 1 if p[j] > p[i] 
            end
        end
        result
    end

    def unrank_indices(m)
        result = Array.new(size, 0)
        for i in 0...size
            f = factorial(i)
            x = m % (f * (i + 1))
            m -= x
            x /= f
            result[size - i - 1] = x
            x -= 1
            for j in (size - i)...size
                result[j] += 1 if result[j] > x
            end
        end
        result
    end

end
