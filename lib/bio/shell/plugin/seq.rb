#
#  bio/shell/plugin/seq.rb - plugin for biological sequence manipulations
#
#   Copyright (C) 2005 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: seq.rb,v 1.1 2005/09/23 13:57:08 k Exp $
#

require 'bio/sequence'

module Bio::Shell

  def naseq(str)
    Bio::Sequence::NA.new(str)
  end

  def aaseq(str)
    Bio::Sequence::AA.new(str)
  end
  
  def revseq(str)
    seq = Bio::Sequence::NA.new(str)
    res = seq.complement
    display res
    return res
  end

  def translate(str)
    seq = Bio::Sequence::NA.new(str)
    res = seq.translate
    display res
    return res
  end
  
  def seq_report(str)
    if File.exist?(str)
      Bio::FlatFile.open(nil, arg).each do |f|
        seq = f.seq
        if seq.class == Bio::Sequence::NA
          na_report(seq) 
        else
          aa_report(seq) 
        end
      end
    else
      case Bio::Seq.guess(str)
      when :NA
        display na_report(str)
      when :AA
        display aa_report(str)
      end
      return Bio::Seq.guess(str)
    end
  end

  def na_report(seq)
    seq = naseq(seq) unless seq === Bio::Sequence::NA
    str = ""
    str << "input sequence     : #{seq}\n"
    str << "reverse complement : #{seq.complement}\n"
    str << "translation 1      : #{seq.translate}\n"
    str << "translation 2      : #{seq.translate(2)}\n"
    str << "translation 3      : #{seq.translate(3)}\n"
    str << "translation -1     : #{seq.translate(-1)}\n"
    str << "translation -2     : #{seq.translate(-2)}\n"
    str << "translation -3     : #{seq.translate(-3)}\n"
    str << "gc percent         : #{seq.gc} %\n"
    str << "composition        : #{seq.composition.inspect}\n"
    str << "molecular weight   : #{seq.molecular_weight}\n"
    str << "complemnet weight  : #{seq.complement.molecular_weight}\n"
    str << "protein weight     : #{seq.translate.molecular_weight}\n"
    str << "//\n"
    return str
  end

  def aa_report(seq)
    seq = aaseq(seq) unless seq === Bio::Sequence::AA
    str = ""
    str << "input sequence    : #{seq}\n"
    str << "composition       : #{seq.composition.inspect}\n"
    str << "protein weight    : #{seq.molecular_weight}\n"
    str << "amino acid codes  : #{seq.codes.inspect}\n"
    str << "amino acid names  : #{seq.names.inspect}\n"
    str << "//\n"
    return str
  end

end
