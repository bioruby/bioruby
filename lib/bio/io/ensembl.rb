#
# = bio/io/ensembl.rb - An Ensembl Genome Browser client.
#
# Copyright::   Copyright (C) 2006
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id: ensembl.rb,v 1.11 2007/04/05 23:35:41 trevor Exp $
#
# == Description
#
# Client classes for Ensembl Genome Browser.
#
# == Examples
#
#  human = Bio::Ensembl.new('Homo_sapiens')
#  seq = human.exportview(1, 1000, 100000)
#  gff = human.exportview(1, 1000, 100000, ['gene', 'variation', 'genscan'])
#
#  human = Bio::Ensembl.human
#  seq = human.exportview(1, 1000, 100000)
#  gff = human.exportview(1, 1000, 100000, ['gene'])
#
#  seq = Bio::Ensembl.human.exportview(1, 1000, 100000)
#  gff = Bio::Ensembl.human.exportview(1, 1000, 100000, ['gene', 'variation', 'genscan'])
#
#  
# == References
#
# * Ensembl
#   http:/www.ensembl.org/
#

require 'bio/command'

module Bio

# == Description
#
# An Ensembl Genome Browser client class.
#
# == Examples
#
#  human = Bio::Ensembl.new('Homo_sapiens')
#  seq = human.exportview(1, 1000, 100000)
#  gff = human.exportview(1, 1000, 100000, ['gene'])
#
#  mouse = Bio::Ensembl.new('Mus_musculus')
#  seq = mouse.exportview(1, 1000, 100000)
#  gff = mouse.exportview(1, 1000, 100000, ['gene', 'variation', 'genscan'])
#
#  rice = Bio::Enesmbl.new('Oryza_sativa', 'http://www.gramene.org')
#  seq = rice.exportview(1, 1000, 100000)
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
  
  ENSEMBL_URL = 'http://www.ensembl.org'

  # Server URL (ex. 'http://www.ensembl.org')
  attr_reader :server

  # Organism name. (ex. 'Homo_sapiens').
  attr_reader :organism

  def initialize(organism, server = nil)
    @server = server || ENSEMBL_URL
    @organism = organism
    @uri = [ @server.chomp('/'), @organism ].join('/')
  end

  def self.human
    self.new("Homo_sapiens")
  end

  def self.mouse
    self.new("Mus_musculus")
  end

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
  #   human = Bio::Ensembl.new('Homo_sapiens')
  #     or
  #   human = Bio::Ensembl.human
  #
  #   # Genomic sequence in Fasta format
  #   human.exportview(:seq_region_name => 1, 
  #                    :anchor1 => 1149206, :anchor2 => 1149229)
  #   human.exportview(1, 1149206, 1149229)
  #
  #   # Feature in GFF
  #   human.exportview(:seq_region_name => 1, 
  #                    :anchor1 => 1149206, :anchor2 => 1150000, 
  #                    :options => ['similarity', 'repeat', 
  #                                 'genscan', 'variation', 'gene'])
  #   human.exportview(1, 1149206, 1150000, ['variation', 'gene'])
  #   
  # Feature in TAB
  #   human.exportview(:seq_region_name => 1, 
  #                    :anchor1 => 1149206, :anchor2 => 1150000, 
  #                    :options => ['similarity', 'repeat', 
  #                                 'genscan', 'variation', 'gene'],
  #                    :format => 'tab')
  #
  # == Arguments
  #
  # Bio::Ensembl#exportview method allow both orderd arguments and 
  # named arguments. (Note: mandatory arguments are marked by '*').
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
  def exportview(*args)
    defaults = {
      :type1 => 'bp', 
      :type2 => 'bp', 
      :downstream => '', 
      :upstream => '', 
      :format => 'fasta',
      :options => [],
      :action => 'export', 
      :_format => 'Text', 
      :output => 'txt', 
      :submit => 'Continue >>'
    }

    if args.first.class == Hash
      options = args.first
      if options[:options] and options[:format] != 'fasta' and options[:format] != 'tab' 
        options.update({:format => 'gff'}) 
      end
    else
      options = {
        :seq_region_name => args[0], 
        :anchor1 => args[1], 
        :anchor2 => args[2],
      }

      case args[3]
      when Array
        options.update({:format => 'gff', :options => args[3]}) 
      when Hash
        options.update(args[3])
      end

      if args[4].class == Hash
        options.update(args[4])
      end
    end

    params = defaults.update(options)

    result, = Bio::Command.post_form("#{@uri}/exportview", params)

    return result.body
  end

end # class Ensembl

end # module Bio



# Codes for backward-compatibility.
#
class Bio::Ensembl
  EBIServerURI = ENSEMBL_URL

  def self.server_uri(uri = nil)
    if uri
      @uri = uri
    else
      @uri || EBIServerURI
    end
  end
    
  class Base
    def self.exportview(*args)
      Bio::Ensembl.new(Organism).exportview(*args)
    end
  end
  
  class Human < Base
    Organism = Bio::Ensembl.human.organism
  end
  
  class Mouse < Base
    Organism = Bio::Ensembl.mouse.organism
  end
end # class Bio::Ensembl




