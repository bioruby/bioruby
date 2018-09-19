#
# = bio/appl/blast/genomenet.rb - Remote BLAST wrapper using GenomeNet
# 
# Copyright::  Copyright (C) 2001,2008  Mitsuteru C. Nakao <n@bioruby.org>
# Copyright::  Copyright (C) 2002,2003  Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2006       Jan Aerts <jan.aerts@bbsrc.ac.uk>
# Copyright::  Copyright (C) 2008       Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#

require 'net/http'
require 'uri'
require 'bio/command'
require 'shellwords'

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
  # === BLAST options
  #
  # Options are basically the same as those of the blastall command
  # in NCBI BLAST. See http://www.genome.jp/tools-bin/show_man?blast2
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
  # * http://www.genome.jp/tools/blast/
  #
  module GenomeNet

    Host = "www.genome.jp".freeze

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
        http = Bio::Command.new_https(host)
        result = http.get('/tools/blast/')
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
      #path = "/sit-bin/blast" #2005.08.12
      path = "/tools-bin/blast" #2012.01.12

      options = make_command_line_options
      opt = Bio::Blast::NCBIOptions.new(options)

      program = opt.delete('-p')
      db = opt.delete('-d')

      # When database name starts with mine-aa or mine-nt,
      # space-separated list of KEGG organism codes can be given.
      # For example, "mine-aa eco bsu hsa".
      if /\A(mine-(aa|nt))\s+/ =~ db.to_s then
        db = $1
        myspecies = {}
        myspecies["myspecies-#{$2}"] = $'
      end

      matrix = opt.delete('-M') || 'blosum62'
      filter = opt.delete('-F') || 'T'

      opt_v = opt.delete('-v') || 500 # default value for GenomeNet
      opt_b = opt.delete('-b') || 250 # default value for GenomeNet

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
        'V_value'        => opt_v, 
        'B_value'        => opt_b, 
        'alignment_view' => 0,
      }

      form.merge!(myspecies) if myspecies

      form.keys.each do |k|
        form.delete(k) unless form[k]
      end

      begin
        http = Bio::Command.new_https(host)
        http.open_timeout = 300
        http.read_timeout = 600
        result = Bio::Command.http_post_form(http, path, form)
        @output = result.body

        # workaround 2008.8.13
        if result.code == '302' then
          newuri = URI.parse(result['location'])
          newpath = newuri.path
          result = http.get(newpath)
          @output = result.body
          # waiting for BLAST finished
          while /Your job ID is/ =~ @output and
              /Your result will be displayed here\.?\<br\>/i =~ @output
            if /This page will be reloaded automatically in\s*((\d+)\s*min\.)?\s*((\d+)\s*sec\.)?/ =~ @output then
              reloadtime = $2.to_i * 60 + $4.to_i
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

        # workaround 2005.08.12 + 2011.01.27 + 2011.7.22
        if /\<A +HREF=\"(https?\:\/\/[\-\.a-z0-9]+\.genome\.jp)?(\/tmp\/[^\"]+)\"\>Show all result\<\/A\>/i =~ @output.to_s then
          all_prefix = $1
          all_path = $2
          all_prefix = "https://#{Host}" if all_prefix.to_s.empty?
          all_uri = all_prefix + all_path
          @output = Bio::Command.read_uri(all_uri)
          case all_path
          when /\.txt\z/
            ; # don't touch the data
          else
            txt = @output.to_s.split(/\<pre\>/)[1]
            raise 'cannot understand response' unless txt
            txt.sub!(/\<\/pre\>.*\z/m, '')
            txt.sub!(/.*^ \-{20,}\s*/m, '')
            @output = txt
          end
        else
          raise 'cannot understand response'
        end
      end

      # for -m 0 (NCBI BLAST default) output, html tags are removed.
      if opt_m.to_i == 0 then
        #@output_bak = @output
        txt = @output.sub!(/^\<select .*/, '')
        #txt.gsub!(/^\s*\<img +src\=\"\/Fig\/arrow\_top\.gif\"\>.+$\r?\n/, '')
        txt.gsub!(/^.+\<\/form\>$/, '')
        #txt.gsub!(/^\<form *method\=\"POST\" name\=\"clust\_check\"\>.+$\r?\n/, '')
        txt.gsub!(/\<a href\=\"\/tmp[^\"]\>\&uarr\;\&nbsp\;Top\<\/a\>/, '')
        txt.gsub!(/\<[^\>\<]+\>/m, '')
        txt.gsub!(/\&gt\;/, '>')
        txt.gsub!(/\&lt\;/, '<')
        @output = txt
      end

      return @output
    end

  end # class GenomeNet

  # alias for lazy load
  Genomenet = GenomeNet

end # module Bio::Blast::Remote

