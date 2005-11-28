#
# = bio/shell/access.rb - database access module
#
# Copyright::	Copyright (C) 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	LGPL
#
# $Id: entry.rb,v 1.2 2005/11/28 07:09:34 k Exp $
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

module Bio::Shell

  private

  # Obtain a Bio::Sequence::NA (DNA) or a Bio::Sequence::AA (Amino Acid)
  # sequence from
  #   * String -- "atgcatgc" or "MQKKP"
  #   * File   -- "gbvrl.gbk" (only the first entry is used)
  #   * ID     -- "embl:BUM"  (entry is retrieved by the OBDA)
  def seq(arg)
    seq = ""

    if arg.kind_of?(Bio::Sequence)
      seq = arg
    elsif arg.respond_to?(:gets) or File.exists?(arg)
      ent = flatauto(arg)
    elsif arg[/:/]
      str = ent(arg)
      ent = flatparse(str)
    else
      tmp = arg
    end

    if ent.respond_to?(:seq)
      tmp = ent.seq
    elsif ent.respond_to?(:naseq)
      seq = ent.naseq
    elsif ent.respond_to?(:aaseq)
      seq = ent.aaseq
    end

    if tmp and tmp.is_a?(String) and not tmp.empty?
      seq = Bio::Sequence.auto(tmp)
    end

    return seq
  end

  def ent(arg)
    entry = ""

    db, entry_id = arg.to_s.strip.split(/:/)
    
    if arg.respond_to?(:gets) or File.exists?(arg)
      entry = flatfile(arg)
    elsif Bio::Shell.find_flat_dir(db)
      entry = flatsearch(db, entry_id)
    elsif obdadbs.include?(db)
      entry = obdaentry(db, entry_id)
    else
      entry = bget(arg)
    end

    display entry
    return entry
  end

end
