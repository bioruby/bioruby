module Bio
  class Chromatogram
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
      @qualities.reverse!
      
      #reverse peak indices
      @peak_indices = @peak_indices.map{|index|@samples - index}
      @peak_indices.reverse!
      
      # reverse sequence
      @sequence.reverse!.tr!('ATGCNRYKMSWBVDH','TACGNYRMKSWVBHD')
    end
  end
end