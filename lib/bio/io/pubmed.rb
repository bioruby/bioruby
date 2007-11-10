#
# = bio/io/pubmed.rb - NCBI Entrez/PubMed client module
#
# Copyright::  Copyright (C) 2001 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2006 Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::    The Ruby License
#
# $Id: pubmed.rb,v 1.18 2007/11/10 08:21:54 k Exp $
#

require 'net/http'
require 'cgi' unless defined?(CGI)
require 'bio/command'

module Bio

# == Description
#
# The Bio::PubMed class provides several ways to retrieve bibliographic
# information from the PubMed database at
#   http://www.ncbi.nlm.nih.gov/sites/entrez?db=PubMed
#
# Basically, two types of queries are possible:
#
# * searching for PubMed IDs given a query string:
#   * Bio::PubMed#esearch  (recommended)
#   * Bio::PubMed#search   (only retrieves top 20 hits)
#
# * retrieving the MEDLINE text (i.e. authors, journal, abstract, ...)
#   given a PubMed ID
#   * Bio::PubMed#efetch   (recommended)
#   * Bio::PubMed#query    (unstable for the change of the HTML design)
#   * Bio::PubMed#pmfetch  (still working but could be obsoleted by NCBI)
#
# The different methods within the same group are interchangeable and should
# return the same result.
# 
# Additional information about the MEDLINE format and PubMed programmable
# APIs can be found on the following websites:
#
# * PubMed Overview:
#     http://www.ncbi.nlm.nih.gov/entrez/query/static/overview.html
# * PubMed help:
#     http://www.ncbi.nlm.nih.gov/entrez/query/static/help/pmhelp.html
# * Entrez utilities index:
#      http://www.ncbi.nlm.nih.gov/entrez/utils/utils_index.html
# * How to link:
#     http://www.ncbi.nlm.nih.gov/books/bv.fcgi?rid=helplinks.chapter.linkshelp
#
# == Usage
#
#   require 'bio'
#
#   # If you don't know the pubmed ID:
#   Bio::PubMed.esearch("(genome AND analysis) OR bioinformatics)").each do |x|
#     p x
#   end
#
#   Bio::PubMed.search("(genome AND analysis) OR bioinformatics)").each do |x|
#     p x
#   end
#   
#   # To retrieve the MEDLINE entry for a given PubMed ID:
#   puts Bio::PubMed.efetch("10592173", "14693808")
#   puts Bio::PubMed.query("10592173")
#   puts Bio::PubMed.pmfetch("10592173")
#
#   # This can be converted into a Bio::MEDLINE object:
#   manuscript = Bio::PubMed.query("10592173")
#   medline = Bio::MEDLINE.new(manuscript)
#  
class PubMed

  # Search the PubMed database by given keywords using E-Utils and returns 
  # an array of PubMed IDs.
  # 
  # For information on the possible arguments, see
  # http://eutils.ncbi.nlm.nih.gov/entrez/query/static/esearch_help.html#PubMed
  # ---
  # *Arguments*:
  # * _id_: query string (required)
  # * _field_
  # * _reldate_
  # * _mindate_
  # * _maxdate_
  # * _datetype_
  # * _retstart_
  # * _retmax_ (default 100)
  # * _retmode_
  # * _rettype_
  # *Returns*:: array of PubMed IDs or a number of results
  def self.esearch(str, hash = {})
    hash['retmax'] = 100 unless hash['retmax']

    opts = []
    hash.each do |k, v|
      opts << "#{k}=#{v}"
    end

    host = "eutils.ncbi.nlm.nih.gov"
    path = "/entrez/eutils/esearch.fcgi?tool=bioruby&db=pubmed&#{opts.join('&')}&term="

    http = Bio::Command.new_http(host)
    response, = http.get(path + CGI.escape(str))
    result = response.body
    if hash['rettype'] == 'count'
      result = result.scan(/<Count>(.*?)<\/Count>/m).flatten.first.to_i
    else
      result = result.scan(/<Id>(.*?)<\/Id>/m).flatten
    end
    return result
  end

  # Retrieve PubMed entry by PMID and returns MEDLINE formatted string using
  # entrez efetch. Multiple PubMed IDs can be provided:
  #   Bio::PubMed.efetch(123)
  #   Bio::PubMed.efetch(123,456,789)
  #   Bio::PubMed.efetch([123,456,789])
  # ---
  # *Arguments*:
  # * _ids_: list of PubMed IDs (required)
  # *Returns*:: MEDLINE formatted String
  def self.efetch(*ids)
    return [] if ids.empty?

    host = "eutils.ncbi.nlm.nih.gov"
    path = "/entrez/eutils/efetch.fcgi?tool=bioruby&db=pubmed&retmode=text&rettype=medline&id="

    list = ids.join(",")

    http = Bio::Command.new_http(host)
    response, = http.get(path + list)
    result = response.body
    result = result.split(/\n\n+/)
    return result
  end

  # Search the PubMed database by given keywords using entrez query and returns
  # an array of PubMed IDs. Caution: this method returns the first 20 hits only.
  # Instead, use of the 'esearch' method is strongly recomended.
  # ---
  # *Arguments*:
  # * _id_: query string (required)
  # *Returns*:: array of PubMed IDs
  def self.search(str)
    host = "www.ncbi.nlm.nih.gov"
    path = "/sites/entrez?tool=bioruby&cmd=Search&doptcmdl=Brief&db=PubMed&term="

    http = Bio::Command.new_http(host)
    response, = http.get(path + CGI.escape(str))
    result = response.body
    result = result.scan(/value="(\d+)" id="UidCheckBox"/m).flatten
    return result
  end

  # Retrieve PubMed entry by PMID and returns MEDLINE formatted string using
  # entrez query.
  # ---
  # *Arguments*:
  # * _id_: PubMed ID (required)
  # *Returns*:: MEDLINE formatted String
  def self.query(*ids)
    host = "www.ncbi.nlm.nih.gov"
    path = "/sites/entrez?tool=bioruby&cmd=Text&dopt=MEDLINE&db=PubMed&uid="

    list = ids.join(",")

    http = Bio::Command.new_http(host)
    response, = http.get(path + list)
    result = response.body
    result = result.scan(/<pre>\s*(.*?)<\/pre>/m).flatten

    if result =~ /id:.*Error occurred/
      # id: xxxxx Error occurred: Article does not exist
      raise( result )
    else
      if ids.size > 1
        return result
      else
        return result.first
      end
    end
  end

  # Retrieve PubMed entry by PMID and returns MEDLINE formatted string using
  # entrez pmfetch.
  # ---
  # *Arguments*:
  # * _id_: PubMed ID (required)
  # *Returns*:: MEDLINE formatted String
  def self.pmfetch(id)
    host = "www.ncbi.nlm.nih.gov"
    path = "/entrez/utils/pmfetch.fcgi?tool=bioruby&mode=text&report=medline&db=PubMed&id="

    http = Bio::Command.new_http(host)
    response, = http.get(path + id.to_s)
    result = response.body
    if result =~ /#{id}\s+Error/
      raise( result )
    else
      result = result.gsub("\r", "\n").squeeze("\n").gsub(/<\/?pre>/, '')
      return result
    end
  end

end # PubMed

end # Bio


if __FILE__ == $0

  puts "--- Search PubMed by E-Utils ---"
  Bio::PubMed.esearch("(genome AND analysis) OR bioinformatics)").each do |x|
    p x
  end

  puts "--- Retrieve PubMed entry by E-Utils ---"
  puts Bio::PubMed.efetch("10592173", "14693808")

  puts "--- Search PubMed by Entrez CGI ---"
  Bio::PubMed.search("(genome AND analysis) OR bioinformatics)").each do |x|
    p x
  end

  puts "--- Retrieve PubMed entry by Entrez CGI ---"
  puts Bio::PubMed.query("10592173")


  puts "--- Retrieve PubMed entry by PMfetch ---"
  puts Bio::PubMed.pmfetch("10592173")

end
