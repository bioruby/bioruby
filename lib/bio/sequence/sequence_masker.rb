#
# = bio/sequence/sequence_masker.rb - Sequence masking helper methods
#
# Copyright::  Copyright (C) 2010
#              Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# == Description
# 
# Bio::Sequence::SequenceMasker is a mix-in module to provide helpful
# methods for masking a sequence.
#
# For details, see documentation of Bio::Sequence::SequenceMasker.
#

module Bio

require 'bio/sequence' unless const_defined?(:Sequence)

class Sequence

  # Bio::Sequence::SequenceMasker is a mix-in module to provide helpful
  # methods for masking a sequence.
  #
  # It is only expected to be included in Bio::Sequence.
  # In the future, methods in this module might be moved to
  # Bio::Sequence or other module and this module might be removed.
  # Please do not depend on this module.
  #
  module SequenceMasker

    # Masks the sequence with each value in the <em>enum</em>.
    # The <em>enum<em> should be an array or enumerator.
    # A block must be given. 
    # When the block returns true, the sequence is masked with
    # <em>mask_char</em>.
    # ---
    # *Arguments*:
    # * (required) <em>enum</em> : Enumerator
    # * (required) <em>mask_char</em> : (String) character used for masking
    # *Returns*:: Bio::Sequence object
    def mask_with_enumerator(enum, mask_char)
      offset = 0
      unit = mask_char.length - 1
      s = self.seq.class.new(self.seq)
      j = 0
      enum.each_with_index do |item, index|
        if yield item then
          j = index + offset
          if j < s.length then
            s[j, 1] = mask_char
            offset += unit
          end
        end
      end
      newseq = self.dup
      newseq.seq = s
      newseq
    end

    # Masks low quality sequence regions.
    # For each sequence position, if the quality score is smaller than
    # the threshold, the sequence in the position is replaced with
    # <em>mask_char</em>.
    #
    # Note: This method does not care quality_score_type.
    # ---
    # *Arguments*:
    # * (required) <em>threshold</em> : (Numeric) threshold
    # * (required) <em>mask_char</em> : (String) character used for masking
    # *Returns*:: Bio::Sequence object
    def mask_with_quality_score(threshold, mask_char)
      scores = self.quality_scores || []
      mask_with_enumerator(scores, mask_char) do |item|
        item < threshold
      end
    end

    # Masks high error-probability sequence regions.
    # For each sequence position, if the error probability is larger than
    # the threshold, the sequence in the position is replaced with
    # <em>mask_char</em>.
    #
    # ---
    # *Arguments*:
    # * (required) <em>threshold</em> : (Numeric) threshold
    # * (required) <em>mask_char</em> : (String) character used for masking
    # *Returns*:: Bio::Sequence object
    def mask_with_error_probability(threshold, mask_char)
      values = self.error_probabilities || []
      mask_with_enumerator(values, mask_char) do |item|
        item > threshold
      end
    end
  end #module SequenceMasker
end #class Sequence
end #module Bio

