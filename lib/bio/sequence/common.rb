#
# = bio/sequence/common.rb - common methods for biological sequence
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>,
#               Ryan Raaum <ryan@raaum.org>
# License::     The Ruby License
#

module Bio

  autoload :Locations, 'bio/location' unless const_defined?(:Locations)

  require 'bio/sequence' unless const_defined?(:Sequence)

class Sequence

# = DESCRIPTION
# Bio::Sequence::Common is a 
# Mixin[http://www.rubycentral.com/book/tut_modules.html]
# implementing methods common to
# Bio::Sequence::AA and Bio::Sequence::NA.  All of these methods
# are available to either Amino Acid or Nucleic Acid sequences, and
# by encapsulation are also available to Bio::Sequence objects.
#
# = USAGE
#
#   # Create a sequence
#   dna = Bio::Sequence.auto('atgcatgcatgc')
#
#   # Splice out a subsequence using a Genbank-style location string
#   puts dna.splice('complement(1..4)')
#
#   # What is the base composition?
#   puts dna.composition
#
#   # Create a random sequence with the composition of a current sequence
#   puts dna.randomize
module Common
  
  # Return sequence as 
  # String[http://corelib.rubyonrails.org/classes/String.html].
  # The original sequence is unchanged.
  #
  #   seq = Bio::Sequence::NA.new('atgc')
  #   puts s.to_s                             #=> 'atgc'
  #   puts s.to_s.class                       #=> String
  #   puts s                                  #=> 'atgc'
  #   puts s.class                            #=> Bio::Sequence::NA
  # ---
  # *Returns*:: String object
  def to_s
    String.new(self)
  end
  alias to_str to_s

  # Create a new sequence based on the current sequence.
  # The original sequence is unchanged.
  # 
  #   s = Bio::Sequence::NA.new('atgc')
  #   s2 = s.seq
  #   puts s2                                 #=> 'atgc'
  # ---
  # *Returns*:: new Bio::Sequence::NA/AA object
  def seq
    self.class.new(self)
  end
  
  # Normalize the current sequence, removing all whitespace and 
  # transforming all positions to uppercase if the sequence is AA or
  # transforming all positions to lowercase if the sequence is NA.
  # The original sequence is modified.
  #
  #   s = Bio::Sequence::NA.new('atgc')
  #   s.normalize!
  # ---
  # *Returns*:: current Bio::Sequence::NA/AA object (modified)
  def normalize!
    initialize(self)
    self
  end
  alias seq! normalize!

  # Add new data to the end of the current sequence.
  # The original sequence is modified.
  #
  #   s = Bio::Sequence::NA.new('atgc')
  #   s << 'atgc'
  #   puts s                                  #=> "atgcatgc"
  #   s << s
  #   puts s                                  #=> "atgcatgcatgcatgc"
  # ---
  # *Returns*:: current Bio::Sequence::NA/AA object (modified)
  def concat(*arg)
    super(self.class.new(*arg))
  end

  def <<(*arg)
    concat(*arg)
  end

  # Create a new sequence by adding to an existing sequence.
  # The existing sequence is not modified.
  #
  #   s = Bio::Sequence::NA.new('atgc')
  #   s2 = s + 'atgc'
  #   puts s2                                 #=> "atgcatgc"
  #   puts s                                  #=> "atgc"
  #
  # The new sequence is of the same class as the existing sequence if 
  # the new data was added to an existing sequence,
  #
  #   puts s2.class == s.class                #=> true
  #
  # but if an existing sequence is added to a String, the result is a String
  #
  #   s3 = 'atgc' + s
  #   puts s3.class                           #=> String
  # ---
  # *Returns*:: new Bio::Sequence::NA/AA *or* String object
  def +(*arg)
    self.class.new(super(*arg))
  end

  # Returns a new sequence containing the subsequence identified by the 
  # start and end numbers given as parameters.  *Important:* Biological 
  # sequence numbering conventions (one-based) rather than ruby's 
  # (zero-based) numbering conventions are used.  
  #
  #   s = Bio::Sequence::NA.new('atggaatga')
  #   puts s.subseq(1,3)                      #=> "atg"
  #
  # Start defaults to 1 and end defaults to the entire existing string, so
  # subseq called without any parameters simply returns a new sequence 
  # identical to the existing sequence.
  #
  #   puts s.subseq                           #=> "atggaatga"
  # ---
  # *Arguments*:
  # * (optional) _s_(start): Integer (default 1)
  # * (optional) _e_(end): Integer (default current sequence length)
  # *Returns*:: new Bio::Sequence::NA/AA object
  def subseq(s = 1, e = self.length)
    raise "Error: start/end position must be a positive integer" unless s > 0 and e > 0
    s -= 1
    e -= 1
    self[s..e]
  end

  # This method steps through a sequences in steps of 'step_size' by 
  # subsequences of 'window_size'. Typically used with a block.
  # Any remaining sequence at the terminal end will be returned.
  #
  # Prints average GC% on each 100bp
  #
  #   s.window_search(100) do |subseq|
  #     puts subseq.gc
  #   end
  #   
  # Prints every translated peptide (length 5aa) in the same frame
  #
  #   s.window_search(15, 3) do |subseq|
  #     puts subseq.translate
  #   end
  #
  # Split genome sequence by 10000bp with 1000bp overlap in fasta format
  #
  #   i = 1
  #   remainder = s.window_search(10000, 9000) do |subseq|
  #     puts subseq.to_fasta("segment #{i}", 60)
  #     i += 1
  #   end
  #   puts remainder.to_fasta("segment #{i}", 60)
  # ---
  # *Arguments*:
  # * (required) _window_size_: Fixnum
  # * (optional) _step_size_: Fixnum (default 1)
  # *Returns*:: new Bio::Sequence::NA/AA object
  def window_search(window_size, step_size = 1)
    last_step = 0
    0.step(self.length - window_size, step_size) do |i| 
      yield self[i, window_size]                        
      last_step = i
    end                          
    return self[last_step + window_size .. -1] 
  end

  # Returns a float total value for the sequence given a hash of
  # base or residue values,
  #
  #   values = {'a' => 0.1, 't' => 0.2, 'g' => 0.3, 'c' => 0.4}
  #   s = Bio::Sequence::NA.new('atgc')
  #   puts s.total(values)                    #=> 1.0
  # ---
  # *Arguments*:
  # * (required) _hash_: Hash object
  # *Returns*:: Float object
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
  #
  #   s = Bio::Sequence::NA.new('atgc')
  #   puts s.composition              #=> {"a"=>1, "c"=>1, "g"=>1, "t"=>1}
  # ---
  # *Returns*:: Hash object
  def composition
    count = Hash.new(0)
    self.scan(/./) do |x|
      count[x] += 1
    end
    return count
  end

  # Returns a randomized sequence. The default is to retain the same 
  # base/residue composition as the original.  If a hash of base/residue 
  # counts is given, the new sequence will be based on that hash 
  # composition.  If a block is given, each new randomly selected 
  # position will be passed into the block.  In all cases, the
  # original sequence is not modified.
  #
  #   s = Bio::Sequence::NA.new('atgc')
  #   puts s.randomize                        #=> "tcag"  (for example)
  #
  #   new_composition = {'a' => 2, 't' => 2}
  #   puts s.randomize(new_composition)       #=> "ttaa"  (for example)
  #
  #   count = 0
  #   s.randomize { |x| count += 1 }
  #   puts count                              #=> 4
  # ---
  # *Arguments*:
  # * (optional) _hash_: Hash object
  # *Returns*:: new Bio::Sequence::NA/AA object
  def randomize(hash = nil)
    if hash
      tmp = ''
      hash.each {|k, v|
        tmp += k * v.to_i
      }
    else
      tmp = self
    end
    seq = self.class.new(tmp)
    # Reference: http://en.wikipedia.org/wiki/Fisher-Yates_shuffle
    seq.length.downto(2) do |n|
      k = rand(n)
      c = seq[n - 1]
      seq[n - 1] = seq[k]
      seq[k] = c
    end
    if block_given? then
      (0...seq.length).each do |i|
        yield seq[i, 1]
      end
      return self.class.new('')
    else
      return seq
    end
  end

  # Return a new sequence extracted from the original using a GenBank style 
  # position string.  See also documentation for the Bio::Location class.
  #
  #   s = Bio::Sequence::NA.new('atgcatgcatgcatgc')
  #   puts s.splice('1..3')                           #=> "atg"
  #   puts s.splice('join(1..3,8..10)')               #=> "atgcat"
  #   puts s.splice('complement(1..3)')               #=> "cat"
  #   puts s.splice('complement(join(1..3,8..10))')   #=> "atgcat"
  #
  # Note that 'complement'ed Genbank position strings will have no 
  # effect on Bio::Sequence::AA objects.
  # ---
  # *Arguments*:
  # * (required) _position_: String *or* Bio::Location object
  # *Returns*:: Bio::Sequence::NA/AA object
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

