#
# = bio/io/ddbjxml.rb - DDBJ SOAP server access class
#
# Copyright::	Copyright (C) 2003, 2004
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
# $Id: ddbjxml.rb,v 1.14 2007/04/05 23:35:41 trevor Exp $
#

require 'bio/io/soapwsdl'
require 'bio/db/genbank/ddbj'


module Bio
class DDBJ


# = Bio::DDBJ::XML
#
# Accessing the DDBJ web services.
#
# * http://xml.nig.ac.jp/
# * http://xml.nig.ac.jp/wsdl/index.jsp
#
class XML < Bio::SOAPWSDL

  BASE_URI = "http://xml.nig.ac.jp/wsdl/"

  # set default to GetEntry
  SERVER_URI = BASE_URI + "GetEntry.wsdl"

  def initialize(wsdl = nil)
    super(wsdl || self.class::SERVER_URI)
  end

  # === Description
  #
  # DDBJ XML BLAST Database Search 
  #
  # * http://xml.nig.ac.jp/doc/Blast.txt
  #
  # === Examples
  #
  #   serv = Bio::DDBJ::XML::Blast.new
  #   program = 'blastp'
  #   database = 'SWISS'
  #   query = "MSSRIARALALVVTLLHLTRLALSTCPAACHCPLEAPKCAPGVGLVRDGCGCCKVCAKQL"
  #   
  #   report = serv.searchSimple(program, database, query)
  #   Bio::Blast::Default::Report.new(report).each_hit do |hit|
  #     hit.hsps.find_all {|x| x.evalue < 0.1 }.each do |hsp|
  #       p [hsps.evalue, hsps.identity, hsps.definition]
  #     end
  #   end
  #  
  #   program = 'tblastn'
  #   database = 'ddbjvrl'
  #   param = '-m 8 -e 0.001'
  #   puts serv.searchParam(program, database, query, param)
  # 
  # === WSDL Methods
  # 
  # * searchSimple(program, database, query)
  #
  # Returns a blast report in the default format.
  #
  # * searchParam(program, database, query, param)
  #
  # Blasts with param and returns a blast report.
  #
  # === References
  #
  # * http://xml.nig.ac.jp/doc/Blast.txt
  #
  class Blast < XML
    SERVER_URI = BASE_URI + "Blast.wsdl"
  end


  # === ClustalW
  # 
  # Multiple seaquece alignment using ClustalW.
  #
  # * http://xml.nig.ac.jp/doc/ClustalW.txt
  #
  # === Examples
  #
  #   serv = Bio::DDBJ::XML::ClustalW.new
  #
  #   query = <<END
  #   > RABSTOUT   rabbit Guinness receptor
  #   LKMHLMGHLKMGLKMGLKGMHLMHLKHMHLMTYTYTTYRRWPLWMWLPDFGHAS
  #   ADSCVCAHGFAVCACFAHFDVCFGAVCFHAVCFAHVCFAAAVCFAVCAC
  #   > MUSNOSE   mouse nose drying factor
  #   mhkmmhkgmkhmhgmhmhglhmkmhlkmgkhmgkmkytytytryrwtqtqwtwyt
  #   fdgfdsgafdagfdgfsagdfavdfdvgavfsvfgvdfsvdgvagvfdv
  #   > HSHEAVEN    human Guinness receptor repeat
  #   mhkmmhkgmkhmhgmhmhg   lhmkmhlkmgkhmgkmk  ytytytryrwtqtqwtwyt
  #   fdgfdsgafdagfdgfsag   dfavdfdvgavfsvfgv  dfsvdgvagvfdv
  #   mhkmmhkgmkhmhgmhmhg   lhmkmhlkmgkhmgkmk  ytytytryrwtqtqwtwyt
  #   fdgfdsgafdagfdgfsag   dfavdfdvgavfsvfgv  dfsvdgvagvfdv
  #   END
  #
  #   puts serv.analyzeSimple(query)
  #   puts serv.analyzeParam(query, '-align -matrix=blosum')
  #
  # === WSDL Methods
  #
  # * analyzeSimple(query)
  # * analyzeParam(query, param)
  #
  # === References
  #
  # * http://xml.nig.ac.jp/doc/ClustalW.txt
  #
  class ClustalW < XML
    SERVER_URI = BASE_URI + "ClustalW.wsdl"
  end


  # == DDBJ
  #
  # Retrieves a sequence entry from the DDBJ DNA Data Bank Japan.
  #
  # * http://xml.nig.ac.jp/doc/DDBJ.txt
  #
  # === Examples
  #
  #   serv = Bio::DDBJ::XML::DDBJ.new
  #   puts serv.getFFEntry('AB000050')
  #   puts serv.getXMLEntry('AB000050')
  #   puts serv.getFeatureInfo('AB000050', 'cds')
  #   puts serv.getAllFeatures('AB000050')
  #   puts serv.getRelatedFeatures('AL121903', '59000', '64000')
  #   puts serv.getRelatedFeaturesSeq('AL121903', '59000', '64000')
  #
  # === WSDL Methods 
  #
  # * getFFEntry(accession)
  # * getXMLEntry(accession)
  # * getFeatureInfo(accession, feature)
  # * getAllFeatures(accession)
  # * getRelatedFeatures(accession, start, stop)
  # * getRelatedFeaturesSeq(accession, start, stop)
  #
  # === References
  #
  # * http://xml.nig.ac.jp/doc/DDBJ.txt
  #
  class DDBJ < XML
    SERVER_URI = BASE_URI + "DDBJ.wsdl"
  end


  # == Fasta
  # 
  # Searching database using the Fasta package.
  #
  # * http://xml.nig.ac.jp/doc/Fasta.txt
  # 
  # === Examples
  #
  #   serv = Bio::DDBJ::XML::Fasta.new
  #   query = ">Test\nMSDGAVQPDG GQPAVRNERA TGSGNGSGGG GGGGSGGVGI"
  #    
  #   puts serv.searchSimple('fasta34', 'PDB', query)
  #   query = ">Test\nAGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTCTGATAGCAGC"
  #   puts serv.searchParam('fastx34_t', 'PDB', query, '-n')
  #
  # === WSDL Methods
  #
  # * searchSimple(program, database, query)
  # * searchParam(program, database, query, param)
  #
  # === References
  #
  # * http://xml.nig.ac.jp/doc/Fasta.txt
  #
  class Fasta < XML
    SERVER_URI = BASE_URI + "Fasta.wsdl"
  end


  # == GetEntry
  #
  # Retrieves database entries.
  #
  # * http://xml.nig.ac.jp/doc/GetEntry.txt
  #
  # === Examples
  #
  #  serv = Bio::DDBJ::XML::GetEntry.new
  #  puts serv.getDDBJEntry('AB000050')
  #  puts serv. getPDBEntry('1AAR')
  #
  # === WSDL Methods
  #
  # * getEntry(database, var, param1, param2)
  # * getEntry(database, var)
  # * getDDBJEntry(accession)
  # * getDDBJCONEntry(accession)
  # * getDDBJVerEntry(accession)
  # * getLocus_DDBJEntry(locus)
  # * getGene_DDBJEntry(gene)
  # * getProd_DDBJEntry(products)
  # * getPID_DDBJEntry(pid)
  # * getClone_DDBJEntry(clone)
  # * getXML_DDBJEntry(accession)
  # * getEMBLEntry(accession)
  # * getSWISSEntry(accession)
  # * getPIREntry(accession)
  # * getPRFEntry(accession)
  # * getPDBEntry(accession)
  # * getQVEntry(accession)
  # * getDADEntry(accession)
  # * getPID_DADEntry(pid)
  # * getFASTA_DDBJEntry(accession)
  # * getFASTA_DDBJCONEntry(accession)
  # * getFASTA_DDBJVerEntry(accession)
  # * getFASTA_DDBJSeqEntry(accession, start, end)
  # * getFASTA_DADEntry(accession)
  # * getFASTA_PIREntry(accession)
  # * getFASTA_SWISSEntry(accession)
  # * getFASTA_PDBEntry(accession)
  # * getFASTA_PRFEntry(accession)
  # * getFASTA_CDSEntry(accession)
  #
  # === References
  #
  # * http://xml.nig.ac.jp/doc/GetEntry.txt
  #
  class GetEntry < XML
    SERVER_URI = BASE_URI + "GetEntry.wsdl"
  end


  # === Gib
  # 
  # Genome Information broker
  #
  # * http://xml.nig.ac.jp/doc/Gib.txt
  #
  # === Examples
  #
  #   serv = Bio::DDBJ::XML::Gib.new
  #   puts serv.getOrganismList
  #   puts serv.getChIDList
  #   puts serv.getOrganismNameFromChid('Sent_CT18:')
  #   puts serv.getChIDFromOrganismName('Aquifex aeolicus VF5')
  #   puts serv.getAccession('Ecol_K12_MG1655:')
  #   puts serv.getPieceNumber('Mgen_G37:')
  #   puts serv.getDivision('Mgen_G37:')
  #   puts serv.getType('Mgen_G37:')
  #   puts serv.getCDS('Aaeo_VF5:ece1')
  #   puts serv.getFlatFile('Nost_PCC7120:pCC7120zeta')
  #   puts serv.getFastaFile('Nost_PCC7120:pCC7120zeta', 'cdsaa')
  #
  # === WSDL Methods
  #
  # * getOrganismList
  # * getChIDList
  # * getOrganismNameFromChid(chid)
  # * getChIDFromOrganismName(orgName)
  # * getAccession(chid)
  # * getPieceNumber(chid)
  # * getDivision(chid)
  # * getType(chid)
  # * getFlatFile(chid)
  # * getFastaFile(chid, type)
  # * getCDS(chid)
  #
  # === References
  #
  # * http://xml.nig.ac.jp/doc/Gib.txt
  #
  class Gib < XML
    SERVER_URI = BASE_URI + "Gib.wsdl"
  end

  
  # === Gtop
  #
  # GTOP: Gene to protein.
  #
  # * http://xml.nig.ac.jp/doc/Gtop.txt
  #
  # === Examples
  #
  #   serv = Bio::DDBJ::XML::Gtop.new
  #   puts serv.getOrganismList
  #   puts serv.getMasterInfo('thrA', 'ecol0')
  #
  # === WSDL Methods
  #
  # * getOrganismList
  # * getMasterInfo(orfID, organism)
  #
  # === References
  #
  # * http://xml.nig.ac.jp/doc/Gtop.txt
  #
  class Gtop < XML
    SERVER_URI = BASE_URI + "Gtop.wsdl"
  end


  # === PML
  #
  # Variation database
  #
  # * http://xml.nig.ac.jp/doc/PML.txt
  # 
  # === Examples
  #
  #   serv = Bio::DDBJ::XML::PML.new
  #   puts serv.getVariation('1')
  #
  # === WSDL Methods
  #
  # * searchVariation(field, query, order)
  # * searchVariationSimple(field, query)
  # * searchFrequency(field, query, order)
  # * searchFrequencySimple(field, query)
  # * getVariation(variation_id)
  # * getFrequency(variation_id, population_id)
  #
  # === References
  #
  # * http://xml.nig.ac.jp/doc/PML.txt
  #
  class PML < XML
    SERVER_URI = BASE_URI + "PML.wsdl"
  end


  # === SRS
  #
  # Sequence Retrieving System
  # 
  # * http://xml.nig.ac.jp/doc/SRS.txt
  # 
  # === Examples
  #
  #   serv = Bio::DDBJ::XML::SRS.new
  #   puts serv.searchSimple('[pathway-des:sugar]')
  #   puts serv.searchParam('[swissprot-des:cohesin]', '-f seq -sf fasta')
  #
  # === WSDL Methods
  #
  # * searchSimple(query)
  # * searchParam(query, param)
  #
  # === Examples
  #
  # * http://xml.nig.ac.jp/doc/SRS.txt
  #
  class SRS < XML
    SERVER_URI = BASE_URI + "SRS.wsdl"
  end
  

  # === TxSearch
  #
  # Searching taxonomy information.
  # 
  # * http://xml.nig.ac.jp/doc/TxSearch.txt
  #
  # === Examples
  #
  #   serv = Bio::DDBJ::XML::TxSearch.new
  #   puts serv.searchSimple('*coli')
  #   puts serv.searchSimple('*tardigrada*')
  #   puts serv.getTxId('Escherichia coli')
  #   puts serv.getTxName('562')
  #
  #   query = ["Campylobacter coli", "Escherichia coli"].join("\n")
  #   rank = ["family", "genus"].join("\n")
  #   puts serv.searchLineage(query, rank, 'Bacteria')
  #
  # === WSDL Methdos
  #
  # * searchSimple(tx_Name)
  # * searchParam(tx_Name, tx_Clas, tx_Rank, tx_Rmax, tx_Dcls)
  # * getTxId(tx_Name)
  # * getTxName(tx_Id)
  # * searchLineage(query, ranks, superkingdom)
  # 
  # === References
  #
  # * http://xml.nig.ac.jp/doc/TxSearch.txt
  #
  class TxSearch < XML
    SERVER_URI = BASE_URI + "TxSearch.wsdl"
  end

end # XML

end # DDBJ
end # Bio



if __FILE__ == $0

  begin
    require 'pp'
    alias p pp
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

