module Bio
  class Scf < Chromatogram
    # header attributes
    attr_accessor :scf, :samples, :sample_offset, :bases, :bases_left_clip, :bases_right_clip, :bases_offset, :comment_size, :comments_offset, :version, :sample_size, :code_set, :header_spare
    # sequence attributes
    attr_accessor :atrace, :ctrace, :gtrace, :ttrace, :peak_indices, :aqual, :cqual, :gqual, :tqual, :qualities, :sequence

    def initialize(string)
      header = string.slice(0,128)
      # read in header info
      @scf, @samples, @sample_offset, @bases, @bases_left_clip, @bases_right_clip, @bases_offset, @comment_size, @comments_offset, @version, @sample_size, @code_set, @header_spare = header.unpack("a4 NNNNNNNN a4 NN N20")
      get_traces(string)
      get_bases_peakIndices_and_qualities(string)
    end

    def self.open(filename)
      ff = Bio::FlatFile.open(self, filename)
      ff.next_entry
    end

    private

    def get_traces(string)
      if @version == "3.00"
        # read in trace info
        offset = @sample_offset
        length = @samples * @sample_size
        # determine whether the data is stored in 1 byte as an unsigned byte or 2 bytes as an  unsigned short
        @sample_size == 2 ? byte = "n" : byte = "c"
        for base in ["a" , "c" , "g" , "t"]
          trace_read = string.slice(offset,length).unpack("#{byte}#{@samples}")
          # convert offsets
          for sample_num in (0..trace_read.nitems-1)
            if trace_read[sample_num] > 30000
              trace_read[sample_num] = trace_read[sample_num] - 65536
            end
          end
          # For 8-bit data we need to emulate a signed/unsigned
          # cast that is implicit in the C implementations.....
          if @sample_size == 1
            for sample_num in (0..trace_read.nitems-1)
              trace_read[sample_num] += 256 if trace_read[sample_num] < 0
            end
          end
          trace_read = convert_deltas_to_values(trace_read)
          self.instance_variable_set("@#{base}trace", trace_read)
          offset += length
        end
      elsif @version == "2.00"
        @atrace = []
        @ctrace = []
        @gtrace = []
        @ttrace = []
        # read in trace info
        offset = @sample_offset
        length = @samples * @sample_size * 4
        # determine whether the data is stored in 1 byte as an unsigned byte or 2 bytes as an  unsigned short
        @sample_size == 2 ? byte = "n" : byte = "c"
        trace_read = string.slice(offset,length).unpack("#{byte}#{@samples*4}")
        (0..(@samples-1)*4).step(4) do |offset2|
          @atrace << trace_read[offset2]
          @ctrace << trace_read[offset2+1]
          @gtrace << trace_read[offset2+2]
          @ttrace << trace_read[offset2+3]
        end
      end
    end
    def get_bases_peakIndices_and_qualities(string)
      if @version == "3.00"
        # now go and get the peak index information
        offset = @bases_offset
        length = @bases * 4
        get_v3_peak_indices(string,offset,length)

        # now go and get the accuracy information
        offset += length;
        get_v3_accuracies(string,offset,length)

        # OK, now go and get the base information.
        offset += length;
        length = @bases;
        get_v3_sequence(string,offset,length)

        #combine accuracies to get quality scores
        @qualities= convert_accuracies_to_qualities
      elsif @version == "2.00"
        @peak_indices = []
        @aqual = []
        @cqual = []
        @gqual = []
        @tqual = []
        @qualities = []
        @sequence = ""
        # now go and get the base information
        offset = @bases_offset
        length = @bases * 12
        all_bases_info = string.slice(offset,length)

        (0..length-1).step(12) do |offset2|
          base_info = all_bases_info.slice(offset2,12).unpack("N C C C C a C3")
          @peak_indices << base_info[0]
          @aqual << base_info[1]
          @cqual << base_info[2]
          @gqual << base_info[3]
          @tqual << base_info[4]
          @sequence += base_info[5].upcase
          case base_info[5].upcase
          when "A"
            @qualities << base_info[1]
          when "C"
            @qualities << base_info[2]
          when "G"
            @qualities << base_info[3]
          when "T"
            @qualities << base_info[4]
          end
        end
      end
    end
    def get_v3_peak_indices(string,offset,length)
      @peak_indices = string.slice(offset,length).unpack("N#{length/4}")
    end
    def get_v3_accuracies(string,offset,length)
      qualities   = string.slice(offset,length)
      qual_length = length/4;
      qual_offset = 0;
      for base in ["a" , "c" , "g" , "t"]
        self.instance_variable_set("@#{base}qual",qualities.slice(qual_offset,qual_length).unpack("C#{qual_length}"))
        qual_offset += qual_length
      end
    end
    def get_v3_sequence(string,offset,length)
      @sequence = string.slice(offset,length).unpack("a#{length}").to_s.upcase
    end

    def convert_deltas_to_values(trace_read)
      p_sample = 0;
      for sample_num in (0..trace_read.nitems-1)
        trace_read[sample_num] = trace_read[sample_num] + p_sample
        p_sample = trace_read[sample_num];
      end
      p_sample = 0;
      for sample_num in (0..trace_read.nitems-1)
        trace_read[sample_num] = trace_read[sample_num] + p_sample
        p_sample = trace_read[sample_num];
      end
      return trace_read
    end
    def convert_accuracies_to_qualities
      qualities = Array.new
      for base_pos in (0..@sequence.length-1)
        case sequence.slice(base_pos,1)
        when "A"
          qualities << @aqual[base_pos]
        when "C"
          qualities << @cqual[base_pos]
        when "G"
          qualities << @gqual[base_pos]
        when "T"
          qualities << @tqual[base_pos]
        end
      end
      return qualities
    end
  end
end