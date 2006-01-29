#
# bio/db/pdb.rb - PDB database classes
#
#   Copyright (C) 2004 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
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
#  $Id: pdb.rb,v 1.6 2006/01/29 06:54:13 ngoto Exp $
#

require 'bio/db'

# definition of the PDB class
module Bio
  class PDB #< DB

    autoload :ChemicalComponent, 'bio/db/pdb/chemicalcomponent'

  end #class PDB
end #module Bio

# require other files under pdb directory
require 'bio/db/pdb/utils'
require 'bio/db/pdb/atom'
require 'bio/db/pdb/residue'
require 'bio/db/pdb/chain'
require 'bio/db/pdb/model'
require 'bio/db/pdb/pdb'

