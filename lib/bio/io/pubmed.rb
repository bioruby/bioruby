#
# bio/io/pubmed.rb - NCBI Entrez/PubMed client class
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
#  $Id: pubmed.rb,v 1.3 2001/09/17 22:31:28 katayama Exp $
#
#  For more informations :
#    http://www.ncbi.nlm.nih.gov/entrez/query/static/overview.html
#    http://www.ncbi.nlm.nih.gov/entrez/query/static/linking.html
#    http://www.ncbi.nlm.nih.gov/entrez/query/static/help/pmhelp.html#MEDLINEDisplayFormat
#    http://www.ncbi.nlm.nih.gov/entrez/query/static/help/pmhelp.html#SearchFieldDescriptionsandTags
#    http://www.ncbi.nlm.nih.gov/entrez/utils/utils_index.html
#    http://www.ncbi.nlm.nih.gov/entrez/utils/pmfetch_help.html
#

require 'net/http'

module PubMed

  def query(id)
    host = "www.ncbi.nlm.nih.gov"
    http = Net::HTTP.new(host)

    path = "/entrez/query.fcgi?cmd=Text&dopt=MEDLINE&db=PubMed&uid="

    result = http.get(path + id.to_s).pop

    if result =~ /#{id}\s+Error/
      raise( result )
    else
      result = result.gsub("\r", "\n").squeeze("\n").gsub(/<\/?pre>/, '')
      return result
    end
  end

  def search(str)
    host = "www.ncbi.nlm.nih.gov"
    http = Net::HTTP.new(host)

    path = "/entrez/query.fcgi?cmd=Search&doptcmdl=MEDLINE&db=PubMed&term="

    if str =~ /\s+/
      str = str.split(/\s+/).join('+')
    end

    result = http.get(path + str).pop

    if result =~ /#{id}\s+Error/
      raise( result )
    else
      result = result.gsub("\r", "\n").squeeze("\n")
      # FIXME : substitution fails because '.' doesn't match "\n"
      #result = result.sub(/.*<pre>/, '').sub(/<\/pre>.*/, '')
      return result
    end
  end

  def pmfetch(id)
    host = "www.ncbi.nlm.nih.gov"
    http = Net::HTTP.new(host)

    path = "/entrez/utils/pmfetch.fcgi?mode=text&report=medline&db=PubMed&id="

    result = http.get(path + id.to_s).pop

    if result =~ /#{id}\s+Error/
      raise( result )
    else
      result = result.gsub("\r", "\n").squeeze("\n").gsub(/<\/?pre>/, '')
      return result
    end
  end

  module_function :query, :search, :pmfetch

end

