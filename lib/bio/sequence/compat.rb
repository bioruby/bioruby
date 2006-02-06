#
# = bio/sequence/compat.rb - methods for backward compatibility
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: compat.rb,v 1.2 2006/02/06 14:18:03 k Exp $
#


module Bio

class Sequence

  autoload :Common, 'bio/sequence/common'
  autoload :NA,     'bio/sequence/na'
  autoload :AA,     'bio/sequence/aa'

  def to_s
    String.new(@seq)
  end
  alias to_str to_s


module Common

  # Output the FASTA format string of the sequence.  The 1st argument is
  # used as the comment string.  If the 2nd option is given, the output
  # sequence will be folded.
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

  def self.randomize(*arg, &block)
    self.new('').randomize(*arg, &block)
  end

  def pikachu
    self.dna.tr("atgc", "pika") # joke, of course :-)
  end

end # NA


class AA

  def self.randomize(*arg, &block)
    self.new('').randomize(*arg, &block)
  end

end # AA


end # Sequence

end # Bio
