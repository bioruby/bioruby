#
# bio/appl/blast.rb - BLAST wrapper
# 
#   Copyright (C) 2001 Mitsuteru C. Nakao <n@bioruby.org>
#   Copyright (C) 2002,2003 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: blast.rb,v 1.21 2005/08/16 09:38:34 ngoto Exp $
#

require 'net/http'
require 'cgi' unless defined?(CGI)
require 'bio/appl/blast/report'
require 'bio/command'
require 'shellwords'

module Bio

  class Blast

    include Bio::Command::Tools

    def initialize(program, db, opt = [], server = 'local')
      if defined?(XMLParser) or defined?(REXML)
	@format = 7
      else
	@format	= 8
      end

      @program	= program
      @db	= db
      @server	= server

      @blastall = 'blastall'
      @matrix	= nil
      @filter	= nil

      @output	= ''
      @parser	= nil

      begin
        a = opt.to_ary
      rescue NameError #NoMethodError
        # backward compatibility
        a = Shellwords.shellwords(opt)
      end
      @options	= [ "-m",  @format,  *a ]
    end
    attr_accessor :program, :db, :options, :server, :blastall, :matrix, :filter
    attr_reader :output, :format
    attr_writer :parser		# to change :xmlparser, :rexml, :tab

    def self.local(program, db, option = '')
      self.new(program, db, option, 'local')
    end

    def self.remote(program, db, option = '', server = 'genomenet')
      self.new(program, db, option, server)
    end

    def query(query)
      return self.send("exec_#{@server}", query.to_s)
    end

    def option
      # backward compatibility
      make_command_line(@options)
    end

    def option=(str)
      # backward compatibility
      @options = Shellwords.shellwords(str)
    end


    private


    def parse_result(data)
      Report.new(data, @parser)
    end


    def exec_local(query)
      cmd = [ @blastall, '-p', @program, '-d', @db, *@options ]
      cmd.concat([ '-M', @matrix ]) if @matrix
      cmd.concat([ '-F', @filter ]) if @filter

      report = nil

      @output = call_command_local(cmd, query)
      report = parse_result(@output)

      return report
    end


    def exec_genomenet(query)
      host = "blast.genome.jp"
      #path = "/sit-bin/nph-blast"
      path = "/sit-bin/blast" #2005.08.12

      matrix = @matrix ? @matrix : 'blosum62'
      filter = @filter ? @filter : 'T'

      form = {
	'style'		=> 'raw',
	'prog'		=> @program,
	'dbname'	=> @db,
	'sequence'	=> CGI.escape(query),
	'other_param'	=> CGI.escape(make_command_line_unix(@options)),
	'matrix'	=> matrix,
	'filter'	=> filter,
	'V_value'	=> 500,		# default value for GenomeNet
	'B_value'	=> 250,		# default value for GenomeNet
        'alignment_view' => 0,
      }

      data = []

      form.each do |k, v|
	data.push("#{k}=#{v}") if v
      end

      report = nil

      begin
        http = Net::HTTP.new(host)
        http.open_timeout = 300
        http.read_timeout = 600
	result, = http.post(path, data.join('&'))
        @output = result.body
        # workaround 2005.08.12
        if /\<A +HREF=\"(http\:\/\/blast\.genome\.jp(\/tmp\/[^\"]+))\"\>Show all result\<\/A\>/i =~ @output.to_s then
          result, = http.get($2)
          @output = result.body
          txt = @output.to_s.split(/\<pre\>/)[1]
          raise 'cannot understand response' unless txt
          txt.sub!(/\<\/pre\>.*\z/m, '')
          txt.sub!(/.*^ \-{20,}\s*/m, '')
          @output = txt.gsub(/\&lt\;/, '<')
          report = parse_result(@output)
        else
          raise 'cannot understand response'
        end
      end

      return report
    end


    def exec_ncbi(query)
      raise NotImplementedError
    end
  end

end


if __FILE__ == $0
  begin
    require 'pp'
    alias :p :pp
  rescue
  end

# serv = Bio::Blast.local('blastn', 'hoge.nuc')
# serv = Bio::Blast.local('blastp', 'hoge.pep')
  serv = Bio::Blast.remote('blastp', 'genes')

  query = ARGF.read
  p serv.query(query)
end


=begin

= Bio::Blast

--- Bio::Blast.new(program, db, option = '', server = 'local')
--- Bio::Blast.local(program, db, option = '')
--- Bio::Blast.remote(program, db, option = '', server = 'genomenet')

      Returns a blast factory object (Bio::Blast).

      For the develpper, you can add server 'hoge' by adding
      exec_hoge(query) method.

--- Bio::Blast#query(query)

      Execute blast search and returns Report object (Bio::Blast::Report).

--- Bio::Blast#output

      Returns a String containing blast execution output in as is format.

--- Bio::Blast#program
--- Bio::Blast#db
--- Bio::Blast#options
--- Bio::Blast#server
--- Bio::Blast#blastall
--- Bio::Blast#filter

      Accessors for the factory parameters.

--- Bio::Blast#option
--- Bio::Blast#option=(str)

      Get/set options by string.

== Available databases for Blast.remote(@program, @db, option, 'genomenet')

  # ----------+-------+---------------------------------------------------
  #  @program | query | @db (supported in GenomeNet)
  # ----------+-------+---------------------------------------------------
  #  blastp   | AA    | nr-aa, genes, vgenes.pep, swissprot, swissprot-upd,
  # ----------+-------+ pir, prf, pdbstr
  #  blastx   | NA    | 
  # ----------+-------+---------------------------------------------------
  #  blastn   | NA    | nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss,
  # ----------+-------+ htgs, dbsts, embl-nonst, embnonst-upd, epd,
  #  tblastn  | AA    | genes-nt, genome, vgenes.nuc
  # ----------+-------+---------------------------------------------------

See http://blast.genome.jp/ideas/ideas.html#blast for more details.

=end

