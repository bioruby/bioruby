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
#  $Id: bio.rb,v 1.48 2005/09/09 14:59:52 ngoto Exp $
#

module Bio

  BIORUBY_VERSION = [0, 7, 0].extend(Comparable)

  ### Basic data types

  ## Sequence

  autoload :Seq,            'bio/sequence'
  autoload :Sequence,       'bio/sequence'

  ## Locations/Location

  autoload :Location,       'bio/location'
  autoload :Locations,      'bio/location'

  ## Features/Feature

  autoload :Feature,        'bio/feature'
  autoload :Features,       'bio/feature'       # to_gff

  ## References/Reference

  autoload :Reference,      'bio/reference'
  autoload :References,     'bio/reference'

  ## Pathway/Relation

  autoload :Pathway,        'bio/pathway'
  autoload :Relation,       'bio/pathway'

  ## Alignment

  autoload :Alignment,      'bio/alignment'


  ### Constants

  autoload :NucleicAcid,    'bio/data/na'
  autoload :AminoAcid,      'bio/data/aa'
  autoload :CodonTable,     'bio/data/codontable'


  ### DB parsers

  autoload :DB,             'bio/db'
  autoload :NCBIDB,         'bio/db'
  autoload :KEGGDB,         'bio/db'
  autoload :EMBLDB,         'bio/db'

  ## GenBank/RefSeq/DDBJ

  # module Bio
  #   autoload :NCBIDB, 'bio/db'
  #   class GenBank < NCBIDB
  #     autoload :Common, 'bio/db/genbank/common'
  #     include Bio::GenBank::Common

  # module Bio
  #   autoload :NCBIDB, 'bio/db'
  #  end
  #  class Bio::GenBank < Bio::NCBIDB
  #     autoload :Common, 'bio/db/genbank/common'
  #     include Bio::GenBank::Common

  autoload :GenBank,        'bio/db/genbank/genbank'
  autoload :GenPept,        'bio/db/genbank/genpept'
  autoload :RefSeq,         'bio/db/genbank/refseq'
  autoload :DDBJ,           'bio/db/genbank/ddbj'

  ## EMBL/TrEMBL/Swiss-Prot/SPTR

  autoload :EMBL,           'bio/db/embl/embl'
  autoload :SPTR,           'bio/db/embl/sptr'
  autoload :TrEMBL,         'bio/db/embl/trembl'
  autoload :UniProt,        'bio/db/embl/uniprot'
  autoload :SwissProt,      'bio/db/embl/swissprot'


  ## KEGG

  class KEGG
    autoload :GENOME,       'bio/db/kegg/genome'
    autoload :GENES,        'bio/db/kegg/genes'
    autoload :ENZYME,       'bio/db/kegg/enzyme'
    autoload :COMPOUND,     'bio/db/kegg/compound'
    autoload :GLYCAN,       'bio/db/kegg/glycan'
    autoload :REACTION,     'bio/db/kegg/reaction'
    autoload :BRITE,        'bio/db/kegg/brite'
    autoload :CELL,         'bio/db/kegg/cell'
    autoload :Microarray,   'bio/db/kegg/microarray'
    autoload :Microarrays,  'bio/db/kegg/microarray'
    autoload :Keggtab,      'bio/db/kegg/keggtab'
    autoload :KO,           'bio/db/kegg/ko'
  end

  ## other formats

  autoload :FastaFormat,    'bio/db/fasta'
  autoload :FastaNumericFormat, 'bio/db/fasta' # change to FastaFormat::Numeric ?
  autoload :FastaDefline,       'bio/db/fasta' # change to FastaFormat::Defline
  autoload :GFF,            'bio/db/gff'
  autoload :GFF2,           'bio/db/gff'       # change to GFF::GFF2, improve
  autoload :GFF3,           'bio/db/gff'       # change to GFF::GFF3, improve
  autoload :AAindex,        'bio/db/aaindex'
  autoload :TRANSFAC,       'bio/db/transfac'
  autoload :TFMATRIX,       'bio/db/transfac'  # change to TRANSFAC::MATRIX
  autoload :TFSITE,         'bio/db/transfac'  # change to TRANSFAC::SITE
  autoload :TFFACTOR,       'bio/db/transfac'  # change to TRANSFAC::FACTOR
  autoload :TFCELL,         'bio/db/transfac'  # change to TRANSFAC::CELL
  autoload :TFCLASS,        'bio/db/transfac'  # change to TRANSFAC::CLASS
  autoload :TFGENE,         'bio/db/transfac'  # change to TRANSFAC::GENE
  autoload :PROSITE,        'bio/db/prosite'
  autoload :LITDB,          'bio/db/litdb'
  autoload :MEDLINE,        'bio/db/medline'
  autoload :FANTOM,         'bio/db/fantom'
  autoload :GO,             'bio/db/go'
  autoload :PDB,            'bio/db/pdb'
  autoload :NBRF,           'bio/db/nbrf'


  ### IO interface modules

  autoload :Registry,       'bio/io/registry'
  autoload :Fetch,          'bio/io/fetch'
  autoload :SQL,            'bio/io/sql'
  autoload :FlatFile,       'bio/io/flatfile'
  autoload :FlatFileIndex,  'bio/io/flatfile/index' # chage to FlatFile::Index ?
  ## below are described in bio/io/flatfile/index.rb
  #class FlatFileIndex
  #  autoload :Indexer,    'bio/io/flatfile/indexer'
  #  autoload :BDBdefault, 'bio/io/flatfile/bdb'
  #  autoload :BDBwrapper, 'bio/io/flatfile/bdb'
  #  autoload :BDB_1,      'bio/io/flatfile/bdb'
  #end

  autoload :PubMed,         'bio/io/pubmed'
  autoload :DAS,            'bio/io/das'
  autoload :DBGET,          'bio/io/dbget'

  ## below are described in bio/appl/blast.rb
  #class Blast
  #  autoload :Fastacmd,     'bio/io/fastacmd'
  #end

  class KEGG
    autoload :API,          'bio/io/keggapi'
  end

  class DDBJ
    autoload :XML,          'bio/io/ddbjxml'
  end

  class HGC
    autoload :HiGet,        'bio/io/higet'
  end

