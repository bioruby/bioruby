#
# = bio/db/sanger_chromatogram/chromatogram.rb - Sanger Chromatogram class 
#
# Copyright::	Copyright (C) 2009 Anthony Underwood <anthony.underwood@hpa.org.uk>, <email2ants@gmail.com>
# License::	The Ruby License
#
# $Id:$
#
require 'bio/sequence/adapter'
module Bio
  # == Description
  #
  # This is the Superclass for the Abif and Scf classes that allow importing of the common scf
  # and abi sequence chromatogram formats
  # The following attributes are Common to both the Abif and Scf subclasses
  #
  # * *chromatogram_type* (String): This is extracted from the chromatogram file itself and will 
  #   probably be either .scf or ABIF for Scf and Abif files respectively.
  # * *version* (String): The version of the Scf or Abif file
  # * *sequence* (String): the sequence contained within the chromatogram as a string.
  # * *qualities* (Array): the quality scores of each base as an array of integers. These will
  #   probably be phred scores.
  # * *peak_indices* (Array): if the sequence traces contained within the chromatogram are imagined   
  #   as being plotted on an x,y graph, the peak indices are the x positions of the peaks that  
  #   represent the nucleotides bases found in the sequence from the chromatogram. For example if  
  #   the peak_indices are [16,24,37,49 ....] and the sequence is AGGT...., at position 16 the  
  #   traces in the chromatogram were base-called as an A, position 24 a G, position 37 a G,
  #   position 49 a T etc
  # * *atrace*, *ctrace*, *gtrace*, *ttrace* (Array): If the sequence traces contained within 
  #   the chromatogram are imagined as being plotted on an x,y graph, these attributes are arrays of 
  #   y positions for each of the 4 nucleotide bases along the length of the x axis. If these were 
  #   plotted joined by lines of different colours then the resulting graph should look like the
  #   original chromatogram file when viewed in a chromtogram viewer such as Chromas, 4Peaks or
  #   FinchTV.
  # * *dye_mobility* (String):  The mobility of the dye used when sequencing. This can influence the 
  #   base calling
  #
  # == Usage
  #   filename = "path/to/sequence_chromatogram_file"
  # 
  # for Abif files
  #   chromatogram_ff = Bio::Abif.open(filename)
  # for Scf files
  #   chromatogram_ff = Bio::Scf.open(filename)
  #
  #   chromatogram = chromatogram_ff.next_entry
  #   chromatogram.to_seq # => returns a Bio::Sequence object
  #   chromatogram.sequence # => returns the sequence contained within the chromatogram as a string
  #   chromatogram.qualities # => returns an array of quality values for each base
  #   chromatogram.atrace # => returns an array of the a trace y positions
  #
  class SangerChromatogram
    # The type of chromatogram file .scf for Scf files and ABIF doe Abif files
    attr_accessor :chromatogram_type
    # The Version of the Scf or Abif file (String)
    attr_accessor :version
    # The sequence contained within the chromatogram (String)
    attr_accessor :sequence
    # An array of quality scores for each base in the sequence (Array) 
    attr_accessor :qualities
    # An array  'x' positions (see description) on the trace where the bases occur/have been called (Array)
    attr_accessor :peak_indices
    # An array of 'y' positions (see description) for the 'A' trace from the chromatogram (Array
    attr_accessor :atrace
    # An array of 'y' positions (see description) for the 'C' trace from the chromatogram (Array
    attr_accessor :ctrace
    # An array of 'y' positions (see description) for the 'G' trace from the chromatogram (Array
    attr_accessor :gtrace
    # An array of 'y' positions (see description) for the 'T' trace from the chromatogram (Array
    attr_accessor :ttrace
    #The mobility of the dye used when sequencing (String)
    attr_accessor :dye_mobility

    def self.open(filename)
      Bio::FlatFile.open(self, filename)
    end
    
    # Returns a Bio::Sequence::NA object based on the sequence from the chromatogram
    def seq
      Bio::Sequence::NA.new(@sequence)
    end
    
    # Returns a Bio::Sequence object based on the sequence from the chromatogram
    def to_biosequence
      Bio::Sequence.adapter(self, Bio::Sequence::Adapter::SangerChromatogram)
    end
    alias :to_seq :to_biosequence
    
    # Returns the sequence from the chromatogram as a string
    def sequence_string
      @sequence
    end
    
    # Reverses and complements the current chromatogram object including its sequence, traces
    # and qualities
    def complement!
      # reverse traces
      tmp_trace = @atrace
      @atrace = @ttrace.reverse
      @ttrace = tmp_trace.reverse
      tmp_trace = @ctrace
      @ctrace = @gtrace.reverse
      @gtrace = tmp_trace.reverse

      # reverse base qualities
      if !@aqual.nil? # if qualities exist
        tmp_qual = @aqual
        @aqual = @tqual.reverse
        @tqual = tmp_qual.reverse
        tmp_qual = @cqual
        @cqual = @gqual.reverse
        @gqual = tmp_qual.reverse
      end

      #reverse qualities
      @qualities = @qualities.reverse

      #reverse peak indices
      @peak_indices = @peak_indices.map{|index| @atrace.size - index}
      @peak_indices.reverse!

      # reverse sequence
      @sequence = @sequence.reverse.tr('atgcnrykmswbvdh','tacgnyrmkswvbhd')
    end
    # Returns a new chromatogram object of the appropriate subclass (scf or abi) where the 
    # sequence, traces and qualities have all been revesed and complemented
    def complement
      chromatogram = self.dup
      chromatogram.complement!
      return chromatogram
    end
  end
end
