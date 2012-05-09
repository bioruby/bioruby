#
# = bio/db/fasta/format_qual.rb - Qual format and FastaNumericFormat generater
#
# Copyright::   Copyright (C) 2009
#               Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#

module Bio::Sequence::Format::Formatter

  # INTERNAL USE ONLY, YOU SHOULD NOT USE THIS CLASS.
  # Simple FastaNumeric format output class for Bio::Sequence.
  class Fasta_numeric < Bio::Sequence::Format::FormatterBase

    # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD.
    #
    # Creates a new FastaNumericFormat generater object from the sequence.
    #
    # It does not care whether the content of the quality score is
    # consistent with the sequence or not, e.g. it does not check
    # length of the quality score.
    #
    # ---
    # *Arguments*:
    # * _sequence_: Bio::Sequence object
    # * (optional) :header => _header_: (String) (default nil)
    # * (optional) :width => _width_: (Fixnum) (default 70)
    def initialize; end if false # dummy for RDoc

    # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD.
    #
    # Output the FASTA format string of the sequence.  
    #
    # Currently, this method is used in Bio::Sequence#output like so,
    #
    #   s = Bio::Sequence.new('atgc')
    #   s.quality_scores = [ 70, 80, 90, 100 ]
    #   puts s.output(:fasta_numeric)
    # ---
    # *Returns*:: String object
    def output
      header = @options[:header]
      width = @options.has_key?(:width) ? @options[:width] : 70
      seq = @sequence.seq.to_s
      entry_id = @sequence.entry_id || 
        "#{@sequence.primary_accession}.#{@sequence.sequence_version}"
      definition = @sequence.definition
      header ||= "#{entry_id} #{definition}"

      sc = fastanumeric_quality_scores(seq)
      if width then
        if width <= 0 then
          main = sc.join("\n")
        else
          len = 0
          main = sc.collect do |x|
            str = (len == 0) ? "#{x}" : " #{x}"
            len += str.size
            if len > width then
              len = "#{x}".size
              str = "\n#{x}"
            end
            str
          end.join('')
        end
      else
        main = sc.join(' ')
      end

      ">#{header}\n#{main}\n"
    end

    private

    def fastanumeric_quality_scores(seq)
      @sequence.quality_scores || []
    end

  end #class Fasta_numeric

  # INTERNAL USE ONLY, YOU SHOULD NOT USE THIS CLASS.
  # Simple Qual format (sequence quality) output class for Bio::Sequence.
  class Qual < Fasta_numeric

    # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD.
    #
    # Creates a new Qual format generater object from the sequence.
    #
    # The only difference from Fastanumeric is that Qual outputs
    # Phred score by default, and data conversion will be performed
    # if needed. Output score type can be changed by the
    # ":quality_score_type" option.
    #
    # If the sequence have no quality score type information
    # and no error probabilities, but the score exists,
    # the score is regarded as :phred (Phred score).
    #
    # ---
    # *Arguments*:
    # * _sequence_: Bio::Sequence object
    # * (optional) :header => _header_: (String) (default nil)
    # * (optional) :width => _width_: (Fixnum) (default 70)
    # * (optional) :quality_score_type => _type_: (Symbol) (default nil)
    # * (optional) :default_score => _score_: (Integer) default score for bases that have no valid quality scores or error probabilities (default 0)
    def initialize; end if false # dummy for RDoc

    private

    def fastanumeric_quality_scores(seq)
      qsc = qual_quality_scores(seq)
      if qsc.size > seq.length then
        qsc = qsc[0, seq.length]
      elsif qsc.size < seq.length then
        padding = @options[:default_score] || 0
        psize = seq.length - qsc.size
        qsc += Array.new(psize, padding)
      end
      qsc
    end

    def qual_quality_scores(seq)
      return [] if seq.length <= 0

      # get output quality score type
      fmt = @options[:quality_score_type]

      qsc = @sequence.quality_scores
      qsc_type = @sequence.quality_score_type

      # checks if no need to convert
      if qsc and qsc_type == fmt and
          qsc.size >= seq.length then
        return qsc
      end

      # default output quality score type is :phred
      fmt ||= :phred
      # If quality score type of the sequence is nil, implicitly
      # regarded as :phred.
      qsc_type ||= :phred

      # checks error_probabilities
      ep = @sequence.error_probabilities
      if ep and ep.size >= seq.length then
        case fmt
        when :phred
          return Bio::Sequence::QualityScore::Phred.p2q(ep[0, seq.length])
        when :solexa
          return Bio::Sequence::QualityScore::Solexa.p2q(ep[0, seq.length])
        end
      end

      # Checks if scores can be converted.
      if qsc and qsc.size >= seq.length then
        case [ qsc_type, fmt ]
        when [ :phred, :solexa ]
          return Bio::Sequence::QualityScore::Phred.convert_scores_to_solexa(qsc[0, seq.length])
        when [ :solexa, :phred ]
          return Bio::Sequence::QualityScore::Solexa.convert_scores_to_phred(qsc[0, seq.length])
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
        case [ qsc_type, fmt ]
        when [ :phred, :phred ], [ :solexa, :solexa ]
          return qsc
        when [ :phred, :solexa ]
          return Bio::Sequence::QualityScore::Phred.convert_scores_to_solexa(qsc)
        when [ :solexa, :phred ]
          return Bio::Sequence::QualityScore::Solexa.convert_scores_to_phred(qsc)
        end
      elsif ep_cov > qsc_cov then
        case fmt
        when :phred
          return Bio::Sequence::QualityScore::Phred.p2q(ep)
        when :solexa
          return Bio::Sequence::QualityScore::Solexa.p2q(ep)
        end
      end

      # if no information, returns empty array
      return []
    end
  end #class Qual

end #module Bio::Sequence::Format::Formatter

