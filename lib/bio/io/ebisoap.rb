#
# = bio/io/emblsoap.rb - EBI SOAP server access class
#
# Copyright::  Copyright (C) 2006
#              Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: ebisoap.rb,v 1.3 2007/04/05 23:35:41 trevor Exp $
#

require 'bio/io/soapwsdl'

module Bio
class EBI

class SOAP < Bio::SOAPWSDL

  BASE_URI = "http://www.ebi.ac.uk/Tools/webservices/wsdl/"

  # set default to Dbfetch
  SERVER_URI = BASE_URI + "WSDbfetch.wsdl"

  def initialize(wsdl = nil)
    super(wsdl || self.class::SERVER_URI)
  end

  # * fetchData
  # * getSupportedDBs
  # * getSupportedFormats
  # * getSupportedStyles
  class Dbfetch < Bio::EBI::SOAP
    SERVER_URI = BASE_URI + "WSDbfetch.wsdl"
  end

  # * checkStatus
  # * doIprscan
  # * getResults
  # * poll
  # * polljob
  # * runInterProScan
  # * test
  class InterProScan < Bio::EBI::SOAP
    SERVER_URI = BASE_URI + "WSInterProScan.wsdl"
  end

  # * checkStatus
  # * getInfo
  # * getResults
  # * getTools
  # * poll
  # * run
  # * test
  class Emboss < Bio::EBI::SOAP
    SERVER_URI = BASE_URI + "WSEmboss.wsdl"
  end

  # * checkStatus
  # * getResults
  # * poll
  # * runClustalW
  # * test
  class ClustalW < Bio::EBI::SOAP
    SERVER_URI = BASE_URI + "WSClustalW.wsdl"
  end

  # * checkStatus
  # * getResults
  # * poll
  # * runTCoffee
  class TCoffee < Bio::EBI::SOAP
    SERVER_URI = BASE_URI + "WSTCoffee.wsdl"
  end

  # * checkStatus
  # * getResults
  # * poll
  # * runMuscle
  # * test
  class Muscle < Bio::EBI::SOAP
    SERVER_URI = BASE_URI + "WSMuscle.wsdl"
  end

  # * checkStatus
  # * doFasta
  # * getResults
  # * poll
  # * polljob
  # * runFasta
  class Fasta < Bio::EBI::SOAP
    SERVER_URI = BASE_URI + "WSFasta.wsdl"
  end

  # * checkStatus
  # * doWUBlast
  # * getIds
  # * getResults
  # * poll
  # * polljob
  # * runWUBlast
  # * test
  class WUBlast < Bio::EBI::SOAP
    SERVER_URI = BASE_URI + "WSWUBlast.wsdl"
  end

  # * checkStatus
  # * getResults
  # * poll
  # * runMPsrch
  # * test
  class MPsrch < Bio::EBI::SOAP
    SERVER_URI = BASE_URI + "WSMPsrch.wsdl"
  end

  # * checkStatus
  # * getResults
  # * poll
  # * runScanPS
  # * test
  class ScanPS < Bio::EBI::SOAP
    SERVER_URI = BASE_URI + "WSScanPS.wsdl"
  end

  class MSD < Bio::EBI::SOAP
    SERVER_URI = "http://www.ebi.ac.uk/msd-srv/docs/api/msd_soap_service.wsdl"
  end

  class Ontology < Bio::EBI::SOAP
    SERVER_URI = "http://www.ebi.ac.uk/ontology-lookup/OntologyQuery.wsdl"
  end

  class Citation < Bio::EBI::SOAP
    SERVER_URI = "http://www.ebi.ac.uk/citations/webservices/wsdl"
  end

end # SOAP

end # EBI
end # Bio



if __FILE__ == $0
  serv = Bio::EBI::SOAP::Dbfetch.new
  p serv.getSupportedDBs

  require 'base64'

  serv = Bio::EBI::SOAP::Emboss.new
  hash = {"tool" => "water",
          "asequence" => "uniprot:alk1_human",
          "bsequence" => "uniprot:alk1_mouse",
          "email" => "ebisoap@example.org"}
  poll = serv.run(hash, [])
  puts poll
  base = serv.poll(poll, "tooloutput")
  puts Base64.decode64(base)  
end

