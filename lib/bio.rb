#
# bio.rb - Loading all BioRuby modules
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  $Id: bio.rb,v 1.4 2001/09/26 19:17:57 katayama Exp $
#
#    This modlue provides eazy loading of all BioRuby products.
#    By using this module, you you don't need to conscious about
#    organization changes in the BioRuby repositiory.
#

### Sequence

require 'bio/sequence'

### Locations

require 'bio/location'		# included by bio/sequence.rb

### Reference

# require 'bio/reference'	# included by bio/db.rb

### Matrix/Vector

require 'bio/matrix'

### IO interfaces

require 'bio/io/dbget'
require 'bio/io/pubmed'

### Constants

# require 'bio/data/na'		# included by bio/sequence.rb
# require 'bio/data/aa'		# included by bio/sequence.rb
# require 'bio/data/codontable'	# included by bio/sequence.rb
# require 'bio/data/keggorg'	# included by bio/db.rb

### DB parsers

# require 'bio/db'		# included by bio/db/*.rb

# GenBank/RefSeq/DDBJ
require 'bio/db/genbank'
require 'bio/db/refseq'
require 'bio/db/ddbj'

# EMBL/TrEMBL/Swiss-Prot
#require 'bio/db/embl'
#require 'bio/db/trembl'
#require 'bio/db/swissprot'

# KEGG
require 'bio/db/kegg/genome'
require 'bio/db/kegg/genes'
require 'bio/db/kegg/brite'
require 'bio/db/kegg/cell'
require 'bio/db/kegg/compound'
require 'bio/db/kegg/enzyme'

# AAindex
require 'bio/db/aaindex'

# TRANSFAC
require 'bio/db/transfac'

# Prosite
require 'bio/db/prosite'

# LITDB
require 'bio/db/litdb'

# MEDLINE
require 'bio/db/medline'

### misc utils

require 'bio/util/fold'


