#
# bio/appl/fasta.rb - FASTA wrapper
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
#  $Id: fasta.rb,v 1.3 2001/12/08 08:57:25 katayama Exp $
#

require 'bio/sequence'
require 'net/http'
require 'cgi-lib'

module Bio

  class Fasta

    def initialize(program, db, option = {}, remote = false)
      @program	= program
      @db	= db
      @option	= option
      @remote	= remote
    end
    attr_reader :program, :db, :option, :remote

    def Fasta.local(program, db, option = {})
      self.new(program, db, option)
    end

    def Fasta.remote(program, db, option = {})
      self.new(program, db, option, true)
    end

    def query(query)
      report = @remote ? remote_fasta(query) : local_fasta(query)
      return report
    end


    private

    def local_fasta(query)
      raise "[Error] can't open #{@db}" unless test(?R, @db)

      cmd = "#{@program} -Q -H -m 10"

      @option.each do |opt, value|
	next if opt.kind_of?(Symbol)
	if opt =~ /^-/
	  cmd += " #{opt} #{value}"
	end
      end

      cmd += " -n" if query.type == Bio::Sequence::NA
      cmd += " @ #{@db}"
      cmd += " #{@option[:ktup]}" if @option[:ktup]

      report = false

      begin
	io = IO.popen(cmd, "w+")
	io.sync = true
	io.puts(query)
	io.close_write
	report = Report.new(io.read)
      rescue
	raise "[Error] command execution failed : #{cmd}"
      ensure
	io.close
      end

      return report
    end

    def remote_fasta(query)
      host = "fasta.genome.ad.jp"
#     path = "/sit-bin/nph-fasta"
      path = "/sit-bin/nph-fasta.ktym"		# GenomeNet nph- bug work around

      # ----------+-------+---------------------------------------------------
      #  @program | query | dbname (supported in GenomeNet)
      # ----------+-------+---------------------------------------------------
      #  fasta    | AA    | nr-aa, genes, vgenes, swissprot, swissprot-upd,
      #           |       | pir, prf, pdbstr
      #           +-------+---------------------------------------------------
      #           | NA    | nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss,
      #           |       | htgs, dbsts, embl-nonst, embnonst-upd, genes-nt,
      #           |       | vgenes-nt, vgenome, epd
      # ----------+-------+---------------------------------------------------
      #  tfasta   | AA    | nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss,
      #           |       | htgs, dbsts, embl-nonst, embnonst-upd, genes-nt,
      #           |       | vgenes-nt, vgenome
      # ----------+-------+---------------------------------------------------

      max_hits  = @option[:hits]   ? @option[:hits]   : 200
      max_align = @option[:align]  ? @option[:align]  : 50

      other_param = "-m 10"
      @option.each do |opt, value|
	next if opt.kind_of?(Symbol)
	if opt =~ /^-/
	  other_param += " #{opt} #{value}"
	end
      end

      query = CGI.escape(query)
      other_param = CGI.escape(other_param)

      data = "sequence=#{query}&other_param=#{other_param}"
      data += "&dbname=#{@db}"
      data += "&prog=#{@program}"
      data += "&b_value=#{max_hits}"
      data += "&d_value=#{max_align}"
      data += "&ktup_value=#{@option[:ktup]}" if @option[:ktup]
      data += "&matrix=#{@option[:matrix]}" if @option[:matrix]

      response, result = Net::HTTP.new(host).post(path, data)

      return Report.new(result, @remote)
    end


    class Report

      def initialize(data, remote = false)
	if remote
	  data.gsub!(/\n>>/, "\n>")		# GenomeNet '>' increment bug
        end

	# header lines - brief list of the hits
        data.sub!(/.*\nThe best scores are/m, '')
	data.sub!(/(.*)\n\n>>>/m, '')
	@list = "The best scores are" + $1

	# body lines - fasta execution result
	program, *hits = data.split(/\n>>/)

	# trailing lines - log messages of the execution
	@log = hits.pop
        @log.sub!(/.*<\n/m, '')
        @log.sub!(/\n<.*/m, '') if remote
        @log.strip!

	# parse results
	@program = Program.new(program)
	@hits = []

	hits.each do |x|
	  @hits.push(Hit.new(x))
	end
      end
      attr_reader :list, :log, :program, :hits

      def each
	@hits.each do |x|
	  yield x
	end
      end

      def threshold(evalue_max = 0.1)
	list = []
	@hits.each do |x|
	  list.push(x) if x.evalue <= evalue_max
	end
	return list
      end

      def lap_over(length_min = 0)
	list = []
	@hits.each do |x|
	  list.push(x) if x.overlap > length_min
	end
	return list
      end


      class Program

	def initialize(data)
	  @definition, *program = data.split(/\n/)
	  @program = {}

	  pat = /;\s+([^:]+):\s+(.*)/

	  program.each do |x|
	    if pat.match(x)
	      @program[$1] = $2
	    end
	  end
	end
	attr_reader :definition, :program

	def command_line
	  @program['mp_argv']
	end

	def version
	  @program['mp_ver']
	end

      end


      class Hit

	def initialize(data)
	  score, query, target = data.split(/\n>/)

	  @definition, *score = score.split(/\n/)
	  @score = {}

	  pat = /;\s+([^:]+):\s+(.*)/

	  score.each do |x|
	    if pat.match(x)
	      @score[$1] = $2
	    end
	  end

	  @query = Query.new(query)
	  @target = Target.new(target)
	end
	attr_reader :definition, :score, :query, :target

	def evalue
	  if @score['sw_expect']
	    @score['sw_expect'].to_f
	  else
	    @score['fa_expect'].to_f
	  end
	end

	def sw
	  @score['sw_score'].to_i
	end

	def ident
	  @score['sw_ident'].to_f
	end

	def overlap
	  @score['sw_overlap'].to_i
	end

	def lap_at
	  [
	    @query.data['al_start'].to_i,
	    @query.data['al_stop'].to_i,
	    @target.data['al_start'].to_i,
	    @target.data['al_stop'].to_i,
	  ]
	end

	def q_id
	  @query.definition
	end

	def t_id
	  @target.definition
	end

	def q_len
	  @query.length
	end

	def t_len
	  @target.length
	end


	class Query

	  def initialize(data)
	    definition, *data = data.split(/\n/)

	    @definition = definition.sub(/ .*/, '')
	    @data = {}
	    @sequence = ''

	    pat = /;\s+([^:]+):\s+(.*)/

	    data.each do |x|
	      if pat.match(x)
		@data[$1] = $2
	      else
		@sequence += x
	      end
	    end
	  end
	  attr_reader :definition, :data, :sequence

	  def seq
	    if @data['sq_type'] == 'p'
	      Bio::Sequence::AA.new(@sequence)
	    else
	      Bio::Sequence::NA.new(@sequence)
	    end
	  end

	  def length
	    @data['sq_len'].to_i
	  end

	end

	class Target < Query; end

      end

    end

  end

