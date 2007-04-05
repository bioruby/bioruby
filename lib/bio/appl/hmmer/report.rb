#
# = bio/appl/hmmer/report.rb - hmmsearch, hmmpfam parserer
#
# Copyright::   Copyright (C) 2002 
#               Hiroshi Suga <suga@biophys.kyoto-u.ac.jp>,
# Copyright::   Copyright (C) 2005 
#               Masashi Fujita <fujita@kuicr.kyoto-u.ac.jp>
# License::     The Ruby License
#
# $Id: report.rb,v 1.13 2007/04/05 23:35:40 trevor Exp $
#
# == Description
#
# Parser class for hmmsearch and hmmpfam in the HMMER package.
#
# == Examples
#
#    #for multiple reports in a single output file (example.hmmpfam)
#    Bio::HMMER.reports(File.read("example.hmmpfam")) do |report|
#      report.program['name']
#      report.parameter['HMM file']
#      report.query_info['Query sequence']
#      report.hits.each do |hit|
#        hit.accession
#        hit.description
#        hit.score
#        hit.evalue
#        hit.hsps.each do |hsp|
#          hsp.accession
#          hsp.domain
#          hsp.evalue
#          hsp.midline
#      end
#    end
#
# == References
#
# * HMMER
#   http://hmmer.wustl.edu/
#

require 'bio/appl/hmmer'

module Bio


