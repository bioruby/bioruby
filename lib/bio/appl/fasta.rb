#
# = bio/appl/fasta.rb - FASTA wrapper
#
# Copyright::  Copyright (C) 2001, 2002 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: fasta.rb,v 1.25 2007/05/18 15:22:52 k Exp $
#

require 'net/http'
require 'cgi' unless defined?(CGI)
require 'bio/command'
require 'shellwords'

module Bio

class Fasta

  #autoload :Report, 'bio/appl/fasta/format10'
  #autoload :?????,  'bio/appl/fasta/format6'

  # Returns a FASTA factory object (Bio::Fasta).
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

  # Returns a String containing fasta execution output in as is format.
  attr_reader :output

  def option
    # backward compatibility
    Bio::Command.make_command_line(@options)
  end

  def option=(str)
    # backward compatibility
    @options = Shellwords.shellwords(str)
  end

  # Accessors for the -m option.
  def format=(num)
    @format = num.to_i
    if i = @options.index('-m') then
      @options[i+1, 1] = @format.to_s
    else
      @options << '-m' << @format.to_s
    end
  end
  attr_reader :format

  # Select parser to use ('format6' and 'format10' is acceptable for now)
  #
  # This method will import Bio::Fasta::Report class by requiring specified
  # parser and will be useful when you already have fasta output files and
  # want to use appropriate Report class for parsing.
  #
  def self.parser(parser)
    require "bio/appl/fasta/#{parser}"
  end

  # Returns a FASTA factory object (Bio::Fasta) to run FASTA search on
  # local computer.
  def self.local(program, db, option = '')
    self.new(program, db, option, 'local')
  end

  # Returns a FASTA factory object (Bio::Fasta) to execute FASTA search on
  # remote server.
  #
  # For the develpper, you can add server 'hoge' by adding
  # exec_hoge(query) method.
  #
  def self.remote(program, db, option = '', server = 'genomenet')
    self.new(program, db, option, server)
  end

  # Execute FASTA search and returns Report object (Bio::Fasta::Report).
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
    cmd.concat([ '@', @db ])
    cmd.push(@ktup) if @ktup

    report = nil

    @output = Bio::Command.query_command(cmd, query)
    report = parse_result(@output)

    return report
  end


  # == Available databases for Fasta.remote(@program, @db, option, 'genomenet')
  #
  # See http://fasta.genome.jp/ideas/ideas.html#fasta for more details.
  #
  #   ----------+-------+---------------------------------------------------
  #    @program | query | @db (supported in GenomeNet)
  #   ----------+-------+---------------------------------------------------
  #    fasta    | AA    | nr-aa, genes, vgenes.pep, swissprot, swissprot-upd,
  #             |       | pir, prf, pdbstr
  #             +-------+---------------------------------------------------
  #             | NA    | nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss,
  #             |       | htgs, dbsts, embl-nonst, embnonst-upd, epd,
  #             |       | genes-nt, genome, vgenes.nuc
  #   ----------+-------+---------------------------------------------------
  #    tfasta   | AA    | nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss,
  #             |       | htgs, dbsts, embl-nonst, embnonst-upd,
  #             |       | genes-nt, genome, vgenes.nuc
  #   ----------+-------+---------------------------------------------------
  #
  def exec_genomenet(query)
    host = "fasta.genome.jp"
    #path = "/sit-bin/nph-fasta"
    path = "/sit-bin/fasta"  # 2005.08.12

    form = {
      'style'        => 'raw',
      'prog'         => @program,
      'dbname'       => @db,
      'sequence'     => CGI.escape(query),
      'other_param'  => CGI.escape(Bio::Command.make_command_line_unix(@options)),
      'ktup_value'   => @ktup,
      'matrix'       => @matrix,
    }

    data = []

    form.each do |k, v|
      data.push("#{k}=#{v}") if v
    end

    report = nil

    begin
      http = Bio::Command.new_http(host)
      http.open_timeout = 3000
      http.read_timeout = 6000
      result, = http.post(path, data.join('&'))
      # workaround 2006.8.1 - fixed for new batch queuing system
      case result.code
      when "302"
        result_location = result.header['location']
        result_uri = URI.parse(result_location)
        result_path = result_uri.path
        done = false
        until done
          result = http.get(result_path)
          if result.body[/Your job ID is/]
            sleep 15
          else
            done = true
          end
        end
      end
      @output = result.body.to_s
      # workaround 2005.08.12
      re = %r{<A HREF="http://#{host}(/tmp/[^"]+)">Show all result</A>} # "
      if path = @output[re, 1]
        result, = http.get(path)
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

end # Fasta

end # Bio


if __FILE__ == $0
  begin
    require 'pp'
    alias p pp
  rescue
  end

# serv = Bio::Fasta.local('fasta34', 'hoge.nuc')
# serv = Bio::Fasta.local('fasta34', 'hoge.pep')
# serv = Bio::Fasta.local('ssearch34', 'hoge.pep')

  # This may take 3 minutes or so.
  serv = Bio::Fasta.remote('fasta', 'genes')
  p serv.query(ARGF.read)
end