#--
# Workaround for Ruby 3.0.0 incompatible changes
if ::RUBY_VERSION > "3"

  # Acts almost the same as String#split.
  def split(*arg)
    if block_given?
      super
    else
      ret = super(*arg)
      ret.collect! { |x| self.class.new('').replace(x) }
      ret
    end
  end

  %w( * ljust rjust center ).each do |w|
    module_eval %Q{
      def #{w}(*arg)
        self.class.new('').replace(super)
      end
    }
  end

  %w( chomp chop
      delete delete_prefix delete_suffix
      lstrip rstrip strip
      reverse
      squeeze
      succ next
      tr tr_s
      capitalize upcase downcase swapcase
  ).each do |w|
    module_eval %Q{
      def #{w}(*arg)
        s = self.dup
        s.#{w}!(*arg)
        s
      end
    }
  end

  %w( sub gsub ).each do |w|
    module_eval %Q{
      def #{w}(*arg, &block)
        s = self.dup
        s.#{w}!(*arg, &block)
        s
      end
    }
  end

  #Reference: https://nacl-ltd.github.io/2018/11/08/gsub-wrapper.html
  #(Title: Is it possible to implement gsub wrapper?)
  %w( sub! gsub! ).each do |w|
    module_eval %Q{
      def #{w}(*arg, &block)
        if block_given? then
          super(*arg) do |m|
            b = Thread.current[:_backref]
            Thread.current[:_backref] = ::Regexp.last_match
            block.binding.eval("$~ = Thread.current[:_backref]")
            Thread.current[:_backref] = b
            block.call(self.class.new('').replace(m))
          end
        else
          super
        end
      end
    }
  end

  %w( each_char each_grapheme_cluster each_line ).each do |w|
    module_eval %Q{
      def #{w}
        if block_given?
          super { |c| yield(self.class.new('').replace(c)) }
        else
          enum_for(:#{w})
        end
     end
    }
  end

  %w( slice [] slice! ).each do |w|
    module_eval %Q{
      def #{w}(*arg)
        r = super
        r ? self.class.new('').replace(r) : r
      end
    }
  end

  %w( partition rpartition ).each do |w|
    module_eval %Q{
      def #{w}(sep)
        r = super
        if r.kind_of?(Array)
          r[1] == sep ?
            [ self.class.new('').replace(r[0]),
              r[1],
              self.class.new('').replace(r[2]) ] :
            r.collect { |x| self.class.new('').replace(x) }
        else
          r
        end
      end
    }
  end
#++

end # if ::RUBY_VERSION > "3"

end # Common

end # Sequence

end # Bio
