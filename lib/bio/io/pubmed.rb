#
# bio/io/pubmed.rb - NCBI Entrez/PubMed client module
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  $Id: pubmed.rb,v 1.5 2001/10/17 14:43:12 katayama Exp $
#
#  For more informations :
#    http://www.ncbi.nlm.nih.gov
#      /entrez/query/static/overview.html
#      /entrez/query/static/linking.html
#      /entrez/query/static/help/pmhelp.html#MEDLINEDisplayFormat
#      /entrez/query/static/help/pmhelp.html#SearchFieldDescriptionsandTags
#      /entrez/utils/utils_index.html
#      /entrez/utils/pmfetch_help.html
#

module Bio

require 'net/http'

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
      result = result.sub(/.*<pre>/m, '').sub(/<\/pre>.*/m, '')
      return result
    end
  end

end

end				# module Bio

