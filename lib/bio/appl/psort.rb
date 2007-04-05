module Bio

#
# = bio/appl/psort.rb - PSORT, protein sorting site prediction systems
#
# Copyright::   Copyright (C) 2003-2006
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id: psort.rb,v 1.13 2007/04/05 23:35:39 trevor Exp $
#

require 'bio/appl/psort/report'
autoload :FastaFormat, 'bio/db/fasta'
autoload :Command, 'bio/command'
require 'cgi'
require 'uri'

  # == A client for PSORT WWW Server 
  #
  # A client for PSORT WWW Server for predicting protein subcellular 
  # localization.
  #
  # PSORT family members,
  # 1. PSORT
  # 2. PSORT II
  # 3. iPSORT
  # 4. PSORT-B  http://psort.org
  # 5. WoLF-PSORT
  #
  # == References
  #
  # * http://psort.hgc.jp/
  #
  class PSORT

    # a Hash for PSORT official hosts:
    #   Key      value (host)
    #   -------  -----------------------
    #   IMSUT    psort.ims.u-tokyo.ac.jp  
    #   Okazaki  psort.nibb.ac.jp        
    #   Peking   srs.pku.edu.cn:8088     
    ServerURI = {
      :IMSUT   => {
        :PSORT1 => URI.parse("http://psort.hgc.jp/cgi-bin/okumura.pl"),
        :PSORT2 => URI.parse("http://psort.hgc.jp/cgi-bin/runpsort.pl") },
      :Okazaki => {
        :PSORT1 => URI.parse("http://psort.nibb.ac.jp/cgi-bin/okumura.pl"),
        :PSORT2 => URI.parse("http://psort.nibb.ac.jp/cgi-bin/runpsort.pl") },
      :Peking  => {
        :PSORT1 => URI.parse("http:///src.pku.edu.cn:8088/cgi-bin/okumura.pl"),
        :PSORT2 => URI.parse("http://src.pku.edu.cn:8088/cgi-bin/runpsort.pl") },
    }

    # = Generic CGI client class
    # A generic CGI client class for Bio::PSORT::* classes.
    # The class provides an interface for CGI argument processing and output 
    # report parsing.
    #
    # == Example
    # 
    #  class NewClient < CGIDriver
    #    def initialize(host, path)
    #      super(host, path)
    #    end
    #  end
    #  private
    #  def make_args(query)
    #    # ...
    #  end
    #  def parse_report(output)
    #    # ...
    #  end
    #
    class CGIDriver

      # CGI query argument in Hash ({key => value, ...}).
      attr_accessor :args

      # CGI output raw text
      attr_reader :report


      # Sets remote host name and cgi path or uri.
      #
      # == Examples
      #
      #   CGIDriver.new("localhost", "/cgi-bin/psort_www.pl")
      #
      #   CGIDriver.new("http://localhost/cgi-bin/psort_www.pl")
      #
      #   CGIDriver.new(URI.parse("http://localhost/cgi-bin/psort_www.pl"))
      #
      def initialize(host = '', path = '')
        case host.to_s
        when /^http:/
          uri = host.to_s
        else
          uri = 'http://' + host + '/' + path
        end
        @uri = URI.parse(uri)
        @args = {}
        @report = ''
      end


      # Executes a CGI ``query'' and returns aReport
      def exec(query)
        data = make_args(query)  

        begin
          result = nil
          Bio::Command.start_http(@uri.host) {|http|
            result, = http.post(@uri.path, data)
          }
          @report = result.body
          output = parse_report(@report)
        end

        return output
      end

      private

      # Bio::CGIDriver#make_args. An API skelton.
      def make_args(args_hash)
        # The routin should be provided in the inherited class
      end

      # Bio::CGIDriver#parse_report. An API skelton.
      def parse_report(result_body)
        # The routin should be provided in the inherited class
      end

      # Erases HTML tags
      def erase_html_tags(str)
        return str.gsub(/<\S.*?>/, '')
      end

      # Returns CGI argument text in String (key=value&) from a Hash ({key=>value}).
      def args_join(hash, delim = '&')
        tmp = []
        hash.each do |key, val|
          tmp << CGI.escape(key.to_s) + '=' + CGI.escape(val.to_s)
        end
        return tmp.join(delim)  # not ';' but '&' in the psort cgi script.
      end

    end # class CGIDriver



    # = Bio::PSORT::PSORT1
    #
    # Bio::PSORT::PSORT1 is a wapper class for the original PSORT program.
    #
    # == Example
    # 
    #  serv = Bio::PSORT::PSORT1.imsut
    #  serv.title = 'Query_title_splited_by_white space'
    #  serv.exec(seq, false)  # seq.class => String
    #  serv.exec(seq)
    #  report = serv.exec(Bio::FastaFormat.new(seq))
    #  report_raw = serv.exec(Bio::FastaFormat.new(seq), false)
    # 
    # == References
    #
    # 1. Nakai, K. and Kanehisa, M., A knowledge base for predicting protein 
    #    localization sites in eukaryotic cells, Genomics 14, 897-911 (1992).
    #    [PMID:1478671]
    #
    class PSORT1

      autoload :Report, 'bio/appl/psort/report'

      # Returns a PSORT1 CGI Driver object (Bio::PSORT::PSORT1::Remote)     
      # connecting to the IMSUT server.
      def self.imsut
        self.new(Remote.new(ServerURI[:IMSUT][:PSORT1]))
      end


      # Returns a PSORT1 CGI Driver object (Bio::PSORT::PSORT1::Remote)
      # connecting to the NIBB server.
      def self.okazaki
        self.new(Remote.new(ServerURI[:Okazaki][:PSORT1]))
      end
      

      # Returns a PSORT1 CGI Driver object (Bio::PSORT::PSORT1::Remote)
      # connecting to the Peking server.
      def self.peking
        self.new(Remote.new(ServerURI[:Peking][:PSORT1]))
      end


      # Sets a cgi client (Bio::PSORT::PSORT1::Remote).
      #
      def initialize(driver, origin = 'yeast', title = 'MYSEQ')
        @serv = driver
        @origin = origin  # Gram-positive bacterium, Gram-negative bacterium,
                          # yeast, aminal, plant
        @title = title
        @sequence = ''
      end


      # An accessor of the origin argument. Default setting is "yeast".
      # Usable values:
      # 1. Gram-positive bacterium
      # 2. Gram-negative bacterium
      # 3. yeast
      # 4. animal
      # 5. plant
      attr_accessor :origin

      # An accessor of the query sequence argument.
      attr_accessor :sequence

      # An accessor of the title argument. Default setting is 'MYSEQ'.
      # The value is automatically setted if you use a query in
      # Bio::FastaFormat.
      attr_accessor :title


      # Executes the query (faa) and returns an Bio::PSORT::PSORT1::Report.
      #
      # The ``faa'' argument is acceptable a sequence both in String and in 
      # Bio::FastaFormat.
      #
      # If you set the second argument is ``parsing = false'', 
      # returns ourput text without any parsing.
      def exec(faa, parsing = true)
        if faa.class == Bio::FastaFormat
          @title = faa.entry_id if @title == 'MYSEQ'
          @sequence = faa.seq
          @serv.args = {'title' => @title, 'origin' => @origin}
          @serv.parsing = parsing
          return @serv.exec(sequence)
        else
          self.exec(Bio::FastaFormat.new(faa), parsing)
        end
      end


      # =  Bio::PSORT::PSORT1::Remote
      # PSORT1 specific CGIDriver.
      class Remote < CGIDriver

        # Accessor for Bio::PSORT::PSORT1::Remote#origin to contein target domain.
        # Taget domains:
        # 1. Gram-positive bacterium
        # 2. Gram-negative bacterium
        # 3. yeast
        # 4. animal
        # 5. plant
        attr_accessor :origin

        # Accessor for Bio::POSRT::PSORT1#sequence to contein the query sequence.
        attr_accessor :title

        # Accessor for Bio::PSORT::PSORT1#title to contain the query title.
        attr_accessor :parsing
        
        # Sets remote ``host'' and cgi ``path''.
        def initialize(host, path = nil, title = 'MYSEQ', origin = 'yeast')
          @title   = title
          @origin  = origin
          @parsing = true
          super(host, path)
        end

        private

        # Returns parsed CGI argument.
        # An API implementation.
        def make_args(query)
          @args.update({'sequence' => query})
          return args_join(@args)
        end


        # Returns parsed output report. 
        # An API implementation.
        def parse_report(str)
          str = erase_html_tags(str)
          str = Bio::PSORT::PSORT1::Report.parser(str) if @parsing
          return str
        end

      end # Class Remote

    end # class PSORT1

      
    # = Bio::PSORT::PSORT2
    # Bio::PSORT::PSORT2 is a wapper class for the original PSORT program.
    #
    # == Example
    # 
    #  serv = Bio::PSORT::PSORT2.imsut
    #  serv.title = 'Query_title_splited_by_white space'
    #  serv.exec(seq, false)  # seq.class => String
    #  serv.exec(seq)
    #  report = serv.exec(Bio::FastaFormat.new(seq))
    #  report_raw = serv.exec(Bio::FastaFormat.new(seq), false)
    #
    # == References
    # 1. Nakai, K. and Horton, P., PSORT: a program for detecting the sorting 
    #    signals of proteins and predicting their subcellular localization, 
    #    Trends Biochem. Sci, 24(1) 34-35 (1999).
    #    [PMID:10087920]
    class PSORT2

      autoload :Report, 'bio/appl/psort/report'

      # Returns a PSORT2 CGI Driver object (Bio::PSORT::PSORT2::Remote).
      #
      # PSORT official hosts:
      #  key      host                     path
      #  -------  -----------------------  --------------------  ---------
      #  IMSUT    psort.ims.u-tokyo.ac.jp  /cgi-bin/runpsort.pl  (default)
      #  Okazaki  psort.nibb.ac.jp         /cgi-bin/runpsort.pl
      #  Peking   srs.pku.edu.cn:8088      /cgi-bin/runpsort.pl
      def self.remote(host, path = nil)
        self.new(Remote.new(host, path))
      end

      # Returns a PSORT2 CGI Driver object (Bio::PSORT::PSORT2::Remote)     
      # connecting to the IMSUT server.
      def self.imsut
        self.remote(ServerURI[:IMSUT][:PSORT2])
      end

      # Returns a PSORT2 CGI Driver object (Bio::PSORT::PSORT2::Remote)
      # connecting to the NIBB server.
      def self.okazaki
        self.remote(ServerURI[:Okazaki][:PSORT2])
      end

      # Returns a PSORT2 CGI Driver object (Bio::PSORT::PSORT2::Remote)
      # connecting to the Peking server.
      def self.peking
        self.remote(ServerURI[:Peking][:PSORT2])
      end

      # An accessor of the origin argument.
      # Default setting is ``yeast''.
      attr_accessor :origin

      # An accessor of the title argument. Default setting is ``QUERY''.
      # The value is automatically setted if you use a query in
      # Bio::FastaFormat.
      attr_accessor :title

      # Sets a server CGI Driver (Bio::PSORT::PSORT2::Remote).
      def initialize(driver, origin = 'yeast')
        @serv   = driver
        @origin = origin
        @title  = ''
      end


      # Executes PSORT II prediction and returns Report object 
      # (Bio::PSORT::PSORT2::Report) if parsing = true.
      # Returns PSORT II report in text if parsing = false.
      def exec(faa, parsing = true)
        if faa.class == Bio::FastaFormat
          @title = faa.entry_id if @title == nil
          @sequence = faa.seq
          @serv.args = {'origin' => @origin, 'title' => @title}
          @serv.parsing = parsing
          return @serv.exec(@sequence)
        else
          self.exec(Bio::FastaFormat.new(faa), parsing)
        end
      end


      # = Bio::PSORT::PSORT2::Remote
      # PSORT2 specific CGIDriver
      class Remote < CGIDriver

        # Sets remote ``host'' and cgi ``path''.
        def initialize(host, path)
          @origin = 'yeast'
          super(host, path)
          @parsing = true
        end
        
        # An accessor of the origin argument.
        # Default setting is ``yeast''.
        attr_accessor :origin

        # An accessor of the output parsing.
        # Default setting is ``true''.
        attr_accessor :parsing

        
        private
         
        # Returns parsed CGI argument.
        # An API implementation.
        def make_args(query)
          @args.update({'sequence' => query})
          return args_join(@args)
        end


        # Returns parsed output report. 
        # An API implementation.
        def parse_report(str)
          str = str.gsub(/\n<hr>/i, Report::BOUNDARY)
          str = erase_html_tags(str)
          str = Bio::PSORT::PSORT2::Report.parser(str, self.args['title']) if @parsing
          return str
        end

      end # class Remote

    end # class PSORT2      


    class IPSORT
    end # class IPSORT

    
    class PSORTB
    end # class PSORTB

    class WoLF_PSORT
    end # class PSORTB

  end # class PSORT

