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
#  $Id: pubmed.rb,v 1.7 2001/12/07 20:32:54 katayama Exp $
#

require 'net/http'

module Bio

  class PubMed

    def PubMed.query(id)
      host = "www.ncbi.nlm.nih.gov"
      path = "/entrez/query.fcgi?cmd=Text&dopt=MEDLINE&db=PubMed&uid="

      http = Net::HTTP.new(host)

      result = http.get(path + id.to_s).pop

      if result =~ /#{id}\s+Error/
	raise( result )
      else
	result = result.gsub("\r", "\n").squeeze("\n").gsub(/<\/?pre>/, '')
	return result
      end
    end

    def PubMed.pmfetch(id)
      host = "www.ncbi.nlm.nih.gov"
      path = "/entrez/utils/pmfetch.fcgi?mode=text&report=medline&db=PubMed&id="

      http = Net::HTTP.new(host)

      result = http.get(path + id.to_s).pop

      if result =~ /#{id}\s+Error/
	raise( result )
      else
	result = result.gsub("\r", "\n").squeeze("\n").gsub(/<\/?pre>/, '')
	return result
      end
    end

    def PubMed.search(str)
      host = "www.ncbi.nlm.nih.gov"
      path = "/entrez/query.fcgi?cmd=Search&doptcmdl=MEDLINE&db=PubMed&term="

      http = Net::HTTP.new(host)

      if str =~ /\s+/
	str = str.split(/\s+/).join('+')
      end

      result = http.get(path + str).pop

      if result =~ /#{id}\s+Error/
	raise( result )
      else
	result = result.gsub("\r", "\n").squeeze("\n")
	result = result.scan(/<pre>(.*?)<\/pre>/m).flatten
	return result
      end
    end

  end

end


if __FILE__ == $0

  puts Bio::PubMed.query("10592173")
  puts "--- ---"
  puts Bio::PubMed.pmfetch("10592173")
  puts "--- ---"
  Bio::PubMed.search("genome bioinformatics").each do |x|
    p x
  end

end

=begin

= Bio::PubMed

These class methods access NCBI/PubMed database via HTTP.

--- Bio::PubMed.query(id)

      Retrieve PubMed entry by PMID and returns MEDLINE format string (can
      be parsed by the Bio::MEDLINE and can be converted into Bio::Reference
      object).

--- Bio::PubMed.pmfetch(id)

      Just another query method.

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

=end


