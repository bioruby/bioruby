#
# = bio/shell/plugin/soap.rb - web services
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: soap.rb,v 1.1 2007/07/09 11:17:09 k Exp $
#

module Bio::Shell

  private

  def ncbisoap(wsdl = nil)
    if wsdl
      @ncbisoap = Bio::NCBI::SOAP.new(wsdl)
    else
      @ncbisoap ||= Bio::NCBI::SOAP.new
    end
    return @ncbisoap
  end

  def ebisoap(wsdl = nil)
    case wsdl
    when :ipscan
      @ebisoap = Bio::EBI::SOAP::InterProScan.new(wsdl)
    when :emboss
      @ebisoap = Bio::EBI::SOAP::Emboss.new(wsdl)
    when :clustalw
      @ebisoap = Bio::EBI::SOAP::ClustalW.new(wsdl)
    when :tcoffee
      @ebisoap = Bio::EBI::SOAP::TCoffee.new(wsdl)
    when :muscle
      @ebisoap = Bio::EBI::SOAP::Muscle.new(wsdl)
    when :fasta
      @ebisoap = Bio::EBI::SOAP::Fasta.new(wsdl)
    when :wublast
      @ebisoap = Bio::EBI::SOAP::WUBlast.new(wsdl)
    when :mpsrch
      @ebisoap = Bio::EBI::SOAP::MPsrch.new(wsdl)
    when :scanps
      @ebisoap = Bio::EBI::SOAP::ScanPS.new(wsdl)
    when :msd
      @ebisoap = Bio::EBI::SOAP::MSD.new(wsdl)
    when :ontology
      @ebisoap = Bio::EBI::SOAP::Ontology.new(wsdl)
    when :citation
      @ebisoap = Bio::EBI::SOAP::Citation.new(wsdl)
    when /^http/
      @ebisoap = Bio::EBI::SOAP.new(wsdl)
    else
      @ebisoap ||= Bio::EBI::SOAP.new
    end
    return @ebisoap
  end

  def ddbjsoap(wsdl = nil)
    case wsdl
    when :blast
      @ddbjsoap = Bio::DDBJ::XML::Blast.new
    when :fasta
      @ddbjsoap = Bio::DDBJ::XML::Fasta.new
    when :clustalw
      @ddbjsoap = Bio::DDBJ::XML::ClustalW.new
    when :ddbj
      @ddbjsoap = Bio::DDBJ::XML::DDBJ.new
    when :gib
      @ddbjsoap = Bio::DDBJ::XML::Gib.new
    when :gtop
      @ddbjsoap = Bio::DDBJ::XML::Gtop.new
    when :pml
      @ddbjsoap = Bio::DDBJ::XML::PML.new
    when :srs
      @ddbjsoap = Bio::DDBJ::XML::SRS.new
    when :txsearch
      @ddbjsoap = Bio::DDBJ::XML::TxSearch.new
    when /^http/
      @ddbjsoap = Bio::DDBJ::XML.new(wsdl)
    else
      @ddbjsoap ||= Bio::DDBJ::XML.new
    end
    return @ddbjsoap
  end

end

