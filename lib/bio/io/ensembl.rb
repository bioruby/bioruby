#
# = bio/io/ensembl.rb - An Ensembl Genome Browser client.
#
# Copyright::   Copyright (C) 2006
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     Ruby's
#
# $Id: ensembl.rb,v 1.3 2006/07/14 14:28:44 ngoto Exp $
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

require 'bio/command'
require 'uri'
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
#  Bio::Enesmbl.server_uri("http://www.gramene.org")
#  class Rice < Base
#    Organism = 'Oryza_sativa'
#  end
#  seq = Bio::Ensembl::Rice.exportview(1, 1000, 100000)
#
# == References
#
# * Ensembl
#   http:/www.ensembl.org/
#
# * GRAMENE
#   http://www.gramene.org/
#
class Ensembl

  # Hostname of the Ensembl Genome Browser.
  EBIServerURI = 'http://www.ensembl.org'

  # An Alternative Hostname for Ensembl Genome Browser.
  @@server_uri = nil

  # Sets and uses an alternative hostname for ensembl genome browser.
  #
  # == Example
  #
  #   require 'bio'
  #   p Bio::Enesmbl.server_uri #=> 'http://www.ensembl.org'
  #   Bio::Enesmbl.server_uri("http://www.gramene.org")
  #   p Bio::Enesmbl.server_uri #=> "http://www.gramene.org"
  #
  def self.server_uri(uri = nil)
    if uri
      @@server_uri = uri
    else
      @@server_uri || EBIServerURI
    end
  end


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
    #   Bio::Ensembl::Human.exportview(:seq_region_name => 1, 
    #                                  :anchor1 => 1149206, :anchor2 => 1149229)
    #   Bio::Ensembl::Human.exportview(1, 1149206, 1149229)
    #
    #   # Feature in GFF
    #   Bio::Ensembl::Human.exportview(:seq_region_name => 1, 
    #                                  :anchor1 => 1149206, :anchor2 => 1150000, 
    #                                  :options => ['similarity', 'repeat', 
    #                                               'genscan', 'variation', 
    #                                               'gene'])
    #   Bio::Ensembl::Human.exportview(1, 1149206, 1150000, 
    #                                  ['variation', 'gene'])
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
    #                      ['similarity', 'repeat', 'genscan', 'variation', 
    #                       'gene']
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
    #                      ['similarity', 'repeat', 'genscan', 'variation', 
    #                       'gene']
    # 
    def self.exportview(*args)
      if args.first.class == Hash then opts = args.first
      else
        options = {:seq_region_name => args[0], 
                   :anchor1 => args[1], 
                   :anchor2 => args[2]}
        case args.size
        when 3 then 
          options.update({:format => 'fasta'})
        when 4 then 
          options.update({:format => 'gff', :options => args[3]})
        end
      end

      @data = {:type1 => 'bp', 
               :type2 => 'bp', 
               :downstream => '', 
               :upstream => '', 
               :format => 'fasta',
               :options => [],
               :action => 'export', 
               :_format => 'Text', 
               :output => 'txt', 
               :submit => 'Continue >>'}

      cgi = Client.new('exportview', self::Organism)
      cgi.exec(@data.update(options))
    end



    # An Ensembl CGI client class
    #
    # Enable the use of HTTP access via a proxy by setting the proxy address up
    # as the 'http_proxy' enviroment variable. 
    # 
    # === Examples
    #
    #  cgi = Client.new('martview', 'Homo_sapiens')
    #  result_body = cgi.exec(hash_data)
    #
    class Client

      # Sets cgi_name and genome_name.
      #
      # === Example
      #
      #  cgi = Client.new('martview', 'Homo_sapiens')
      #
      def initialize(cgi_name, genome_name)
        @uri = URI.parse(Ensembl.server_uri)
        @path = ['', genome_name, cgi_name].join('/')
      end

      # Executes query with data.
      #
      # === Example
      #
      #  result_body = cgi.exec(hash_data)
      #
      def exec(data_hash)
        data = make_args(data_hash)

        result = nil      
        Bio::Command.start_http(@uri.host, @uri.port) {|http|
          result, = http.post(@path, data)
        }
        result.body
      end

      private

      def make_args(hash)
        tmp = []
        hash.each do |key, value|
          if value.class == Array then 
            value.each { |val| tmp << [key, val] } 
          else 
            tmp << [key, value] 
          end
        end
        tmp.map {|e| e.map {|x| CGI.escape(x.to_s) }.join("=") }.join('&')
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


