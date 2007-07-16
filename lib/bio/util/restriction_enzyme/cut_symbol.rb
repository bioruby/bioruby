#
# bio/util/restriction_enzyme/cut_symbol.rb - Defines the symbol used to mark a cut in an enzyme sequence
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: cut_symbol.rb,v 1.6 2007/07/16 19:28:48 k Exp $
#

module Bio
class RestrictionEnzyme

# = Usage
#
#   #require 'bio/util/restriction_enzyme/cut_symbol'
#   require 'cut_symbol'
#   include Bio::RestrictionEnzyme::CutSymbol
#   
#   cut_symbol                            # => "^"
#   set_cut_symbol('|')                   # => "|"
#   cut_symbol                            # => "|"
#   escaped_cut_symbol                    # => "\\|"
#   re_cut_symbol                         # => /\|/
#   set_cut_symbol('^')                   # => "^"
#   "abc^de" =~ re_cut_symbol             # => 3
#   "abc^de" =~ re_cut_symbol_adjacent    # => nil
#   "abc^^de" =~ re_cut_symbol_adjacent   # => 3
#   "a^bc^^de" =~ re_cut_symbol_adjacent  # => 4
#   "a^bc^de" =~ re_cut_symbol_adjacent   # => nil
#
module CutSymbol

  # Set the token to be used as the cut symbol in a restriction enzyme sequece
  #
  # Starts as +^+ character
  #
  # ---
  # *Arguments*
  # * +glyph+: The single character to be used as the cut symbol in an enzyme sequence
  # *Returns*:: +glyph+
  def set_cut_symbol(glyph)
    CutSymbol__.cut_symbol = glyph
  end

  # Get the token that's used as the cut symbol in a restriction enzyme sequece
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +glyph+
  def cut_symbol; CutSymbol__.cut_symbol; end

  # Get the token that's used as the cut symbol in a restriction enzyme sequece with
  # a back-slash preceding it.
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +\glyph+
  def escaped_cut_symbol; CutSymbol__.escaped_cut_symbol; end

  # Used to check if multiple cut symbols are next to each other.
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +RegExp+
  def re_cut_symbol_adjacent
    %r"#{escaped_cut_symbol}{2}"
  end

  # A Regexp of the cut_symbol.
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +RegExp+
  def re_cut_symbol
    %r"#{escaped_cut_symbol}"
  end

  #########
  #protected  # NOTE this is a Module, can't hide CutSymbol__
  #########
  
  require 'singleton'
  
  # Class to keep state
  class CutSymbol__
    include Singleton

    @cut_symbol = '^'
    
    def self.cut_symbol; @cut_symbol; end
    
    def self.cut_symbol=(glyph);
      raise ArgumentError if glyph.size != 1
      @cut_symbol = glyph
    end
    
    def self.escaped_cut_symbol; "\\" + self.cut_symbol; end
  end
  
end # CutSymbol
end # RestrictionEnzyme
end # Bio
