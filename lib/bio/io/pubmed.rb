#
# bio/io/pubmed.rb - NCBI Entrez/PubMed client module
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
#                 2006 Jan Aerts <jan.aerts@bbsrc.ac.uk>
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
#  $Id: pubmed.rb,v 1.14 2006/07/14 14:48:56 ngoto Exp $
#

require 'net/http'
require 'cgi' unless defined?(CGI)
require 'bio/command'

module Bio

  # = DESCRIPTION
  # The Bio::PubMed class provides several ways to retrieve bibliographic
  # information from the PubMed database at
  # http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=PubMed. Basically, two
  # types of queries are possible:
  # * searching for PubMed IDs given a query string:
  #   * Bio::PubMed#search
  #   * Bio::PubMed#esearch
  # * retrieving the MEDLINE text (i.e. authors, journal, abstract, ...) given a PubMed ID
  #   * Bio::PubMed#query
  #   * Bio::PubMed#pmfetch
  #   * Bio::PubMed#efetch
  #
  # The different methods within the same group are interchangeable and should
  # return the same result.
  # 
  # Additional information about the MEDLINE format and PubMed programmable
  # APIs can be found on the following websites:
  # * Overview: http://www.ncbi.nlm.nih.gov/entrez/query/static/overview.html
  # * How to link: http://www.ncbi.nlm.nih.gov/entrez/query/static/linking.html
  # * MEDLINE format: http://www.ncbi.nlm.nih.gov/entrez/query/static/help/pmhelp.html#MEDLINEDisplayFormat
  # * Search field descriptions and tags: http://www.ncbi.nlm.nih.gov/entrez/query/static/help/pmhelp.html#SearchFieldDescriptionsandTags
  # * Entrez utilities index: http://www.ncbi.nlm.nih.gov/entrez/utils/utils_index.html
  # * PmFetch CGI help: http://www.ncbi.nlm.nih.gov/entrez/utils/pmfetch_help.html
  # * E-Utilities CGI help: http://eutils.ncbi.nlm.nih.gov/entrez/query/static/eutils_help.html
  #
  # = USAGE
  #  require 'bio'
  #
  #  # If you don't know the pubmed ID:
  #  Bio::PubMed.search("(genome AND analysis) OR bioinformatics)").each do |x|
  #    p x
  #  end
  #  Bio::PubMed.esearch("(genome AND analysis) OR bioinformatics)").each do |x|
  #    p x
  #  end
  #  
  #  # To retrieve the MEDLINE entry for a given PubMed ID:
  #  puts Bio::PubMed.query("10592173")
  #  puts Bio::PubMed.pmfetch("10592173")
  #  puts Bio::PubMed.efetch("10592173", "14693808")
  #  # This can be converted into a Bio::MEDLINE object:
  #  manuscript = Bio::PubMed.query("10592173")
  #  medline = Bio::MEDLINE(manuscript)
  #  
  # = REMARK
  # This class can not be used at the moment if you're behind a proxy server. This will be solved in the near future.
  class PubMed

    # Search the PubMed database by given keywords using entrez query and returns
    # an array of PubMed IDs.
    # ---
    # *Arguments*:
    # * _id_: query string (required)
    # *Returns*:: array of PubMed IDs
    def self.search(str)
      host = "www.ncbi.nlm.nih.gov"
      path = "/entrez/query.fcgi?tool=bioruby&cmd=Search&doptcmdl=MEDLINE&db=PubMed&term="

      http = Bio::Command.new_http(host)
      response, = http.get(path + CGI.escape(str))
      result = response.body
      result = result.gsub("\r", "\n").squeeze("\n")
      result = result.scan(/<pre>(.*?)<\/pre>/m).flatten
      return result
    end

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
    # *Returns*:: array of PubMed IDs
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
      result = result.scan(/<Id>(.*?)<\/Id>/m).flatten
      return result
    end

    # Retrieve PubMed entry by PMID and returns MEDLINE formatted string using
    # entrez query.
    # ---
    # *Arguments*:
    # * _id_: PubMed ID (required)
    # *Returns*:: MEDLINE formatted String
    def self.query(id)
      host = "www.ncbi.nlm.nih.gov"
      path = "/entrez/query.fcgi?tool=bioruby&cmd=Text&dopt=MEDLINE&db=PubMed&uid="

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

      ids = ids.join(",")

      http = Bio::Command.new_http(host)
      response, = http.get(path + ids)
      result = response.body
      result = result.split(/\n\n+/)
      return result
    end

  end

end


if __FILE__ == $0

  puts Bio::PubMed.query("10592173")
  puts "--- ---"
  puts Bio::PubMed.pmfetch("10592173")
  puts "--- ---"
  Bio::PubMed.search("(genome AND analysis) OR bioinformatics)").each do |x|
    p x
  end
  puts "--- ---"
  Bio::PubMed.esearch("(genome AND analysis) OR bioinformatics)").each do |x|
    p x
  end
  puts "--- ---"
  puts Bio::PubMed.efetch("10592173", "14693808")

end
