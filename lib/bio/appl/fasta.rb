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
#  $Id: fasta.rb,v 1.8 2002/05/28 14:49:06 k Exp $
#

require 'net/http'
require 'cgi' unless defined?(CGI)

module Bio

  class Fasta

    def initialize(program, db, option = '', server = 'local')
      @format	= 10

      @program	= program
      @db	= db
      @option	= "-Q -H -m #{@format} #{option}"	# need -a ?
      @server	= server

      @ktup	= nil
      @matrix	= nil
    end
    attr_accessor :program, :db, :option, :server, :ktup, :matrix

    def format=(num)
      @format = num
      @option.gsub!(/\s*-m\s+\d+/, '')
      @option += " -m #{num} "
    end

    def self.local(program, db, option = '')
      self.new(program, db, option, 'local')
    end

    def self.remote(program, db, option = '', server = 'genomenet')
      self.new(program, db, option, server)
    end

    def query(query)
      return self.send("exec_#{@server}", query)
    end


    private


    def parse_result(data)
      case @format
      when 6 || '6'
	require 'bio/appl/fasta/format6'
      when 10 || '10'
	require 'bio/appl/fasta/format10'
      end
      Report.new(data) 
   end


    def exec_local(query)
      cmd = "#{@program} #{@option} @ #{@db} #{@ktup}"

      report = nil

      begin
	io = IO.popen(cmd, "w+")
	io.sync = true
	io.puts(query)
	io.close_write
	report = parse_result(io.read)
      rescue
	raise "[Error] command execution failed : #{cmd}"
      ensure
	io.close
      end

      return report
    end


    def exec_genomenet(query)
      host = "fasta.genome.ad.jp"
      path = "/sit-bin/nph-fasta"

      form = {
	'prog'		=> @program,
	'dbname'	=> @db,
	'sequence'	=> CGI.escape(query),
	'other_param'	=> CGI.escape(@option),
	'ktup_value'	=> @ktup,
	'matrix'	=> @matrix,
      }

      data = []

      form.each do |k, v|
	data.push("#{k}=#{v}") if v
      end

      report = nil

      begin
	response, result = Net::HTTP.new(host).post(path, data.join('&'))
	result_path = nil
	result.each do |line|
	  if %r|href="http://#{host}(.*?)".*Show all result|i.match(line)
	    result_path = $1
	    break
	  end
	end
	if result_path
	  response, result = Net::HTTP.new(host).get(result_path)
	  if %r|<pre>.*?</pre>.*<pre>(.*)</pre>|mi.match(result)
	    report = parse_result($1)
	  end
	end
      end

      return report
    end

  end

end


if __FILE__ == $0
  begin
    require 'pp'
    alias :p :pp
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

      Returns a Fasta factory object (Bio::Fasta).

      For the develpper, you can add server 'hoge' by adding
      Bio::Fasta#exec_hoge(query) method.

--- Bio::Fasta#query(query)

      Execute fasta search and returns Report object (Bio::Fasta::Report).

--- Bio::Fasta#program
--- Bio::Fasta#db
--- Bio::Fasta#option
--- Bio::Fasta#server
--- Bio::Fasta#ktup

      Accessors for the factory parameters.

== Available databases for Fasta.remote(@program, @db, option, 'genomenet')

  # ----------+-------+---------------------------------------------------
  #  @program | query | @db (supported in GenomeNet)
  # ----------+-------+---------------------------------------------------
  #  fasta    | AA    | nr-aa, genes, vgenes, swissprot, swissprot-upd,
  #           |       | pir, prf, pdbstr
  # ----------+-------+---------------------------------------------------

=end

