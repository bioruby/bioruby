#
# tDiary : plugin/bio.rb
#
#   Copyright (C) 2003 KATAYAMA Toshiaki <k@bioruby.org>
#                      Mitsuteru C. Nakao <n@bioruby.org>
#                      Itoshi NIKAIDO  <itoshi@gsc.riken.go.jp>
#                      Takeya KASUKAWA <kasukawa@gsc.riken.go.jp>
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
#  $Id: tdiary.rb,v 1.3 2003/03/17 04:24:47 k Exp $
#

=begin

== What's this?

This is a plugin for the ((<tDiary|URL:http://www.tdiary.org/>)) to create
various links for biological resources from your diary.

tDiary is an extensible web diary application written in Ruby.

== How to install

Just copy this file under the tDiary's plugin directory as bio.rb.

== Usage

--- pubmed(pmid, comment = nil)

Create a link to NCBI Entrez reference database by using PubMed ID.
See ((<URL:http://www.ncbi.nlm.nih.gov/entrez/query.fcgi>)) for more
information.

  * tDiary style
     * <%= pubmed 12345 %>
     * <%= pubmed 12345, 'hogehoge' %>
  * RD style
     * ((% pubmed 12345 %))
     * ((% pubmed 12345, 'hogehoge' %))

--- biofetch(db, entry_id)

Create a link to the BioFetch detabase entry retrieval system.
See ((<URL:http://biofetch.bioruby.org/>)) for more information.

  * tDiary style
    * <%= biofetch 'genbank', 'AA2CG' %>
  * RD style
    * ((% biofetch 'genbank', 'AA2CG' %))

--- amigo(go_id, comment = nil)

Create a link to the AmiGO GO term browser by using GO ID.
See ((<URL:http://www.godatabase.org/cgi-bin/go.cgi>)) for more 
information.

  * tDiary style
    * <%= amigo '0003673' %>
    * <%= amigo '0003673', 'The root of GO' %>
  * RD style
    * ((% amigo 0003673 %))
    * ((% amigo 0003673, 'The root of GO' %))

--- fantom(id, comment = nil)

Create a link to FANTOM database by using Clone ID.
You can use RIKEN clone ID, Rearray ID, Seq ID and Accession Number.
See ((<URL:http://fantom2.gsc.riken.go.jp/db/>)) for more information.

  * tDiary style
     * <%= fantom 12345 %>
     * <%= fantom 12345, 'hogehoge' %>
  * RD style
    * ((% fantom 12345 %))
    * ((% fantom 12345, 'hogehoge' %))

--- rtps(id, comment = nil)

Create a link to FANTOM RTPS database by using Clone ID. 
You can use only RTPS ID.
See ((<URL:http://fantom2.gsc.riken.go.jp/RTPS/>)) for more information.

  * tDiary style
     * <%= rtps 12345 %>
     * <%= rtps 12345, 'hogehoge' %>
  * RD style
    * ((% rtps 12345 %))
    * ((% rtps 12345, 'hogehoge' %))

== References

* Analysis of the mouse transcriptome based on functional annotation of
  60,770 full-length cDNAs, The FANTOM Consortium and the RIKEN Genome
  Exploration Research Group Phase I & II Team, Nature 420:563-573, 2002

* Functional annotation of a full-length mouse cDNA collection,
  The RIKEN Genome Exploration Research Group Phase II Team and 
  the FANTOM Consortium, Nature 409:685-690, 2001

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

def amigo(go_id = '0003673', comment = nil)
  go_id = go_id.to_s.strip
  url = "http://www.godatabase.org/cgi-bin/go.cgi?query=#{go_id};view=query;action=query;search_constraint=terms"
  comment = "AmiGO:#{go_id}" unless comment
  %Q[<a href="#{url}">#{comment}</a>]
end

def fantom(id, comment = nil)
  id = id.to_s.strip
  url = "http://fantom2.gsc.riken.go.jp/db/link/id.cgi"
  url << "?id=#{id}"
  if comment
    %Q[<a href="#{url}">#{comment.to_s.strip}</a>]
  else
    %Q[<a href="#{url}">FANTOM DB:#{id}</a>]
  end
end

def rtps(id, comment = nil)
  id = id.to_s.strip
  url = "http://fantom2.gsc.riken.go.jp/RTPS/link/id.cgi"
  url << "?id=#{id}"
  if comment
    %Q[<a href="#{url}">#{comment.to_s.strip}</a>]
  else
    %Q[<a href="#{url}">FANTOM RTPS DB:#{id}</a>]
  end
end
