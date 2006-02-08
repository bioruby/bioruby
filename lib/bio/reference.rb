#
# = bio/reference.rb - Journal reference classes
#
# Copyright::   Copyright (C) 2001 
#               KATAYAMA Toshiaki <k@bioruby.org>
# Lisence::     LGPL
#
# $Id: reference.rb,v 1.21 2006/02/08 15:06:26 nakao Exp $
#
# == Description
# 
# Journal reference classes.
#
# == Examples
#
# == References
#
# 
#
#--
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
#++
#

module Bio

  # A class for journal reference information.
  #
  # === Examples
  # 
  #    hash = {'authors' => [ "Hoge, J.P.", "Fuga, F.B." ], 
  #            'title' => "Title of the study.",
  #            'journal' => "Theor. J. Hoge", 
  #            'volume' => 12, 
  #            'issue' => 3, 
  #            'pages' => "123-145",
  #            'year' => 2001, 
  #            'pubmed' => 12345678, 
  #            'medline' => 98765432, 
  #            'abstract' => "Hoge fuga. ...",
  #            'url' => "http://example.com", 
  #            'mesh' => [], 
  #            'affiliations' => []}
  #    ref = Bio::Reference.new(hash)
  #
  #    # Formats in the BiBTeX style.
  #    ref.format("bibtex")
  #    
  #    # Short-cut for Bio::Reference#format("bibtex")
  #    ref.bibtex
  #
  class Reference

    # Author names in an Array, [ "Hoge, J.P.", "Fuga, F.B." ].
    attr_reader :authors

    # "Title of the study."
    attr_reader :title

    # "Theor. J. Hoge"
    attr_reader :journal

    # 12
    attr_reader :volume
    
    # 3
    attr_reader :issue

    # "123-145"
    attr_reader :pages

    # 2001
    attr_reader :year

    # 12345678
    attr_reader :pubmed

    # 98765432
    attr_reader :medline
    
    # Abstract test in String.
    attr_reader :abstract

    # A URL String.
    attr_reader :url

    # MeSH terms in an Array.
    attr_reader :mesh

    # Affiliations in an Array.
    attr_reader :affiliations

    # 
    def initialize(hash)
      hash.default = ''
      @authors  = hash['authors'] # [ "Hoge, J.P.", "Fuga, F.B." ]
      @title    = hash['title']   # "Title of the study."
      @journal  = hash['journal'] # "Theor. J. Hoge"
      @volume   = hash['volume']  # 12
      @issue    = hash['issue']   # 3
      @pages    = hash['pages']   # 123-145
      @year     = hash['year']    # 2001
      @pubmed   = hash['pubmed']  # 12345678
      @medline  = hash['medline'] # 98765432
      @abstract = hash['abstract']
      @url      = hash['url']
      @mesh     = hash['mesh']
      @affiliations = hash['affiliations']
      @authors = [] if @authors.empty?
      @mesh    = [] if @mesh.empty?
      @affiliations = [] if @affiliations.empty?
    end

    # Formats the reference in a given style.
    #
    # Styles:
    # 0. nil - general
    # 1. endnote - Endnote
    # 2. bibitem - Bibitem (option acceptable)
    # 3. bibtex - BiBTeX (option acceptable)
    # 4. rd - rd (option acceptable)
    # 5. nature - Nature (option acceptable)
    # 6. science - Science
    # 7. genome_biol - Genome Biology
    # 8. genome_res - Genome Research
    # 9. nar - Nucleic Acids Research
    # 10. current - Current Biology
    # 11. trends - Trends in *
    # 12. cell - Cell Press
    def format(style = nil, option = nil)
      case style
      when 'endnote'
        return endnote
      when 'bibitem'
        return bibitem(option)
      when 'bibtex'
        return bibtex(option)
      when 'rd'
        return rd(option)
      when /^nature$/i
        return nature(option)
      when /^science$/i
        return science
      when /^genome\s*_*biol/i
        return genome_biol
      when /^genome\s*_*res/i
        return genome_res
      when /^nar$/i
        return nar
      when /^current/i
        return current
      when /^trends/i
        return trends
      when /^cell$/i
        return cell
      else
        return general
      end
    end

    # Formats in the Endonote style.
    def endnote
      lines = []
      lines << "%0 Journal Article"
      @authors.each do |author|
        lines << "%A #{author}"
      end
      lines << "%D #{@year}" unless @year.to_s.empty?
      lines << "%T #{@title}" unless @title.empty?
      lines << "%J #{@journal}" unless @journal.empty?
      lines << "%V #{@volume}" unless @volume.to_s.empty?
      lines << "%N #{@issue}" unless @issue.to_s.empty?
      lines << "%P #{@pages}" unless @pages.empty?
      lines << "%M #{@pubmed}" unless @pubmed.to_s.empty?
      if @pubmed
        cgi = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi"
        opts = "cmd=Retrieve&db=PubMed&dopt=Citation&list_uids"
        @url = "#{cgi}?#{opts}=#{@pubmed}"
      end
      lines << "%U #{@url}" unless @url.empty?
      lines << "%X #{@abstract}" unless @abstract.empty?
      @mesh.each do |term|
        lines << "%K #{term}"
      end
      lines << "%+ #{@affiliations.join(' ')}" unless @affiliations.empty?
      return lines.join("\n")
    end

    # Formats in the bibitem.
    def bibitem(item = nil)
      item  = "PMID:#{@pubmed}" unless item
      pages = @pages.sub('-', '--')
      return <<-"END".collect {|line| line.strip}.join("\n")
        \\bibitem{#{item}}
        #{@authors.join(', ')}
        #{@title},
        {\\em #{@journal}}, #{@volume}(#{@issue}):#{pages}, #{@year}.
      END
    end

    # Formats in the BiBTeX style.
    def bibtex(section = nil)
      section = "article" unless section
      authors = authors_join(' and ', ' and ')
      pages   = @pages.sub('-', '--')
      return <<-"END".gsub(/\t/, '')
        @#{section}{PMID:#{@pubmed},
          author  = {#{authors}},
          title   = {#{@title}},
          journal = {#{@journal}},
          year    = {#{@year}},
          volume  = {#{@volume}},
          number  = {#{@issue}},
          pages   = {#{pages}},
        }
      END
    end

    # Formats in a general style.                
    def general
      authors = @authors.join(', ')
      "#{authors} (#{@year}). \"#{@title}\" #{@journal} #{@volume}:#{@pages}."
    end

    # Formats in the RD style.
    def rd(str = nil)
      @abstract ||= str
      lines = []
      lines << "== " + @title
      lines << "* " + authors_join(' and ')
      lines << "* #{@journal} #{@year} #{@volume}:#{@pages} [PMID:#{@pubmed}]"
      lines << @abstract
      return lines.join("\n\n")
    end

    # Formats in the Nature Publish Group style.
    # * http://www.nature.com
    def nature(short = false)
      if short
        if @authors.size > 4
          authors = "#{@authors[0]} et al."
        elsif @authors.size == 1
          authors = "#{@authors[0]}"
        else
          authors = authors_join(' & ')
        end
        "#{authors} #{@journal} #{@volume}, #{@pages} (#{@year})."
      else
        authors = authors_join(' & ')
        "#{authors} #{@title} #{@journal} #{@volume}, #{@pages} (#{@year})."
      end
    end

    # Formats in the Science style.
    # * http://www.siencemag.com/
    def science
      if @authors.size > 4
        authors = rev_name(@authors[0]) + " et al."
      else
        authors = @authors.collect {|name| rev_name(name)}.join(', ')
      end
      page_from, = @pages.split('-')
      "#{authors}, #{@journal} #{@volume} #{page_from} (#{@year})."
    end

    # Formats in the Genome Biology style.
    # * http://genomebiology.com/
    def genome_biol
      authors = @authors.collect {|name| strip_dots(name)}.join(', ')
      journal = strip_dots(@journal)
      "#{authors}: #{@title} #{journal} #{@year}, #{@volume}:#{@pages}."
    end
    # Formats in the Current Biology style.
    # * http://www.current-biology.com/
    alias current genome_biol

    # Formats in the Genome Research style.
    # * http://genome.org/
    def genome_res
      authors = authors_join(' and ')
      "#{authors} #{@year}.\n  #{@title} #{@journal} #{@volume}: #{@pages}."
    end

    # Formats in the Nucleic Acids Reseach style.
    # * http://nar.oxfordjournals.org/
    def nar
      authors = authors_join(' and ')
      "#{authors} (#{@year}) #{@title} #{@journal}, #{@volume}, #{@pages}."
    end

    # Formats in the CELL Press style.
    # http://www.cell.com/
    def cell
      authors = authors_join(' and ')
      "#{authors} (#{@year}). #{@title} #{@journal} #{@volume}, #{pages}."
    end
    
    # Formats in the TRENDS Journals.
    # * http://www.trends.com/
    def trends
      if @authors.size > 2
        authors = "#{@authors[0]} et al."
      elsif @authors.size == 1
        authors = "#{@authors[0]}"
      else
        authors = authors_join(' and ')
      end
      "#{authors} (#{@year}) #{@title} #{@journal} #{@volume}, #{@pages}"
    end


    private

    def strip_dots(data)
      data.tr(',.', '') if data
    end

    def authors_join(amp, sep = ', ')
      authors = @authors.clone
      if authors.length > 1
        last = authors.pop
        authors = authors.join(sep) + "#{amp}" + last
      elsif authors.length == 1
        authors = authors.pop
      else
        authors = ""
      end
    end

    def rev_name(name)
      if name =~ /,/
        name, initial = name.split(/,\s+/)
        name = "#{initial} #{name}"
      end
      return name
    end

  end

  # Set of Bio::Reference.
  #
  # === Examples
  #
  #   refs = Bio::References.new
  #   refs.append(Bio::Reference.new(hash))
  #   refs.each do |reference|
  #     ...
  #   end
  #
  class References

    # Array of Bio::Reference.
    attr_accessor :references

    # 
    def initialize(ary = [])
      @references = ary
    end


    # Append a Bio::Reference object.
    def append(reference)
      @references.push(reference) if reference.is_a? Reference
      return self
    end

    # Iterates each Bio::Reference object.
    def each
      @references.each do |reference|
        yield reference
      end
    end

  end

end

