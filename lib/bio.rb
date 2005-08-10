#
# bio.rb - Loading all BioRuby modules
#
#   Copyright (C) 2001-2005 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: bio.rb,v 1.44 2005/08/10 12:56:37 k Exp $
#

module Bio
  BIORUBY_VERSION = [0, 6, 4].extend(Comparable)
end


### Basic data type modules

## Sequence

require 'bio/sequence'

## Locations/Location

require 'bio/location'

## Features/Feature

require 'bio/feature'

## References/Reference

require 'bio/reference'

## Pathway/Relation

require 'bio/pathway'

## Alignment

require 'bio/alignment'


### Constants

require 'bio/data/na'
require 'bio/data/aa'
require 'bio/data/codontable'


### DB parsers

require 'bio/db'

## GenBank/RefSeq/DDBJ

require 'bio/db/genbank'

## EMBL/TrEMBL/Swiss-Prot/SPTR

require 'bio/db/embl'

## KEGG

require 'bio/db/kegg/genome'
require 'bio/db/kegg/genes'
require 'bio/db/kegg/enzyme'
require 'bio/db/kegg/compound'
require 'bio/db/kegg/glycan'
require 'bio/db/kegg/reaction'
require 'bio/db/kegg/brite'
require 'bio/db/kegg/cell'
require 'bio/db/kegg/microarray'
require 'bio/db/kegg/keggtab'
require 'bio/db/kegg/ko'

## other formats

require 'bio/db/fasta'
require 'bio/db/gff'
require 'bio/db/aaindex'
require 'bio/db/transfac'
require 'bio/db/prosite'
require 'bio/db/litdb'
require 'bio/db/medline'
require 'bio/db/fantom'
require 'bio/db/go'
require 'bio/db/pdb'
require 'bio/db/nbrf'


### IO interface modules

require 'bio/io/registry'
require 'bio/io/flatfile'
require 'bio/io/flatfile/indexer'
require 'bio/io/flatfile/index'
require 'bio/io/flatfile/bdb'
require 'bio/io/fastacmd'
require 'bio/io/fetch'
require 'bio/io/sql'

require 'bio/io/dbget'
require 'bio/io/keggapi'
require 'bio/io/pubmed'
require 'bio/io/das'
require 'bio/io/ddbjxml'
require 'bio/io/higet'
#require 'bio/io/esoap'
#require 'bio/io/brdb'


### Applications

require 'bio/appl/fasta'
require 'bio/appl/fasta/format10'
require 'bio/appl/blast'
require 'bio/appl/blast/report'
require 'bio/appl/blast/format0'
require 'bio/appl/blast/wublast'
require 'bio/appl/blast/rexml'
require 'bio/appl/blast/xmlparser'
require 'bio/appl/blast/format8'
require 'bio/appl/bl2seq/report'
require 'bio/appl/hmmer'
require 'bio/appl/hmmer/report'
require 'bio/appl/emboss'
require 'bio/appl/psort'
require 'bio/appl/tmhmm/report'
require 'bio/appl/targetp/report'
require 'bio/appl/sosui/report'
require 'bio/appl/genscan/report'
require 'bio/appl/clustalw'
require 'bio/appl/clustalw/report'
require 'bio/appl/mafft'
require 'bio/appl/mafft/report'
require 'bio/appl/sim4'
require 'bio/appl/sim4/report'
require 'bio/appl/spidey/report'
require 'bio/appl/blat/report'

### Utilities

require 'bio/util/sirna'