end # module Bio





if __FILE__ == $0

  begin
    require 'psort/report.rb'
  rescue LoadError
  end


  seq = ">hoge mit
MALEPIDYTT RDEDDLDENE LLMKISNAAG SSRVNDNNDD LTFVENDKII 
ARYSIQTSSK QQGKASTPPV EEAEEAAPQL PSRSSAAPPP PPRRATPEKK 
DVKDLKSKFE GLAASEKEEE EMENKFAPPP KKSEPTIISP KPFSKPQEPV
FKGYHVQVTA HSREIDAEYL KIVRGSDPDT TWLIISPNAK KEYEPESTGS 
KKSFTPSKSP APVSKKEPVK TPSPAPAAKI PKENPWATAE YDYDAAEDNE
NIEFVDDDWW LGELEKDGSK GLFPSNYVSL LPSRNVASGA PVQKEEPEQE 
SFHDFLQLFD ETKVQYGLAR RKAKQNSGNA ETKAEAPKPE VPEDEPEGEP
DDWNEPELKE RDFDQAPLKP NQSSYKPIGK IDLQKVIAEE KAKEDPRLVQ
DYKKIGNPLP GMHIEADNEE EPEENDDDWD DDEDEAAQPP ANFAAVANNL 
KPTAAGSKID DDKVIKGFRN EKSPAQLWAE VSPPGSDVEK IIIIGWCPDS 
APLKTRASFA PSSDIANLKN ESKLKRDSEF NSFLGTTKPP SMTESSLKND
KAEEAEQPKT EIAPSLPSRN SIPAPKQEEA PEQAPEEEIE GN
"
  Seq1 = ">hgoe