end


if __FILE__ == $0
end


=begin

= Bio::Fasta

--- Bio::Fasta.new(program, db, option = {}, remote = false)
--- Bio::Fasta.local(program, db, option = {})
--- Bio::Fasta.remote(program, db, option = {})
--- Bio::Fasta#query(query)
--- Bio::Fasta#program
--- Bio::Fasta#db
--- Bio::Fasta#option
--- Bio::Fasta#remote

== Bio::Fasta::Report

--- Bio::Fasta::Report.new(data, remote = false)
--- Bio::Fasta::Report#list
--- Bio::Fasta::Report#log
--- Bio::Fasta::Report#program
--- Bio::Fasta::Report#hits
--- Bio::Fasta::Report#each
--- Bio::Fasta::Report#threshold(evalue_max = 0.1)
--- Bio::Fasta::Report#lap_over(length_min = 0)

=== Bio::Fasta::Report::Program

--- Bio::Fasta::Report::Program.new(data)
--- Bio::Fasta::Report::Program#definition
--- Bio::Fasta::Report::Program#program
--- Bio::Fasta::Report::Program#command_line
--- Bio::Fasta::Report::Program#version

=== Bio::Fasta::Report::Hit

--- Bio::Fasta::Report::Hit.new(data)
--- Bio::Fasta::Report::Hit#definition
--- Bio::Fasta::Report::Hit#score
--- Bio::Fasta::Report::Hit#query
--- Bio::Fasta::Report::Hit#target
--- Bio::Fasta::Report::Hit#evalue
--- Bio::Fasta::Report::Hit#sw
--- Bio::Fasta::Report::Hit#ident
--- Bio::Fasta::Report::Hit#overlap
--- Bio::Fasta::Report::Hit#lap_at
--- Bio::Fasta::Report::Hit#q_id
--- Bio::Fasta::Report::Hit#q_len
--- Bio::Fasta::Report::Hit#t_id
--- Bio::Fasta::Report::Hit#t_len

=== Bio::Fasta::Report::Hit::Query

--- Bio::Fasta::Report::Hit::Query.new(data)
--- Bio::Fasta::Report::Hit::Query#definition
--- Bio::Fasta::Report::Hit::Query#data
--- Bio::Fasta::Report::Hit::Query#sequence
--- Bio::Fasta::Report::Hit::Query#seq
--- Bio::Fasta::Report::Hit::Query#length

=== Bio::Fasta::Report::Hit::Target

--- Bio::Fasta::Report::Hit::Target.new(data)
--- Bio::Fasta::Report::Hit::Target#definition
--- Bio::Fasta::Report::Hit::Target#data
--- Bio::Fasta::Report::Hit::Target#sequence
--- Bio::Fasta::Report::Hit::Target#seq
--- Bio::Fasta::Report::Hit::Target#length

=end

