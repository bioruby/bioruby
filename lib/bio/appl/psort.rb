#
# bio/appl/psort.rb - PSORT, protein sorting site prediction systems
#
#   Copyright (C) 2003 Mitsuteru C. Nakao <n@bioruby.org>
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
#  $Id: psort.rb,v 1.4 2004/07/21 03:12:02 nakao Exp $
#



require 'bio/sequence'
require 'bio/db/fasta'
require 'bio/appl/psort/report'
require 'net/http'
require 'cgi'


module Bio

  class PSORT

    WWWServer = {
      'IMSUT'   => {'host' => 'psort.hgc.jp', #'psort.ims.u-tokyo.ac.jp', 
 	            'PSORT1' => '/cgi-bin/okumura.pl',
 	            'PSORT2' => '/cgi-bin/runpsort.pl'},
      'Okazaki' => {'host' => 'psort.nibb.ac.jp', 
 	            'PSORT1' => '/cgi-bin/okumura.pl',
	            'PSORT2' => '/cgi-bin/runpsort.pl'},
      'Peking'  => {'host' => 'srs.pku.edu.en:8088', 
 	            'PSORT1' => '/cgi-bin/okumura.pl',
	            'PSORT2' => '/cgi-bin/runpsort.pl'}
    }


    # Command-line client super class

    # HTTP client super class
    # inherited claaes should have make_form_args and parse_html method.
    class CGIDriver
      def initialize(host = '', path = '') 
	@host = host
	@path = path
	@args = {}
	@report
      end
      attr_accessor :args
      attr_reader :report


      # CGIDriver#exec(query) -> aReport
      def exec(query)
	data = make_args(query)  

	begin
	  result, = Net::HTTP.new(@host).post(@path, data)
	  @report = result.body
	  output = parse_report(@report)
	end

	return output
      end


      private

      def make_args(args_hash)
	# The routin should be provided in the inherited class
      end

      def parse_report(result_body)
	# The routin should be provided in the inherited class	
      end

      # tools

      def erase_html_tags(str)
	return str.gsub(/<\S.*?>/,'')	
      end

      def args_join(hash, delim = '&')
	tmp = []
	hash.each do |key, val|
	  tmp << CGI.escape(key.to_s) + '=' + CGI.escape(val.to_s)
	end
	return tmp.join(delim)  # not ';' but '&' in psort's cgi
      end

    end # class CGIDriver




    class PSORT1

      def self.imsut
	self.new(Remote.new(WWWServer['IMSUT']['host'],
			    WWWServer['IMSUT']['PSORT1']))
      end

      def self.okazaki
	self.new(Remote.new(WWWServer['Okazaki']['host'],
			    WWWServer['Okazaki']['PSORT1']))
      end
      
      def self.peking
	self.new(Remote.new(WWWServer['Peking']['host'],
			    WWWServer['Peking']['PSORT1']))
      end

      #
      def initialize(serv)
	@serv = serv
	@origin   = 'yeast' # Gram-positive bacterium, Gram-negative bacterium,
	                    # yeast, aminal, plant
	@title    = 'MYSEQ'
	@sequence = ''
      end
      attr_accessor :origin, :sequence, :title

      # 
      def exec(faa, parsing = true)
	if faa.class == Bio::FastaFormat
	  @title        = faa.entry_id if @title == 'MYSEQ'
	  @sequence     = faa.seq
	  @serv.args    = {'title' => @title, 'origin' => @origin}
	  @serv.parsing = parsing
	  return @serv.exec(sequence)
	else
	  self.exec(Bio::FastaFormat.new(faa), parsing)
	end
      end


      # PSORT1 specific CGIDriver
      class Remote < CGIDriver

	def initialize(host, path)
	  @origin  = 'yeast' # Gram-positive bacterium, 
  	                     # Gram-negative bacterium,
	                     # yeast, aminal, plant
	  @title   = 'MYSEQ'
	  @parsing = true
	  super(host, path)
	end
	attr_accessor :origin, :title, :parsing


	private

	def make_args(query)
	  @args.update({'sequence' => query})
	  return args_join(@args)
	end

	def parse_report(str)
	  str = erase_html_tags(str)
	  str = Bio::PSORT::PSORT1::Report.parser(str) if @parsing
	  return str
	end

      end # Class Remote

    end # class PSORT1

      

    # Nakai and Horton 1999 TiBS
    class PSORT2

      # remote
      def self.remote(host, path)
	self.new(Remote.new(host, path))
      end

      def self.imsut
	self.remote(WWWServer['IMSUT']['host'],
		    WWWServer['IMSUT']['PSORT2'])
      end
      
      def self.okazaki
	self.remote(WWWServer['Okazaki']['host'],
		    WWWServer['Okazaki']['PSORT2'])
      end

      def self.peking
	self.remote(WWWServer['Peking']['host'],
		    WWWServer['Peking']['PSORT2'])
      end

      # wrapper for ``psort'' command
      def initialize(serv, origin = 'yeast')
	@serv   = serv
	@origin = origin
	@title  = nil
      end
      attr_accessor :origin, :title

      def exec(faa, parsing = true)
	if faa.class == Bio::FastaFormat
	  @title        = faa.entry_id if @title == nil
	  @sequence     = faa.seq
	  @serv.args    = {'origin' => @origin, 'title' => @title}
	  @serv.parsing = parsing
	  return @serv.exec(@sequence)
	else
	  self.exec(Bio::FastaFormat.new(faa), parsing)
	end
      end


      # PSORT2 specific CGIDriver
      class Remote < CGIDriver
	def initialize(host, path)
	  @origin = 'yeast'
	  super(host, path)
	  @parsing = true
	end
	attr_accessor :origin, :parsing

	
	private
	
	def make_args(query)
	  @args.update({'sequence' => query})
	  return args_join(@args)
	end

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





