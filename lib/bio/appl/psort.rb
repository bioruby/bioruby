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
#  $Id: psort.rb,v 1.2 2003/09/08 05:46:25 n Exp $
#



require 'bio/sequence'
#require 'psort/report'
require 'bio/appl/psort/report'
require 'net/http'
require 'cgi'


module Bio

  class PSORT

    WWWServer = {
      'IMSUT'   => {'host' => 'psort.ims.u-tokyo.ac.jp', 
 	            'PSORT1' => '/cgi-bin/okumura.pl',
 	            'PSORT2' => '/cgi-bin/runpsort.pl'},
      'Okazaki' => {'host' => 'psort.nibb.ac.jp', 
 	            'PSORT1' => '/cgi-bin/okumura.pl',
	            'PSORT2' => '/cgi-bin/runpsort.pl'},
      'Peking'  => {'host' => 'srs.pku.edu.en:8088', 
 	            'PSORT1' => '/cgi-bin/okumura.pl',
	            'PSORT2' => '/cgi-bin/runpsort.pl'}
    }
      

    class PSORT1
    end

    # Nakai and Horton 1999 TiBS
    class PSORT2

      # wrapper for ``psort'' command
      def initialize
	@host = ''
	@path = ''
	@origin = ''
      end
      attr_accessor :host, :path, :origin


      def self.remote(host = WWWServer['IMSUT']['host'],
		      path = WWWServer['IMSUT']['PSORT2'], origin = 'yeast')
	pio = PSORT2.new
	pio.host = host
	pio.path = path
	pio.origin = origin
	pio
      end


      def query(query)
	self.exec_remote(query)
      end


      def exec_remote(query)
	form = {
	  'origin'   => @origin,
	  'sequence' => CGI.escape(query)
	}
	data = []
	form.each {|k, v|
	  data.push("#{k}=#{v}") if v
	}

	begin
	  result, = Net::HTTP.new(@host).post(@path, data.join('&'))
	  @output = result.body.gsub(/\n<hr>/i, Report::BOUNDARY).gsub(/<.+?>/,'')
	end
	
	Bio::PSORT::PSORT2::Report.parser(@output)
      end

    end # class PSORT2      


    class IPSORT
    end # class IPSORT

    
    class PSORTB
    end # class PSORTB

  end # class PSORT

end # module Bio





if __FILE__ == $0



  seq = ">hoge fuga
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
  seq1 = ">hgoe
LTFVENDKII NI
"
  puts "\n ==> io = Bio::PSORT::PSORT2.remote"
  io = Bio::PSORT::PSORT2.remote

  puts "\n ==> seq "
  puts seq
  puts "\n ==> io.query(seq)"
  p io.query(seq)

  puts "\n ==> seq1 "
  puts seq1
  puts "\n ==> io.query(seq1)"
  p io.query(seq1)

end





=begin

= Bio::PSORT

--- Bio::PSORT::WWWServer

      PSORT official hosts:
                | host                    
        IMSUT   | psort.ims.u-tokyo.ac.jp 
        Okazaki | psort.nibb.ac.jp        
        Peking  | srs.pku.edu.cn:8088     


= Bio::PSORT::PSORT2

--- Bio::PSORT::PSORT2.remote
--- Bio::PSORT::PSORT2.remote(host, path)

      Returns a PSORT2 factory object (Bio::PSORT::PSORT2).

      PSORT official hosts:
                | host                    | path
        IMSUT   | psort.ims.u-tokyo.ac.jp | /cgi-bin/runpsort.pl  (default setting)
        Okazaki | psort.nibb.ac.jp        | /cgi-bin/runpsort.pl
        Peking  | srs.pku.edu.cn:8088     | /cgi-bin/runpsort.pl
      

   
--- Bio::PSORT::PSORT2.query(query)

      Execute PSORT2 prediction and returns Report object 
      (Bio::PSORT::PSORT2::Report).
  
=end


