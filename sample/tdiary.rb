#
# tDiary : plugin/bio.rb
#
#   Copyright (C) 2003 KATAYAMA Toshiaki <k@bioruby.org>,
#                      Mitsuteru C. Nakao <n@bioruby.org>
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
#  $Id: tdiary.rb,v 1.1 2003/03/10 17:29:33 k Exp $
#

=begin

== What's this?

This is a plugin for the ((<tDiary|URL:http://www.tdiary.org/>)) to create
various links for biological resources from your diary.

tDiary is an extensible web diary application written in Ruby.

== How to install

Just copy this file under the tDiary's plugin directory.

== Usage

--- pubmed

Create a link to NCBI Entrez reference database by using PubMed ID.
See ((<URL:http://www.ncbi.nlm.nih.gov/entrez/query.fcgi>)) for more
informations.

  * tDiary style
     * <%=pubmed 12345%>
     * <%=pubmed 12345, hogehoge%>
  * RD style
     * ((%pubmed 12345%))
     * ((%pubmed 12345, 'hogehoge'%))

--- biofetch

Create a link to the BioFetch detabase entry retrieval system.
See ((<URL:http://biofetch.bioruby.org/>)) for more informations.

  * tDiary style
    * <%=biofetch genbank, AA2CG%>
  * RD style
    * ((%biofetch 'genbank', 'AA2CG'%))

=end


def pubmed(pmid, comment = nil)
  pmid = pmid.to_s.strip
  url = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi"
  url << "?cmd=Retrieve&db=PubMed&dopt=Abstract&list_uids=#{pmid}"
  if comment
    %Q[<a href="#{url}">#{comment.to_s.strip}</a>]
  else
    %Q[<a href="#{url}">PMID:#{pmid}</a>]
  end
end

def biofetch(db, entry_id) 
  url = "http://biofetch.bioruby.org/"
  %Q[<a href="#{url}?db=#{db};id=#{entry_id};style=raw">#{db}:#{entry_id}</a>] 
end



