#
# = bio/db/embl/uniprot.rb - UniProt database class
# 
# Copyright::   Copyright (C) 2005 KATAYAMA Toshiaki <k@bioruby.org>
# License::     LGPL
#
#  $Id: uniprot.rb,v 1.2 2006/01/28 06:40:39 nakao Exp $
#
# == Description
# 
# Name space for UniProtKB/SwissProt specific methods.
#
# UniProtKB/SwissProt specific methods are defined in this class. 
# Shared methods for UniProtKB/SwissProt and TrEMBL classes are 
# defined in Bio::SPTR class.
#
# == Examples
#
#   str = File.read("p53_human.swiss")
#   obj = Bio::UniProt.new(str)
#   obj.entry_id #=> "P53_HUMAN"
#
# == Referencees
#
# * UniProt
#   http://uniprot.org/
#
# * The UniProtKB/SwissProt/TrEMBL User Manual
#   http://www.expasy.org/sprot/userman.html

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

require 'bio/db/embl/sptr'

module Bio

# Parser class for SwissProt database entry.
# See also Bio::SPTR class.
class UniProt < SPTR
  # Nothing to do (UniProt format is abstracted in SPTR)
end

end

