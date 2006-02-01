require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/single_strand/cut_locations_in_enzyme_notation'
require 'bio/util/restriction_enzyme/cut_symbol'
require 'bio/util/restriction_enzyme/string_formatting'
require 'bio/sequence'

class Bio::RestrictionEnzyme

#
# bio/util/restriction_enzyme/single_strand.rb - Single strand of a restriction enzyme sequence
#
# Copyright::  Copyright (C) 2006 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: single_strand.rb,v 1.1 2006/02/01 07:34:11 trevor Exp $
#
#
#--
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#++
#

=begin rdoc
bio/util/restriction_enzyme/single_strand.rb - Single strand of a restriction enzyme sequence

A single strand of restriction enzyme sequence pattern with a 5' to 3' 
orientation.
 
DoubleStranded puts the SingleStrand and SingleStrandComplement together to 
create the sequence pattern with cuts on both strands.
=end
class SingleStrand < Bio::Sequence::NA
  include CutSymbol
  include StringFormatting

  # The cut locations in enzyme notation. Contains a 
  # CutLocationsInEnzymeNotation object.
  attr_reader :cut_locations_in_enzyme_notation

  # The cut locations transformed from enzyme index notation to 0-based 
  # array index notation.  Contains an Array
  attr_reader :cut_locations

  # Orientation of the strand, 5' to 3'
  def orientation; [5,3]; end

  # +sequence+:: The enzyme sequence.
  # +c+:: Cut locations in enzyme notation.  See CutLocationsInEnzymeNotation.
  #
  # * +sequence+ is required, +c+ is optional
  # * You cannot provide a sequence with cut symbols and provide cut locations.
  # * If +c+ is omitted, +input_pattern+ must contain a cut symbol.
  # * +sequence+ cannot contain adjacent cut symbols.
  # * +c+ is in enzyme index notation and therefore cannot contain a 0.
  #
  # +sequence+ must be a kind of:
  # * String
  # * Bio::Sequence::NA
  # * Bio::RestrictionEnzyme::SingleStrand
  #
  # +c+ must be a kind of:
  # * Integer, one or more
  # * Array
  # * CutLocationsInEnzymeNotation
  #
  def initialize( sequence, *c )
    c.flatten! # if an array was supplied as an argument
    validate_args(sequence, c)
    sequence.downcase!
    
    if sequence =~ re_cut_symbol
      @cut_locations_in_enzyme_notation = CutLocationsInEnzymeNotation.new( strip_padding(sequence) )
    else
      @cut_locations_in_enzyme_notation = CutLocationsInEnzymeNotation.new( c )
    end

    @stripped = Bio::Sequence::NA.new( strip_cuts_and_padding( sequence ) )
    super( pattern )
    @cut_locations = @cut_locations_in_enzyme_notation.to_array_index
  end

  # Returns true if this enzyme is palindromic with its reverse complement.
  # Does not report if the +cut_locations+ are palindromic or not.
  #
  # Examples:
  # * This would be palindromic: 
  #     5' - ATGCAT - 3'
  #          TACGTA
  #
  # * This would not be palindromic: 
  #     5' - ATGCGTA - 3'
  #          TACGCAT
  #
  def palindromic?
    @stripped.reverse_complement == @stripped
  end

  # Pattern with no cut symbols and no 'n' padding.
  # * <code>SingleStrand.new('garraxt', [-2, 1, 7]).stripped  # "garraxt"</code>
  attr_reader :stripped

  # The sequence with 'n' padding and cut symbols.
  # * <code>SingleStrand.new('garraxt', [-2, 1, 7]).with_cut_symbols  # => "n^ng^arraxt^n"</code>
  def with_cut_symbols
    s = pattern
    @cut_locations_in_enzyme_notation.to_array_index.sort.reverse.each { |c| s.insert(c+1, cut_symbol) }
    s
  end

  # The sequence with 'n' padding on the left and right for cuts larger than the sequence.
  # * <code>SingleStrand.new('garraxt', [-2, 1, 7]).pattern  # => "nngarraxtn"</code>
  def pattern
    return stripped if @cut_locations_in_enzyme_notation.min == nil
    left = (@cut_locations_in_enzyme_notation.min.negative? ? 'n' * @cut_locations_in_enzyme_notation.min.abs : '')

    # Add one more 'n' if a cut is at the last position 
    right = (@cut_locations_in_enzyme_notation.max >= @stripped.length ? 'n' * (@cut_locations_in_enzyme_notation.max - @stripped.length + 1) : '')
    [left, stripped, right].to_s
  end

  # The sequence with 'n' pads, cut symbols, and spacing for alignment.
  # * <code>SingleStrand.new('garraxt', [-2, 1, 7]).with_spaces # => "n^n g^a r r a x t^n"</code>
  def with_spaces
    add_spacing( with_cut_symbols )
  end


  # NOTE: BEING WORKED ON, BUG EXISTS IN Bio::NucleicAcid
=begin  
  to_re - important
  example z = [agc]
  z must match [agcz]
  not just [agc]
=end

  #########
  protected
  #########

  def validate_args( input_pattern, input_cut_locations )
    unless input_pattern.kind_of?(String)
      err = "input_pattern is not a String, Bio::Sequence::NA, or Bio::RestrictionEnzyme::SingleStrand::Sequence object\n"
      err += "pattern: #{input_pattern}\n"
      err += "class: #{input_pattern.class}"
      raise ArgumentError, err
    end

    if ( input_pattern =~ re_cut_symbol ) and !input_cut_locations.empty?
      err = "Cut symbol found in sequence, but cut locations were also supplied.  Ambiguous.\n"
      err += "pattern: #{input_pattern}\n"
      err += "symbol: #{cut_symbol}\n"
      err += "locations: #{input_cut_locations.inspect}"
      raise ArgumentError, err
    end

    input_pattern.each_byte do |c| 
      c = c.chr.downcase
      unless Bio::NucleicAcid::NAMES.has_key?(c) or c == 'x' or c == 'X' or c == cut_symbol
        err = "Invalid character in pattern.\n"
        err += "Not a nucleotide or representation of possible nucleotides.  See Bio::NucleicAcid::NAMES for more information.\n"
        err += "char: #{c}\n"
        err += "input_pattern: #{input_pattern}"
        raise ArgumentError, err
      end
    end
  end

  # Tadayoshi Funaba's method as discussed in Programming Ruby 2ed, p390
  def self.once(*ids)
    for id in ids
      module_eval <<-"end;"
        alias_method :__#{id.to_i}__, :#{id.to_s}
        private :__#{id.to_i}__
        def #{id.to_s}(*args, &block)
          (@__#{id.to_i}__ ||= [__#{id.to_i}__(*args, &block)])[0]
        end
      end;
    end
  end

  once :pattern, :with_cut_symbols, :with_spaces, :to_re

end

end
