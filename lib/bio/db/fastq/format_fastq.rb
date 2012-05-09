#
# = bio/db/fasta/format_fastq.rb - FASTQ format generater
#
# Copyright::   Copyright (C) 2009
#               Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#

require 'bio/db/fastq'

module Bio::Sequence::Format::Formatter

  # INTERNAL USE ONLY, YOU SHOULD NOT USE THIS CLASS.
  #
  # FASTQ format output class for Bio::Sequence.
  #
  # The default FASTQ format is fastq-sanger.
  class Fastq < Bio::Sequence::Format::FormatterBase

    # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD.
    #
    # Creates a new Fasta format generater object from the sequence.
    #
    # ---
    # *Arguments*:
    # * _sequence_: Bio::Sequence object
    # * (optional) :repeat_title => (true or false) if true, repeating title in the "+" line; if not true, "+" only (default false)
    # * (optional) :width => _width_: (Fixnum) width to wrap sequence and quality lines;  nil to prevent wrapping (default nil)
    # * (optional) :title => _title_: (String) completely replaces title line with the _title_ (default nil)
    # * (optional) :default_score => _score_: (Integer) default score for bases that have no valid quality scores or error probabilities; false or nil means the lowest score, true means the highest score (default nil)
    def initialize; end if false # dummy for RDoc

    # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD.
    #
    # Output the FASTQ format string of the sequence.  
    #
    # Currently, this method is used in Bio::Sequence#output like so,
    #
    #   s = Bio::Sequence.new('atgc')
    #   puts s.output(:fastq_sanger)
    # ---
    # *Returns*:: String object
    def output
      title = @options[:title]
      width = @options.has_key?(:width) ? @options[:width] : nil
      seq = @sequence.seq.to_s
      entry_id = @sequence.entry_id || 
        "#{@sequence.primary_accession}.#{@sequence.sequence_version}"
      definition = @sequence.definition
      unless title then
        title = definition.to_s
        unless title[0, entry_id.length] == entry_id and
            /\s/ =~ title[entry_id.length, 1].to_s then
          title = "#{entry_id} #{title}"
        end
      end
      title2 = @options[:repeat_title] ? title : ''
      qstr = fastq_quality_string(seq, @options[:default_score])

      "@#{title}\n" +
        if width then
          seq.gsub(Regexp.new(".{1,#{width}}"), "\\0\n")
        else
          seq + "\n"
        end +
        "+#{title2}\n" +
        if width then
          qstr.gsub(Regexp.new(".{1,#{width}}"), "\\0\n")
        else
          qstr + "\n"
        end
    end

    private
    def fastq_format_data
      Bio::Fastq::FormatData::FASTQ_SANGER.instance
    end

    def fastq_quality_string(seq, default_score)
      sc = fastq_quality_scores(seq)
      if sc.size < seq.length then
        if default_score == true then
          # when true, the highest score
          default_score = fastq_format_data.score_range.end
        else
          # when false or nil, the lowest score
          default_score ||= fastq_format_data.score_range.begin
        end
        sc = sc + ([ default_score ] * (seq.length - sc.size))
      end
      fastq_format_data.scores2str(sc)
    end

    def fastq_quality_scores(seq)
      return [] if seq.length <= 0
      fmt = fastq_format_data
      # checks quality_scores
      qsc = @sequence.quality_scores
      qsc_type = @sequence.quality_score_type
      if qsc and qsc_type and
          qsc_type == fmt.quality_score_type and
          qsc.size >= seq.length then
        return qsc
      end
      
      # checks error_probabilities
      ep = @sequence.error_probabilities
      if ep and ep.size >= seq.length then
        return fmt.p2q(ep[0, seq.length])
      end

      # If quality score type of the sequence is nil, regarded as :phred.
      qsc_type ||= :phred

      # checks if scores can be converted
      if qsc and qsc.size >= seq.length then
        case [ qsc_type, fmt.quality_score_type ]
        when [ :phred, :solexa ]
          return fmt.convert_scores_from_phred_to_solexa(qsc[0, seq.length])
        when [ :solexa, :phred ]
          return fmt.convert_scores_from_solexa_to_phred(qsc[0, seq.length])
        end
      end

      # checks quality scores type
      case qsc_type
      when :phred, :solexa
        #does nothing
      else
        qsc_type = nil
        qsc = nil
      end

      # collects piece of information
      qsc_cov = qsc ? qsc.size.quo(seq.length) : 0
      ep_cov = ep ? ep.size.quo(seq.length) : 0
      if qsc_cov > ep_cov then
        case [ qsc_type, fmt.quality_score_type ]
        when [ :phred, :phred ], [ :solexa, :solexa ]
          return qsc
        when [ :phred, :solexa ]
          return fmt.convert_scores_from_phred_to_solexa(qsc)
        when [ :solexa, :phred ]
          return fmt.convert_scores_from_solexa_to_phred(qsc)
        end
      elsif ep_cov > qsc_cov then
        return fmt.p2q(ep)
      end

      # if no information, returns empty array
      return []
    end
  end #class Fastq

  # class Fastq_sanger is the same as the Fastq class.
  Fastq_sanger = Fastq

  class Fastq_solexa < Fastq
    private
    def fastq_format_data
      Bio::Fastq::FormatData::FASTQ_SOLEXA.instance
    end
  end #class Fastq_solexa

  class Fastq_illumina < Fastq
    private
    def fastq_format_data
      Bio::Fastq::FormatData::FASTQ_ILLUMINA.instance
    end
  end #class Fastq_illumina

end #module Bio::Sequence::Format::Formatter


