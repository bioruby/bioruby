#
# = bio/shell/access.rb - database access module
#
# Copyright::	Copyright (C) 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	LGPL
#
# $Id: entry.rb,v 1.1 2005/11/28 02:05:41 k Exp $
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
      str = ent(arg)
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

  def ent(arg)
    db, entry_id = arg.to_s.strip.split(/:/)
    
    if Bio::Shell.find_flat_dir(db)
      entry = flatsearch(db, entry_id)
    eleif obdadbs.include?(db)
      entry = obda_get_entry(db, entry_id)
    else
      entry = bget(arg)
    end
    return entry
  end

end
