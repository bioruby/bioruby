#
# = bio/shell/plugin/seq.rb - plugin for biological sequence manipulations
#
# Copyright::	Copyright (C) 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	LGPL
#
# $Id: seq.rb,v 1.9 2005/11/16 04:03:23 k Exp $
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

require 'bio/sequence'
require 'bio/util/color_scheme'

module Bio::Shell

  private

  # Obtain a Bio::Sequence::NA (DNA) or a Bio::Sequence::AA (Amino Acid)
  # sequence from
  #   * String -- "atgcatgc" or "MQKKP"
  #   * File   -- "gbvrl.gbk" (only the first entry is used)
  #   * ID     -- "embl:BUM"  (entry is retrieved by the OBDA)
  def seq(arg)
    if arg.kind_of?(Bio::Sequence)
      s = arg
    elsif arg.respond_to?(:gets) or File.exists?(arg)
      entry = flatauto(arg)
    elsif arg[/:/]
      db, entry_id = arg.split(/:/)
      str = obda_get_entry(db, entry_id)
      entry = parse(str)
    else
      tmp = arg
    end

    if entry.respond_to?(:seq)
      tmp = entry.seq
    elsif entry.respond_to?(:naseq)
      s = entry.naseq
    elsif entry.respond_to?(:aaseq)
      s = entry.aaseq
    end

    if tmp and tmp.is_a?(String) and not tmp.empty?
      s = Bio::Sequence.auto(tmp)
    end

    return s || ""
  end


  # Convert sequence to colored HTML string
  def htmlseq(str)
    if str.kind_of?(Bio::Sequence)
      seq = str
    else
      seq = seq(str)
    end

    if seq.is_a?(Bio::Sequence::AA)
      scheme = Bio::ColorScheme::Taylor
    else
      scheme = Bio::ColorScheme::Nucleotide
    end

    html = %Q[<div style="font-family:monospace;">\n]
    seq.fold(50).each_byte do |c|
      case c.chr
      when "\n"
        html += "<br>\n"
      else
        color = scheme[c.chr]
        html += %Q[<span style="background:\##{color};">#{c.chr}</span>\n]
      end
    end
    html += "</div>\n"
    return html
  end


  # Displays some basic properties of the sequence.
  def seqstat(str)
    seq = seq(str)
    rep = ""
    if seq.respond_to?(:complement)
      rep << "Sequence           : #{seq.fold(71,21).strip}\n"
      rep << "Reverse complement : #{seq.complement.fold(71,21).strip}\n"
      rep << "Translation  1     : #{seq.translate.fold(71,21).strip}\n"
      rep << "Translation  2     : #{seq.translate(2).fold(71,21).strip}\n"
      rep << "Translation  3     : #{seq.translate(3).fold(71,21).strip}\n"
      rep << "Translation -1     : #{seq.translate(-1).fold(71,21).strip}\n"
      rep << "Translation -2     : #{seq.translate(-2).fold(71,21).strip}\n"
      rep << "Translation -3     : #{seq.translate(-3).fold(71,21).strip}\n"
      rep << "GC percent         : #{seq.gc_percent} %\n"
      rep << "Composition        : #{seq.composition.inspect}\n"
      begin
        rep << "Molecular weight   : #{seq.molecular_weight}\n"
      rescue
        rep << "Molecular weight   : #{$!}\n"
      end
      begin
        rep << "Complemnet weight  : #{seq.complement.molecular_weight}\n"
      rescue
        rep << "Complement weight  : #{$!}\n"
      end
      begin
        rep << "Protein weight     : #{seq.translate.molecular_weight}\n"
      rescue
        rep << "Protein weight     : #{$!}\n"
      end
    else
      rep << "Sequence           : #{seq.fold(71,21).strip}\n"
      rep << "Composition        : #{seq.composition.inspect}\n"
      begin
        rep << "Protein weight     : #{seq.molecular_weight}\n"
      rescue
        rep << "Protein weight     : #{$!}\n"
      end
#     rep << "amino acid codes   : #{seq.codes.inspect}\n"
#     rep << "amino acid names   : #{seq.names.inspect}\n"
    end
    rep  << "//\n"
    display rep
  end

  # Displays a DNA sequence by ascii art in B-type double helix.
  # Argument need to be at least 16 bases in length.
  def doublehelix(str)
    seq = seq(str)
    if str.length < 16
      display "Sequence must be longer than 16 bases."
      return
    end
    if ! seq.respond_to?(:complement)
      display "Sequence must be a DNA sequence."
      return
    end
    helix = ''
    pairs = [ [5, 0], [4, 2], [3, 3], [2, 4], 
              [1, 4], [0, 3], [0, 2], [1, 0] ]
    seq.window_search(16, 16) do |subseq|
      pairs.each_with_index do |ij, x|
        base = subseq[x, 1]
        helix << ' ' * ij[0] + base + '-' * ij[1] + base.complement + "\n"
      end
      pairs.reverse.each_with_index do |ij, x|
        base = subseq[x + 8, 1]
        helix << ' ' * ij[0] + base.complement + '-' * ij[1] + base + "\n"
      end
    end
    display helix
  end

end


class String

  def to_naseq
    Bio::Sequence::NA.new(self)
  end

  def to_aaseq
    Bio::Sequence::AA.new(self)
  end

  # folding both line end justified
  def fold(fill_column = 72, indent = 0)
    str = ''

    # size : allowed length of the actual text
    unless (size = fill_column - indent) > 0
      raise "[Error] indent > fill_column"
    end

    0.step(self.length - 1, size) do |n|
      str << ' ' * indent + self[n, size] + "\n"
    end

    return str
  end

  # folding with conscious about word boundaries with prefix string
  def fill(fill_column = 80, indent = 0, separater = ' ', prefix = '', first_line_only = true)

    # size : allowed length of the actual text
    unless (size = fill_column - indent) > 0
      raise "[Error] indent > fill_column"
    end

    n = pos = 0
    str = []
    while n < self.length
      pos = self[n, size].rindex(separater)

      if self[n, size].length < size	# last line of the folded str
        pos = nil
      end

      if pos
        str << self[n, pos+separater.length]
        n += pos + separater.length
      else				# line too long or the last line
        str << self[n, size]
        n += size
      end
    end
    str = str.join("\n")

    str[0,0] = prefix + ' ' * (indent - prefix.length)
    if first_line_only
      head = ' ' * indent
    else
      head = prefix + ' ' * (indent - prefix.length)
    end
    str.gsub!("\n", "\n#{head}")

    return str.chomp
  end
end
