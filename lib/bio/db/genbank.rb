#
# bio/db/genbank.rb - loader for GenBank style database classes
#
#   Copyright (C) 2004 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: genbank.rb,v 0.34 2005/10/23 07:00:15 k Exp $
#

module Bio
  autoload :NCBIDB,   'bio/db'
  class NCBIDB
    autoload :Common, 'bio/db/genbank/common'
  end
  autoload :GenBank,  'bio/db/genbank/genbank'
  autoload :GenPept,  'bio/db/genbank/genpept'
  autoload :RefSeq,   'bio/db/genbank/refseq'
  autoload :DDBJ,     'bio/db/genbank/ddbj'
end
