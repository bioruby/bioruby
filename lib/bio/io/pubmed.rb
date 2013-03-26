#
# = bio/io/pubmed.rb - NCBI Entrez/PubMed client module
#
# Copyright::  Copyright (C) 2001, 2007, 2008 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2006 Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/io/ncbirest'
require 'bio/command'
require 'cgi'

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
#   Bio::PubMed.esearch("(genome AND analysis) OR bioinformatics").each do |x|
#     p x
#   end
#
#   Bio::PubMed.search("(genome AND analysis) OR bioinformatics").each do |x|
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
class PubMed < Bio::NCBI::REST

  # Search the PubMed database by given keywords using E-Utils and returns 
  # an array of PubMed IDs.
  # 
  # For information on the possible arguments, see
  # http://eutils.ncbi.nlm.nih.gov/entrez/query/static/esearch_help.html#PubMed
  # ---
  # *Arguments*:
  # * _str_: query string (required)
  # * _hash_: hash of E-Utils options
  #   * _retmode_: "xml", "html", ...
  #   * _rettype_: "medline", ...
  #   * _retmax_: integer (default 100)
  #   * _retstart_: integer
  #   * _field_
  #   * _reldate_
  #   * _mindate_
  #   * _maxdate_
  #   * _datetype_
  # *Returns*:: array of PubMed IDs or a number of results
  def esearch(str, hash = {})
    opts = { "db" => "pubmed" }
    opts.update(hash)
    super(str, opts)
  end

  # Retrieve PubMed entry by PMID and returns MEDLINE formatted string using
  # entrez efetch. Multiple PubMed IDs can be provided:
  #   Bio::PubMed.efetch(123)
  #   Bio::PubMed.efetch([123,456,789])
  # ---
  # *Arguments*:
  # * _ids_: list of PubMed IDs (required)
  # * _hash_: hash of E-Utils options
  #   * _retmode_: "xml", "html", ...
  #   * _rettype_: "medline", ...
  #   * _retmax_: integer (default 100)
  #   * _retstart_: integer
  #   * _field_
  #   * _reldate_
  #   * _mindate_
  #   * _maxdate_
  #   * _datetype_
  # *Returns*:: Array of MEDLINE formatted String
  def efetch(ids, hash = {})
    opts = { "db" => "pubmed", "rettype"  => "medline" }
    opts.update(hash)
    result = super(ids, opts)
    if !opts["retmode"] or opts["retmode"] == "text"
      result = result.split(/\n\n+/)
    end
    result
  end

  # Search the PubMed database by given keywords using entrez query and returns
  # an array of PubMed IDs. Caution: this method returns the first 20 hits only.
  # Instead, use of the 'esearch' method is strongly recomended.
  # ---
  # *Arguments*:
  # * _id_: query string (required)
  # *Returns*:: array of PubMed IDs
  def search(str)
    host = "www.ncbi.nlm.nih.gov"
    path = "/pubmed?tool=bioruby&cmd=Search&doptcmdl=Brief&db=PubMed&term="

    ncbi_access_wait

    http = Bio::Command.new_http(host)
    response = http.get(path + CGI.escape(str))
    result = response.body
    result = result.scan(/<dt>PMID:<\/dt>\s+<dd>(\d+)<\/dd>/m).flatten
    return result
  end

  # Retrieve PubMed entry by PMID and returns MEDLINE formatted string using
  # pubmed query.
  # ---
  # *Arguments*:
  # * _ids_: One or more PubMed IDs (required)
  # *Returns*:: MEDLINE formatted String, if one result, or an array of results
  def query(*ids)
    ids = ids.flatten # Handle somone passing an array
    host = "www.ncbi.nlm.nih.gov"
    path = "/pubmed?tool=bioruby&cmd=Text&dopt=MEDLINE&db=PubMed&uid="
    list = ids.collect { |x| CGI.escape(x.to_s) }.join(",")
    ncbi_access_wait

    http = Bio::Command.new_http(host)
    response = http.get(path + list)
    
    body = response.body
    # Extract the contents of the result from the page.
    # PubMed returns a page with all the results in a pre tag.
    # This may change to being pre tags for each result, so we 
    # can handle that too as it's trivial.
    results = []
    body.scan(/<pre>\s*(.*?)<\/pre>/m) do |result_block|
      # Split the result block into pieces if there are more than one.
      # Records are split by a clear line betwen.
      # As we are using a capture group result_block will be a single element
      # array.
      results += result_block.first.split("\n\n")
    end

    if ids.size > 1
      return results
    else
      return results.first
    end
  end

  # Retrieve PubMed entry by PMID and returns MEDLINE formatted string using
  # entrez pmfetch.
  # ---
  # *Arguments*:
  # * _id_: PubMed ID (required)
  # *Returns*:: MEDLINE formatted String
  def pmfetch(id)
    host = "www.ncbi.nlm.nih.gov"
    path = "/entrez/utils/pmfetch.fcgi?tool=bioruby&mode=text&report=medline&db=PubMed&id="

    ncbi_access_wait

    http = Bio::Command.new_http(host)
    response = http.get(path + CGI.escape(id.to_s))
    result = response.body
    if result =~ /#{id}\s+Error/
      raise( result )
    else
      result = result.gsub("\r", "\n").squeeze("\n").gsub(/<\/?pre>/, '')
      return result
    end
  end

  def self.esearch(*args)
    self.new.esearch(*args)
  end

  def self.efetch(*args)
    self.new.efetch(*args)
  end

  def self.search(*args)
    self.new.search(*args)
  end

  def self.query(*args)
    self.new.query(*args)
  end

  def self.pmfetch(*args)
    self.new.pmfetch(*args)
  end

end # PubMed

end # Bio

