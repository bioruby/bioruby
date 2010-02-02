#
# = bio/db/fasta/qual.rb - Qual format, FASTA formatted numeric entry
#
# Copyright::  Copyright (C) 2001, 2002, 2009
#              Naohisa Goto <ng@bioruby.org>,
#              Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
# 
# == Description
# 
# QUAL format, FASTA formatted numeric entry.
#
# == Examples
#
# See documents of Bio::FastaNumericFormat class.
#
# == References
#
# * FASTA format (WikiPedia)
#   http://en.wikipedia.org/wiki/FASTA_format
#
# * Phred quality score (WikiPedia)
#   http://en.wikipedia.org/wiki/Phred_quality_score
#   
# * Fasta format description (NCBI)
#   http://www.ncbi.nlm.nih.gov/BLAST/fasta.shtml
#

require 'bio/db/fasta'

module Bio

  # Treats a FASTA formatted numerical entry, such as:
  # 
  #   >id and/or some comments                    <== comment line
  #   24 15 23 29 20 13 20 21 21 23 22 25 13      <== numerical data
  #   22 17 15 25 27 32 26 32 29 29 25
  # 
  # The precedent '>' can be omitted and the trailing '>' will be removed
  # automatically.
  #
  # --- Bio::FastaNumericFormat.new(entry)
  # 
  # Stores the comment and the list of the numerical data.
  # 
  # --- Bio::FastaNumericFormat#definition
  #
  # The comment line of the FASTA formatted data.
  #
  # * FASTA format (Wikipedia)
  #   http://en.wikipedia.org/wiki/FASTA_format
  #
  # * Phred quality score (WikiPedia)
  #   http://en.wikipedia.org/wiki/Phred_quality_score
  #   
  class FastaNumericFormat < FastaFormat

    # Returns the list of the numerical data (typically the quality score
    # of its corresponding sequence) as an Array.
    # ---
    # *Returns*:: (Array containing Integer) numbers
    def data
      unless defined?(@list)
        @list = @data.strip.split(/\s+/).map {|x| x.to_i}
      end
      @list
    end

    # Returns the number of elements in the numerical data,
    # which will be the same of its corresponding sequence length.
    # ---
    # *Returns*:: (Integer) the number of elements
    def length
      data.length
    end

    # Yields on each elements of the numerical data.
    # ---
    # *Yields*:: (Integer) a numerical data element
    # *Returns*:: (undefined)
    def each
      data.each do |x|
        yield x
      end
    end

    # Returns the n-th element. If out of range, returns nil.
    # ---
    # *Arguments*:
    # * (required) _n_: (Integer) position
    # *Returns*:: (Integer or nil) the value
    def [](n)
      data[n]
    end

    # Returns the data as a Bio::Sequence object.
    # In the returned sequence object, the length of the sequence is zero,
    # and the numeric data is stored to the Bio::Sequence#quality_scores
    # attirbute.
    #
    # Because the meaning of the numeric data is unclear,
    # Bio::Sequence#quality_score_type is not set by default.
    #
    # Note: If you modify the returned Bio::Sequence object,
    # the sequence or definition in this FastaNumericFormat object
    # might also be changed (but not always be changed)
    # because of efficiency.
    # 
    # ---
    # *Arguments*:
    # *Returns*:: (Bio::Sequence) sequence object
    def to_biosequence
      s = Bio::Sequence.adapter(self,
                                Bio::Sequence::Adapter::FastaNumericFormat)
      s.seq = Bio::Sequence::Generic.new('')
      s
    end
    alias to_seq to_biosequence

    undef query, blast, fasta, seq, naseq, nalen, aaseq, aalen

  end #class FastaNumericFormat

end #module Bio
