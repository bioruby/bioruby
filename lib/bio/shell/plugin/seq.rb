#
# = bio/shell/plugin/seq.rb - plugin for biological sequence manipulations
#
# Copyright::	Copyright (C) 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	LGPL
#
# $Id: seq.rb,v 1.12 2005/11/25 16:47:10 k Exp $
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
require 'bio/shell/plugin/codon'

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
    max = 150
    seq = seq(str)
    rep = "\n* * * Sequence statistics * * *\n\n"
    if seq.respond_to?(:complement)
      fwd = seq
      rev = seq.complement
      if seq.length > max
        dot = " ..."
        fwd = fwd.subseq(1, max)
        rev = rev.subseq(1, max)
      end
      rep << "5'->3' sequence   : #{fwd.fold(70,20).strip}#{dot}\n"
      rep << "3'->5' sequence   : #{rev.fold(70,20).strip}#{dot}\n"
      [ 1, 2, 3, -1, -2, -3 ].each do |frame|
        pep = fwd.translate(frame).fold(70,20).strip
        rep << "Translation  #{frame.to_s.rjust(2)}   : #{pep}#{dot}\n"
      end
      rep << "Length            : #{seq.length} bp\n"
      rep << "GC percent        : #{seq.gc_percent} %\n"

      ary = []
      seq.composition.sort.each do |base, num|
        percent = format("%.2f", 100.0 * num / seq.length).rjust(6)
        count   = num.to_s.rjust(seq.length.to_s.length)
        ary << "                    #{base} - #{count} (#{percent} %)\n"
      end
      rep << "Composition       : #{ary.join.strip}\n"

      rep << "Codon usage       :\n"
      hash = Hash.new("0.0%")
      seq.codon_usage.sort.each do |codon, num|
        percent = format("%.1f%", 100.0 * num / (seq.length / 3))
        hash[codon] = percent
      end
      rep << codon_usage_table(1, hash).output

      begin
        rep << "Molecular weight  : #{seq.molecular_weight}\n"
      rescue
        rep << "Molecular weight  : #{$!}\n"
      end
      begin
        rep << "Protein weight    : #{seq.translate.chomp('*').molecular_weight}\n"
      rescue
        rep << "Protein weight    : #{$!}\n"
      end
    else
      pep = seq
      if seq.length > max
        dot = " ..."
        pep = seq.subseq(1, max)
      end
      rep << "N->C sequence     : #{pep.fold(70,20).strip}#{dot}\n"
      rep << "Length            : #{seq.length} aa\n"

      names = Bio::AminoAcid.names
      ary = []
      seq.composition.sort.each do |aa, num|
        percent = format("%.2f", 100.0 * num / seq.length).rjust(6)
        count   = num.to_s.rjust(seq.length.to_s.length)
        code    = names[aa]
        name    = names[names[aa]]
        ary << "                    #{aa} #{code} - #{count} (#{percent} %) #{name}\n"
      end
      rep << "Composition       : #{ary.join.strip}\n"

      begin
        rep << "Protein weight    : #{seq.molecular_weight}\n"
      rescue
        rep << "Protein weight    : #{$!}\n"
      end
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
      warn "Error: indent > fill_column (indent is set to 0)"
      size = fill_column
      indent = 0
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
      warn "Error: indent > fill_column (indent is set to 0)"
      size = fill_column
      indent = 0
    end

    n = pos = 0
    ary = []
    while n < self.length
      pos = self[n, size].rindex(separater)

      if self[n, size].length < size	# last line of the folded str
        pos = nil
      end

      if pos
        ary << self[n, pos+separater.length]
        n += pos + separater.length
      else				# line too long or the last line
        ary << self[n, size]
        n += size
      end
    end
    str = ary.join("\n")

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

