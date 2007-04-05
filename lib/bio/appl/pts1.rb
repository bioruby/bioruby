module Bio

#
# = bio/appl/pts1.rb - A web service client of PTS1, predicting for the 
#   peroxisomal targeting signal type 1.
#
# Copyright::   Copyright (C) 2006 
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id: pts1.rb,v 1.5 2007/04/05 23:35:39 trevor Exp $
#

require 'uri'
require 'net/http'
require 'bio/db/fasta'
require 'bio/command'

# = Bio::PTS1 - A web service client class for PTS1 predictor.
#
# == Peroxisomal targeting signal type 1 (PTS1) predictor
#
# Bio::PTS1 class is a client of the PTS1 predictor.
#
# == Examples
#
#   require 'bio'
#   sp = Bio::SPTR.new(Bio::Fetch.query("sp", "p53_human"))
#   faa = sp.seq.to_fasta(sp.entry_id)
#   pts1 = Bio::PTS1.new
#   report = pts1.exec_remote(faa)
#   report.output     #=> "<HTML>\n<HEAD><TITLE>PTS1 Prediction Server ..."
#   report.prediction #=> "Not targeted"
#   report.cterm      #=> "KLMFKTEGPDSD"
#   report.score      #=> "-79.881"
#   report.fp         #=> "67.79%"
#   report.sppta      #=> "-1.110"
#   report.spptna     #=> "-41.937"
#   report.profile    #=> "-36.834"
#
# == References
#
# * The PTS1 predictor
#   http://mendel.imp.ac.at/mendeljsp/sat/pts1/PTS1predictor.jsp
#
# * Neuberger G, Maurer-Stroh S, Eisenhaber B, Hartig A, Eisenhaber F. 
#   Motif refinement of the peroxisomal targeting signal 1 and evaluation 
#   of taxon-specific differences. 
#   J Mol Biol. 2003 May 2;328(3):567-79. PMID: 12706717 
#
# * Neuberger G, Maurer-Stroh S, Eisenhaber B, Hartig A, Eisenhaber F. 
#   Prediction of peroxisomal targeting signal 1 containing proteins from 
#   amino acid sequence. 
#   J Mol Biol. 2003 May 2;328(3):581-92. PMID: 12706718 
#
class PTS1

  # Organism specific parameter value: function names.
  FUNCTION = {
    'METAZOA-specific' => 1,
    'FUNGI-specific'   => 2,
    'GENERAL'          => 3,
  }

  # Output report.
  attr_reader :output

  # Used function name (Integer). 
  # function_name = Bio::PTS1::FUNCTION.find_all {|k,v| v == pts1.function }[0][0]
  attr_reader :function

  # Short-cut for Bio::PTS1.new(Bio::PTS1::FUNCTION['METAZOA-specific'])
  def self.new_with_metazoa_function
    self.new('METAZOA-specific')
  end

  # Short-cut for Bio::PTS1.new(Bio::PTS1::FUNCTION['FUNGI-specific'])
  def self.new_with_fungi_function
    self.new('FUNGI-specific')
  end

  # Short-cut for Bio::PTS1.new(Bio::PTS1::FUNCTION['GENERAL'])
  def self.new_with_general_function
    self.new('GENERAL')
  end

   
  # Constructs Bio::PTS1 web service client.
  # 
  # == Examples
  #
  #   serv_default_metazoa_specific = Bio::PTS1.new
  #   serv_general_function = Bio::PTS1.new('GENERAL')
  #   serv_fungi_specific = Bio::PTS1.new(2)    # See Bio::PTS1::FUNCTION.
  #
  def initialize(func = 'METAZOA-specific')
    @host = "mendel.imp.ac.at"
    @cgi_path = "/sat/pts1/cgi-bin/pts1.cgi"
    @output = nil
    @function = function(func)
  end


  # Sets and shows the function parameter.
  #
  # Organism specific parameter: function names (Bio::PTS1::FUNTION.keys).
  #
  #
  # == Examples
  #
  #  # sets function name parameter.
  #  serv = Bio::PTS1.new
  #  serv.function('METAZOA-specific')
  #
  #  # shows function name parameter.
  #  serv.function #=> "METAZOA-specific"
  # 
  def function(func = nil)
    return @function.keys.to_s if func == nil

    if FUNCTION.values.include?(func)
      @function = Hash[*FUNCTION.find {|x| x[1] == func}]
    elsif FUNCTION[func]
      @function = {func => FUNCTION[func]} 
    else
      raise ArgumentError, 
            "Invalid argument: #{func}", 
            "Available function names: #{FUNCTION.keys.inspect}"
    end
    @function
  end


  # Executes the query request and returns result output in Bio::PTS1::Report.
  # The query argument is available both aSting in fasta format text and 
  # aBio::FastaFormat.
  #
  # == Examples
  # 
  #   require 'bio'
  #   pts1 = Bio::PTS1.new
  #   pts1.exec(">title\nKLMFKTEGPDSD")
  #
  #   pts1.exec(Bio::FastaFormat.new(">title\nKLMFKTEGPDSD"))
  #
  def exec(query)
    seq = set_sequence_in_fastaformat(query)
    
    @form_data = {'function' => @function.values.to_s,
                  'sequence' => seq.seq,
                  'name'     => seq.definition }
    @uri = URI.parse(["http:/", @host, @cgi_path].join('/'))

    result, = Bio::Command.post_form(@uri, @form_data)
    @output = Report.new(result.body)
    
    return @output
  end

  private 

  # Sets query sequence in Fasta Format if any.
  def set_sequence_in_fastaformat(query)
    if query.class == Bio::FastaFormat
      return query
    else
      return Bio::FastaFormat.new(query)
    end
  end


  # = Parser for the PTS1 prediction Report (in HTML).
  #
  #
  class Report

    # Query sequence name.
    attr_reader :entry_id

    # Amino acids subsequence at C-terminal region.
    attr_reader :cterm

    # Score
    attr_reader :score

    # Profile
    attr_reader :profile

    # S_ppt (non accessibility)
    attr_reader :spptna

    # S_ppt (accessibility)
    attr_reader :sppta

    # False positive probability
    attr_reader :fp

    # Prediction ("Targeted", "Twilight zone" and "Not targeted")
    attr_reader :prediction
    
    # Raw output
    attr_reader :output

    # Parsing PTS1 HTML report.
    # 
    # == Example
    #
    #   report = Bio::PTS1::Report.new(str)
    #   report.cterm 
    #
    def initialize(str)
      @cterm   = ''
      @score   = 0
      @profile = 0
      @spptna  = 0
      @sppta   = 0
      @fp      = 0
      @prediction = 0
      
      if /PTS1 query prediction/m =~ str
        @output = str
        parse
      else
        raise 
      end
    end


    private

    def parse
      @output.each do |line|
        case line
        when /Name<\/td><td>(\S.+)<\/td><\/tr>/
          @entry_id = $1
        when /C-terminus<\/td><td>(\w+)<\/td>/
          @cterm = $1
        when /Score<\/b><td><b>(-?\d.+?)<\/b><\/td><\/tr>/
          @score = $1
        when /Profile<\/i><\/td><td>(.+?)<\/td>/
          @profile = $1
        when /S_ppt \(non-accessibility\)<\/i><\/td><td>(.+?)<\/td>/
          @spptna = $1
        when /S_ppt \(accessibility\)<\/i><\/td><td>(.+?)<\/td>/
          @sppta = $1
        when /P\(false positive\)<\/i><\/td><td>(.+?)<\/td>/
          @fp = $1
        when /Prediction classification<\/i><\/td><td>(\w.+?)<\/td>/
          @prediction = $1
        else
        end
      end
    end
    
  end # class Report
  
end # class PTS1

end # module Bio




