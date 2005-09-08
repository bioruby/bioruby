#
# bio/io/pubmed.rb - NCBI Entrez/PubMed client module
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: pubmed.rb,v 1.12 2005/09/08 01:22:12 k Exp $
#

require 'net/http'
require 'cgi' unless defined?(CGI)

module Bio

  class PubMed

    def self.query(id)
      host = "www.ncbi.nlm.nih.gov"
      path = "/entrez/query.fcgi?tool=bioruby&cmd=Text&dopt=MEDLINE&db=PubMed&uid="

      http = Net::HTTP.new(host)
      response, = http.get(path + id.to_s)
      result = response.body
      if result =~ /#{id}\s+Error/
        raise( result )
      else
        result = result.gsub("\r", "\n").squeeze("\n").gsub(/<\/?pre>/, '')
        return result
      end
    end

    def self.pmfetch(id)
      host = "www.ncbi.nlm.nih.gov"
      path = "/entrez/utils/pmfetch.fcgi?tool=bioruby&mode=text&report=medline&db=PubMed&id="

      http = Net::HTTP.new(host)
      response, = http.get(path + id.to_s)
      result = response.body
      if result =~ /#{id}\s+Error/
        raise( result )
      else
        result = result.gsub("\r", "\n").squeeze("\n").gsub(/<\/?pre>/, '')
        return result
      end
    end

    def self.search(str)
      host = "www.ncbi.nlm.nih.gov"
      path = "/entrez/query.fcgi?tool=bioruby&cmd=Search&doptcmdl=MEDLINE&db=PubMed&term="

      http = Net::HTTP.new(host)
      response, = http.get(path + CGI.escape(str))
      result = response.body
      result = result.gsub("\r", "\n").squeeze("\n")
      result = result.scan(/<pre>(.*?)<\/pre>/m).flatten
      return result
    end

    def self.esearch(str, hash = {})
      hash['retmax'] = 100 unless hash['retmax']

      opts = []
      hash.each do |k, v|
        opts << "#{k}=#{v}"
      end

      host = "eutils.ncbi.nlm.nih.gov"
      path = "/entrez/eutils/esearch.fcgi?tool=bioruby&db=pubmed&#{opts.join('&')}&term="

      http = Net::HTTP.new(host)
      response, = http.get(path + CGI.escape(str))
      result = response.body
      result = result.scan(/<Id>(.*?)<\/Id>/m).flatten
      return result
    end

    def self.efetch(*ids)
      return [] if ids.empty?

      host = "eutils.ncbi.nlm.nih.gov"
      path = "/entrez/eutils/efetch.fcgi?tool=bioruby&db=pubmed&retmode=text&rettype=medline&id="

      ids = ids.join(",")

      http = Net::HTTP.new(host)
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

=begin

= Bio::PubMed

These class methods access NCBI/PubMed database via HTTP.

--- Bio::PubMed.esearch(str, options)

      Search keywords in PubMed by E-Utils and returns an array of PubMed IDs.
      Options can be a hash containing keys include 'field', 'reldate',
      'mindate', 'maxdate', 'datetype', 'retstart', 'retmax', 'retmode',
      and 'rettype' as specified in the following URL:

        ((<URL:http://eutils.ncbi.nlm.nih.gov/entrez/query/static/esearch_help.html#PubMed>))

     Default 'retmax' is 100.

--- Bio::PubMed.efetch(pmids)

      Returns an array of MEDLINE records.  A list of PubMed IDs can be
      supplied as following:

        Bio::PubMed.efetch(123)
        Bio::PubMed.efetch(123,456,789)
        Bio::PubMed.efetch([123,456,789])

--- Bio::PubMed.query(pmid)

      Retrieve PubMed entry by PMID and returns MEDLINE format string (can
      be parsed by the Bio::MEDLINE and can be converted into Bio::Reference
      object).

--- Bio::PubMed.pmfetch(pmid)

      Just another query method (by pmfetch).

--- Bio::PubMed.search(str)

      Search the PubMed database by given keywords and returns the list of
      matched records in MEDLINE format.


= For more informations

* Overview
  * ((<URL:http://www.ncbi.nlm.nih.gov/entrez/query/static/overview.html>))
* How to link
  * ((<URL:http://www.ncbi.nlm.nih.gov/entrez/query/static/linking.html>))
* MEDLINE format
  * ((<URL:http://www.ncbi.nlm.nih.gov/entrez/query/static/help/pmhelp.html#MEDLINEDisplayFormat>))
* Search field descriptions and tags
  * ((<URL:http://www.ncbi.nlm.nih.gov/entrez/query/static/help/pmhelp.html#SearchFieldDescriptionsandTags>))
* Entrez utilities index
  * ((<URL:http://www.ncbi.nlm.nih.gov/entrez/utils/utils_index.html>))
* PmFetch CGI help
  * ((<URL:http://www.ncbi.nlm.nih.gov/entrez/utils/pmfetch_help.html>))
* E-Utilities CGI help
  * ((<URL:http://eutils.ncbi.nlm.nih.gov/entrez/query/static/eutils_help.html>))

=end


