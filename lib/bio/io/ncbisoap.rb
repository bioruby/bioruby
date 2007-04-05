#
# = bio/io/ncbisoap.rb - SOAP interface for NCBI Entrez Utilities
#
# Copyright::   Copyright (C) 2004, 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: ncbisoap.rb,v 1.3 2007/04/05 23:35:41 trevor Exp $
#

require 'bio/io/soapwsdl'

module Bio
class NCBI

# == References
#
# * http://eutils.ncbi.nlm.nih.gov/entrez/query/static/esoap_help.html
#
# == Methods
#
# All methods accept a hash as its argument and most of the keys can be
# ommited (values are string).
#
# Note: Methods which name ends with _MS are designed for use with
# Microsoft Visual Studio and SOAP Toolkit 3.0
#
# * http://www.ncbi.nlm.nih.gov/entrez/query/static/esoap_ms_help.html
#
# * run_eFetch(_MS)
#   * "db", "id", "WebEnv", "query_key", "tool", "email", "retstart",
#     "retmax", "rettype", "strand", "seq_start", "seq_stop", "complexity",
#     "report" 
#
# * run_eGquery(_MS)
#   * "term", "tool", "email"
#
# * run_eInfo(_MS)
#   * "db", "tool", "email"
#
# * run_eSpell(_MS)
#   * "db", "term", "tool", "email"
#
# * run_eLink(_MS)
#   * "db", "id", "reldate", "mindate", "maxdate", "datetype", "term"
#     "dbfrom", "WebEnv", "query_key", "cmd", "tool", "email"
#
# * run_eSearch(_MS)
#   * "db", "term", "WebEnv", "QueryKey", "usehistory", "tool", "email",
#     "field", "reldate", "mindate", "maxdate", "datetype", "RetStart",
#     "RetMax", "rettype", "sort"
#
# * run_eSummary(_MS)
#   * "db", "id", "WebEnv", "query_key", "retstart", "retmax", "tool", "email"
#
# == Complex data types
#
# * http://www.ncbi.nlm.nih.gov/entrez/eutils/soap/egquery.xsd
# * http://www.ncbi.nlm.nih.gov/entrez/eutils/soap/einfo.xsd
# * http://www.ncbi.nlm.nih.gov/entrez/eutils/soap/esearch.xsd
# * http://www.ncbi.nlm.nih.gov/entrez/eutils/soap/esummary.xsd
# * http://www.ncbi.nlm.nih.gov/entrez/eutils/soap/elink.xsd
# * http://www.ncbi.nlm.nih.gov/entrez/eutils/soap/efetch.xsd
# * http://www.ncbi.nlm.nih.gov/entrez/eutils/soap/espell.xsd
#
class SOAP < Bio::SOAPWSDL

  BASE_URI = "http://www.ncbi.nlm.nih.gov/entrez/eutils/soap/"

  # set default to EUtils
  SERVER_URI = BASE_URI + "eutils.wsdl"

  def initialize(wsdl = nil)
    super(wsdl || self.class::SERVER_URI)
  end

  def method_missing(*arg)
    sleep 3			# make sure to rest for 3 seconds per request
    @driver.send(*arg)
  end

  class EUtils < Bio::NCBI::SOAP
    SERVER_URI = BASE_URI + "eutils.wsdl"
  end

  class EUtilsLite < Bio::NCBI::SOAP
    SERVER_URI = BASE_URI + "eutils_lite.wsdl"
  end

  class EFetch < Bio::NCBI::SOAP
    SERVER_URI = BASE_URI + "efetch.wsdl"
  end

  class EFetchLite < Bio::NCBI::SOAP
    SERVER_URI = BASE_URI + "efetch_lit.wsdl"
  end

end # SOAP
end # NCBI
end # Bio


if __FILE__ == $0

  puts ">>> Bio::NCBI::SOAP::EFetch"
  efetch = Bio::NCBI::SOAP::EFetch.new

  puts "### run_eFetch in EFetch"
  hash = {"db" => "protein", "id" => "37776955"}
  result = efetch.run_eFetch(hash)
  p result

  puts ">>> Bio::NCBI::SOAP::EUtils"
  eutils = Bio::NCBI::SOAP::EUtils.new

  puts "### run_eFetch in EUtils"
  hash = {"db" => "pubmed", "id" => "12345"}
  result = eutils.run_eFetch(hash)
  p result

  puts "### run_eGquery - Entrez meta search to count hits in each DB"
  hash = {"term" => "kinase"}
  result = eutils.run_eGquery(hash)      # working?
  p result

  puts "### run_eInfo - listing of the databases"
  hash = {"db" => "protein"}
  result = eutils.run_eInfo(hash)
  p result

  puts "### run_eSpell"
  hash = {"db" => "pubmed", "term" => "kinas"}
  result = eutils.run_eSpell(hash)
  p result
  p result["CorrectedQuery"]
  
  puts "### run_eLink"
  hash = {"db" => "protein", "id" => "37776955"}
  result = eutils.run_eLink(hash)        #  working?
  p result

  puts "### run_eSearch"
  hash = {"db" => "pubmed", "term" => "kinase"}
  result = eutils.run_eSearch(hash)
  p result

  puts "### run_eSummary"
  hash = {"db" => "protein", "id" => "37776955"}
  result = eutils.run_eSummary(hash)
  p result

end



