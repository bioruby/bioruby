#!/usr/bin/env ruby
#
# = pmfetch - PubMed client
#
# Copyright::   Copyright (C) 2004, 2005
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: br_pmfetch.rb,v 1.7 2007/04/05 23:35:39 trevor Exp $
#

PROG_VER  = '$Id: br_pmfetch.rb,v 1.7 2007/04/05 23:35:39 trevor Exp $'
PROG_NAME = File.basename($0)


require 'getoptlong'
require 'bio'


### formatting

class String
  def fill(fill_column = 80, prefix = '', separater = ' ')
    prefix = ' ' * prefix if prefix.is_a?(Integer)
    maxlen = fill_column - prefix.length
    raise "prefix is longer than fill_column" if maxlen <= 0

    cursor = pos = 0
    lines = []
    while cursor < self.length
      line = self[cursor, maxlen]
      pos = line.rindex(separater)
      pos = nil if line.length < maxlen
      if pos
        len = pos + separater.length
        lines << self[cursor, len]
        cursor += len
      else
        lines << self[cursor, maxlen]
        cursor += maxlen
      end
    end
    return lines.join("\n#{prefix}")
  end
end


module Bio
  class Reference
    def report
      if (num = @authors.size) > 10
        authors = "#{@authors[0]} et al. (#{num} authors)"
      elsif num > 4
        sep = ',' * (num - 1)
        authors = "#{@authors[0]}#{sep} #{@authors[-1]}"
      else
        authors = authors_join(' & ')
      end
      journal = "#{@journal} #{@year} #{@volume}(#{@issue}):#{@pages}"

      indent = 8
      prefix = ' ' * indent
      [
        "#{@pages[/\d+/]}".ljust(indent) + "#{@title}".fill(78, indent),
        authors,
        "#{journal} [PMID:#{@pubmed}]",
      ].join("\n#{prefix}")
    end
  end
end


class PMFetch

  class Examples < StandardError; end
  class Version < StandardError; end
  class Usage < StandardError; end

  ### default options

  def initialize
    @format = 'rd'
    @search_opts = {
      'retmax' => 20,
    }
    @query = nil
    @query_opts = []
    @pmid_list_only = false

    pmfetch
  end


  ### main

  def pmfetch
    begin
      set_options
      parse_options
      check_query
    rescue PMFetch::Examples
      puts examples
      exit
    rescue PMFetch::Version
      puts version
      exit
    rescue PMFetch::Usage
      puts usage
      exit
    rescue GetoptLong::MissingArgument, GetoptLong::InvalidOption
      puts usage
      exit
    end

    list = pm_esearch

    if list.empty?
      ;
    elsif @pmid_list_only
      puts list
    else
      pm_efetch(list)
    end
  end


  ### help

  def usage
