#
# = bio/db/pdb.rb - PDB database classes
#
# Copyright::	Copyright (C) 2004
# 		GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
# License::	The Ruby License
#
#

# definition of the PDB class
module Bio
  class PDB

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

