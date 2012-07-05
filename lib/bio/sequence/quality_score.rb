#
# = bio/sequence/quality_score.rb - Sequence quality score manipulation modules
#
# Copyright::  Copyright (C) 2009
#              Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# == Description
# 
# Sequence quality score manipulation modules, mainly used by Bio::Fastq
# and related classes.
#
# == References
#
# * FASTQ format specification
#   http://maq.sourceforge.net/fastq.shtml
#

module Bio

require 'bio/sequence' unless const_defined?(:Sequence)

class Sequence

  # Bio::Sequence::QualityScore is a name space for quality score modules. 
  # BioRuby internal use only (mainly from Bio::Fastq).
  module QualityScore

    # Converter methods between PHRED and Solexa quality scores.
    module Converter

      # Converts PHRED scores to Solexa scores.
      #
      # The values may be truncated or incorrect if overflows/underflows
      # occurred during the calculation.
      # ---
      # *Arguments*:
      # * (required) _scores_: (Array containing Integer) quality scores
      # *Returns*:: (Array containing Integer) quality scores
      def convert_scores_from_phred_to_solexa(scores)
        sc = scores.collect do |q|
          t = 10 ** (q / 10.0) - 1
          t = Float::MIN if t < Float::MIN
          r = 10 * Math.log10(t)
          r.finite? ? r.round : r
        end
        sc
      end

      # Converts Solexa scores to PHRED scores.
      #
      # The values may be truncated if overflows/underflows occurred
      # during the calculation.
      # ---
      # *Arguments*:
      # * (required) _scores_: (Array containing Integer) quality scores
      # *Returns*:: (Array containing Integer) quality scores
      def convert_scores_from_solexa_to_phred(scores)
        sc = scores.collect do |q|
          r = 10 * Math.log10(10 ** (q / 10.0) + 1)
          r.finite? ? r.round : r
        end
        sc
      end

      # Does nothing and simply returns the given argument.
      # 
      # ---
      # *Arguments*:
      # * (required) _scores_: (Array containing Integer) quality scores
      # *Returns*:: (Array containing Integer) quality scores
      def convert_nothing(scores)
        scores
      end

    end #module Converter

    # Bio::Sequence::QualityScore::Phred is a module having quality calculation
    # methods for the PHRED quality score.
    #
    # BioRuby internal use only (mainly from Bio::Fastq).
    module Phred

      include Converter

      # Type of quality scores.
      # ---
      # *Returns*:: (Symbol) the type of quality score.
      def quality_score_type
        :phred
      end

      # PHRED score to probability conversion.
      # ---
      # *Arguments*:
      # * (required) _scores_: (Array containing Integer) scores
      # *Returns*:: (Array containing Float) probabilities (0<=p<=1)
      def phred_q2p(scores)
        scores.collect do |q|
          r = 10 ** (- q / 10.0)
          if r > 1.0 then
            r = 1.0
          #elsif r < 0.0 then
          #  r = 0.0
          end
          r
        end
      end
      alias q2p phred_q2p
      module_function :q2p
      public :q2p

      # Probability to PHRED score conversion.
      #
      # The values may be truncated or incorrect if overflows/underflows
      # occurred during the calculation.
      # ---
      # *Arguments*:
      # * (required) _probabilities_: (Array containing Float) probabilities
      # *Returns*:: (Array containing Float) scores
      def phred_p2q(probabilities)
        probabilities.collect do |p|
          p = Float::MIN if p < Float::MIN
          q = -10 * Math.log10(p)
          q.finite? ? q.round : q
        end
      end
      alias p2q phred_p2q
      module_function :p2q
      public :p2q

      alias convert_scores_from_phred   convert_nothing
      alias convert_scores_to_phred     convert_nothing
      alias convert_scores_from_solexa  convert_scores_from_solexa_to_phred 
      alias convert_scores_to_solexa    convert_scores_from_phred_to_solexa
      module_function :convert_scores_to_solexa
      public :convert_scores_to_solexa

    end #module Phred

    # Bio::Sequence::QualityScore::Solexa is a module having quality
    # calculation methods for the Solexa quality score.
    #
    # BioRuby internal use only (mainly from Bio::Fastq).
    module Solexa

      include Converter

      # Type of quality scores.
      # ---
      # *Returns*:: (Symbol) the type of quality score.
      def quality_score_type
        :solexa
      end

      # Solexa score to probability conversion.
      # ---
      # *Arguments*:
      # * (required) _scores_: (Array containing Integer) scores
      # *Returns*:: (Array containing Float) probabilities
      def solexa_q2p(scores)
        scores.collect do |q|
          t = 10 ** (- q / 10.0)
          t /= (1.0 + t)
          if t > 1.0 then
            t = 1.0
          #elsif t < 0.0 then
          #  t = 0.0
          end
          t
        end
      end
      alias q2p solexa_q2p
      module_function :q2p
      public :q2p

      # Probability to Solexa score conversion.
      # ---
      # *Arguments*:
      # * (required) _probabilities_: (Array containing Float) probabilities
      # *Returns*:: (Array containing Float) scores
      def solexa_p2q(probabilities)
        probabilities.collect do |p|
          t = p / (1.0 - p)
          t = Float::MIN if t < Float::MIN
          q = -10 * Math.log10(t)
          q.finite? ? q.round : q
        end
      end
      alias p2q solexa_p2q
      module_function :p2q
      public :p2q

      alias convert_scores_from_solexa  convert_nothing
      alias convert_scores_to_solexa    convert_nothing
      alias convert_scores_from_phred   convert_scores_from_phred_to_solexa
      alias convert_scores_to_phred     convert_scores_from_solexa_to_phred
      module_function :convert_scores_to_phred
      public :convert_scores_to_phred

    end #module Solexa

  end #module QualityScore

end #class Sequence

end #module Bio