%Q[
Usage: #{PROG_NAME} [options...] "query string"
    or #{PROG_NAME} --query "query string" [other options...] 

Options:
 -q  --query "genome AND virus"  Query string for PubMed search
 -t  --title "mobile elements"   Title of the article to search
 -j  --journal "genome res"      Journal title to search
 -v  --volume #                  Journal volume to search
 -i  --issue #                   Journal issue to search
 -p  --page #                    First page number of the article to search
 -a  --author "Altschul SF"      Author name to search
 -m  --mesh "SARS virus"         MeSH term to search
 -f  --format bibtex             Summary output format
     --pmidlist                  Output only a list of PubMed IDs
 -n  --retmax #                  Number of articles to retrieve at the maximum
 -N  --retstart #                Starting number of the articles to retrieve
 -s  --sort pub+date             Sort method for the summary output
     --reldate #                 Search articles published within recent # days
     --mindate YYYY/MM/DD        Search articles published after the date
     --maxdate YYYY/MM/DD        Search articles published before the date
     --help                      Output this help, then exit
     --examples                  Output examples, then exit
     --version                   Output version number, then exit

Formats:
 endnote, medline, bibitem, bibtex, report, rd,
 nature, science, genome_res, genome_biol, nar, current, trends, cell

Sort:
 author, journal, pub+date, page

See the following pages for the PubMed search options:
 http://www.ncbi.nlm.nih.gov/entrez/query/static/help/pmhelp.html
 http://www.ncbi.nlm.nih.gov/entrez/query/static/esearch_help.html

#{version}

]
  end

  def version
    PROG_VER
  end

  def examples
    DATA.read.gsub('PMFetch', PROG_NAME)
  end


  private


  ### options

  def set_options
    @parser = GetoptLong.new

    @parser.set_options(
	[ '--query',	'-q',	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--title',	'-t',	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--journal',	'-j',	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--volume',	'-v',	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--issue',	'-i',	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--page',	'-p',	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--author',	'-a',	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--mesh',	'-m',	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--format',	'-f',	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--pmidlist',		GetoptLong::NO_ARGUMENT ],
	[ '--retmax',	'-n',	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--retstart', '-N',	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--sort',	'-s',	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--reldate',		GetoptLong::REQUIRED_ARGUMENT ],
	[ '--mindate',		GetoptLong::REQUIRED_ARGUMENT ],
	[ '--maxdate',		GetoptLong::REQUIRED_ARGUMENT ],
	[ '--examples',		GetoptLong::NO_ARGUMENT ],
	[ '--help',		GetoptLong::NO_ARGUMENT ],
	[ '--version',		GetoptLong::NO_ARGUMENT ]
    )
  end

  def parse_options
    @parser.each_option do |optname, optarg|
      case optname
      when /--query/
        @query = optarg
      when /--title/
        @query_opts << "#{optarg}[ti]"
      when /--journal/
        @query_opts << "#{optarg}[ta]"
      when /--volume/
        @query_opts << "#{optarg}[vi]"
      when /--issue/
        @query_opts << "#{optarg}[ip]"
      when /--page/
        @query_opts << "#{optarg}[pg]"
      when /--author/
        @query_opts << "#{optarg}[au]"
      when /--mesh/
        @query_opts << "#{optarg}[mh]"
      when /--format/
        @format = optarg
      when /--pmidlist/
        @pmid_list_only = true
      when /--examples/
        raise PMFetch::Examples
      when /--help/
        raise PMFetch::Usage
      when /--version/
        raise PMFetch::Version
      when /--sort/
        @sort = optarg
        @search_opts["sort"] = @sort unless @sort == "page"
      else
        optname.delete!('-')
        @search_opts[optname] = optarg
      end
    end
  end


  ### check query

  def check_query
    p @query if $DEBUG
    @query ||= ARGV.join(" ") unless ARGV.empty?

    p @query if $DEBUG
    @query_str = [ @query, @query_opts ].flatten.compact.join(" AND ")

    p @query_str if $DEBUG
    if @query_str.empty?
      raise PMFetch::Usage
    end
  end


  ### search

  def pm_esearch
    return Bio::PubMed.esearch(@query_str, @search_opts)
  end

  def pm_efetch(list)
    entries = Bio::PubMed.efetch(list)

    if @format == 'medline'
      medline_format(entries)
    else
      entries = parse_entries(entries)
      if @sort == 'page'
        entries = sort_entries(entries)
      end
      if @format == 'report'
        report_format(entries)
      else
        other_format(entries)
      end
    end
  end


  ### output

  def medline_format(entries)
    entries.each do |entry|
      puts entry
      puts '//'
    end
  end

  def parse_entries(entries)
    entries.map { |entry| Bio::MEDLINE.new(entry) }
  end

  def sort_entries(entries)
    if RUBY_VERSION > "1.8.0"
       entries.sort_by { |x|
         [ x.journal, x.volume.to_i, x.issue.to_i, x.pages.to_i ]
       }
    else
      entries.map { |x|
        [ x.journal, x.volume.to_i, x.issue.to_i, x.pages.to_i, x ]
      }.sort { |a, b|
        a[0..3] <=> b[0..3]
      }.map { |y|
        y.pop
      }
    end
  end

  def report_format(entries)
    entries.each do |entry|
      puts entry.reference.report
      puts
    end
  end

  def other_format(entries)
    entries.each do |entry|
      puts entry.reference.format(@format)
      puts
    end
  end

end


PMFetch.new


__END__

= Examples : PubMed search

These four lines will do the same job.

  % PMFetch transcription factor
  % PMFetch "transcription factor"
  % PMFetch --query "transcription factor"
  % PMFetch -q "transcription factor"


Retrieve max 100 artiecles (20 is a NCBI's default) at a time, use --retmax as

  % PMFetch -q "transcription factor" --retmax 100

and, to retrieve next 100 articles, use --retstart as

  % PMFetch -q "transcription factor" --retmax 100 --retstart 100


You can narrow the search target for an issue of the journal.

  % PMFetch --journal development --volume 131 --issue 3  transcription factor


Short options are also available.

  % PMFetch -j development -v 131 -i 3  transcription factor


Search articles indexed in PubMed within these 90 days.

  % PMFetch -q "transcription factor" --reldate 90


Search articles indexed in PubMed during the period of 2001/04/01 to 2001/08/31

  % PMFetch -q "transcription factor" --mindate 2001/04/01 --maxdate 2001/08/31


Output format can be changed by --format option.

  % PMFetch -q "transcription factor" -j development -v 131 -i 3 -f report
  % PMFetch -q "transcription factor" -j development -v 131 -i 3 -f rd
  % PMFetch -q "transcription factor" -j development -v 131 -i 3 -f endnote
  % PMFetch -q "transcription factor" -j development -v 131 -i 3 -f medline
  % PMFetch -q "transcription factor" -j development -v 131 -i 3 -f bibitem
  % PMFetch -q "transcription factor" -j development -v 131 -i 3 -f bibtex
  % PMFetch -q "transcription factor" -j development -v 131 -i 3 -f nature
  % PMFetch -q "transcription factor" -j development -v 131 -i 3 -f science


Generate title listings for the journal report meeting (don't forget
to inclease the number of --retmax for fetching all titles).

  % PMFetch -f report -j development -v 131 -i 3 -n 100


Search by author name.

  % PMFetch -a "Karlin S"
  % PMFetch -a "Koonin EV"


Search by MeSH term.

  % PMFetch -m "computational biology"
  % PMFetch -m "SARS virus"


Search by PubMed ID (PMID).

  % PMFetch 12345


Output PMID only.

  % PMFetch --pmidlist tardigrada


