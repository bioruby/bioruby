#
# = bio/sequence/compat.rb - methods for backward compatibility
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>,
#               Ryan Raaum <ryan@raaum.org>
# License::     The Ruby License
#
# $Id: compat.rb,v 1.4 2007/04/05 23:35:41 trevor Exp $
#


module Bio

class Sequence

  autoload :Common, 'bio/sequence/common'
  autoload :NA,     'bio/sequence/na'
  autoload :AA,     'bio/sequence/aa'

  # Return sequence as 
  # String[http://corelib.rubyonrails.org/classes/String.html].
  # The original sequence is unchanged.
  #
  #   seq = Bio::Sequence.new('atgc')
  #   puts s.to_s                             #=> 'atgc'
  #   puts s.to_s.class                       #=> String
  #   puts s                                  #=> 'atgc'
  #   puts s.class                            #=> Bio::Sequence
  # ---
  # *Returns*:: String object
  def to_s
    String.new(@seq)
  end
  alias to_str to_s


module Common

  # *DEPRECIATED* Do not use! Use Bio::Sequence#output instead. 
  # 
  # Output the FASTA format string of the sequence.  The 1st argument is
  # used as the comment string.  If the 2nd option is given, the output
  # sequence will be folded.
  # ---
  # *Arguments*:
  # * (optional) _header_: String object
  # * (optional) _width_: Fixnum object (default nil)
  # *Returns*:: String
  def to_fasta(header = '', width = nil)
    warn "Bio::Sequence#to_fasta is obsolete. Use Bio::Sequence#output(:fasta) instead" if $DEBUG
    ">#{header}\n" +
    if width
      self.to_s.gsub(Regexp.new(".{1,#{width}}"), "\\0\n")
    else
      self.to_s + "\n"
    end
  end

end # Common


class NA

  # Generate a new random sequence with the given frequency of bases.
  # The sequence length is determined by their cumulative sum.
  # (See also Bio::Sequence::Common#randomize which creates a new
  # randomized sequence object using the base composition of an existing 
  # sequence instance).
  #
  #   counts = {'a'=>1,'c'=>2,'g'=>3,'t'=>4}
  #   puts Bio::Sequence::NA.randomize(counts)  #=> "ggcttgttac" (for example)
  #
  # You may also feed the output of randomize into a block
  #
  #   actual_counts = {'a'=>0, 'c'=>0, 'g'=>0, 't'=>0}
  #   Bio::Sequence::NA.randomize(counts) {|x| actual_counts[x] += 1}
  #   actual_counts                     #=> {"a"=>1, "c"=>2, "g"=>3, "t"=>4}
  # ---
  # *Arguments*:
  # * (optional) _hash_: Hash object
  # *Returns*:: Bio::Sequence::NA object
  def self.randomize(*arg, &block)
    self.new('').randomize(*arg, &block)
  end

  def pikachu #:nodoc:
    self.dna.tr("atgc", "pika") # joke, of course :-)
  end

end # NA


class AA

  # Generate a new random sequence with the given frequency of bases.
  # The sequence length is determined by their cumulative sum.
  # (See also Bio::Sequence::Common#randomize which creates a new
  # randomized sequence object using the base composition of an existing 
  # sequence instance).
  #
  #   counts = {'R'=>1,'L'=>2,'E'=>3,'A'=>4}
  #   puts Bio::Sequence::AA.randomize(counts)  #=> "AAEAELALRE" (for example)
  #
  # You may also feed the output of randomize into a block
  #
  #   actual_counts = {'R'=>0,'L'=>0,'E'=>0,'A'=>0}
  #   Bio::Sequence::AA.randomize(counts) {|x| actual_counts[x] += 1}
  #   actual_counts                     #=> {"A"=>4, "L"=>2, "E"=>3, "R"=>1}
  # ---
  # *Arguments*:
  # * (optional) _hash_: Hash object
  # *Returns*:: Bio::Sequence::AA object
  def self.randomize(*arg, &block)
    self.new('').randomize(*arg, &block)
  end

end # AA


end # Sequence

end # Bio
