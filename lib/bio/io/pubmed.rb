#
# = bio/io/pubmed.rb - NCBI Entrez/PubMed client module
#
# Copyright::  Copyright (C) 2001, 2007, 2008 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2006 Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::    The Ruby License
#

require 'bio/io/ncbirest'

module Bio

# == Description
#
# The Bio::PubMed class provides several ways to retrieve bibliographic
# information from the PubMed database at NCBI.
#
# Basically, two types of queries are possible:
#
# * searching for PubMed IDs given a query string:
#   * Bio::PubMed#esearch  (recommended)
#   * Bio::PubMed#search   (only retrieves top 20 hits; will be deprecated)
#
# * retrieving the MEDLINE text (i.e. authors, journal, abstract, ...)
#   given a PubMed ID
#   * Bio::PubMed#efetch   (recommended)
#   * Bio::PubMed#query    (will be deprecated)
#   * Bio::PubMed#pmfetch  (will be deprecated)
#
# Since BioRuby 1.5, all implementations uses NCBI E-Utilities services.
# The different methods within the same group still remain because
# specifications of arguments and/or return values are different.
# The search, query, and pmfetch will be obsoleted in the future.
# 
# Additional information about the MEDLINE format and PubMed programmable
# APIs can be found on the following websites:
#
# * PubMed Tutorial:
#   http://www.nlm.nih.gov/bsd/disted/pubmedtutorial/index.html
# * E-utilities Quick Start:
#   http://www.ncbi.nlm.nih.gov/books/NBK25500/
# * Creating a Web Link to PubMed:
#   http://www.ncbi.nlm.nih.gov/books/NBK3862/
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
#   Bio::PubMed.efetch("10592173").each { |x| puts x }
#   puts Bio::PubMed.query("10592173")
#   puts Bio::PubMed.pmfetch("10592173")
#
#   # To retrieve MEDLINE entries for given PubMed IDs:
#   Bio::PubMed.efetch([ "10592173", "14693808" ]).each { |x| puts x }
#   puts Bio::PubMed.query("10592173", "14693808") # returns a String
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
  #   * _"retmode"_: "xml", "html", ...
  #   * _"rettype"_: "medline", ...
  #   * _"retmax"_: integer (default 100)
  #   * _"retstart"_: integer
  #   * _"field"_
  #   * _"reldate"_
  #   * _"mindate"_
  #   * _"maxdate"_
  #   * _"datetype"_
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
  #   * _"retmode"_: "xml", "html", ...
  #   * _"rettype"_: "medline", ...
  #   * _"retmax"_: integer (default 100)
  #   * _"retstart"_: integer
  #   * _"field"_
  #   * _"reldate"_
  #   * _"mindate"_
  #   * _"maxdate"_
  #   * _"datetype"_
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

  # This method will be DEPRECATED in the future.
  #
  # Search the PubMed database by given keywords using entrez query and returns
  # an array of PubMed IDs.
  #
  # Caution: this method returns the first 20 hits only,
  #
  # Instead, use of the 'esearch' method is strongly recomended.
  #
  # Implementation details: Since BioRuby 1.5, this method internally uses
  # NCBI EUtils with retmax=20 by using Bio::PubMed#efetch method.
  #
  # ---
  # *Arguments*:
  # * _id_: query string (required)
  # *Returns*:: array of PubMed IDs
  def search(str)
    warn "Bio::PubMed#search is now a subset of Bio::PubMed#esearch. Using Bio::PubMed#esearch is recommended." if $VERBOSE
    esearch(str, { "retmax" => 20 })
  end

  # This method will be DEPRECATED in the future.
  #
  # Retrieve PubMed entry by PMID and returns MEDLINE formatted string using
  # entrez query.
  # ---
  # *Arguments*:
  # * _id_: PubMed ID (required)
  # *Returns*:: MEDLINE formatted String
  def query(*ids)
    warn "Bio::PubMed#query internally uses Bio::PubMed#efetch. Using Bio::PubMed#efetch is recommended." if $VERBOSE
    ret = efetch(ids)
    if ret && ret.size > 0 then
      ret.join("\n\n") + "\n"
    else
      ""
    end
  end

  # This method will be DEPRECATED in the future.
  #
  # Retrieve PubMed entry by PMID and returns MEDLINE formatted string.
  #
  # ---
  # *Arguments*:
  # * _id_: PubMed ID (required)
  # *Returns*:: MEDLINE formatted String
  def pmfetch(id)
    warn "Bio::PubMed#pmfetch internally use Bio::PubMed#efetch. Using Bio::PubMed#efetch is recommended." if $VERBOSE

    ret = efetch(id)
    if ret && ret.size > 0 then
      ret.join("\n\n") + "\n"
    else
      ""
    end
  end

  # The same as Bio::PubMed.new.esearch(*args).
  def self.esearch(*args)
    self.new.esearch(*args)
  end

  # The same as Bio::PubMed.new.efetch(*args).
  def self.efetch(*args)
    self.new.efetch(*args)
  end

  # This method will be DEPRECATED. Use esearch method.
  #
  # The same as Bio::PubMed.new.search(*args).
  def self.search(*args)
    self.new.search(*args)
  end

  # This method will be DEPRECATED. Use efetch method.
  #
  # The same as Bio::PubMed.new.query(*args).
  def self.query(*args)
    self.new.query(*args)
  end

  # This method will be DEPRECATED. Use efetch method.
  #
  # The same as Bio::PubMed.new.pmfetch(*args).
  def self.pmfetch(*args)
    self.new.pmfetch(*args)
  end

end # PubMed

end # Bio

