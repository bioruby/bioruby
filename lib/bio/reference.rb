#
# bio/reference.rb - journal reference class
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
#  $Id: reference.rb,v 1.5 2001/11/02 10:35:51 katayama Exp $
#

=begin

= Bio::Reference

--- Bio::Reference#new(hash)

--- Bio::Reference#authors
--- Bio::Reference#title
--- Bio::Reference#journal
--- Bio::Reference#volume
--- Bio::Reference#issue
--- Bio::Reference#pages
--- Bio::Reference#year
--- Bio::Reference#pubmed
--- Bio::Reference#medline

--- Bio::Reference#format(style, option)

--- Bio::Reference#bibitem
--- Bio::Reference#bibtex
--- Bio::Reference#nature(short)
--- Bio::Reference#science
--- Bio::Reference#genomebiology
--- Bio::Reference#genomeres
--- Bio::Reference#nar
--- Bio::Reference#cell
--- Bio::Reference#trends
--- Bio::Reference#general

=end


module Bio

class Reference

  def initialize(hash)
    @authors	= hash['authors']	# [ "Hoge, J.P.", "Fuga, F.B." ]
    @title	= hash['title']		# "Title of the study."
    @journal	= hash['journal']	# "Theor. J. Hoge"
    @volume	= hash['volume']	# 12
    @issue	= hash['issue']		# 3
    @pages	= hash['pages']		# 123-145
    @year	= hash['year']		# 2001
    @pubmed	= hash['pubmed']	# 12345678
    @medline	= hash['medline']	# 98765432
  end
  attr_reader :authors, :title, :journal, :volume, :issue, :pages, :year, :pubmed, :medline

  def format(style = nil, option = nil)
    case style
    when /^nature$/i
      return nature(option)
    when /^science$/i
      return science
    when /^genome\s*biology$/i
      return genomebiology
    when /^genome\s*res/i
      return genomeres
    when /^nar$/i
      return nar
    when /^current/i
      return current
    when /^trends/i
      return trends
    when /^cell$/i
      return cell
    when 'bibitem'
      return bibitem(option)
    when 'bibtex'
      return bibtex(option)
    else
      return general
    end
  end

  def bibitem(item = nil)
    item  = "PMID@pubmed" unless item
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
    authors = authors_join(' and ')
    pages   = @pages.sub('-', '--')
    return <<-END
	@#{section}{PMID#{@pubmed},
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

  def nature(short = nil)
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

  def genomebiology
    authors = @authors.collect {|name| strip_dots(name)}.join(', ')
    journal = strip_dots(@journal)
    "#{authors}: #{@title} #{journal} #{@year}, #{@volume}:#{@pages}."
  end
  alias current genomebiology

  def genomeres
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

  def general
    authors = @authors.collect {|name| strip_dots(name)}.join(', ')
    journal = strip_dots(@journal)
    "#{authors} \"#{@title}\", #{journal} #{@volume}:#{@pages} (#{@year})"
  end


  private

  def strip_dots(data)
    data.tr(',.', '')
  end

  def authors_join(amp, sep = ', ')
    authors = @authors.clone
    if authors.length > 1
      last = authors.pop
      authors = authors.join(sep) + "#{amp}" + last
    else
      authors = authors.pop
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

end				# module Bio

