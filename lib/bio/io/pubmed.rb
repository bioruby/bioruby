#
# = bio/io/pubmed.rb - NCBI Entrez/PubMed client module
#
# Copyright::  Copyright (C) 2001, 2007 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2006 Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::    The Ruby License
#
# $Id: pubmed.rb,v 1.23 2007/12/12 13:53:26 k Exp $
#

require 'bio/command'
require 'cgi' unless defined?(CGI)

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
class PubMed

  # Run retrieval scripts on weekends or between 9 pm and 5 am Eastern Time
  # weekdays for any series of more than 100 requests.
  # -> Not implemented yet in BioRuby

  # Make no more than one request every 3 seconds.
  NCBI_INTERVAL = 3
  @@last_access = nil

  private

  def ncbi_access_wait(wait = NCBI_INTERVAL)
    if @@last_access
      duration = Time.now - @@last_access
      if wait > duration
        sleep wait - duration
      end
    end
    @@last_access = Time.now
  end

  public

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
  def esearch(str, hash = {})
    return nil if str.empty?

    serv = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
    opts = {
      "retmax" => 100,
      "tool"   => "bioruby",
      "db"     => "pubmed",
      "term"   => str
    }
    opts.update(hash)

    ncbi_access_wait

    response, = Bio::Command.post_form(serv, opts)
    result = response.body
    if opts['rettype'] == 'count'
      result = result.scan(/<Count>(.*?)<\/Count>/m).flatten.first.to_i
    else
      result = result.scan(/<Id>(.*?)<\/Id>/m).flatten
    end
    return result
  end

  # Retrieve PubMed entry by PMID and returns MEDLINE formatted string using
  # entrez efetch. Multiple PubMed IDs can be provided:
  #   Bio::PubMed.efetch(123)
  #   Bio::PubMed.efetch([123,456,789])
  # ---
  # *Arguments*:
  # * _ids_: list of PubMed IDs (required)
  # *Returns*:: Array of MEDLINE formatted String
  def efetch(ids, hash = {})
    return nil if ids.to_s.empty?
    ids = ids.join(",") if ids === Array

    serv = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
    opts = {
      "tool"     => "bioruby",
      "db"       => "pubmed",
      "retmode"  => "text",
      "rettype"  => "medline",
      "id"       => ids,
    }
    opts.update(hash)

    ncbi_access_wait

    response, = Bio::Command.post_form(serv, opts)
    result = response.body
    if opts["retmode"] == "text"
      result = result.split(/\n\n+/)
    end
    return result
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
    path = "/sites/entrez?tool=bioruby&cmd=Search&doptcmdl=Brief&db=PubMed&term="

    ncbi_access_wait

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
  def query(*ids)
    host = "www.ncbi.nlm.nih.gov"
    path = "/sites/entrez?tool=bioruby&cmd=Text&dopt=MEDLINE&db=PubMed&uid="
    list = ids.join(",")

    ncbi_access_wait

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
  def pmfetch(id)
    host = "www.ncbi.nlm.nih.gov"
    path = "/entrez/utils/pmfetch.fcgi?tool=bioruby&mode=text&report=medline&db=PubMed&id="

    ncbi_access_wait

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


if __FILE__ == $0

  puts "=== instance methods ==="

  pubmed = Bio::PubMed.new

  puts "--- Search PubMed by E-Utils ---"
  opts = {"rettype" => "count"}
  puts Time.now
  puts pubmed.esearch("(genome AND analysis) OR bioinformatics", opts)
  puts Time.now
  puts pubmed.esearch("(genome AND analysis) OR bioinformatics", opts)
  puts Time.now
  puts pubmed.esearch("(genome AND analysis) OR bioinformatics", opts)
  puts Time.now
  pubmed.esearch("(genome AND analysis) OR bioinformatics").each do |x|
    puts x
  end

  puts "--- Retrieve PubMed entry by E-Utils ---"
  puts Time.now
  puts pubmed.efetch(16381885)
  puts Time.now
  puts pubmed.efetch("16381885")
  puts Time.now
  puts pubmed.efetch("16381885")
  puts Time.now
  opts = {"retmode" => "xml"}
  puts pubmed.efetch([10592173, 14693808], opts)
  puts Time.now
  puts pubmed.efetch(["10592173", "14693808"], opts)

  puts "--- Search PubMed by Entrez CGI ---"
  pubmed.search("(genome AND analysis) OR bioinformatics").each do |x|
    p x
  end

  puts "--- Retrieve PubMed entry by Entrez CGI ---"
  puts pubmed.query("16381885")


  puts "--- Retrieve PubMed entry by PMfetch ---"
  puts pubmed.pmfetch("16381885")


  puts "=== class methods ==="


  puts "--- Search PubMed by E-Utils ---"
  opts = {"rettype" => "count"}
  puts Time.now
  puts Bio::PubMed.esearch("(genome AND analysis) OR bioinformatics", opts)
  puts Time.now
  puts Bio::PubMed.esearch("(genome AND analysis) OR bioinformatics", opts)
  puts Time.now
  puts Bio::PubMed.esearch("(genome AND analysis) OR bioinformatics", opts)
  puts Time.now
  Bio::PubMed.esearch("(genome AND analysis) OR bioinformatics").each do |x|
    puts x
  end

  puts "--- Retrieve PubMed entry by E-Utils ---"
  puts Time.now
  puts Bio::PubMed.efetch(16381885)
  puts Time.now
  puts Bio::PubMed.efetch("16381885")
  puts Time.now
  puts Bio::PubMed.efetch("16381885")
  puts Time.now
  opts = {"retmode" => "xml"}
  puts Bio::PubMed.efetch([10592173, 14693808], opts)
  puts Time.now
  puts Bio::PubMed.efetch(["10592173", "14693808"], opts)

  puts "--- Search PubMed by Entrez CGI ---"
  Bio::PubMed.search("(genome AND analysis) OR bioinformatics").each do |x|
    p x
  end

  puts "--- Retrieve PubMed entry by Entrez CGI ---"
  puts Bio::PubMed.query("16381885")


  puts "--- Retrieve PubMed entry by PMfetch ---"
  puts Bio::PubMed.pmfetch("16381885")

end
