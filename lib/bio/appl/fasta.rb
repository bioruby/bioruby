#
# bio/appl/fasta.rb - FASTA wrapper
#
#   Copyright (C) 2001,2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: fasta.rb,v 1.20 2005/09/26 13:00:04 k Exp $
#

require 'net/http'
require 'cgi' unless defined?(CGI)
require 'bio/command'
require 'shellwords'

module Bio

  class Fasta

    autoload :Report, 'bio/appl/fasta/format10'
    #autoload :?????,  'bio/appl/fasta/format6'

    include Bio::Command::Tools

    def initialize(program, db, opt = [], server = 'local')
      @format	= 10

      @program	= program
      @db	= db
      @server	= server

      @ktup	= nil
      @matrix	= nil

      @output	= ''

      begin
        a = opt.to_ary
      rescue NameError #NoMethodError
        # backward compatibility
        a = Shellwords.shellwords(opt)
      end
      @options	= [ '-Q', '-H', '-m', @format.to_s, *a ] # need -a ?
    end
    attr_accessor :program, :db, :options, :server, :ktup, :matrix
    attr_reader :output

    def option
      # backward compatibility
      make_command_line(@options)
    end

    def option=(str)
      # backward compatibility
      @options = Shellwords.shellwords(str)
    end

    def format=(num)
      @format = num.to_i
      if i = @options.index('-m') then
        @options[i+1, 1] = @format.to_s
      else
        @options << '-m' << @format.to_s
      end
    end
    attr_reader :format

    def self.parser(parser)
      require "bio/appl/fasta/#{parser}"
    end

    def self.local(program, db, option = '')
      self.new(program, db, option, 'local')
    end

    def self.remote(program, db, option = '', server = 'genomenet')
      self.new(program, db, option, server)
    end

    def query(query)
      return self.send("exec_#{@server}", query.to_s)
    end


    private


    def parse_result(data)
      case @format
      when 6
        require 'bio/appl/fasta/format6'
      when 10
        require 'bio/appl/fasta/format10'
      end
      Report.new(data)
    end


    def exec_local(query)
      cmd = [ @program, *@options ]
      cmd.concat([ '@', @db, @ktup ])

      report = nil

      @output = call_command_local(cmd, query)
      report = parse_result(@output)

      return report
    end


    def exec_genomenet(query)
      host = "fasta.genome.jp"
      #path = "/sit-bin/nph-fasta"
      path = "/sit-bin/fasta" #2005.08.12

      form = {
        'style'		=> 'raw',
        'prog'		=> @program,
        'dbname'	=> @db,
        'sequence'	=> CGI.escape(query),
        'other_param'	=> CGI.escape(make_command_line_unix(@options)),
        'ktup_value'	=> @ktup,
        'matrix'	=> @matrix,
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
        if /\<A +HREF=\"(http\:\/\/fasta\.genome\.jp(\/tmp\/[^\"]+))\"\>Show all result\<\/A\>/i =~ @output.to_s then
          result, = http.get($2)
          @output = result.body
          txt = @output.to_s.split(/\<pre\>/)[1]
          raise 'cannot understand response' unless txt
          txt.sub!(/\<\/pre\>.*\z/m, '')
          txt.sub!(/.*^((T?FASTA|SSEARCH) (searches|compares))/m, '\1')
          txt.sub!(/^\<form method\=\"POST\" name\=\"clust_check\"\>.*\n/, '')
          txt.gsub!(/\<input[^\>]+value\=\"[^\"]*\"[^\>]*\>/i, '')
          txt.gsub!(/\<(a|form|select|input|option|img)\s+[^\>]+\>/i, '')
          txt.gsub!(/\<\/(a|form|select|input|option|img)\>/i, '')
          @output = txt.gsub(/\&lt\;/, '<')
          report = parse_result(@output.dup)
        else
          raise 'cannot understand response'
        end
      end

      return report
    end

  end

end


if __FILE__ == $0
  begin
    require 'pp'
    alias p pp
  rescue
  end

# serv = Bio::Fasta.local('fasta34', 'hoge.nuc')
# serv = Bio::Fasta.local('fasta34', 'hoge.pep')
# serv = Bio::Fasta.local('ssearch34', 'hoge.pep')
  serv = Bio::Fasta.remote('fasta', 'genes')
  p serv.query(ARGF.read)
end


=begin

= Bio::Fasta

--- Bio::Fasta.new(program, db, option = '', server = 'local')
--- Bio::Fasta.local(program, db, option = '')
--- Bio::Fasta.remote(program, db, option = '', server = 'genomenet')

      Returns a fasta factory object (Bio::Fasta).

      For the develpper, you can add server 'hoge' by adding
      exec_hoge(query) method.

--- Bio::Fasta#query(query)

      Execute fasta search and returns Report object (Bio::Fasta::Report).

--- Bio::Fasta#output

      Returns a String containing fasta execution output in as is format.

--- Bio::Fasta#program
--- Bio::Fasta#db
--- Bio::Fasta#options
--- Bio::Fasta#server
--- Bio::Fasta#ktup

      Accessors for the factory parameters.

--- Bio::Fasta#option
--- Bio::Fasta#option=(str)

      Get/set options by string.

--- Bio::Fasta#format
--- Bio::Fasta#format=(number)

      Accessors for the -m option.

--- Bio::Fasta.parser(parser)

      Import Bio::Fasta::Report class by requiring specified parser.

      This class method will be useful when you already have fasta
      output files and want to use appropriate Report class for parsing.


== Available databases for Fasta.remote(@program, @db, option, 'genomenet')

  # ----------+-------+---------------------------------------------------
  #  @program | query | @db (supported in GenomeNet)
  # ----------+-------+---------------------------------------------------
  #  fasta    | AA    | nr-aa, genes, vgenes.pep, swissprot, swissprot-upd,
  #           |       | pir, prf, pdbstr
  #           +-------+---------------------------------------------------
  #           | NA    | nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss,
  #           |       | htgs, dbsts, embl-nonst, embnonst-upd, epd,
  #           |       | genes-nt, genome, vgenes.nuc
  # ----------+-------+---------------------------------------------------
  #  tfasta   | AA    | nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss,
  #           |       | htgs, dbsts, embl-nonst, embnonst-upd,
  #           |       | genes-nt, genome, vgenes.nuc
  # ----------+-------+---------------------------------------------------

See http://fasta.genome.jp/ideas/ideas.html#fasta for more details.

=end

