#
# = bio/appl/blast/report.rb - BLAST Report class
# 
# Copyright::  Copyright (C) 2003 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/appl/blast'
require 'bio/appl/blast/xmlparser'
require 'bio/appl/blast/rexml'
require 'bio/appl/blast/format8'
require 'bio/io/flatfile'

module Bio
class Blast

# = Bio::Blast::Report
# 
# Parsed results of the blast execution for Tab-delimited and XML output
# format.  Tab-delimited reports are consists of
# 
#   Query id,
#   Subject id,
#   percent of identity,
#   alignment length,
#   number of mismatches (not including gaps),
#   number of gap openings,
#   start of alignment in query,
#   end of alignment in query,
#   start of alignment in subject,
#   end of alignment in subject,
#   expected value,
#   bit score.
# 
# according to the MEGABLAST document (README.mbl).  As for XML output,
# see the following DTDs.
# 
#   * http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.dtd
#   * http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.mod
#   * http://www.ncbi.nlm.nih.gov/dtd/NCBI_Entity.mod
# 
class Report

  # for Bio::FlatFile support (only for XML data)
  DELIMITER = RS = "</BlastOutput>\n"

  # Specify to use XMLParser to parse XML (-m 7) output.
  def self.xmlparser(data)
    self.new(data, :xmlparser)
  end

  # Specify to use REXML to parse XML (-m 7) output.
  def self.rexml(data)
    self.new(data, :rexml)
  end

  # Specify to use tab delimited output parser.
  def self.tab(data)
    self.new(data, :tab)
  end

  def auto_parse(data)
    if /<?xml/.match(data[/.*/])
      if defined?(XMLParser)
        xmlparser_parse(data)
        @reports = blastxml_split_reports
      else
        rexml_parse(data)
        @reports = blastxml_split_reports
      end
    else
      tab_parse(data)
    end
  end
  private :auto_parse

  # Passing a BLAST output from 'blastall -m 7' or '-m 8' as a String.
  # Formats are auto detected.
  def initialize(data, parser = nil)
    @iterations = []
    @parameters = {}
    case parser
    when :xmlparser		# format 7
      xmlparser_parse(data)
      @reports = blastxml_split_reports
    when :rexml		# format 7
      rexml_parse(data)
      @reports = blastxml_split_reports
    when :tab		# format 8
      tab_parse(data)
    when false
      # do not parse, creates an empty object
    else
      auto_parse(data)
    end
  end

  # Returns an Array of Bio::Blast::Report::Iteration objects.
  attr_reader :iterations

  # Returns a Hash containing execution parameters.  Valid keys are:
  # 'matrix', 'expect', 'include', 'sc-match', 'sc-mismatch',
  # 'gap-open', 'gap-extend', 'filter'
  attr_reader :parameters

  #--
  # Shortcut for BlastOutput values.
  #++

  # program name (e.g. "blastp") (String)
  attr_reader :program

  # BLAST version (e.g. "blastp 2.2.18 [Mar-02-2008]") (String)
  attr_reader :version

  # reference (String)
  attr_reader :reference

  # database name or title (String)
  attr_reader :db

  # query ID (String)
  attr_reader :query_id

  # query definition line (String)
  attr_reader :query_def

  # query length (Integer)
  attr_reader :query_len

  # Matrix used (-M) : shortcuts for @parameters
  def matrix;       @parameters['matrix'];           end
  # Expectation threshold (-e) : shortcuts for @parameters
  def expect;       @parameters['expect'];           end
  # Inclusion threshold (-h) : shortcuts for @parameters
  def inclusion;    @parameters['include'];          end
  # Match score for NT (-r) : shortcuts for @parameters
  def sc_match;     @parameters['sc-match'];         end
  # Mismatch score for NT (-q) : shortcuts for @parameters
  def sc_mismatch;  @parameters['sc-mismatch'];      end
  # Gap opening cost (-G) : shortcuts for @parameters
  def gap_open;     @parameters['gap-open'];         end
  # Gap extension cost (-E) : shortcuts for @parameters
  def gap_extend;   @parameters['gap-extend'];       end
  # Filtering options (-F) : shortcuts for @parameters
  def filter;       @parameters['filter'];           end
  # PHI-BLAST pattern : shortcuts for @parameters
  def pattern;      @parameters['pattern'];          end
  # Limit of request to Entrez : shortcuts for @parameters
  def entrez_query; @parameters['entrez-query'];     end

  # Iterates on each Bio::Blast::Report::Iteration object. (for blastpgp)
  def each_iteration
    @iterations.each do |x|
      yield x
    end
  end

  # Iterates on each Bio::Blast::Report::Hit object of the the last Iteration.
  # Shortcut for the last iteration's hits (for blastall)
  def each_hit
    @iterations.last.each do |x|
      yield x
    end
  end
  alias each each_hit

  # Returns a Array of Bio::Blast::Report::Hits of the last iteration.
  # Shortcut for the last iteration's hits
  def hits
    @iterations.last.hits
  end

  # Returns a Hash containing execution statistics of the last iteration.
  # Valid keys are:
  # 'db-num', 'db-len', 'hsp-len', 'eff-space', 'kappa', 'lambda', 'entropy'
  # Shortcut for the last iteration's statistics.
  def statistics
    @iterations.last.statistics
  end

  # Number of sequences in BLAST db
  def db_num;    statistics['db-num'];    end
  # Length of BLAST db
  def db_len;    statistics['db-len'];    end
  # Effective HSP length
  def hsp_len;   statistics['hsp-len'];   end
  # Effective search space
  def eff_space; statistics['eff-space']; end
  # Karlin-Altschul parameter K
  def kappa;     statistics['kappa'];     end
  # Karlin-Altschul parameter Lamba
  def lambda;    statistics['lambda'];    end
  # Karlin-Altschul parameter H
  def entropy;   statistics['entropy'];   end

  # Returns a String (or nil) containing execution message of the last
  # iteration (typically "CONVERGED").
  # Shortcut for the last iteration's message (for checking 'CONVERGED')
  def message
    @iterations.last.message
  end


  # Bio::Blast::Report::Iteration
  class Iteration
    def initialize
      @message = nil
      @statistics = {}
      @num = 1
      @hits = []
    end
    # Returns an Array of Bio::Blast::Report::Hit objects.
    attr_reader :hits

    # Returns a Hash containing execution statistics.
    # Valid keys are:
    # 'db-len', 'db-num', 'eff-space', 'entropy', 'hsp-len', 'kappa', 'lambda'
    attr_reader :statistics

    # Returns the number of iteration counts.
    attr_accessor :num

    # Returns a String (or nil) containing execution message (typically
    # "CONVERGED").
    attr_accessor :message

    # Iterates on each Bio::Blast::Report::Hit object.
    def each
      @hits.each do |x|
        yield x
      end
    end

    # query ID, only available for new BLAST XML format
    attr_accessor :query_id

    # query definition, only available for new BLAST XML format
    attr_accessor :query_def

    # query length, only available for new BLAST XML format
    attr_accessor :query_len

  end #class Iteration


  # Bio::Blast::Report::Hit
  class Hit
    def initialize
      @hsps = []
    end

    # Returns an Array of Bio::Blast::Report::Hsp objects.
    attr_reader :hsps

    # Hit number
    attr_accessor :num
    # SeqId of subject
    attr_accessor :hit_id
    # Length of subject
    attr_accessor :len
    # Definition line of subject
    attr_accessor :definition
    # Accession
    attr_accessor :accession

    # Iterates on each Hsp object.
    def each
      @hsps.each do |x|
        yield x
      end
    end

    # Compatible method with Bio::Fasta::Report::Hit class.
    attr_accessor :query_id
    # Compatible method with Bio::Fasta::Report::Hit class.
    attr_accessor :query_def
    # Compatible method with Bio::Fasta::Report::Hit class.
    attr_accessor :query_len

    # Compatible method with Bio::Fasta::Report::Hit class.
    alias target_id accession
    # Compatible method with Bio::Fasta::Report::Hit class.
    alias target_def definition
    # Compatible method with Bio::Fasta::Report::Hit class.
    alias target_len len

    # Shortcut methods for the best Hsp, some are also compatible with
    # Bio::Fasta::Report::Hit class.
    def evalue;           @hsps.first.evalue;           end
    def bit_score;        @hsps.first.bit_score;        end
    def identity;         @hsps.first.identity;         end
    def percent_identity; @hsps.first.percent_identity; end
    def overlap;          @hsps.first.align_len;        end

    def query_seq;        @hsps.first.qseq;             end
    def target_seq;       @hsps.first.hseq;             end
    def midline;          @hsps.first.midline;          end

    def query_start;      @hsps.first.query_from;       end
    def query_end;        @hsps.first.query_to;         end
    def target_start;     @hsps.first.hit_from;         end
    def target_end;       @hsps.first.hit_to;           end
    def lap_at
      [ query_start, query_end, target_start, target_end ]
    end
  end


  # Bio::Blast::Report::Hsp
  class Hsp
    def initialize
      @hsp = {}
    end
    attr_reader :hsp

    # HSP number
    attr_accessor :num
    # Score (in bits) of HSP
    attr_accessor :bit_score
    # Sscore of HSP
    attr_accessor :score
    # E-value of HSP
    attr_accessor :evalue
    # Start of HSP in query
    attr_accessor :query_from
    # End of HSP
    attr_accessor :query_to
    # Start of HSP in subject
    attr_accessor :hit_from
    # End of HSP
    attr_accessor :hit_to
    # Start of PHI-BLAST pattern
    attr_accessor :pattern_from
    # End of PHI-BLAST pattern
    attr_accessor :pattern_to
    # Translation frame of query
    attr_accessor :query_frame
    # Translation frame of subject
    attr_accessor :hit_frame
    # Number of identities in HSP
    attr_accessor :identity
    # Number of positives in HSP
    attr_accessor :positive
    # Number of gaps in HSP
    attr_accessor :gaps
    # Length of the alignment used
    attr_accessor :align_len
    # Score density
    attr_accessor :density
    # Alignment string for the query (with gaps)
    attr_accessor :qseq
    # Alignment string for subject (with gaps)
    attr_accessor :hseq
    # Formating middle line
    attr_accessor :midline
    # Available only for '-m 8' format outputs.
    attr_accessor :percent_identity
    # Available only for '-m 8' format outputs.
    attr_accessor :mismatch_count
  end


  # When the report contains results for multiple query sequences,
  # returns an array of Bio::Blast::Report objects corresponding to
  # the multiple queries.
  # Otherwise, returns nil.
  #
  # Note for "No hits found":
  # When no hits found for a query sequence, the result for the query
  # is completely void and no information available in the result XML,
  # including query ID and query definition.
  # The only trace is that iteration number is skipped.
  # This means that if the no-hit query is the last query,
  # the query can not be detected, because the result XML is
  # completely the same as the result XML without the query.
  attr_reader :reports
 
  private
  # (private method)
  # In new BLAST XML (blastall >= 2.2.14), results of multiple queries
  # are stored in <Iteration>. This method splits iterations into
  # multiple Bio::Blast objects and returns them as an array.
  def blastxml_split_reports
    unless self.iterations.find { |iter|
        iter.query_id || iter.query_def || iter.query_len
      } then
      # traditional BLAST XML format, or blastpgp result.
      return nil
    end

    # new BLAST XML format (blastall 2.2.14 or later)
    origin = self
    reports = []
    prev_iternum = 0
    firsttime = true

    orig_iters = self.iterations
    orig_iters.each do |iter|
      blast = self.class.new(nil, false)
      # When no hits found, the iteration is skipped in NCBI BLAST XML.
      # So, filled with empty report object.
      if prev_iternum + 1 < iter.num then
        ((prev_iternum + 1)...(iter.num)).each do |num|
          empty_i = Iteration.new
          empty_i.num = num
          empty_i.instance_eval {
            if firsttime then
              @query_id  = origin.query_id
              @query_def = origin.query_def
              @query_len = origin.query_len
              firsttime = false
            end
          }
          empty = self.class.new(nil, false)
          empty.instance_eval {
            # queriy_* are copied from the empty_i
            @query_id  = empty_i.query_id
            @query_def = empty_i.query_def
            @query_len = empty_i.query_len
            # others are copied from the origin
            @program   = origin.program
            @version   = origin.version
            @reference = origin.reference
            @db        = origin.db
            @parameters.update(origin.parameters)
            # the empty_i is added to the iterations
            @iterations.push empty_i
          }
          reports.push empty
        end
      end

      blast.instance_eval {
        if firsttime then
          @query_id  = origin.query_id
          @query_def = origin.query_def
          @query_len = origin.query_len
          firsttime = false
        end
        # queriy_* are copied from the iter
        @query_id  = iter.query_id if iter.query_id
        @query_def = iter.query_def if iter.query_def
        @query_len = iter.query_len if iter.query_len
        # others are copied from the origin
        @program   = origin.program
        @version   = origin.version
        @reference = origin.reference
        @db        = origin.db
        @parameters.update(origin.parameters)
        # rewrites hit's query_id, query_def, query_len
        iter.hits.each do |h|
          h.query_id  = @query_id
          h.query_def = @query_def
          h.query_len = @query_len
        end
        # the iter is added to the iterations
        @iterations.push iter
      }

      prev_iternum = iter.num
      reports.push blast
    end #orig_iters.each

    # This object's iterations is set as first report's iterations
    @iterations.clear
    if rep = reports.first then
      @iterations = rep.iterations
    end

    return reports
  end

  # Flatfile splitter for NCBI BLAST XML format.
  # It is internally used when reading BLAST XML.
  # Normally, users do not need to use it directly.
  class BlastXmlSplitter < Bio::FlatFile::Splitter::Default

    # creates a new splitter object
    def initialize(klass, bstream)
      super(klass, bstream)
      @parsed_entries = []
      @raw_unsupported = false
    end

    # rewinds
    def rewind
      ret = super
      @parsed_entries.clear
      @raw_unsupported = false
      ret
    end

    # do nothing
    def skip_leader
      nil
    end

    # get an entry and return the entry as a string
    def get_entry
      if @parsed_entries.empty? then
        @raw_unsupported = false
        ent = super
        prepare_parsed_entries(ent)
        self.parsed_entry = @parsed_entries.shift
      else
        raise 'not supported for new BLAST XML format'
      end
      ent
    end

    # get an entry as a Bio::Blast::Report object
    def get_parsed_entry
      if @parsed_entries.empty? then
        ent = get_entry
      else
        self.parsed_entry = @parsed_entries.shift
        self.entry = nil
        @raw_unsupported = true
      end
      self.parsed_entry
    end

    # current raw entry as a String
    def entry
      raise 'not supported for new BLAST XML format' if @raw_unsupported
      super
    end

    # start position of the entry
    def entry_start_pos
      if entry_pos_flag then
        raise 'not supported for new BLAST XML format' if @raw_unsupported
      end
      super
    end

    # (end position of the entry) + 1
    def entry_ended_pos
      if entry_pos_flag then
        raise 'not supported for new BLAST XML format' if @raw_unsupported
      end
      super
    end

    private
    # (private method) to prepare parsed entry
    def prepare_parsed_entries(ent)
      if ent then
        blast = dbclass.new(ent)
        if blast.reports and blast.reports.size >= 1 then
          # new blast xml using <Iteration> for multiple queries
          @parsed_entries.concat blast.reports
        else
          # traditional blast xml
          @parsed_entries.push blast
        end
      end
    end

  end #class BlastXmlSplitter

  # splitter for Bio::FlatFile support
  FLATFILE_SPLITTER = BlastXmlSplitter

