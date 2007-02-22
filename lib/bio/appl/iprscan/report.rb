#
# = bio/appl/iprscan/report.rb - a class for iprscan output.
#
# Copyright::   Copyright (C) 2006
#               Mitsuteru C. Nakao <mn@kazusa.or.jp>
# License::     Ruby's
#
#  $Id: report.rb,v 1.3 2007/02/22 08:44:34 nakao Exp $
#
# == Report classes for the iprscan program.
# 


module Bio

  class Iprscan

    # = DESCRIPTION
    # Class for InterProScan report. It is used to parse results and reformat 
    # results from (raw|xml|txt) into (html, xml, ebihtml, txt, gff3) format.
    #
    # See ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/README.html
    # 
    # == USAGE
    #  # Read a marged.txt and split each entry.
    #  Bio::Iprscan::Report.reports_in_txt(File.read("marged.txt")) do |report| 
    #    report.query_id
    #    report.matches.size
    #    report.matches.each do |match|
    #      match.ipr_id #=> 'IPR...'
    #      match.ipr_description
    #      match.method
    #      match.accession
    #      match.description
    #      match.match_start
    #      match.match_end
    #      match.evalue    
    #    end
    #    # report.to_gff3 
    #    # report.to_html
    #  end
    #
    #  Bio::Iprscan::Report.reports_in_raw(File.read("marged.raw")) do |report| 
    #    report.class #=> Bio::Iprscan::Report
    #  end
    #
    class Report
      # Entry delimiter pattern.
      RS = DELIMITER = "\n\/\/\n"

      # Qeury sequence name (entry_id).
      attr_accessor :query_id
      alias :entry_id :query_id

      # Qeury sequence length.
      attr_accessor :query_length

      # CRC64 checksum of query sequence.
      attr_accessor :crc64

      # Matched InterPro motifs in Hash. Each InterPro motif have :name, 
      # :definition, :accession and :motifs keys. And :motifs key contains
      # motifs in Array. Each motif have :method, :accession, :definition, 
      # :score, :location_from and :location_to keys.
      attr_accessor :matches
      
      # == USAGE
      #  Bio::Iprscan::Report.reports_in_raw(File.open("merged.raw")) do |report|
      #    report
      #  end
      #
      def self.reports_in_raw(io)
        entry = ''
        while line = io.gets
          if entry != '' and entry.split("\t").first == line.split("\t").first
            entry << line
          elsif entry != ''
            yield Bio::Iprscan::Report.parse_in_raw(entry)
            entry = line
          else
            entry << line
          end
        end
      end
    
      # Parser method for a raw formated entry. Retruns a Bio::Iprscan::Report 
      # object.
      def self.parse_in_raw(str)
        report = self.new
        str.split(/\n/).each do |line|
          line = line.split("\t")
          report.matches << Match.new(:query_id => line[0],
                                      :crc64    => line[1],
                                      :query_length => line[2].to_i,
                                      :method       => line[3], 
                                      :accession    => line[4],
                                      :description => line[5], 
                                      :match_start => line[6].to_i,
                                      :match_end   => line[7].to_i,
                                      :evalue => line[8],
                                      :status => line[9],
                                      :date   => line[10])
          if line[11]
            report.matches.last.ipr_id = line[11]
            report.matches.last.ipr_description = line[12]
          end
          report.matches.last.go_terms = line[13].split(', ') if line[13]          
        end
        report.query_id = report.matches.first.query_id
        report.query_length = report.matches.first.query_length
        report
      end



      # Parser method for a xml formated entry. Retruns a Bio::Iprscan::Report 
      # object.
      def self.parse_in_xml(str)
        NotImplementedError
      end

      # Splits entry stream.
      # 
      # == Usage
      #  Bio::Iprscan::Report.reports_in_txt(File.open("merged.txt")) do |report|
      #    report
      #  end
      def self.reports_in_txt(io)
        io.each("\n\nSequence") do |entry|
          if entry =~ /Sequence$/
            entry = entry.sub(/Sequence$/, '')
          end
          unless entry =~ /^Sequence/
            entry = 'Sequence' + entry
          end
          yield self.parse_in_txt(entry)
        end
      end



      # Parser method for a txt formated entry. Returns a Bio::Iprscan::Report
      # object.
      #
      def self.parse_in_txt(str)
        unless str =~ /^Sequence /
          raise Exception, "Invalid format: \n\n#{str}"
        end
        header, *matches = str.split(/\n\n/)
        report = self.new
        report.query_id = if header =~ /Sequence \"(.+)\" / then $1 else '' end
        report.query_length = if header =~ /length: (\d+) aa./ then $1.to_i else nil end
        report.crc64 = if header =~ /crc64 checksum: (\S+) / then $1 else nil end
        ipr_line = ''
        go_annotation = ''
        matches.each do |m|
          m = m.split(/\n/).map {|x| x.split(/  +/) }
          m.each do |match|
            case match[0]
            when 'method'
            when /(Molecular Function|Cellular Component|Biological Process):/
              go_annotation = match[0].scan(/([MCB]\w+ \w+): (\S.+?\S) \((GO:\d+)\),*/)
            when 'InterPro'
              ipr_line = match
            else
              pos_scores = match[3].scan(/(\S)\[(\d+)-(\d+)\] (\S+) */)
              pos_scores.each do |pos_score|
                report.matches << Match.new(:ipr_id          => ipr_line[1],
                                            :ipr_description => ipr_line[2],
                                            :method      => match[0], 
                                            :accession   => match[1],
                                            :description => match[2], 
                                            :evalue      => pos_score[3],
                                            :match_start => pos_score[1].to_i,
                                            :match_end   => pos_score[2].to_i,
                                            :go_terms => go_annotation)
              end
            end
          end
        end
        return report
      end 


      # Splits entry stream.
      # 
      # == Usage
      #  Bio::Iprscan::Report.reports_in_ptxt(File.open("merged.txt")) do |report|
      #    report
      #  end
      def self.reports_in_ptxt(io)
        io.each(/\n\/\/\n/m) do |entry|
          yield self.parse_in_ptxt(entry)
        end
      end

      # Parser method for a pseudo-txt formated entry. Retruns a Bio::Iprscan::Report 
      # object.
      # 
      # == Usage
      #
      #  File.read("marged.txt").each(Bio::Iprscan::Report::RS) do |e| 
      #    report = Bio::Iprscan::Report.parse_in_ptxt(e)
      #  end
      #
      def self.parse_in_ptxt(str)
        report = self.new
        ipr_line = ''
        str.split(/\n/).each do |line|
          line = line.split("\t")
          if line.size == 2
            report.query_id = line[0]
            report.query_length = line[1].to_i
          elsif line.first == '//'
          elsif line.first == 'InterPro'
            ipr_line = line
          else
            startp, endp = line[4].split("-")
            report.matches << Match.new(:ipr_id => ipr_line[1], 
                                        :ipr_description => ipr_line[2],
                                        :method => line[0], 
                                        :accession => line[1],
                                        :description => line[2], 
                                        :evalue => line[3],
                                        :match_start => startp.to_i,
                                        :match_end => endp.to_i)
          end
        end
        report
      end

      # 
      def initialize
        @query_id = nil
        @query_length = nil
        @crc64 = nil
        @matches = []
      end

      def to_html
        NotImplementedError
      end
      
      def to_xml
        NotImplementedError
      end
      
      def to_ebihtml
        NotImplementedError        
      end
      
      def to_txt
        NotImplementedError        
      end
      
      def to_raw
        NotImplementedError        
      end
      
      def to_gff3
        NotImplementedError        
      end

      # == DESCRIPTION
      # Container class for InterProScan matches.
      #
      # == USAGE
      #  match = Match.new(:query_id => ...)
      #
      #  match.ipr_id = 'IPR001234'
      #  match.ipr_id #=> 'IPR1234'
      #
      class Match
        def initialize(hash)
          @data = Hash.new
          hash.each do |key, value|
            @data[key.to_sym] = value
          end
        end

        # Date for computation.
        def date;            @data[:date];            end
        # CRC64 checksum of query sequence.
        def crc64;           @data[:crc64];           end
        # E-value of the match
        def evalue;          @data[:evalue];          end
        # Status of the match (T for true / M for marginal).
        def status;          @data[:status];          end
        # the corresponding InterPro entry (if any).
        def ipr_id;          @data[:ipr_id];          end
        # the length of the sequence in AA.
        def length;          @data[:length];          end
        # the analysis method launched.
        def method;          @data[:method];          end  # Object#metod overrided by Match#method
        # the Gene Ontology description for the InterPro entry, in "Aspect:term (ID)" format.
        def go_terms;        @data[:go_terms];        end
        # Id of the input sequence.
        def query_id;        @data[:query_id];        end
        # the end of the domain match.
        def match_end;       @data[:match_end];       end
        # the database members entry for this match.
        def accession;       @data[:accession];       end
        # the database mambers description for this match.
        def description;     @data[:description];     end
        # the start of the domain match.
        def match_start;     @data[:match_start];     end
        # the descriotion of the InterPro entry.
        def ipr_description; @data[:ipr_description]; end

        def method_missing(name, arg = nil)
          if arg
            name = name.to_s.sub(/=$/, '') 
            @data[name.to_sym] = arg 
          else
            @data[name.to_sym]
          end
        end

      end # class Match

    end # class Report

  end # class Iprscan

end # module Bio
