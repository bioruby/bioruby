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
#  $Id: bio.rb,v 1.2 2001/08/21 17:49:05 katayama Exp $
#
#    This modlue provides eazy loading of BioRuby products and
#    by using this module, you you don't need to conscious about
#    organization changes in the BioRuby repositiory.
#

### Sequence

require 'bio/sequence'
# require 'bio/data/na'		# included by sequence.rb
# require 'bio/data/aa'		# included by sequence.rb
# require 'bio/data/codontable'	# included by sequence.rb

### Matrix

require 'bio/matrix'

### Locations

require 'bio/location'

### IO

require 'bio/io/dbget'

### DB parsers

# require 'bio/db'		# included by bio/db/*.rb
# require 'bio/data/keggorg'	# included by db.rb

# DDBJ
require 'bio/db/ddbj'

# GenBank
require 'bio/db/genbank'

# EMBL/TrEMBL
#require 'bio/db/embl'
#require 'bio/db/trembl'

# KEGG
#require 'bio/db/kegg/brite'
#require 'bio/db/kegg/cell'
#require 'bio/db/kegg/compound'
#require 'bio/db/kegg/enzyme'
require 'bio/db/kegg/genes'
require 'bio/db/kegg/genome'

# AAindex
require 'bio/db/aaindex'

# TRANSFAC
require 'bio/db/transfac'

# Prosite
require 'bio/db/prosite'

# LITDB
require 'bio/db/litdb'

### misc utils

require 'bio/util/fold'


