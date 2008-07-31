#
# = bio/reference.rb - Journal reference classes
#
# Copyright::   Copyright (C) 2001, 2006, 2008
#               Toshiaki Katayama <k@bioruby.org>,
#               Ryan Raaum <ryan@raaum.org>,
#               Jan Aerts <jandot@bioruby.org>
# License::     The Ruby License
#
# $Id: reference.rb,v 1.24.2.7 2008/06/17 12:23:49 ngoto Exp $
#

module Bio

  # = DESCRIPTION
  #
  # A class for journal reference information.
  #
  # = USAGE
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

    # String with title of the study
    attr_reader :title

    # String with journal name
    attr_reader :journal

    # volume number (typically Fixnum)
    attr_reader :volume
    
    # issue number (typically Fixnum)
    attr_reader :issue

    # page range (typically String, e.g. "123-145")
    attr_reader :pages

    # year of publication (typically Fixnum)
    attr_reader :year

    # pubmed identifier (typically Fixnum)
    attr_reader :pubmed

    # medline identifier (typically Fixnum)
    attr_reader :medline

    # DOI identifier (typically String, e.g. "10.1126/science.1110418")
    attr_reader :doi
    
    # Abstract text in String.
    attr_reader :abstract

    # An URL String.
    attr_reader :url

    # MeSH terms in an Array.
    attr_reader :mesh

    # Affiliations in an Array.
    attr_reader :affiliations
    
    # Sequence number in EMBL/GenBank records
    attr_reader :embl_gb_record_number
    
    # Position in a sequence that this reference refers to
    attr_reader :sequence_position

    # Comments for the reference (typically Array of String, or nil)
    attr_reader :comments

    # Create a new Bio::Reference object from a Hash of values. 
    # Data is extracted from the values for keys:
    #
    # * authors - expected value: Array of Strings
    # * title - expected value: String
    # * journal - expected value: String
    # * volume - expected value: Fixnum or String
    # * issue - expected value: Fixnum or String
    # * pages - expected value: String
    # * year - expected value: Fixnum or String
    # * pubmed - expected value: Fixnum or String
    # * medline - expected value: Fixnum or String
    # * abstract - expected value: String
    # * url - expected value: String
    # * mesh - expected value: Array of Strings
    # * affiliations - expected value: Array of Strings
    #
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
    # ---
    # *Arguments*:
    # * (required) _hash_: Hash
    # *Returns*:: Bio::Reference object
    def initialize(hash)
      @authors  = hash['authors'] || [] # [ "Hoge, J.P.", "Fuga, F.B." ]
      @title    = hash['title']   || '' # "Title of the study."
      @journal  = hash['journal'] || '' # "Theor. J. Hoge"
      @volume   = hash['volume']  || '' # 12
      @issue    = hash['issue']   || '' # 3
      @pages    = hash['pages']   || '' # 123-145
      @year     = hash['year']    || '' # 2001
      @pubmed   = hash['pubmed']  || '' # 12345678
      @medline  = hash['medline'] || '' # 98765432
      @doi      = hash['doi']
      @abstract = hash['abstract'] || '' 
      @url      = hash['url']
      @mesh     = hash['mesh'] || []
      @embl_gb_record_number = hash['embl_gb_record_number'] || nil
      @sequence_position = hash['sequence_position'] || nil
      @comments  = hash['comments']
      @affiliations = hash['affiliations'] || []
    end

    # Formats the reference in a given style.
    #
    # Styles:
    # 0. nil - general
    # 1. endnote - Endnote
    # 2. bibitem - Bibitem (option available)
    # 3. bibtex - BiBTeX (option available)
    # 4. rd - rd (option available)
    # 5. nature - Nature (option available)
    # 6. science - Science
    # 7. genome_biol - Genome Biology
    # 8. genome_res - Genome Research
    # 9. nar - Nucleic Acids Research
    # 10. current - Current Biology
    # 11. trends - Trends in *
    # 12. cell - Cell Press
    #
    # See individual methods for details. Basic usage is:
    #
    #   # ref is Bio::Reference object
    #   # using simplest possible call (for general style)
    #   puts ref.format
    #   
    #   # output in Nature style
    #   puts ref.format("nature")      # alternatively, puts ref.nature
    #
    #   # output in Nature short style (see Bio::Reference#nature)
    #   puts ref.format("nature",true) # alternatively, puts ref.nature(true)
    # ---
    # *Arguments*:
    # * (optional) _style_: String with style identifier
    # * (optional) _options_: Options for styles accepting one
    # *Returns*:: String
    def format(style = nil, *options)
      case style
      when 'embl'
        return embl
      when 'endnote'
        return endnote
      when 'bibitem'
        return bibitem(*options)
      when 'bibtex'
        return bibtex(*options)
      when 'rd'
        return rd(*options)
      when /^nature$/i
        return nature(*options)
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

    # Returns reference formatted in the Endnote style.
    #
    #   # ref is a Bio::Reference object
    #   puts ref.endnote
    #
    #     %0 Journal Article
    #     %A Hoge, J.P.
    #     %A Fuga, F.B.
    #     %D 2001
    #     %T Title of the study.
    #     %J Theor. J. Hoge
    #     %V 12
    #     %N 3
    #     %P 123-145
    #     %M 12345678
    #     %U http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=PubMed&dopt=Citation&list_uids=12345678
    #     %X Hoge fuga. ...
    # ---
    # *Returns*:: String
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
      u = @url.empty? ? pubmed_url : @url
      lines << "%U #{u}" unless u.empty?
      lines << "%X #{@abstract}" unless @abstract.empty?
      @mesh.each do |term|
        lines << "%K #{term}"
      end
      lines << "%+ #{@affiliations.join(' ')}" unless @affiliations.empty?
      return lines.join("\n")
    end

    # Returns reference formatted in the EMBL style.
    #
    #   # ref is a Bio::Reference object
    #   puts ref.embl
    #
    #     RP   1-1859
    #     RX   PUBMED; 1907511.
    #     RA   Oxtoby E., Dunn M.A., Pancoro A., Hughes M.A.;
    #     RT   "Nucleotide and derived amino acid sequence of the cyanogenic
    #     RT   beta-glucosidase (linamarase) from white clover (Trifolium repens L.)";
    #     RL   Plant Mol. Biol. 17(2):209-219(1991).
    def embl
      r = self
      Bio::Sequence::Format::NucFormatter::Embl.new('').instance_eval {
        reference_format_embl(r)
      }
    end

    # Returns reference formatted in the bibitem style
    #
    #   # ref is a Bio::Reference object
    #   puts ref.bibitem
    #
    #     \bibitem{PMID:12345678}
    #     Hoge, J.P., Fuga, F.B.
    #     Title of the study.,
    #     {\em Theor. J. Hoge}, 12(3):123--145, 2001.
    # ---
    # *Arguments*:
    # * (optional) _item_: label string (default: <tt>"PMID:#{pubmed}"</tt>).
    # *Returns*:: String
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

    # Returns reference formatted in the BiBTeX style.
    #
    #   # ref is a Bio::Reference object
    #   puts ref.bibtex
    #
    #     @article{PMID:12345678,
    #       author  = {Hoge, J.P. and Fuga, F.B.},
    #       title   = {Title of the study.},
    #       journal = {Theor. J. Hoge},
    #       year    = {2001},
    #       volume  = {12},
    #       number  = {3},
    #       pages   = {123--145},
    #     }
    #
    #   # using a different section (e.g. "book")
    #   # (but not really configured for anything other than articles)
    #   puts ref.bibtex("book")
    #
    #     @book{PMID:12345678,
    #       author  = {Hoge, J.P. and Fuga, F.B.},
    #       title   = {Title of the study.},
    #       journal = {Theor. J. Hoge},
    #       year    = {2001},
    #       volume  = {12},
    #       number  = {3},
    #       pages   = {123--145},
    #     }    
    # ---
    # *Arguments*:
    # * (optional) _section_: BiBTeX section as String
    # * (optional) _label_: Label string cited by LaTeX documents.
    #                       Default is <tt>"PMID:#{pubmed}"</tt>.
    # * (optional) _keywords_: Hash of additional keywords,
    #                          e.g. { 'abstract' => 'This is abstract.' }.
    #                          You can also override default keywords.
    #                          To disable default keywords, specify false as
    #                          value, e.g. { 'url' => false, 'year' => false }.
    # *Returns*:: String
    def bibtex(section = nil, label = nil, keywords = {})
      section = "article" unless section
      authors = authors_join(' and ', ' and ')
      thepages = pages.to_s.empty? ? nil : pages.sub(/\-/, '--')
      unless label then
        label = "PMID:#{pubmed}"
      end
      theurl = if !(url.to_s.empty?) then
                 url
               elsif pmurl = pubmed_url and !(pmurl.to_s.empty?) then
                 pmurl
               else
                 nil
               end
      hash = {
        'author'  => authors.empty?    ? nil : authors,
        'title'   => title.to_s.empty? ? nil : title,
        'number'  => issue.to_s.empty? ? nil : issue,
        'pages'   => thepages,
        'url'     => theurl
      }
      keys = %w( author title journal year volume number pages url )
      keys.each do |k|
        hash[k] = self.__send__(k.intern) unless hash.has_key?(k)
      end
      hash.merge!(keywords) { |k, v1, v2| v2.nil? ? v1 : v2 }
      bib = [ "@#{section}{#{label}," ]
      keys.concat((hash.keys - keys).sort)
      keys.each do |kw|
        ref = hash[kw]
        bib.push "  #{kw.ljust(12)} = {#{ref}}," if ref
      end
      bib.push "}\n"
      return bib.join("\n")
    end

    # Returns reference formatted in a general/generic style.
    #
    #   # ref is a Bio::Reference object
    #   puts ref.general
    #
    #     Hoge, J.P., Fuga, F.B. (2001). "Title of the study." Theor. J. Hoge 12:123-145.
    # ---
    # *Returns*:: String
    def general
      authors = @authors.join(', ')
      "#{authors} (#{@year}). \"#{@title}\" #{@journal} #{@volume}:#{@pages}."
    end

    # Return reference formatted in the RD style.
    #
    #   # ref is a Bio::Reference object
    #   puts ref.rd
    #
    #     == Title of the study.
    #     
    #     * Hoge, J.P. and Fuga, F.B.
    #     
    #     * Theor. J. Hoge 2001 12:123-145 [PMID:12345678]
    #     
    #     Hoge fuga. ...
    #
    # An optional string argument can be supplied, but does nothing.
    # ---
    # *Arguments*:
    # * (optional) str: String (default nil)
    # *Returns*:: String
    def rd(str = nil)
      @abstract ||= str
      lines = []
      lines << "== " + @title
      lines << "* " + authors_join(' and ')
      lines << "* #{@journal} #{@year} #{@volume}:#{@pages} [PMID:#{@pubmed}]"
      lines << @abstract
      return lines.join("\n\n")
    end

    # Formats in the Nature Publishing Group 
    # (http://www.nature.com) style.
    #
    #   # ref is a Bio::Reference object
    #   puts ref.nature
    #
    #     Hoge, J.P. & Fuga, F.B. Title of the study. Theor. J. Hoge 12, 123-145 (2001).
    #
    #   # optionally, output short version
    #   puts ref.nature(true)  # or puts ref.nature(short=true)
    #
    #     Hoge, J.P. & Fuga, F.B. Theor. J. Hoge 12, 123-145 (2001).
    # ---
    # *Arguments*:
    # * (optional) _short_: Boolean (default false)
    # *Returns*:: String
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

    # Returns reference formatted in the 
    # Science[http://www.sciencemag.org] style.
    #
    #   # ref is a Bio::Reference object
    #   puts ref.science
    #
    #     J.P. Hoge, F.B. Fuga, Theor. J. Hoge 12 123 (2001).
    # ---
    # *Returns*:: String
    def science
      if @authors.size > 4
        authors = rev_name(@authors[0]) + " et al."
      else
        authors = @authors.collect {|name| rev_name(name)}.join(', ')
      end
      page_from, = @pages.split('-')
      "#{authors}, #{@journal} #{@volume} #{page_from} (#{@year})."
    end

    # Returns reference formatted in the Genome Biology 
    # (http://genomebiology.com) style.
    #
    #   # ref is a Bio::Reference object
    #   puts ref.genome_biol
    #
    #     Hoge JP, Fuga FB: Title of the study. Theor J Hoge 2001, 12:123-145.
    # ---
    # *Returns*:: String
    def genome_biol
      authors = @authors.collect {|name| strip_dots(name)}.join(', ')
      journal = strip_dots(@journal)
      "#{authors}: #{@title} #{journal} #{@year}, #{@volume}:#{@pages}."
    end
    
    # Returns reference formatted in the Current Biology 
    # (http://current-biology.com) style. (Same as the Genome Biology style)
    #
    #   # ref is a Bio::Reference object
    #   puts ref.current
    #
    #     Hoge JP, Fuga FB: Title of the study. Theor J Hoge 2001, 12:123-145.
    # ---
    # *Returns*:: String
    def current 
      self.genome_biol
    end

    # Returns reference formatted in the Genome Research 
    # (http://genome.org) style.
    #
    #   # ref is a Bio::Reference object
    #   puts ref.genome_res
    #
    #     Hoge, J.P. and Fuga, F.B. 2001.
    #       Title of the study. Theor. J. Hoge 12: 123-145.
    # ---
    # *Returns*:: String
    def genome_res
      authors = authors_join(' and ')
      "#{authors} #{@year}.\n  #{@title} #{@journal} #{@volume}: #{@pages}."
    end

    # Returns reference formatted in the Nucleic Acids Reseach 
    # (http://nar.oxfordjournals.org) style.
    #
    #   # ref is a Bio::Reference object
    #   puts ref.nar
    #
    #     Hoge, J.P. and Fuga, F.B. (2001) Title of the study. Theor. J. Hoge, 12, 123-145.
    # ---
    # *Returns*:: String
    def nar
      authors = authors_join(' and ')
      "#{authors} (#{@year}) #{@title} #{@journal}, #{@volume}, #{@pages}."
    end

    # Returns reference formatted in the 
    # CELL[http://www.cell.com] Press style.
    #
    #   # ref is a Bio::Reference object
    #   puts ref.cell
    #
    #     Hoge, J.P. and Fuga, F.B. (2001). Title of the study. Theor. J. Hoge 12, 123-145.
    # ---
    # *Returns*:: String
    def cell
      authors = authors_join(' and ')
      "#{authors} (#{@year}). #{@title} #{@journal} #{@volume}, #{pages}."
    end
    
    # Returns reference formatted in the 
    # TRENDS[http://www.trends.com] style.
    #
    #   # ref is a Bio::Reference object
    #   puts ref.trends
    #
    #     Hoge, J.P. and Fuga, F.B. (2001) Title of the study. Theor. J. Hoge 12, 123-145
    # ---
    # *Returns*:: String
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

    # Returns a valid URL for pubmed records
    #
    # *Returns*:: String
    def pubmed_url
      unless @pubmed.to_s.empty?
        cgi = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi"
        opts = "cmd=Retrieve&db=PubMed&dopt=Citation&list_uids"
        return "#{cgi}?#{opts}=#{@pubmed}"
      end
      ''
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

end

