#
# bio/io/ddbjxml.rb - DDBJ SOAP server access class
#
#   Copyright (C) 2003, 2004 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: ddbjxml.rb,v 1.5 2004/06/23 14:35:26 k Exp $
#

require 'bio/io/soapwsdl'
require 'bio/db/genbank/ddbj'


module Bio
class DDBJ

class XML < Bio::SOAPWSDL

  BASE_URI = "http://xml.nig.ac.jp/wsdl/"

  class Blast < XML
    SERVER_URI = BASE_URI + "Blast.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end

  class ClustalW < XML
    SERVER_URI = BASE_URI + "ClustalW.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end
  
  class DDBJ < XML
    SERVER_URI = BASE_URI + "DDBJ.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end
  
  class Fasta < XML
    SERVER_URI = BASE_URI + "Fasta.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end
  
  class GetEntry < XML
    SERVER_URI = BASE_URI + "GetEntry.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end
  
  class Gib < XML
    SERVER_URI = BASE_URI + "Gib.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end

  class Gtop < XML
    SERVER_URI = BASE_URI + "Gtop.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end

  class PML < XML
    SERVER_URI = BASE_URI + "PML.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end

  class SRS < XML
    SERVER_URI = BASE_URI + "SRS.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end
  
  class TxSearch < XML
    SERVER_URI = BASE_URI + "TxSearch.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end

end # XML

end # DDBJ
end # Bio



if __FILE__ == $0

  begin
    require 'pp'
    alias :p :pp
  rescue LoadError
  end

  puts ">>> Bio::DDBJ::XML::Blast"
  serv = Bio::DDBJ::XML::Blast.new
# serv.log = STDERR

  query = "MSSRIARALALVVTLLHLTRLALSTCPAACHCPLEAPKCAPGVGLVRDGCGCCKVCAKQL"

  puts "### searchSimple('blastp', 'SWISS', query)"
  puts serv.searchSimple('blastp', 'SWISS', query)

  puts "### searchParam('tblastn', 'ddbjvrl', query, '-m 8')"
  puts serv.searchParam('tblastn', 'ddbjvrl', query, '-m 8')


  puts ">>> Bio::DDBJ::XML::ClustalW"
  serv = Bio::DDBJ::XML::ClustalW.new

  query = <<END
> RABSTOUT   rabbit Guinness receptor
   LKMHLMGHLKMGLKMGLKGMHLMHLKHMHLMTYTYTTYRRWPLWMWLPDFGHAS
   ADSCVCAHGFAVCACFAHFDVCFGAVCFHAVCFAHVCFAAAVCFAVCAC
> MUSNOSE   mouse nose drying factor
    mhkmmhkgmkhmhgmhmhglhmkmhlkmgkhmgkmkytytytryrwtqtqwtwyt
    fdgfdsgafdagfdgfsagdfavdfdvgavfsvfgvdfsvdgvagvfdv
> HSHEAVEN    human Guinness receptor repeat
 mhkmmhkgmkhmhgmhmhg   lhmkmhlkmgkhmgkmk  ytytytryrwtqtqwtwyt
 fdgfdsgafdagfdgfsag   dfavdfdvgavfsvfgv  dfsvdgvagvfdv
 mhkmmhkgmkhmhgmhmhg   lhmkmhlkmgkhmgkmk  ytytytryrwtqtqwtwyt
 fdgfdsgafdagfdgfsag   dfavdfdvgavfsvfgv  dfsvdgvagvfdv
