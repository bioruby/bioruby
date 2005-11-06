#
# = bio/shell/plugin/seq.rb - plugin for biological sequence manipulations
#
# Copyright::	Copyright (C) 2005
#		Toshiaki Katayama <k@bioruby.org>
# Lisence::	LGPL
#
# $Id: seq.rb,v 1.6 2005/11/06 03:03:08 k Exp $
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

module Bio::Shell

  private

  # Obtain a Bio::Sequence::NA (DNA) or a Bio::Sequence::AA (Amino Acid)
  # sequence from
  #   * String -- "atgcatgc" or "MQKKP"
  #   * File   -- "gbvrl.gbk" (only the first entry is used)
  #   * ID     -- "embl:BUM"  (entry is retrieved by the OBDA)
  def seq(arg)
    if arg.respond_to?(:gets) or File.exists?(arg)
      entry = flatauto(arg)
    elsif arg[/:/]
      db, entry_id = arg.split(/:/)
      str = obda_get_entry(db, entry_id)
      if cls = Bio::FlatFile.autodetect(str)
        entry = cls.new(str)
      end
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

  # Displays some basic properties of the sequence.
  def seqstat(str)
    seq = seq(str)
    rep = ""
    if seq.respond_to?(:complement)
      rep << "Sequence           : #{seq}\n"
      rep << "Reverse complement : #{seq.complement}\n"
      rep << "Translation  1     : #{seq.translate}\n"
      rep << "Translation  2     : #{seq.translate(2)}\n"
      rep << "Translation  3     : #{seq.translate(3)}\n"
      rep << "Translation -1     : #{seq.translate(-1)}\n"
      rep << "Translation -2     : #{seq.translate(-2)}\n"
      rep << "Translation -3     : #{seq.translate(-3)}\n"
      rep << "GC percent         : #{seq.gc_percent} %\n"
      rep << "Composition        : #{seq.composition.inspect}\n"
      begin
        rep << "Molecular weight   : #{seq.molecular_weight}\n"
        rep << "Complemnet weight  : #{seq.complement.molecular_weight}\n"
        rep << "Protein weight     : #{seq.translate.molecular_weight}\n"
      rescue
        rep << "Molecular weight   : #{$!}\n"
      end
    else
      rep << "Sequence           : #{seq}\n"
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
