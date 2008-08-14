#
# = bio/appl/blast/genomenet.rb - Remote BLAST wrapper using GenomeNet
# 
# Copyright::  Copyright (C) 2001,2008  Mitsuteru C. Nakao <n@bioruby.org>
# Copyright::  Copyright (C) 2002,2003  Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2006       Jan Aerts <jan.aerts@bbsrc.ac.uk>
# Copyright::  Copyright (C) 2008       Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'net/http'
require 'uri'
require 'bio/command'
require 'shellwords'
require 'bio/appl/blast/remote'

module Bio::Blast::Remote

  # == Description
  # 
  # The Bio::Blast::Remote::GenomeNet class contains methods for running
  # remote BLAST searches on GenomeNet (http://blast.genome.jp/).
  #
  # == Usage
  #
  #   require 'bio'
  #   
  #   # To run an actual BLAST analysis:
  #   #   1. create a BLAST factory
  #   blast_factory = Bio::Blast.remote('blastp', 'nr-aa',
  #                                     '-e 0.0001', 'genomenet')
  #   #or:
  #   blast_factory = Bio::Blast::Remote.genomenet('blastp', 'nr-aa',
  #                                                '-e 0.0001')
  #
  #   #   2. run the actual BLAST by querying the factory
  #   report = blast_factory.query(sequence_text)
  #
  #   # Then, to parse the report, see Bio::Blast::Report
  #
  # === Available databases for Bio::Blast::Remote::GenomeNet
  #
  # Up-to-date available databases can be obtained by using
  # Bio::Blast::Remote::GenomeNet.databases(program).
  # Short descriptions of databases
  #
  #  ----------+-------+---------------------------------------------------
  #   program  | query | db (supported in GenomeNet)
  #  ----------+-------+---------------------------------------------------
  #   blastp   | AA    | nr-aa, genes, vgenes.pep, swissprot, swissprot-upd,
  #  ----------+-------+ pir, prf, pdbstr
  #   blastx   | NA    | 
  #  ----------+-------+---------------------------------------------------
  #   blastn   | NA    | nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss,
  #  ----------+-------+ htgs, dbsts, embl-nonst, embnonst-upd, epd,
  #   tblastn  | AA    | genes-nt, genome, vgenes.nuc
  #  ----------+-------+---------------------------------------------------
  #
  # == See also
  #
  # * Bio::Blast
  # * Bio::Blast::Report
  # * Bio::Blast::Report::Hit
  # * Bio::Blast::Report::Hsp
  #
  # == References
  # 
  # * http://www.ncbi.nlm.nih.gov/blast/
  # * http://www.ncbi.nlm.nih.gov/Education/BLASTinfo/similarity.html
  # * http://blast.genome.jp/ideas/ideas.html#blast
  #
  module GenomeNet

    Host = "blast.genome.jp".freeze

    # Creates a remote BLAST factory using GenomeNet.
    # Returns Bio::Blast object.
    #
    # Note for future improvement: In the future, it might return
    # Bio::Blast::Remote::GenomeNet or other object. 
    #
    def self.new(program, db, options = [])
      Bio::Blast.new(program, db, options, 'genomenet')
    end

    # Information for GenomeNet BLAST search.
    module Information

      include Bio::Blast::Remote::Information

      # gets information from remote host and parses database information
      def _parse_databases
        if defined? @parse_databases
          return nil if @parse_databases
        end
        databases = {}
        dbdescs = {}
        key = nil
        host = Bio::Blast::Remote::Genomenet::Host
        http = Bio::Command.new_http(host)
        result = http.get('/')
        #p result.body
        result.body.each_line do |line|
          case line
          when /\"set\_dbtype\(this\.form\,\'(prot|nucl)\'\)\"/
            key = $1
            databases[key] ||= []
            dbdescs[key] ||= {}
          when /\<input *type\=\"radio\" *name\=\"dbname\" *value\=\"([^\"]+)\"[^\>]*\>([^\<\>]+)/
            db = $1.freeze
            desc = $2.strip.freeze
            databases[key].push db
            dbdescs[key][db] = desc
          end
        end

        # mine-aa and mine-nt should be removed
        [ 'prot', 'nucl' ].each do |mol|
          ary  = databases[mol] || []
          hash = dbdescs[mol] || {}
          [ 'mine-aa', 'mine-nt' ].each do |k|
            ary.delete(k)
            hash.delete(k)
          end
          databases[mol] = ary.freeze
          dbdescs[mol] = hash
        end

        [ databases, dbdescs ].each do |h|
          prot = h['prot']
          nucl = h['nucl']
          h.delete('prot')
          h.delete('nucl')
          h['blastp'] = prot
          h['blastx'] = prot
          h['blastn']  = nucl
          h['tblastn'] = nucl
          h['tblastx'] = nucl
        end

        @databases = databases
        @database_descriptions = dbdescs
        @parse_databases = true
        true
      end
      private :_parse_databases

    end #module Information

    extend Information

    private

    # executes BLAST and returns result as a string
    def exec_genomenet(query)
      host = Host
      #host = "blast.genome.jp"
      #path = "/sit-bin/nph-blast"
      path = "/sit-bin/blast" #2005.08.12

      options = make_command_line_options
      opt = Bio::Blast::NCBIOptions.new(options)

      program = opt.delete('-p')
      db = opt.delete('-d')

      matrix = opt.delete('-M') || 'blosum62'
      filter = opt.delete('-F') || 'T'

      opt_V = opt.delete('-V') || 500 # default value for GenomeNet
      opt_B = opt.delete('-B') || 250 # default value for GenomeNet

      # format, not for form parameters, but included in option string
      opt_m = opt.get('-m') || '7' # default of BioRuby GenomeNet factory
      opt.set('-m', opt_m)

      optstr = Bio::Command.make_command_line_unix(opt.options)

      form = {
        'style'          => 'raw',
        'prog'           => program,
        'dbname'         => db,
        'sequence'       => query,
        'other_param'    => optstr,
        'matrix'         => matrix,
        'filter'         => filter,
        'V_value'        => opt_V, 
        'B_value'        => opt_B, 
        'alignment_view' => 0,
      }

      data = []

      form.each do |k, v|
        data.push("#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}") if v
      end

      begin
        http = Bio::Command.new_http(host)
        http.open_timeout = 300
        http.read_timeout = 600
        result = http.post(path, data.join('&'),
                           { 'Content-Type' =>
                             'application/x-www-form-urlencoded' })
        @output = result.body

        # workaround 2008.8.13
        if result.code == '302' then
          newuri = URI.parse(result['location'])
          newpath = newuri.path
          result = http.get(newpath)
          @output = result.body
          # waiting for BLAST finished
          while /Your job ID is/ =~ @output and
              /Your result will be displayed here\<br\>/ =~ @output
            if /This page will be reloaded automatically in\s*((\d+)\s*min\.)?\s*(\d+)\s*sec\./ =~ @output then
              reloadtime = $2.to_i * 60 + $3.to_i
              reloadtime = 300 if reloadtime > 300
              reloadtime = 1 if reloadtime < 1
            else
              reloadtime = 5
            end
            if $VERBOSE then
              $stderr.puts "waiting #{reloadtime} sec to reload #{newuri.to_s}"
            end
            sleep(reloadtime)
            result = http.get(newpath)
            @output = result.body
          end
        end

        # workaround 2005.08.12
        if /\<A +HREF=\"(http\:\/\/blast\.genome\.jp(\/tmp\/[^\"]+))\"\>Show all result\<\/A\>/i =~ @output.to_s then
          result = http.get($2)
          @output = result.body
          txt = @output.to_s.split(/\<pre\>/)[1]
          raise 'cannot understand response' unless txt
          txt.sub!(/\<\/pre\>.*\z/m, '')
          txt.sub!(/.*^ \-{20,}\s*/m, '')
          @output = txt.gsub(/\&lt\;/, '<')
        else
          raise 'cannot understand response'
        end
      end

      # for -m 0 (NCBI BLAST default) output, html tags are removed.
      if opt_m.to_i == 0 then
        #@output_bak = @output
        txt = @output.gsub(/^\s*\<img +src\=\"\/Fig\/arrow\_top\.gif\"\>.+$\r?\n/, '')
        txt.gsub!(/^.+\<\/form\>$/, '')
        txt.gsub!(/^\<form *method\=\"POST\" name\=\"clust\_check\"\>.+$\r?\n/, '')
        txt.gsub!(/\<[^\>\<]+\>/m, '')
        @output = txt
      end

      return @output
    end

  end # class GenomeNet

  # alias for lazy load
  Genomenet = GenomeNet

end # module Bio::Blast::Remote