END

  puts "### analyzeSimple(query)"
  puts serv.analyzeSimple(query)

  puts "### analyzeParam(query, '-align -matrix=blosum')"
  puts serv.analyzeParam(query, '-align -matrix=blosum')


  puts ">>> Bio::DDBJ::XML::DDBJ"
  serv = Bio::DDBJ::XML::DDBJ.new

  puts "### getFFEntry('AB000050')"
  puts serv.getFFEntry('AB000050')

  puts "### getXMLEntry('AB000050')"
  puts serv.getXMLEntry('AB000050')

  puts "### getFeatureInfo('AB000050', 'cds')"
  puts serv.getFeatureInfo('AB000050', 'cds')

  puts "### getAllFeatures('AB000050')"
  puts serv.getAllFeatures('AB000050')

  puts "### getRelatedFeatures('AL121903', '59000', '64000')"
  puts serv.getRelatedFeatures('AL121903', '59000', '64000')

  puts "### getRelatedFeaturesSeq('AL121903', '59000', '64000')"
  puts serv.getRelatedFeaturesSeq('AL121903', '59000', '64000')


  puts ">>> Bio::DDBJ::XML::Fasta"
  serv = Bio::DDBJ::XML::Fasta.new

  query = ">Test\nMSDGAVQPDG GQPAVRNERA TGSGNGSGGG GGGGSGGVGI"

  puts "### searchSimple('fasta34', 'PDB', query)"
  puts serv.searchSimple('fasta34', 'PDB', query)

  query = ">Test\nAGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTCTGATAGCAGC"

  puts "### searchParam('fastx34_t', 'PDB', query, '-n')"
  puts serv.searchParam('fastx34_t', 'PDB', query, '-n')


  puts ">>> Bio::DDBJ::XML::GetEntry"
  serv = Bio::DDBJ::XML::GetEntry.new

  puts "### getDDBJEntry('AB000050')"
  puts serv.getDDBJEntry('AB000050')

  puts "### getPDBEntry('1AAR')"
  puts serv. getPDBEntry('1AAR')


  puts ">>> Bio::DDBJ::XML::Gib"
  serv = Bio::DDBJ::XML::Gib.new

  puts "### getOrganismList"
  puts serv.getOrganismList

  puts "### getChIDList"
  puts serv.getChIDList

  puts "### getOrganismNameFromChid('Sent_CT18:')"
  puts serv.getOrganismNameFromChid('Sent_CT18:')

  puts "### getChIDFromOrganismName('Aquifex aeolicus VF5')"
  puts serv.getChIDFromOrganismName('Aquifex aeolicus VF5')

  puts "### getAccession('Ecol_K12_MG1655:')"
  puts serv.getAccession('Ecol_K12_MG1655:')

  puts "### getPieceNumber('Mgen_G37:')"
  puts serv.getPieceNumber('Mgen_G37:')

  puts "### getDivision('Mgen_G37:')"
  puts serv.getDivision('Mgen_G37:')

  puts "### getType('Mgen_G37:')"
  puts serv.getType('Mgen_G37:')

  puts "### getCDS('Aaeo_VF5:ece1')"
  puts serv.getCDS('Aaeo_VF5:ece1')

  puts "### getFlatFile('Nost_PCC7120:pCC7120zeta')"
  puts serv.getFlatFile('Nost_PCC7120:pCC7120zeta')

  puts "### getFastaFile('Nost_PCC7120:pCC7120zeta')"
  puts serv.getFastaFile('Nost_PCC7120:pCC7120zeta', 'cdsaa')


  puts ">>> Bio::DDBJ::XML::Gtop"
  serv = Bio::DDBJ::XML::Gtop.new

  puts "### getOrganismList"
  puts serv.getOrganismList

  puts "### getMasterInfo"
  puts serv.getMasterInfo('thrA', 'ecol0')


#  puts ">>> Bio::DDBJ::XML::PML"
#  serv = Bio::DDBJ::XML::PML.new
#
#  puts "### getVariation('1')"
#  puts serv.getVariation('1')


  puts ">>> Bio::DDBJ::XML::SRS"
  serv = Bio::DDBJ::XML::SRS.new

  puts "### searchSimple('[pathway-des:sugar]')"
  puts serv.searchSimple('[pathway-des:sugar]')

  puts "### searchParam('[swissprot-des:cohesin]', '-f seq -sf fasta')"
  puts serv.searchParam('[swissprot-des:cohesin]', '-f seq -sf fasta')


  puts ">>> Bio::DDBJ::XML::TxSearch"
  serv = Bio::DDBJ::XML::TxSearch.new

  puts "### searchSimple('*coli')"
  puts serv.searchSimple('*coli')

  puts "### searchSimple('*tardigrada*')"
  puts serv.searchSimple('*tardigrada*')

  puts "### getTxId('Escherichia coli')"
  puts serv.getTxId('Escherichia coli')

  puts "### getTxName('562')"
  puts serv.getTxName('562')

  query = "Campylobacter coli\nEscherichia coli"
  rank = "family\ngenus"

  puts "### searchLineage(query, rank, 'Bacteria')"
  puts serv.searchLineage(query, rank, 'Bacteria')

