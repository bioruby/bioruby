#
# = bio.rb - Loading all BioRuby modules
#
# Copyright::	Copyright (C) 2001-2007
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
# $Id: bio.rb,v 1.89.2.4 2008/03/04 11:29:36 ngoto Exp $
#

module Bio

  BIORUBY_VERSION = [1, 2, 1].extend(Comparable)

  ### Basic data types

  ## Sequence

  autoload :Sequence,       'bio/sequence'

  ## Locations/Location

  autoload :Location,       'bio/location'
  autoload :Locations,      'bio/location'

  ## Features/Feature

  autoload :Feature,        'bio/feature'
  autoload :Features,       'bio/compat/features'

  ## References/Reference

  autoload :Reference,      'bio/reference'
  autoload :References,     'bio/compat/references'

  ## Pathway/Relation

  autoload :Pathway,        'bio/pathway'
  autoload :Relation,       'bio/pathway'

  ## Alignment

  autoload :Alignment,      'bio/alignment'

  ## Tree
  autoload :Tree, 'bio/tree'

  ## Map
  autoload :Map,            'bio/map'
	
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

  autoload :GenBank,        'bio/db/genbank/genbank'
  autoload :GenPept,        'bio/db/genbank/genpept'
  autoload :RefSeq,         'bio/db/genbank/refseq'
  autoload :DDBJ,           'bio/db/genbank/ddbj'
  ## below are described in bio/db/genbank/ddbj.rb
  #class DDBJ
  #  autoload :XML,          'bio/io/ddbjxml'
  #end

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
    autoload :DRUG,         'bio/db/kegg/drug'
    autoload :GLYCAN,       'bio/db/kegg/glycan'
    autoload :REACTION,     'bio/db/kegg/reaction'
    autoload :BRITE,        'bio/db/kegg/brite'
    autoload :CELL,         'bio/db/kegg/cell'
    autoload :EXPRESSION,   'bio/db/kegg/expression'
    autoload :ORTHOLOGY,    'bio/db/kegg/orthology'
    autoload :KGML,         'bio/db/kegg/kgml'
    autoload :Taxonomy,     'bio/db/kegg/taxonomy'
  end

  ## other formats

  autoload :FastaFormat,    'bio/db/fasta'
  autoload :FastaNumericFormat, 'bio/db/fasta' # change to FastaFormat::Numeric ?
  autoload :FastaDefline,       'bio/db/fasta' # change to FastaFormat::Defline
  autoload :GFF,            'bio/db/gff'
  autoload :AAindex,        'bio/db/aaindex'
  autoload :AAindex1,       'bio/db/aaindex' # change to AAindex::AAindex1 ?
  autoload :AAindex2,       'bio/db/aaindex' # change to AAindex::AAindex2 ?
  autoload :TRANSFAC,       'bio/db/transfac'
  autoload :PROSITE,        'bio/db/prosite'
  autoload :LITDB,          'bio/db/litdb'
  autoload :MEDLINE,        'bio/db/medline'
  autoload :FANTOM,         'bio/db/fantom'
  autoload :GO,             'bio/db/go'
  autoload :PDB,            'bio/db/pdb'
  autoload :NBRF,           'bio/db/nbrf'
  autoload :REBASE,         'bio/db/rebase'
  autoload :SOFT,           'bio/db/soft'
  autoload :Lasergene,      'bio/db/lasergene'

  autoload :Newick,         'bio/db/newick'
  autoload :Nexus,          'bio/db/nexus'

  ### IO interface modules

  autoload :Registry,       'bio/io/registry'
  autoload :Fetch,          'bio/io/fetch'
  autoload :SQL,            'bio/io/sql'
  autoload :SOAPWSDL,       'bio/io/soapwsdl'
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

  autoload :Ensembl,        'bio/io/ensembl'
  autoload :Hinv,           'bio/io/hinv'

  ## below are described in bio/appl/blast.rb
  #class Blast
  #  autoload :Fastacmd,     'bio/io/fastacmd'
  #end

  class KEGG
    autoload :API,          'bio/io/keggapi'
  end

  ## below are described in bio/db/genbank/ddbj.rb
  #class DDBJ
  #  autoload :XML,          'bio/io/ddbjxml'
  #end

  class HGC
    autoload :HiGet,        'bio/io/higet'
  end

  class EBI
    autoload :SOAP,         'bio/io/ebisoap'
  end

  class NCBI
    autoload :SOAP,       'bio/io/ncbisoap'
  end


  ### Applications

  autoload :Fasta,          'bio/appl/fasta'
  ## below are described in bio/appl/fasta.rb
  #class Fasta
  #  autoload :Report,       'bio/appl/fasta/format10'
  #end

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
  ## below are described in bio/appl/hmmer.rb
  #class HMMER
  #  autoload :Report,       'bio/appl/hmmer/report'
  #end

  autoload :EMBOSS,         'bio/appl/emboss'    # use bio/command, improve

  autoload :PSORT,          'bio/appl/psort'
  ## below are described in bio/appl/psort.rb
  #class PSORT
  #  class PSORT1
  #    autoload :Report,       'bio/appl/psort/report'
  #  end
  #  class PSORT2
  #    autoload :Report,       'bio/appl/psort/report'
  #  end
  #end

  autoload :TMHMM,          'bio/appl/tmhmm/report'
  autoload :TargetP,        'bio/appl/targetp/report'
  autoload :SOSUI,          'bio/appl/sosui/report'
  autoload :Genscan,        'bio/appl/genscan/report'

  autoload :ClustalW,       'bio/appl/clustalw'
  ## below are described in bio/appl/clustalw.rb
  #class ClustalW
  #  autoload :Report,       'bio/appl/clustalw/report'
  #end

  autoload :MAFFT,          'bio/appl/mafft'
  ## below are described in bio/appl/mafft.rb
  #class MAFFT
  #  autoload :Report,       'bio/appl/mafft/report'
  #end

  autoload :Tcoffee,        'bio/appl/tcoffee'
  autoload :Muscle,         'bio/appl/muscle'
  autoload :Probcons,       'bio/appl/probcons'

  autoload :Sim4,           'bio/appl/sim4'
  ## below are described in bio/appl/sim4.rb
  #class Sim4
  #  autoload :Report,       'bio/appl/sim4/report'
  #end
  
  autoload :Spidey,         'bio/appl/spidey/report'
  autoload :Blat,           'bio/appl/blat/report'
  
  module GCG
    autoload :Msf,          'bio/appl/gcg/msf'
    autoload :Seq,          'bio/appl/gcg/seq'
  end

  module Phylip
    autoload :PhylipFormat,   'bio/appl/phylip/alignment'
    autoload :DistanceMatrix, 'bio/appl/phylip/distance_matrix'
  end

  autoload :Iprscan,        'bio/appl/iprscan/report'

  module PAML
    autoload :Codeml,         'bio/appl/paml/codeml'
    ## below are described in bio/appl/paml/codeml.rb
    #  # class Codeml
    #      autoload :Report,       'bio/appl/paml/codeml/report'
    #      autoload :Rates,        'bio/appl/paml/codeml/rates'
    #  # end
  end

  ### Utilities

  autoload :SiRNA,          'bio/util/sirna'
  autoload :ColorScheme,    'bio/util/color_scheme'
  autoload :ContingencyTable, 'bio/util/contingency_table'
  autoload :RestrictionEnzyme, 'bio/util/restriction_enzyme'

  ### Service libraries
  autoload :Command,        'bio/command'

  ### Provide BioRuby shell 'command' also as 'Bio.command' (like ChemRuby)

  def self.method_missing(*args)
    require 'bio/shell'
    extend Bio::Shell
    public_class_method(*Bio::Shell.private_instance_methods)
    if Bio.respond_to?(args.first)
      Bio.send(*args)
    else
      raise NameError
    end
  end

end

