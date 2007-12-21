#
# = bio/db/medline.rb - NCBI PubMed/MEDLINE database class
#
# Copyright::  Copyright (C) 2001, 2005
#              Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: medline.rb,v 1.17 2007/12/21 05:12:41 k Exp $
#

require 'bio/db'

module Bio

# == Description
#
# NCBI PubMed/MEDLINE database class.
#
# == Examples
#
#   medline = Bio::MEDLINE.new(txt)
#   medline.reference
#   medline.pmid == medline.entry_id
#   medilne.mesh
#
class MEDLINE < NCBIDB

  def initialize(entry)
    @pubmed = Hash.new('')

    tag = ''
    entry.each_line do |line|
      if line =~ /^\w/
        tag = line[0,4].strip
      end
      @pubmed[tag] += line[6..-1] if line.length > 6
    end
  end
  attr_reader :pubmed


  # returns a Reference object.
  def reference
    hash = Hash.new('')

    hash['authors']	= authors
    hash['title']	= title
    hash['journal']	= journal
    hash['volume']	= volume
    hash['issue']	= issue
    hash['pages']	= pages
    hash['year']	= year
    hash['pubmed']	= pmid
    hash['medline']  	= ui
    hash['abstract']	= abstract
    hash['mesh']	= mesh
    hash['affiliations'] = affiliations

    hash.delete_if { |k, v| v.nil? or v.empty? }

    return Reference.new(hash)
  end


  ### Common MEDLINE tags

  # PMID - PubMed Unique Identifier
  #   Unique number assigned to each PubMed citation.
  def pmid
    @pubmed['PMID'].strip
  end
  alias entry_id pmid

  # UI   - MEDLINE Unique Identifier
  #   Unique number assigned to each MEDLINE citation.
  def ui
    @pubmed['UI'].strip
  end

  # TA   - Journal Title Abbreviation
  #   Standard journal title abbreviation.
  def ta
    @pubmed['TA'].gsub(/\s+/, ' ').strip
  end
  alias journal ta

  # VI   - Volume
  #   Journal volume.
  def vi
    @pubmed['VI'].strip
  end
  alias volume vi

  # IP   - Issue
  #   The number of the issue, part, or supplement of the journal in which
  #   the article was published.
  def ip
    @pubmed['IP'].strip
  end
  alias issue ip

  # PG   - Page Number
  #   The full pagination of the article.
  def pg
    @pubmed['PG'].strip
  end

  def pages
    pages = pg
    if pages =~ /-/
      from, to = pages.split('-')
      if (len = from.length - to.length) > 0
        to = from[0,len] + to
      end
      pages = "#{from}-#{to}"
    end
    return pages
  end

  # DP   - Publication Date
  #   The date the article was published.
  def dp
    @pubmed['DP'].strip
  end
  alias date dp

  def year
    dp[0,4]
  end

  # TI   - Title Words
  #   The title of the article.
  def ti
    @pubmed['TI'].gsub(/\s+/, ' ').strip
  end
  alias title ti

  # AB   - Abstract
  #   Abstract.
  def ab
    @pubmed['AB'].gsub(/\s+/, ' ').strip
  end
  alias abstract ab

  # AU   - Author Name
  #   Authors' names.
  def au
    @pubmed['AU'].strip
  end

  def authors
    authors = []
    au.split(/\n/).each do |author|
      if author =~ / /
        name = author.split(/\s+/)
        suffix = name[-2] =~ /^[A-Z]+$/ ? name.pop : nil	# Jr etc.
        initial = name.pop.split(//).join('. ')
        author = "#{name.join(' ')}, #{initial}."
      end
      if suffix
        author << " " + suffix
      end
      authors.push(author)
    end
    return authors
  end

  # SO   - Source
  #   Composite field containing bibliographic information.
  def so
    @pubmed['SO'].strip
  end
  alias source so

  # MH   - MeSH Terms
  #   NLM's controlled vocabulary.
  def mh
    @pubmed['MH'].strip.split(/\n/)
  end
  alias mesh mh

  # AD   - Affiliation
  #   Institutional affiliation and address of the first author, and grant
  #   numbers.
  def ad
    @pubmed['AD'].strip.split(/\n/)
  end
  alias affiliations ad

  # AID  - Article Identifier
  #   Article ID values may include the pii (controlled publisher identifier)
  #   or doi (Digital Object Identifier).
  def doi
    @pubmed['AID'][/(\S+) \[doi\]/, 1]
  end

  def pii
    @pubmed['AID'][/(\S+) \[pii\]/, 1]
  end

  ### Other MEDLINE tags

  # CI   - Copyright Information
  #   Copyright statement.

  # CIN  - Comment In
  #   Reference containing a comment about the article.

  # CN   - Collective Name
  #   Corporate author or group names with authorship responsibility.

  # CON  - Comment On
  #   Reference upon which the article comments.

  # CY   - Country
  #   The place of publication of the journal.

  # DA   - Date Created
  #   Used for internal processing at NLM.

  # DCOM - Date Completed
  #   Used for internal processing at NLM.

  # DEP  - Date of Electronic Publication
  #   Electronic publication date.

  # EDAT - Entrez Date
  #   The date the citation was added to PubMed.

  # EIN  - Erratum In
  #   Reference containing a published erratum to the article.

  # GS   - Gene Symbol
  #   Abbreviated gene names (used 1991 through 1996).

  # ID   - Identification Number 
  #   Research grant numbers, contract numbers, or both that designate
  #   financial support by any agency of the US PHS (Public Health Service).

  # IS   - ISSN
  #   International Standard Serial Number of the journal.

  # JC   - Journal Title Code
  #   MEDLINE unique three-character code for the journal.

  # JID  - NLM Unique ID
  #   Unique journal ID in NLM's catalog of books, journals, and audiovisuals.

  # LA   - Language
  #   The language in which the article was published.

  # LR   - Last Revision Date
  #   The date a change was made to the record during a maintenance procedure.

  # MHDA - MeSH Date
  #   The date MeSH terms were added to the citation. The MeSH date is the
  #   same as the Entrez date until MeSH are added.

  # PHST - Publication History Status Date
  #   History status date.

  # PS   - Personal Name as Subject
  #   Individual is the subject of the article.

  # PST  - Publication Status
  #   Publication status.

  # PT   - Publication Type
  #   The type of material the article represents.
  def pt
    @pubmed['PT'].strip.split(/\n/)   
  end
  alias publication_type pt

  # RF   - Number of References
  #   Number of bibliographic references for Review articles.

  # RIN  - Retraction In
  #   Retraction of the article

  # RN   - EC/RN Number
  #   Number assigned by the Enzyme Commission to designate a particular
  #   enzyme or by the Chemical Abstracts Service for Registry Numbers.

  # ROF  - Retraction Of
  #   Article being retracted.

  # RPF  - Republished From
  #   Original article.

  # SB   - Journal Subset
  #   Code for a specific set of journals.

  # SI   - Secondary Source Identifier
  #   Identifies a secondary source that supplies information, e.g., other
  #   data sources, databanks and accession numbers of molecular sequences
  #   discussed in articles.

  # TT   - Transliterated / Vernacular Title 
  #   Non-Roman alphabet language titles are transliterated.

  # UIN  - Update In
  #   Update to the article.

  # UOF  - Update Of
  #   The article being updated.

  # URLF - URL Full-Text
  #   Link to the full-text of article at provider's website. Links are
  #   incomplete. Use PmLink for the complete set of available links.
  #   [PmLink] http://www.ncbi.nlm.nih.gov/entrez/utils/pmlink_help.html

  # URLS - URL Summary
  #   Link to the article summary at provider's website. Links are
  #   incomplete. Use PmLink for the complete set of available links.
  #   [PmLink] http://www.ncbi.nlm.nih.gov/entrez/utils/pmlink_help.html

end # MEDLINE

end # Bio