end



=begin

= Bio::DDBJ::XML

Accessing the DDBJ web services at

  * ((<URL:http://xml.nig.ac.jp/>))
  * ((<URL:http://xml.nig.ac.jp/wsdl/index.jsp>))

== Blast

  * ((<URL:http://xml.nig.ac.jp/doc/Blast.txt>))

--- searchSimple(program, database, query)
--- searchParam(program, database, query, param)

== ClustalW

  * ((<URL:http://xml.nig.ac.jp/doc/ClustalW.txt>))

--- analyzeSimple(query)
--- analyzeParam(query, param)

== DDBJ

  * ((<URL:http://xml.nig.ac.jp/doc/DDBJ.txt>))

--- getFFEntry(accession)
--- getXMLEntry(accession)
--- getFeatureInfo(accession, feature)
--- getAllFeatures(accession)
--- getRelatedFeatures(accession, start, stop)
--- getRelatedFeaturesSeq(accession, start, stop)

== Fasta

  * ((<URL:http://xml.nig.ac.jp/doc/Fasta.txt>))

--- searchSimple(program, database, query)
--- searchParam(program, database, query, param)

== GetEntry

  * ((<URL:http://xml.nig.ac.jp/doc/GetEntry.txt>))

--- getEntry(database, var, param1, param2)
--- getEntry(database, var)
--- getDDBJEntry(accession)
--- getDDBJCONEntry(accession)
--- getDDBJVerEntry(accession)
--- getLocus_DDBJEntry(locus)
--- getGene_DDBJEntry(gene)
--- getProd_DDBJEntry(products)
--- getPID_DDBJEntry(pid)
--- getClone_DDBJEntry(clone)
--- getXML_DDBJEntry(accession)
--- getEMBLEntry(accession)
--- getSWISSEntry(accession)
--- getPIREntry(accession)
--- getPRFEntry(accession)
--- getPDBEntry(accession)
--- getQVEntry(accession)
--- getDADEntry(accession)
--- getPID_DADEntry(pid)
--- getFASTA_DDBJEntry(accession)
--- getFASTA_DDBJCONEntry(accession)
--- getFASTA_DDBJVerEntry(accession)
--- getFASTA_DDBJSeqEntry(accession, start, end)
--- getFASTA_DADEntry(accession)
--- getFASTA_PIREntry(accession)
--- getFASTA_SWISSEntry(accession)
--- getFASTA_PDBEntry(accession)
--- getFASTA_PRFEntry(accession)
--- getFASTA_CDSEntry(accession)

== Gib

  * ((<URL:http://xml.nig.ac.jp/doc/Gib.txt>))

--- getOrganismList
--- getChIDList
--- getOrganismNameFromChid(chid)
--- getChIDFromOrganismName(orgName)
--- getAccession(chid)
--- getPieceNumber(chid)
--- getDivision(chid)
--- getType(chid)
--- getFlatFile(chid)
--- getFastaFile(chid, type)
--- getCDS(chid)

== Gtop

  * ((<URL:http://xml.nig.ac.jp/doc/Gtop.txt>))

--- getOrganismList
--- getMasterInfo(orfID, organism)

== PML

  * ((<URL:http://xml.nig.ac.jp/doc/PML.txt>))

--- searchVariation(field, query, order)
--- searchVariationSimple(field, query)
--- searchFrequency(field, query, order)
--- searchFrequencySimple(field, query)
--- getVariation(variation_id)
--- getFrequency(variation_id, population_id)

== SRS

  * ((<URL:http://xml.nig.ac.jp/doc/SRS.txt>))

--- searchSimple(query)
--- searchParam(query, param)

== TxSearch

  * ((<URL:http://xml.nig.ac.jp/doc/TxSearch.txt>))

--- searchSimple(tx_Name)
--- searchParam(tx_Name, tx_Clas, tx_Rank, tx_Rmax, tx_Dcls)
--- getTxId(tx_Name)
--- getTxName(tx_Id)
--- searchLineage(query, ranks, superkingdom)

=end


