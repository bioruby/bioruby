#
# = bio/sequence/common.rb - common methods for biological sequence
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: common.rb,v 1.2 2006/02/06 14:16:17 k Exp $
#

module Bio

  autoload :Locations, 'bio/location'

class Sequence

# This module provides common methods for biological sequence classes
# which must inherit String.
module Common

  def to_s
    String.new(self)
  end
  alias to_str to_s

  # Force self to re-initialize for clean up (remove white spaces,
  # case unification).
  def seq
    self.class.new(self)
  end

  # Similar to the 'seq' method, but changes the self object destructively.
  def normalize!
    initialize(self)
    self
  end
  alias seq! normalize!

  def <<(*arg)
    super(self.class.new(*arg))
  end
  alias concat <<

  def +(*arg)
    self.class.new(super(*arg))
  end

  # Returns the subsequence of the self string.
  def subseq(s = 1, e = self.length)
    raise "Error: start/end position must be a positive integer" unless s > 0 and e > 0
    s -= 1
    e -= 1
    self[s..e]
  end

  # This method iterates on sub string with specified length 'window_size'.
  # By specifing 'step_size', codon sized shifting or spliting genome
  # sequence with ovelapping each end can easily be yielded.
  #
  # The remainder sequence at the terminal end will be returned.
  #
  # Example:
  #   # prints average GC% on each 100bp
  #   seq.window_search(100) do |subseq|
  #     puts subseq.gc
  #   end
  #   # prints every translated peptide (length 5aa) in the same frame
  #   seq.window_search(15, 3) do |subseq|
  #     puts subseq.translate
  #   end
  #   # split genome sequence by 10000bp with 1000bp overlap in fasta format
  #   i = 1
  #   remainder = seq.window_search(10000, 9000) do |subseq|
  #     puts subseq.to_fasta("segment #{i}", 60)
  #     i += 1
  #   end
  #   puts remainder.to_fasta("segment #{i}", 60)
  #
  def window_search(window_size, step_size = 1)
    i = 0
    0.step(self.length - window_size, step_size) do |i| 
      yield self[i, window_size]                        
    end                          
    return self[i + window_size .. -1] 
  end

  # This method receive a hash of residues/bases to the particular values,
  # and sum up the value along with the self sequence.  Especially useful
  # to use with the window_search method and amino acid indices etc.
  def total(hash)
    hash.default = 0.0 unless hash.default
    sum = 0.0
    self.each_byte do |x|
      begin
        sum += hash[x.chr]
      end
    end
    return sum
  end

  # Returns a hash of the occurrence counts for each residue or base.
  def composition
    count = Hash.new(0)
    self.scan(/./) do |x|
      count[x] += 1
    end
    return count
  end

  # Returns a randomized sequence keeping its composition by default.
  # The argument is required when generating a random sequence from the empty
  # sequence (used by the class methods NA.randomize, AA.randomize).
  # If the block is given, yields for each random residue/base.
  def randomize(hash = nil)
    length = self.length
    if hash
      count = hash.clone
      count.each_value {|x| length += x}
    else
      count = self.composition
    end

    seq = ''
    tmp = {}
    length.times do 
      count.each do |k, v|
        tmp[k] = v * rand
      end
      max = tmp.max {|a, b| a[1] <=> b[1]}
      count[max.first] -= 1

      if block_given?
        yield max.first
      else
        seq += max.first
      end
    end
    return self.class.new(seq)
  end

  # Generate a new random sequence with the given frequency of bases
  # or residues.  The sequence length is determined by the sum of each
  # base/residue occurences.
  def self.randomize(*arg, &block)
    self.new('').randomize(*arg, &block)
  end

  # Receive a GenBank style position string and convert it to the Locations
  # objects to splice the sequence itself.  See also: bio/location.rb
  def splice(position)
    unless position.is_a?(Locations) then
      position = Locations.new(position)
    end
    s = ''
    position.each do |location|
      if location.sequence
        s << location.sequence
      else
        exon = self.subseq(location.from, location.to)
        begin
          exon.complement! if location.strand < 0
        rescue NameError
        end
        s << exon
      end
    end
    return self.class.new(s)
  end
  alias splicing splice

end # Common

end # Sequence

end # Bio
