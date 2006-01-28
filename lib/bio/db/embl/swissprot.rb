#
# = bio/db/embl/swissprot.rb - SwissProt database class
# 
# Copyright::   Copyright (C) 2001, 2002 KATAYAMA Toshiaki <k@bioruby.org>
# License::     LGPL
#
#  $Id: swissprot.rb,v 1.4 2006/01/28 06:40:38 nakao Exp $
#
# == Description
# 
# Name space for SwissProt specific methods.
#
# SwissProt (before UniProtKB/SwissProt) specific methods are defined in 
# this class. Shared methods for UniProtKB/SwissProt and TrEMBL classes 
# are defined in Bio::SPTR class.
#
# == Examples
#
#   str = File.read("p53_human.swiss")
#   obj = Bio::SwissProt.new(str)
#   obj.entry_id #=> "P53_HUMAN"
#
# == Referencees
#
# * Swiss-Prot Protein knowledgebase
#   http://au.expasy.org/sprot/
#
# * Swiss-Prot Protein Knowledgebase User Manual
#   http://au.expasy.org/sprot/userman.html
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

require 'bio/db/embl/sptr'

module Bio

# Parser class for SwissProt database entry.
# See also Bio::SPTR class.
class SwissProt < SPTR
  # Nothing to do (SwissProt format is abstracted in SPTR)
end

end

