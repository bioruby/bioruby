#
# bio/util/restrction_enzyme/cut_symbol.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: cut_symbol.rb,v 1.2 2006/12/31 21:50:31 trevor Exp $
#

nil # separate file-level rdoc from following statement

module Bio; end
class Bio::RestrictionEnzyme

#
# bio/util/restrction_enzyme/cut_symbol.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
module CutSymbol

  require 'singleton'

  class CutSymbol__
    include Singleton
    attr_accessor :cut_symbol
    attr_accessor :escaped_cut_symbol
  end

  # NOTE verify this sometime
  def cut_symbol=(c)
    CutSymbol__.instance.cut_symbol = c
  end

  def cut_symbol
    CutSymbol__.instance.cut_symbol ||= '^'
  end

  def escaped_cut_symbol
    CutSymbol__.instance.escaped_cut_symbol ||= "\\#{cut_symbol}"  # \^
  end

  # Used to check if multiple cut symbols are next to each other
  def re_cut_symbol_adjacent
    %r"#{escaped_cut_symbol}{2}"
  end

  # A Regexp of the cut_symbol.  Convenience method.
  def re_cut_symbol
    %r"#{escaped_cut_symbol}"
  end

end # CutSymbol
end # Bio::RestrictionEnzyme