end # Report

end # Blast
end # Bio


if __FILE__ == $0

=begin

  begin			# p is suitable than pp for the following test script
    require 'pp'
    alias p pp
  rescue
  end

  # for multiple xml reports (iterates on each Blast::Report)
  Bio::Blast.reports(ARGF) do |rep|
    rep.iterations.each do |itr|
      itr.hits.each do |hit|
        hit.hsps.each do |hsp|
        end
      end
    end
  end

  # for multiple xml reports (returns Array of Blast::Report)
  reps = Bio::Blast.reports(ARGF.read)

  # for a single report (xml or tab) format auto detect, parser auto selected
  rep = Bio::Blast::Report.new(ARGF.read)

  # to use xmlparser explicitly for a report
  rep = Bio::Blast::Report.xmlparser(ARGF.read)

  # to use resml explicitly for a report
  rep = Bio::Blast::Report.rexml(ARGF.read)

  # to use a tab delimited report
  rep = Bio::Blast::Report.tab(ARGF.read)

=end

  Bio::Blast.reports(ARGF) do |rep|	# for multiple xml reports

  print "# === Bio::Tools::Blast::Report\n"
  puts
  print "  rep.program           #=> "; p rep.program
  print "  rep.version           #=> "; p rep.version
  print "  rep.reference         #=> "; p rep.reference
  print "  rep.db                #=> "; p rep.db
  print "  rep.query_id          #=> "; p rep.query_id
  print "  rep.query_def         #=> "; p rep.query_def
  print "  rep.query_len         #=> "; p rep.query_len
  puts

  print "# === Parameters\n"
  puts
  print "  rep.parameters        #=> "; p rep.parameters
  puts
  print "  rep.matrix            #=> "; p rep.matrix
  print "  rep.expect            #=> "; p rep.expect
  print "  rep.inclusion         #=> "; p rep.inclusion
  print "  rep.sc_match          #=> "; p rep.sc_match
  print "  rep.sc_mismatch       #=> "; p rep.sc_mismatch
  print "  rep.gap_open          #=> "; p rep.gap_open
  print "  rep.gap_extend        #=> "; p rep.gap_extend
  print "  rep.filter            #=> "; p rep.filter
  print "  rep.pattern           #=> "; p rep.pattern
  print "  rep.entrez_query      #=> "; p rep.entrez_query
  puts

  print "# === Statistics (last iteration's)\n"
  puts
  print "  rep.statistics        #=> "; p rep.statistics
  puts
  print "  rep.db_num            #=> "; p rep.db_num
  print "  rep.db_len            #=> "; p rep.db_len
  print "  rep.hsp_len           #=> "; p rep.hsp_len
  print "  rep.eff_space         #=> "; p rep.eff_space
  print "  rep.kappa             #=> "; p rep.kappa
  print "  rep.lambda            #=> "; p rep.lambda
  print "  rep.entropy           #=> "; p rep.entropy
  puts

  print "# === Message (last iteration's)\n"
  puts
  print "  rep.message           #=> "; p rep.message
  puts

  print "# === Iterations\n"
  puts
  print "  rep.itrerations.each do |itr|\n"
  puts

  rep.iterations.each do |itr|
      
  print "# --- Bio::Blast::Report::Iteration\n"
  puts

  print "    itr.num             #=> "; p itr.num
  print "    itr.statistics      #=> "; p itr.statistics
  print "    itr.message         #=> "; p itr.message
  print "    itr.hits.size       #=> "; p itr.hits.size
  puts

  print "    itr.hits.each do |hit|\n"
  puts

  itr.hits.each do |hit|

  print "# --- Bio::Blast::Report::Hit\n"
  puts

  print "      hit.num           #=> "; p hit.num
  print "      hit.hit_id        #=> "; p hit.hit_id
  print "      hit.len           #=> "; p hit.len
  print "      hit.definition    #=> "; p hit.definition
  print "      hit.accession     #=> "; p hit.accession

  print "        --- compatible/shortcut ---\n"
  print "      hit.query_id      #=> "; p hit.query_id
  print "      hit.query_def     #=> "; p hit.query_def
  print "      hit.query_len     #=> "; p hit.query_len
  print "      hit.target_id     #=> "; p hit.target_id
  print "      hit.target_def    #=> "; p hit.target_def
  print "      hit.target_len    #=> "; p hit.target_len

  print "      hit.evalue        #=> "; p hit.evalue
  print "      hit.bit_score     #=> "; p hit.bit_score
  print "      hit.identity      #=> "; p hit.identity
  print "      hit.overlap       #=> "; p hit.overlap

  print "      hit.query_seq     #=> "; p hit.query_seq
  print "      hit.midline       #=> "; p hit.midline
  print "      hit.target_seq    #=> "; p hit.target_seq

  print "      hit.query_start   #=> "; p hit.query_start
  print "      hit.query_end     #=> "; p hit.query_end
  print "      hit.target_start  #=> "; p hit.target_start
  print "      hit.target_end    #=> "; p hit.target_end
  print "      hit.lap_at        #=> "; p hit.lap_at
  print "        --- compatible/shortcut ---\n"

  print "      hit.hsps.size     #=> "; p hit.hsps.size
  puts

  print "      hit.hsps.each do |hsp|\n"
  puts

  hit.hsps.each do |hsp|

  print "# --- Bio::Blast::Report::Hsp\n"
  puts
  print "        hsp.num         #=> "; p hsp.num
  print "        hsp.bit_score   #=> "; p hsp.bit_score 
  print "        hsp.score       #=> "; p hsp.score
  print "        hsp.evalue      #=> "; p hsp.evalue
  print "        hsp.identity    #=> "; p hsp.identity
  print "        hsp.gaps        #=> "; p hsp.gaps
  print "        hsp.positive    #=> "; p hsp.positive
  print "        hsp.align_len   #=> "; p hsp.align_len
  print "        hsp.density     #=> "; p hsp.density

  print "        hsp.query_frame #=> "; p hsp.query_frame
  print "        hsp.query_from  #=> "; p hsp.query_from
  print "        hsp.query_to    #=> "; p hsp.query_to

  print "        hsp.hit_frame   #=> "; p hsp.hit_frame
  print "        hsp.hit_from    #=> "; p hsp.hit_from
  print "        hsp.hit_to      #=> "; p hsp.hit_to

  print "        hsp.pattern_from#=> "; p hsp.pattern_from
  print "        hsp.pattern_to  #=> "; p hsp.pattern_to

  print "        hsp.qseq        #=> "; p hsp.qseq
  print "        hsp.midline     #=> "; p hsp.midline
  print "        hsp.hseq        #=> "; p hsp.hseq
  puts
  print "        hsp.percent_identity  #=> "; p hsp.percent_identity
  print "        hsp.mismatch_count    #=> "; p hsp.mismatch_count
  puts

  end
  end
  end
  end					# for multiple xml reports

end


