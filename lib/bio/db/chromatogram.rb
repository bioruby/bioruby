require 'bio/sequence/adapter'
module Bio
  class Chromatogram
    attr_accessor :sequence, :peak_indices, :atrace, :ctrace, :gtrace, :ttrace, :qualities
    def self.open(filename)
      Bio::FlatFile.open(self, filename)
    end
    
    def seq
      Bio::Sequence::NA.new(@sequence)
    end

    def to_biosequence
      Bio::Sequence.adapter(self, Bio::Sequence::Adapter::Chromatogram)
    end
    alias :to_seq :to_biosequence
    
    def to_s
      @sequence
    end

    def complement!
      # reverse traces
      tmp_trace = @atrace
      @atrace = @ttrace.reverse
      @ttrace = tmp_trace.reverse
      tmp_trace = @ctrace
      @ctrace = @gtrace.reverse
      @gtrace = tmp_trace.reverse

      # reverse base qualities
      tmp_qual = @aqual
      @aqual = @tqual.reverse
      @tqual = tmp_qual.reverse
      tmp_qual = @cqual
      @cqual = @gqual.reverse
      @gqual = tmp_qual.reverse

      #reverse qualities
      @qualities = @qualities.reverse

      #reverse peak indices
      @peak_indices = @peak_indices.map{|index|@samples - index}
      @peak_indices.reverse!

      # reverse sequence
      @sequence = @sequence.reverse.tr('atgcnrykmswbvdh','tacgnyrmkswvbhd')
    end
    
    def complement
      chromatogram = self.clone
      chromatogram.complement!
      return chromatogram
    end
  end
end