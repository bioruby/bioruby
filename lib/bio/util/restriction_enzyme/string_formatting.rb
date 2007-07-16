#
# bio/util/restriction_enzyme/string_formatting.rb - Useful functions for string manipulation
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: string_formatting.rb,v 1.6 2007/07/16 19:28:48 k Exp $
#

require 'bio/util/restriction_enzyme'

module Bio
class RestrictionEnzyme

module StringFormatting
  include CutSymbol
  extend CutSymbol

  # Return the sequence with spacing for alignment.  Does not add whitespace
  # around cut symbols.
  #
  # Example:
  #   pattern = 'n^ng^arraxt^n'
  #   add_spacing( pattern )      # => "n^n g^a r r a x t^n"
  #
  # ---
  # *Arguments*
  # * +seq+: sequence with cut symbols
  # * +cs+: (_optional_) Cut symbol along the string.  The reason this is
  #   definable outside of CutSymbol is that this is a utility function used
  #   to form vertical and horizontal cuts such as:
  #
  #     a|t g c
  #      +---+
  #     t a c|g
  # *Returns*:: +String+ sequence with single character distance between bases
  def add_spacing( seq, cs = cut_symbol )
    str = ''
    flag = false
    seq.each_byte do |c|
      c = c.chr
      if c == cs
        str += c
        flag = false
      elsif flag
        str += ' ' + c
      else
        str += c
        flag = true
      end
    end
    str
  end

  # Remove extraneous nucleic acid wildcards ('n' padding) from the
  # left and right sides
  #
  # ---
  # *Arguments*
  # * +s+: sequence with extraneous 'n' padding
  # *Returns*:: +String+ sequence without 'n' padding on the sides
  def strip_padding( s )
    if s[0].chr == 'n'
      s =~ %r{(n+)(.+)}
      s = $2
    end
    if s[-1].chr == 'n'
      s =~ %r{(.+?)(n+)$}
      s = $1
    end
    s
  end

  # Remove extraneous nucleic acid wildcards ('n' padding) from the
  # left and right sides and remove cut symbols
  #
  # ---
  # *Arguments*
  # * +s+: sequence with extraneous 'n' padding and cut symbols
  # *Returns*:: +String+ sequence without 'n' padding on the sides or cut symbols
  def strip_cuts_and_padding( s )
    strip_padding( s.tr(cut_symbol, '') )
  end

  # Return the 'n' padding on the left side of the strand
  #
  # ---
  # *Arguments*
  # * +s+: sequence with extraneous 'n' padding on the left side of the strand
  # *Returns*:: +String+ the 'n' padding from the left side
  def left_padding( s )
    s =~ %r{^n+}
    ret = $&
    ret ? ret : ''  # Don't pass nil values
  end

  # Return the 'n' padding on the right side of the strand
  #
  # ---
  # *Arguments*
  # * +s+: sequence with extraneous 'n' padding on the right side of the strand
  # *Returns*:: +String+ the 'n' padding from the right side
  def right_padding( s )
    s =~ %r{n+$}
    ret = $&
    ret ? ret : ''  # Don't pass nil values
  end
end # StringFormatting
end # RestrictionEnzyme
end # Bio
