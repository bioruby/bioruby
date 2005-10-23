#
# bio/db/genbank/genpept.rb - GenPept database class
#
#   Copyright (C) 2002-2004 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: genpept.rb,v 1.10 2005/10/23 07:20:37 k Exp $
#

require 'bio/db/genbank/common'
require 'bio/db/genbank/genbank'

module Bio
class GenPept < NCBIDB

  include Bio::NCBIDB::Common

  # LOCUS
  class Locus
    def initialize(locus_line)
      @entry_id = locus_line[12..27].strip
      @length   = locus_line[29..39].to_i
      @circular = locus_line[55..62].strip	# always linear
      @division = locus_line[63..66].strip
      @date     = locus_line[68..78].strip
    end
    attr_accessor :entry_id, :length, :circular, :division, :date
  end

  def locus
    @data['LOCUS'] ||= Locus.new(get('LOCUS'))
  end
  def entry_id;		locus.entry_id;		end
  def length;		locus.length;		end
  def circular;		locus.circular;		end
  def division;		locus.division;		end
  def date;		locus.date;		end


  # ORIGIN
  def seq
    unless @data['SEQUENCE']
      origin
    end
    Bio::Sequence::AA.new(@data['SEQUENCE'])
  end
  alias aaseq seq
  alias aalen length

  def seq_len
    seq.length
  end

  # DBSOURCE
  def dbsource
    get('DBSOURCE')
  end

end # GenPept
end # Bio
