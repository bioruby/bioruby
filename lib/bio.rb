#
# bio.rb - Loading all BioRuby modules
#
#   Copyright (C) 2001, 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: bio.rb,v 1.27 2003/02/25 16:24:11 k Exp $
#

module Bio
  BIORUBY_VERSION = [0, 5, 0].extend(Comparable)
end



### Basic data type modules

## Sequence

require 'bio/sequence'		# required by bio/db.rb

## Locations/Location

require 'bio/location'		# required by bio/sequence.rb

## Features/Feature

require 'bio/feature'		# required by bio/db.rb

## References/Reference

require 'bio/reference'		# required by bio/db.rb

## Pathway/Relation

require 'bio/pathway'


### Constants

require 'bio/data/na'		# required by bio/sequence.rb
require 'bio/data/aa'		# required by bio/sequence.rb
require 'bio/data/codontable'	# required by bio/sequence.rb
require 'bio/data/keggorg'


### IO interface modules

require 'bio/io/registry'
require 'bio/io/flatfile'
require 'bio/io/flatfile/indexer'
require 'bio/io/flatfile/index'
require 'bio/io/flatfile/bdb'
require 'bio/io/fetch'
require 'bio/io/sql'

require 'bio/io/dbget'
require 'bio/io/pubmed'
require 'bio/io/das'
#require 'bio/io/brdb'


### DB parsers

require 'bio/db'		# required by bio/db/*.rb

## GenBank/RefSeq/DDBJ

require 'bio/db/genbank'	# required by bio/db/genbank/*.rb
require 'bio/db/genbank/genbank'
require 'bio/db/genbank/genpept'
require 'bio/db/genbank/refseq'
require 'bio/db/genbank/ddbj'

## EMBL/TrEMBL/Swiss-Prot/SPTR

require 'bio/db/embl'		# required by bio/db/embl/*.rb
require 'bio/db/embl/embl'
require 'bio/db/embl/sptr'
require 'bio/db/embl/trembl'
require 'bio/db/embl/swissprot'

## KEGG

require 'bio/db/kegg/genome'
require 'bio/db/kegg/genes'
require 'bio/db/kegg/compound'
require 'bio/db/kegg/enzyme'
require 'bio/db/kegg/brite'
require 'bio/db/kegg/cell'
require 'bio/db/kegg/microarray'
require 'bio/db/kegg/keggtab'

## other formats

require 'bio/db/aaindex'
require 'bio/db/transfac'
require 'bio/db/prosite'
require 'bio/db/litdb'
require 'bio/db/medline'
require 'bio/db/fasta'
require 'bio/db/gff'


### Applications

require 'bio/appl/fasta'
require 'bio/appl/blast'
require 'bio/appl/hmmer'
require 'bio/appl/emboss'
require 'bio/appl/tmhmm/report'
require 'bio/appl/targetp/report'
require 'bio/appl/sosui/report'