LTFVENDKII NI
"

  puts "\n Bio::PSORT::PSORT"
  
  puts "\n ==> p serv = Bio::PSORT::PSORT.imsut"
  p serv = Bio::PSORT::PSORT1.imsut

  puts "\n ==> p serv.class "  
  p serv.class

  puts "\n ==> p serv.title = 'Query_title_splited_by_white space'"
  p serv.title = 'Query_title_splited_by_white space'

  puts "\n ==> p serv.exec(seq, false) "  
  p serv.exec(seq, false)

  puts "\n ==> p serv.exec(seq) "  
  p serv.exec(seq)

  puts "\n ==> p report = serv.exec(Bio::FastaFormat.new(seq)) "  
  p report = serv.exec(Bio::FastaFormat.new(seq))

  puts "\n ==> p report.class"
  p report.class


  puts "\n ==> p report_raw = serv.exec(Bio::FastaFormat.new(seq), false) "  
  p report_raw = serv.exec(Bio::FastaFormat.new(seq), false)

  puts "\n ==> p report_raw.class"
  p report_raw.class


  puts "\n ==> p report.methods" 
  p report.methods

  methods = ['entry_id', 'origin', 'title', 'sequence','result_info',
             'reasoning', 'final_result', 'raw']
  methods.each do |method|
    puts "\n ==> p report.#{method}"
    p eval("report.#{method}")
  end



  puts "\n Bio::PSORT::PSORT2"

  puts "\n ==> p serv = Bio::PSORT::PSORT2.imsut"
  p serv = Bio::PSORT::PSORT2.imsut

  puts "\n ==> p serv.class "
  p serv.class

  puts "\n ==> p seq "
  p seq

  puts "\n ==> p serv.title = 'Query_title_splited_by_white space'"
  p serv.title = 'Query_title_splited_by_white space'

  puts "\n ==> p serv.exec(seq) # parsed report" 
  p serv.exec(seq)

  puts "\n ==> p report = serv.exec(Bio::FastaFormat.new(seq)) # parsed report" 
  p report = serv.exec(Bio::FastaFormat.new(seq))



  puts "\n ==> p serv.exec(seq, false) # report in plain text"
  p serv.exec(seq, false)

  puts "\n ==> p report_raw = serv.exec(Bio::FastaFormat.new(seq), false) # report in plain text"
  p report_raw = serv.exec(Bio::FastaFormat.new(seq), false)


  puts "\n ==> p report.methods"
  p report.methods

  methods = ['entry_id', 'scl', 'definition', 'seq', 'features', 'prob', 'pred', 'k', 'raw']
  methods.each do |method|
    puts "\n ==> p report.#{method}"
    p eval("report.#{method}")
  end
end