class HMMER

  # A reader interface for multiple reports text into a report 
  # (Bio::HMMER::Report).
  #
  # === Examples
  # 
  #   # Iterator
  #   Bio::HMMER.reports(reports_text) do |report|
  #     report
  #   end
  #
  #   # Array
  #   reports = Bio::HMMER.reports(reports_text)
  #
  def self.reports(multiple_report_text)
    ary = []
    multiple_report_text.each("\n//\n") do |report|
      if block_given?
        yield Report.new(report)
      else
        ary << Report.new(report)
      end
    end
    return ary
  end


  # A parser class for a search report by hmmsearch or hmmpfam program in the 
  # HMMER package. 
  #
  # === Examples
  # 
  #   Examples
  #    #for multiple reports in a single output file (example.hmmpfam)
  #    Bio::HMMER.reports(File.read("example.hmmpfam")) do |report|
  #      report.program['name']
  #      report.parameter['HMM file']
  #      report.query_info['Query sequence']
  #      report.hits.each do |hit|
  #        hit.accession
  #        hit.description
  #        hit.score
  #        hit.evalue
  #        hit.hsps.each do |hsp|
  #          hsp.accession
  #          hsp.domain
  #          hsp.evalue
  #          hsp.midline
  #      end
  #    end
  #
  # === References
  #
  # * HMMER 
  #   http://hmmer.wustl.edu/
  #
  class Report
    
    # Delimiter of each entry for Bio::FlatFile support.
    DELIMITER = RS = "\n//\n"

    
    # A Hash contains program information used. 
    # Valid keys are 'name', 'version', 'copyright' and 'license'.
    attr_reader :program

    # A hash contains parameters used.
    # Valid keys are 'HMM file' and 'Sequence file'.
    attr_reader :parameter
    
    # A hash contains the query information.
    # Valid keys are 'query sequence', 'Accession' and 'Description'.
    attr_reader :query_info

    # 
    attr_reader :hits
    
    # Returns an Array of Bio::HMMER::Report::Hsp objects.
    # Under special circumstances, some HSPs do not have
    # parent Hit objects. If you want to access such HSPs,
    # use this method.
    attr_reader :hsps

    # statistics by hmmsearch.
    attr_reader :histogram
    
    # statistics by hmmsearch. Keys are 'mu', 'lambda', 'chi-sq statistic' and 'P(chi-square)'.
    attr_reader :statistical_detail
    
    # statistics by hmmsearch.
    attr_reader :total_seq_searched
    
    # statistics by hmmsearch. Keys are 'Total memory', 'Satisfying E cutoff' and 'Total hits'. 
    attr_reader :whole_seq_top_hits
    
    # statistics by hmmsearch. Keys are 'Total memory', 'Satisfying E cutoff' and 'Total hits'. 
    attr_reader :domain_top_hits


    # Parses a HMMER search report (by hmmpfam or hmmsearch program) and 
    # reutrns a Bio::HMMER::Report object.
    # 
    # === Examples
    #
    #   hmmpfam_report = Bio::HMMER::Report.new(File.read("hmmpfam.out"))
    #   
    #   hmmsearch_report = Bio::HMMER::Report.new(File.read("hmmsearch.out"))
    #
    def initialize(data)

      # The input data is divided into six data fields, i.e. header,
      # query infomation, hits, HSPs, alignments and search statistics.
      # However, header and statistics data don't necessarily exist.
      subdata, is_hmmsearch = get_subdata(data)

      # if header exists, parse it
      if subdata["header"]
        @program, @parameter = parse_header_data(subdata["header"])
      else
        @program, @parameter = [{}, {}]
      end

      @query_info = parse_query_info(subdata["query"])
      @hits       = parse_hit_data(subdata["hit"])
      @hsps       = parse_hsp_data(subdata["hsp"], is_hmmsearch)

      if @hsps != []
        # split alignment subdata into an array of alignments
        aln_ary = subdata["alignment"].split(/^\S+.*?\n/).slice(1..-1)

        # append alignment information to corresponding Hsp
        aln_ary.each_with_index do |aln, i|
          @hsps[i].set_alignment(aln)
        end
      end

      # assign each Hsp object to its parent Hit
      hits_hash = {}
      @hits.each do |hit|
        hits_hash[hit.accession] = hit
      end
      @hsps.each do |hsp|
        if hits_hash.has_key?(hsp.accession)
          hits_hash[hsp.accession].append_hsp(hsp)
        end
      end

      # parse statistics (for hmmsearch)
      if is_hmmsearch
        @histogram, @statistical_detail, @total_seq_searched, \
        @whole_seq_top_hits, @domain_top_hits = \
        parse_stat_data(subdata["statistics"])
      end

    end


    # Iterates each hit (Bio::HMMER::Report::Hit).
    def each
      @hits.each do |hit|
        yield hit
      end
    end
    alias :each_hit :each


    # Bio::HMMER::Report#get_subdata
    def get_subdata(data)
      subdata = {}
      header_prefix = '\Ahmm(search|pfam) - search'
      query_prefix  = '^Query (HMM|sequence): .*\nAccession: '
      hit_prefix    = '^Scores for (complete sequences|sequence family)'
      hsp_prefix    = '^Parsed for domains:'
      aln_prefix    = '^Alignments of top-scoring domains:\n'
      stat_prefix   = '^\nHistogram of all scores:'

      # if header exists, get it
      if data =~ /#{header_prefix}/
        is_hmmsearch = ($1 == "search")   # hmmsearch or hmmpfam
        subdata["header"] = data[/(\A.+?)(?=#{query_prefix})/m]
      else
        is_hmmsearch = false   # if no header, assumed to be hmmpfam
      end

      # get query, Hit and Hsp data
      subdata["query"] = data[/(#{query_prefix}.+?)(?=#{hit_prefix})/m]
      subdata["hit"]   = data[/(#{hit_prefix}.+?)(?=#{hsp_prefix})/m]
      subdata["hsp"]   = data[/(#{hsp_prefix}.+?)(?=#{aln_prefix})/m]

      # get alignment data
      if is_hmmsearch
        data =~ /#{aln_prefix}(.+?)#{stat_prefix}/m
        subdata["alignment"] = $1
      else
        data =~ /#{aln_prefix}(.+?)\/\/\n/m
        subdata["alignment"] = $1
        raise "multiple reports found" if $'.length > 0
      end
      
      # handle -A option of HMMER
      cutoff_line = '\t\[output cut off at A = \d+ top alignments\]\n\z'
      subdata["alignment"].sub!(/#{cutoff_line}/, '')
      
      # get statistics data
      subdata["statistics"] = data[/(#{stat_prefix}.+)\z/m]

      [subdata, is_hmmsearch]
    end
    private :get_subdata
    
  
    # Bio::HMMER::Report#parse_header_data
    def parse_header_data(data)
      data =~ /\A(.+? - - -$\n)(.+? - - -$\n)\n\z/m
      program_data   = $1
      parameter_data = $2
      
      program = {}
      program['name'], program['version'], program['copyright'], \
      program['license'] = program_data.split(/\n/)
      
      parameter = {}
      parameter_data.each do |x|
        if /^(.+?):\s+(.*?)\s*$/ =~ x
          parameter[$1] = $2
        end
      end

      [program, parameter]
    end
    private :parse_header_data


    # Bio::HMMER::Report#parse_query_info
    def parse_query_info(data)
      hash = {}
      data.each do |x|
        if /^(.+?):\s+(.*?)\s*$/ =~ x
          hash[$1] = $2
        elsif /\s+\[(.+)\]/ =~ x
          hash['comments'] = $1
        end
      end
      hash
    end
    private :parse_query_info

    
    # Bio::HMMER::Report#parse_hit_data
    def parse_hit_data(data)
      data.sub!(/.+?---\n/m, '').chop!
      hits = []
      return hits if data == "\t[no hits above thresholds]\n"
      data.each do |l|
        hits.push(Hit.new(l))
      end
      hits
    end
    private :parse_hit_data

    
    # Bio::HMMER::Report#parse_hsp_data
    def parse_hsp_data(data, is_hmmsearch)
      data.sub!(/.+?---\n/m, '').chop!
      hsps=[]
      return hsps if data == "\t[no hits above thresholds]\n"
      data.each do |l|
        hsps.push(Hsp.new(l, is_hmmsearch))
      end
      return hsps
    end
    private :parse_hsp_data

    
    # Bio::HMMER::Report#parse_stat_data
    def parse_stat_data(data)
      data.sub!(/\nHistogram of all scores:\n(.+?)\n\n\n%/m, '')
      histogram = $1.strip

      statistical_detail = {}
      data.sub!(/(.+?)\n\n/m, '')
      $1.each do |l|
        statistical_detail[$1] = $2.to_f if /^\s*(.+?)\s*=\s*(\S+)/ =~ l
      end
        
      total_seq_searched = nil
      data.sub!(/(.+?)\n\n/m, '')
      $1.each do |l|
        total_seq_searched = $2.to_i if /^\s*(.+)\s*:\s*(\S+)/ =~ l
      end
        
      whole_seq_top_hits = {}
      data.sub!(/(.+?)\n\n/m, '')
      $1.each do |l|
        if /^\s*(.+?):\s*(\d+)\s*$/ =~ l
          whole_seq_top_hits[$1] = $2.to_i
        elsif /^\s*(.+?):\s*(\S+)\s*$/ =~ l
          whole_seq_top_hits[$1] = $2
        end
      end
        
      domain_top_hits = {}
      data.each do |l|
        if /^\s*(.+?):\s*(\d+)\s*$/ =~ l
          domain_top_hits[$1] = $2.to_i
        elsif /^\s*(.+?):\s*(\S+)\s*$/ =~ l
          domain_top_hits[$1] = $2
        end
      end

      [histogram, statistical_detail, total_seq_searched, \
        whole_seq_top_hits, domain_top_hits]
    end
    private :parse_stat_data


    # Container class for HMMER search hits.
    class Hit

      # An Array of Bio::HMMER::Report::Hsp objects. 
      attr_reader :hsps

      # 
      attr_reader :accession
      alias target_id  accession
      alias hit_id     accession
      alias entry_id   accession
      
      # 
      attr_reader :description
      alias definition description

      # Matching scores (total of all HSPs).
      attr_reader :score
      alias bit_score score 

      # E-value
      attr_reader :evalue

      # Number of domains
      attr_reader :num
        
      # Sets hit data.
      def initialize(hit_data)
        @hsps = Array.new
        if /^(\S+)\s+(.*?)\s+(\S+)\s+(\S+)\s+(\S+)$/ =~ hit_data
          @accession, @description, @score, @evalue, @num = \
          [$1, $2, $3.to_f, $4.to_f, $5.to_i]
        end
      end


      # Iterates on each Hsp object (Bio::HMMER::Report::Hsp).
      def each
        @hsps.each do |hsp|
          yield hsp
        end
      end
      alias :each_hsp :each


      # Shows the hit description.
      def target_def
        if @hsps.size == 1
          "<#{@hsps[0].domain}> #{@description}"
        else
          "<#{@num.to_s}> #{@description}"
        end
      end

      # Appends a Bio::HMMER::Report::Hsp object.
      def append_hsp(hsp)
        @hsps << hsp
      end
      
    end # class Hit


    # Container class for HMMER search hsps.
    class Hsp
      
      # 
      attr_reader :accession
      alias target_id accession

      #
      attr_reader :domain
      
      #
      attr_reader :seq_f

      #
      attr_reader :seq_t

      #
      attr_reader :seq_ft

      #
      attr_reader :hmm_f

      #
      attr_reader :hmm_t

      #
      attr_reader :hmm_ft

      # Score
      attr_reader :score
      alias bit_score score

      # E-value
      attr_reader :evalue
      
      # Alignment midline
      attr_reader :midline
      
      #
      attr_reader :hmmseq

      #
      attr_reader :flatseq

      #
      attr_reader :query_frame

      #
      attr_reader :target_frame

      # CS Line
      attr_reader :csline
        
      # RF Line
      attr_reader :rfline

      # Sets hsps.
      def initialize(hsp_data, is_hmmsearch)
        @is_hmmsearch = is_hmmsearch

        @accession, @domain, seq_f, seq_t, @seq_ft, hmm_f, hmm_t, @hmm_ft,\
        score, evalue = hsp_data.split(' ')
        @seq_f = seq_f.to_i
        @seq_t = seq_t.to_i
        @hmm_f = hmm_f.to_i
        @hmm_t = hmm_t.to_i
        @score = score.to_f
        @evalue = evalue.to_f
        @hmmseq = ''
        @flatseq = ''
        @midline = ''
        @query_frame = 1
        @target_frame = 1
        # CS and RF lines are rarely used.
        @csline = nil
        @rfline = nil
      end

      #
      def set_alignment(alignment)
        # First, split the input alignment into an array of
        # "alignment blocks." One block usually has three lines,
        # i.e. hmmseq, midline and flatseq. 
        # However, although infrequent, it can contain CS or RF lines.
        alignment.split(/ (?:\d+|-)\s*\n\n/).each do |blk|
          lines = blk.split(/\n/)   
          cstmp = (lines[0] =~ /^ {16}CS/) ? lines.shift : nil
          rftmp = (lines[0] =~ /^ {16}RF/) ? lines.shift : nil
          aln_width = lines[0][/\S+/].length
          @csline  = @csline.to_s + cstmp[19, aln_width] if cstmp
          @rfline  = @rfline.to_s + rftmp[19, aln_width] if rftmp
          @hmmseq  += lines[0][19, aln_width]
          @midline += lines[1][19, aln_width]
          @flatseq += lines[2][19, aln_width]
        end
        @csline  = @csline[3...-3] if @csline
        @rfline  = @rfline[3...-3] if @rfline
        @hmmseq  = @hmmseq[3...-3]
        @midline = @midline[3...-3]
        @flatseq = @flatseq[3...-3]
      end


      #
      def query_seq
        @is_hmmsearch ? @hmmseq  : @flatseq
      end

      #
      def target_seq
        @is_hmmsearch ? @flatseq : @hmmseq
      end
      
      #
      def target_from
        @is_hmmsearch ? @seq_f   : @hmm_f
      end

      #
      def target_to
        @is_hmmsearch ? @seq_t   : @hmm_t
      end

      #
      def query_from
        @is_hmmsearch ? @hmm_f   : @seq_f
      end

      #
      def query_to
        @is_hmmsearch ? @hmm_t   : @seq_t
      end
      

    end # class Hsp

  end # class Report

end # class HMMER

end # module Bio


if __FILE__ == $0

=begin

  #
  # for multiple reports in a single output file (hmmpfam)
  #
  Bio::HMMER.reports(ARGF.read) do |report|
    report.hits.each do |hit|
      hit.hsps.each do |hsp|
      end
    end
  end

=end

  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  rep = Bio::HMMER::Report.new(ARGF.read)
  p rep

  indent = 18

  puts "### hmmer result"
  print "name : ".rjust(indent)
  p  rep.program['name']
  print "version : ".rjust(indent)
  p rep.program['version']
  print "copyright : ".rjust(indent)
  p rep.program['copyright']
  print "license : ".rjust(indent)
  p rep.program['license']

  print "HMM file : ".rjust(indent)
  p rep.parameter['HMM file']
  print "Sequence file : ".rjust(indent)
  p rep.parameter['Sequence file']

  print "Query sequence : ".rjust(indent)
  p rep.query_info['Query sequence']
  print "Accession : ".rjust(indent)
  p rep.query_info['Accession']
  print "Description : ".rjust(indent)
  p rep.query_info['Description']

  rep.each do |hit|
    puts "## each hit"
    print "accession : ".rjust(indent)
    p [ hit.accession, hit.target_id, hit.hit_id, hit.entry_id ]
    print "description : ".rjust(indent)
    p [ hit.description, hit.definition ]
    print "target_def : ".rjust(indent)
    p hit.target_def
    print "score : ".rjust(indent)
    p [ hit.score, hit.bit_score ]
    print "evalue : ".rjust(indent)
    p hit.evalue
    print "num : ".rjust(indent)
    p hit.num

    hit.each do |hsp|
      puts "## each hsp"
      print "accession : ".rjust(indent)
      p [ hsp.accession, hsp.target_id ]
      print "domain : ".rjust(indent)
      p hsp.domain
      print "seq_f : ".rjust(indent)
      p hsp.seq_f
      print "seq_t : ".rjust(indent)
      p hsp.seq_t
      print "seq_ft : ".rjust(indent)
      p hsp.seq_ft
      print "hmm_f : ".rjust(indent)
      p hsp.hmm_f
      print "hmm_t : ".rjust(indent)
      p hsp.hmm_t
      print "hmm_ft : ".rjust(indent)
      p hsp.hmm_ft
      print "score : ".rjust(indent)
      p [ hsp.score, hsp.bit_score ]
      print "evalue : ".rjust(indent)
      p hsp.evalue
      print "midline : ".rjust(indent)
      p hsp.midline
      print "hmmseq : ".rjust(indent)
      p hsp.hmmseq
      print "flatseq : ".rjust(indent)
      p hsp.flatseq
      print "query_frame : ".rjust(indent)
      p hsp.query_frame
      print "target_frame : ".rjust(indent)
      p hsp.target_frame

      print "query_seq : ".rjust(indent)
      p hsp.query_seq		# hmmseq, flatseq
      print "target_seq : ".rjust(indent)
      p hsp.target_seq		# flatseq, hmmseq
      print "target_from : ".rjust(indent)
      p hsp.target_from		# seq_f, hmm_f
      print "target_to : ".rjust(indent)
      p hsp.target_to		# seq_t, hmm_t
      print "query_from : ".rjust(indent)
      p hsp.query_from		# hmm_f, seq_f
      print "query_to : ".rjust(indent)
      p hsp.query_to		# hmm_t, seq_t
    end 
  end

end 