=begin

= Bio::PSORT

Wrapper classes of PSORT family for predicting protein subcellular 
localization.
((<URL:http://psort.ims.u-tokyo.ac.jp>))

PSORT family contains,
(1) PSORT
(2) PSORT II
(3) iPSORT
(4) PSORT-B  ((<URL:http://psort.org>))



--- Bio::PSORT::WWWServer

      Constants for PSORT official hosts:

        Key      value (host)
        -------  -----------------------
        IMSUT    psort.ims.u-tokyo.ac.jp  
        Okazaki  psort.nibb.ac.jp        
        Peking   srs.pku.edu.cn:8088     



= Bio::PSORT::PSORT1

Bio::PSORT::PSORT1 is a wapper class for original PSORT program.


--- Bio::PSORT::PSORT1.remote(host, path)

      Returns a PSORT1 CGI Driver object (Bio::PSORT::PSORT1::Remote).

--- Bio::PSORT::PSORT1.imsut

      Returns a PSORT1 CGI Driver object (Bio::PSORT::PSORT1::Remote)
      to the IMSUT server.

--- Bio::PSORT::PSORT1.okazaki

      Returns a PSORT1 CGI Driver object (Bio::PSORT::PSORT1::Remote)
      to the NIBB server.

--- Bio::PSORT::PSORT1.peking

      Returns a PSORT1 CGI Driver object (Bio::PSORT::PSORT1::Remote)
      to the Peking server.


--- Bio::PSORT::PSORT1#origin

      An accessor of the origin argument. Default setting is "yeast".
      Usable values:
        ----------------------- 
        Gram-positive bacterium
        Gram-nebative bacterium
        yeast
        animal
        plant


--- Bio::PSORT::PSORT1#title

      An accessor of the title argument. Default setting is 'MYSEQ'.
      The value is automatically setted if you use a query in
      Bio::FastaFormat.

--- Bio::PSORT::PSORT1#exec(faa, parsing = true) -> aRpt

      Execute a query. 
      Returns a PSORT1::Report instance if parsing = true.
      Returns a PSORT1 report in text format if parsing = false.





= Bio::PSORT::PSORT2

--- Bio::PSORT::PSORT2.remote(host, path)

      Returns a PSORT2 CGI Driver object (Bio::PSORT::PSORT2::Remote).

      PSORT official hosts:
        key      host                     path
        -------  -----------------------  --------------------  ---------
        IMSUT    psort.ims.u-tokyo.ac.jp  /cgi-bin/runpsort.pl  (default)
        Okazaki  psort.nibb.ac.jp         /cgi-bin/runpsort.pl
        Peking   srs.pku.edu.cn:8088      /cgi-bin/runpsort.pl

--- Bio::PSORT::PSORT2.imsut
--- Bio::PSORT::PSORT2.okazaki
--- Bio::PSORT::PSORT2.peking


--- Bio::PSORT::PSORT2#origin 
  
      Accessor of the origin argument.
      Default setting is 'yeast'.

--- Bio::PSORT::PSORT2#title      
      
      Accessor of the title argument. Default setting is 'QUERY'.
      The value is automatically setted if you use a query in
      Bio::FastaFormat.

--- Bio::PSORT::PSORT2#exec(faa, parsing = true)

      Executes PSORT II prediction and returns Report object 
      (Bio::PSORT::PSORT2::Report) if parsing = true.
      Returns PSORT II report in text if parsing = false.

  
=end


