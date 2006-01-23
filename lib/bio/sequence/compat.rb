# only for backward compatibility, use Bio::Sequence#output(:fasta) instead

module Bio

class Sequence

  def to_s
    String.new(@seq)
  end
  alias to_str to_s

  module Common

  # Output the FASTA format string of the sequence.  The 1st argument is
  # used as the comment string.  If the 2nd option is given, the output
  # sequence will be folded.
  def to_fasta(header = '', width = nil)
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

end # NA

class AA

  def self.randomize(*arg, &block)
    self.new('').randomize(*arg, &block)
  end

end # AA

end # Sequence

end # Bio
