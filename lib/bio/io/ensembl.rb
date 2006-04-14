#
# = bio/io/ensembl.rb - An Ensembl Genome Browser client.
#
# Copyright::   Copyright (C) 2006
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     Ruby's
#
# $Id: ensembl.rb,v 1.1 2006/04/14 06:28:09 nakao Exp $
#
# == Description
#
# Client classes for Ensembl Genome Browser.
#
# == Examples
#
#  seq = Bio::Ensembl::Human.exportview(1, 1000, 100000)
#  gff = Bio::Ensembl::Human.exportview(1, 1000, 100000, ['gene'])
#
#  seq = Bio::Ensembl::Mouse.exportview(1, 1000, 100000)
#  gff = Bio::Ensembl::Mouse.exportview(1, 1000, 100000, ['gene', 'variation', 'genscan'])
#
#  
# == References
#
# * Ensembl
#   http:/www.ensembl.org/
#

require 'bio'
require 'cgi'

module Bio

# == Description
#
# An Ensembl Genome Browser client class.
#
# == Examples
#
#  seq = Bio::Ensembl::Human.exportview(1, 1000, 100000)
#  gff = Bio::Ensembl::Human.exportview(1, 1000, 100000, ['gene'])
#
#  seq = Bio::Ensembl::Mouse.exportview(1, 1000, 100000)
#  gff = Bio::Ensembl::Mouse.exportview(1, 1000, 100000, ['gene', 'variation', 'genscan'])
#
# == References
#
# * Ensembl
#   http:/www.ensembl.org/
#
class Ensembl

  # Hostname of Ensembl Genome Browser.
  ServerName = 'www.ensembl.org'


  # Ensembl Genome Browser Client Super Class
  #
  # == Examples
  #   
  #   module Bio
  #     class Ensembl::Kumamushi < Base
  #       Organism = 'Milnesium_tardigradum'
  #     end
  #   end
  #   fna = Bio::Ensembl::Kumamushi.exportview(1, 1000, 20000)
  #
  class Base

    # Ensembl ExportView Client.
    #
    # Retrieve genomic sequence/features from Ensembl ExportView in plain text.
    # Ensembl ExportView exports genomic data (sequence and features) in 
    # several file formats including fasta, GFF and tab.
    #
    # * ExportViwe (http://www.ensembl.org/Homo_sapiens/exportview).
    #
    # == Examples
    #
    #   # Genomic sequence in Fasta format
    #   Bio::Ensembl::Human.exportview(:seq_region_name => 1, :anchor1 => 1149206, :anchor2 => 1149229)
    #   Bio::Ensembl::Human.exportview(1, 1149206, 1149229)
    #
    #   # Feature in GFF
    #   Bio::Ensembl::Human.exportview(:seq_region_name => 1, :anchor1 => 1149206, :anchor2 => 1150000, 
    #                                  :options => ['similarity', 'repeat', 'genscan', 'variation', 'gene'])
    #   Bio::Ensembl::Human.exportview(1, 1149206, 1150000, ['variation', 'gene'])
    #
    # == Arguments
    #
    # Bio::Ensembl::Base#exportview method allow both orderd arguments and 
    # named arguments. 
    # Note: mandatory arguments marked '*'.
    #
    # === Orderd Arguments
    #
    # 1. seq_region_name - Chromosome number (*)
    # 2. anchor1         - From coordination (*)
    # 3. anchor2         - To coordination (*)
    # 4. options         - Features to export (in :format => 'gff' or 'tab')
    #                      ['similarity', 'repeat', 'genscan', 'variation', 'gene']
    #
    # === Named Arguments
    # 
    # * :seq_region_name - Chromosome number (*)
    # * :anchor1         - From coordination (*)
    # * :anchor2         - To coordination (*)
    # * :type1           - From coordination type ['bp', ]
    # * :type2           - To coordination type ['bp', ]
    # * :upstream        - Bp upstream
    # * :downstream      - Bp downstream
    # * :format          - File format ['fasta', 'gff', 'tab']
    # * :options         - Features to export (for :format => 'gff' or 'tab')
    #                      ['similarity', 'repeat', 'genscan', 'variation', 'gene']
    # 
    def self.exportview(*args)
      cgi = Client.new('exportview', self::Organism)

      if args.first.class == Hash then opts = args.first
      else
        opts = {:seq_region_name => args[0], :anchor1 => args[1], :anchor2 => args[2]}
        case args.size
        when 3 then opts.update({:format => 'fasta'})
        when 4 then opts.update({:format => 'gff', :options => args[3]}) ;        end
      end
      @hash = {:type1 => 'bp', 
               :type2 => 'bp', 
               :downstream => '', 
               :upstream => '', 
               :format => 'fasta',
               :options => [],
               :action => 'export', :_format => 'Text', :output => 'txt', :submit => 'Continue >>'}

      cgi.exec(@hash.update(opts))
    end

    # An Ensembl CGI client class
    # 
    # === Examples
    #
    #  cgi = Client('martview', 'Homo_sapiens')
    #  cgi.exec(hash_data)
    #
    class Client < PSORT::CGIDriver
      def initialize(cgi_name, genome_name)
        super(Ensembl::ServerName, ['', genome_name, cgi_name].join('/'))
      end

      private

      def make_args(query)
        @args = {}
        query.each { |k, v| @args[k.to_s] = v }
        nested_args_join(query)
      end

      def nested_args_join(hash)
        tmp = []
        hash.each do |key, value|
          if value.class == Array then value.each { |val| tmp << [key, val] } else tmp << [key, value] end
        end
        tmp.map {|x| x.map {|x| CGI.escape(x.to_s) }.join("=") }.join('&')
      end

      def parse_report(result_body)
        result_body
      end
    end # class Client

  end # class Base


  # Ensembl Human Genome
  # 
  # See Bio::Ensembl::Base class.
  # 
  class Human < Base
    Organism = 'Homo_sapiens'
  end # class Human

  # Ensembl Mouse Genome
  #
  # See Bio::Ensembl::Base class.
  #
  class Mouse < Base
    Organism = 'Mus_musculus'
  end # class Mouse

end # class Ensembl

end # module Bio


