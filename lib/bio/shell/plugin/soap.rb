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

end