# autoload :ESOAP,          'bio/io/esoap'      # NCBI::ESOAP ?
# autoload :BRDB,           'bio/io/brdb'       # remove


  ### Applications

  autoload :Fasta,          'bio/appl/fasta'
  autoload :Report,         'bio/appl/fasta/format10' # improve format6

  autoload :Blast,          'bio/appl/blast'
  ## below are described in bio/appl/blast.rb
  #class Blast
  #  autoload :Fastacmd,     'bio/io/fastacmd'
  #  autoload :Report,       'bio/appl/blast/report'
  #  autoload :Default,      'bio/appl/blast/format0'
  #  autoload :WU,           'bio/appl/blast/wublast'
  #  autoload :Bl2seq,       'bio/appl/bl2seq/report'
  #end

  autoload :HMMER,          'bio/appl/hmmer'
  class HMMER
    autoload :Report,       'bio/appl/hmmer/report'
  end

# autoload :EMBOSS,         'bio/appl/emboss'    # use bio/command, improve

  autoload :PSORT,          'bio/appl/psort'
  class PSORT
    autoload :PSORT1,       'bio/appl/psort'
    autoload :PSORT2,       'bio/appl/psort'
  end

  autoload :TMHMM,          'bio/appl/tmhmm/report'
  autoload :TargetP,        'bio/appl/targetp/report'
  autoload :SOSUI,          'bio/appl/sosui/report'
  autoload :Genscan,        'bio/appl/genscan/report'

  autoload :ClustalW,       'bio/appl/clustalw'
  class ClustalW
    autoload :Report,       'bio/appl/clustalw/report'
  end

  autoload :MAFFT,          'bio/appl/mafft'
  class MAFFT
    autoload :Report,       'bio/appl/mafft/report'
  end

  autoload :Sim4,           'bio/appl/sim4'
  class Sim4
    autoload :Report,       'bio/appl/sim4/report'
  end
  
  autoload :Spidey,         'bio/appl/spidey/report'
  autoload :Blat,           'bio/appl/blat/report'
  

  ### Utilities

  autoload :SiRNA,          'bio/util/sirna'

end
