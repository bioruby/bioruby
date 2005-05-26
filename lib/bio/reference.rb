#
# bio/reference.rb - journal reference class
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
#  $Id: reference.rb,v 1.16 2005/05/26 13:16:23 k Exp $
#

module Bio

  class Reference

    def initialize(hash)
      hash.default = ''
      @authors	= hash['authors']	# [ "Hoge, J.P.", "Fuga, F.B." ]
      @title	= hash['title']		# "Title of the study."
      @journal	= hash['journal']	# "Theor. J. Hoge"
      @volume	= hash['volume']	# 12
      @issue	= hash['issue']		# 3
      @pages	= hash['pages']		# 123-145
      @year	= hash['year']		# 2001
      @pubmed	= hash['pubmed']	# 12345678
      @medline	= hash['medline']	# 98765432
      @abstract	= hash['abstract']
      @url	= hash['url']
      @mesh	= hash['mesh']
      @affiliations = hash['affiliations']
      @authors	= [] if @authors.empty?
      @mesh	= [] if @mesh.empty?
      @affiliations = [] if @affiliations.empty?
    end
    attr_reader :authors, :title, :journal, :volume, :issue, :pages, :year,
      :pubmed, :medline, :abstract, :url, :mesh, :affiliations

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

    def endnote
      lines = []
      lines << "%0 Journal Article"
      @authors.each do |author|
        lines << "%A #{author}"
      end
      lines << "%D #{@year}" unless @year.empty?
      lines << "%T #{@title}" unless @title.empty?
      lines << "%J #{@journal}" unless @journal.empty?
      lines << "%V #{@volume}" unless @volume.empty?
      lines << "%N #{@issue}" unless @issue.empty?
      lines << "%P #{@pages}" unless @pages.empty?
      lines << "%M #{@pubmed}" unless @pubmed.empty?
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

    def general
      authors = @authors.join(', ')
      "#{authors} (#{@year}). \"#{@title}\" #{@journal} #{@volume}:#{@pages}."
    end

    def rd(str = nil)
      @abstract ||= str
      lines = []
      lines << "== " + @title
      lines << "* " + authors_join(' and ')
      lines << "* #{@journal} #{@year} #{@volume}:#{@pages} [PMID:#{@pubmed}]"
      lines << @abstract
      return lines.join("\n\n")
    end

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

    def science
      if @authors.size > 4
	authors = rev_name(@authors[0]) + " et al."
      else
	authors = @authors.collect {|name| rev_name(name)}.join(', ')
      end
      page_from, = @pages.split('-')
      "#{authors}, #{@journal} #{@volume} #{page_from} (#{@year})."
    end

    def genome_biol
      authors = @authors.collect {|name| strip_dots(name)}.join(', ')
      journal = strip_dots(@journal)
      "#{authors}: #{@title} #{journal} #{@year}, #{@volume}:#{@pages}."
    end
    alias current genome_biol

    def genome_res
      authors = authors_join(' and ')
      "#{authors} #{@year}.\n  #{@title} #{@journal} #{@volume}: #{@pages}."
    end

    def nar
      authors = authors_join(' and ')
      "#{authors} (#{@year}) #{@title} #{@journal}, #{@volume}, #{@pages}."
    end

    def cell
      authors = authors_join(' and ')
      "#{authors} (#{@year}). #{@title} #{@journal} #{@volume}, #{pages}."
    end

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


  class References

    def initialize(ary = [])
      @references = ary
    end
    attr_accessor :references

    def append(a)
      @references.push(a) if a.is_a? Reference
      return self
    end

    def each
      @references.each do |x|
	yield x
      end
    end

  end

end



=begin

= Bio::Reference

--- Bio::Reference.new(hash)

--- Bio::Reference#authors -> Array
--- Bio::Reference#title -> String
--- Bio::Reference#journal -> String
--- Bio::Reference#volume -> Fixnum
--- Bio::Reference#issue -> Fixnum
--- Bio::Reference#pages -> String
--- Bio::Reference#year -> Fixnum
--- Bio::Reference#pubmed -> Fixnum
--- Bio::Reference#medline -> Fixnum
--- Bio::Reference#abstract -> String
--- Bio::Reference#url -> String
--- Bio::Reference#mesh -> Array
--- Bio::Reference#affiliations -> Array

--- Bio::Reference#format(style = nil, option = nil) -> String

--- Bio::Reference#endnote
--- Bio::Reference#bibitem(item = nil) -> String
--- Bio::Reference#bibtex(section = nil) -> String
--- Bio::Reference#rd(str = nil) -> String
--- Bio::Reference#nature(short = false) -> String
--- Bio::Reference#science -> String
--- Bio::Reference#genome_biol -> String
--- Bio::Reference#genome_res -> String
--- Bio::Reference#nar -> String
--- Bio::Reference#cell -> String
--- Bio::Reference#trends -> String
--- Bio::Reference#general -> String

= Bio::References

--- Bio::References.new(ary = [])

--- Bio::References#references -> Array
--- Bio::References#append(a) -> Bio::References
--- Bio::References#each -> Array

=end


