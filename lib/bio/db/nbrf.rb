#
# = bio/db/nbrf.rb - NBRF/PIR format sequence data class
#
# Copyright:: Copyright (C) 2001-2003,2006 Naohisa Goto <ng@bioruby.org>
#             Copyright (C) 2001-2002 Toshiaki Katayama <k@bioruby.org>
# License::   The Ruby License
#
#  $Id: nbrf.rb,v 1.10 2007/04/05 23:35:40 trevor Exp $
#
# Sequence data class for NBRF/PIR flatfile format.
#
# = References
#
# * http://pir.georgetown.edu/pirwww/otherinfo/doc/techbulletin.html
# * http://www.sander.embl-ebi.ac.uk/Services/webin/help/webin-align/align_format_help.html#pir
# * http://www.cmbi.kun.nl/bioinf/tools/crab_pir.html
#

require 'bio/db'
require 'bio/sequence'

module Bio

  # Sequence data class for NBRF/PIR flatfile format.
  class NBRF < DB
    #--
    # based on Bio::FastaFormat class
    #++

    # Delimiter of each entry. Bio::FlatFile uses it.
    DELIMITER	= RS = "\n>"

    # (Integer) excess read size included in DELIMITER.
    DELIMITER_OVERRUN = 1 # '>'

    #--
    # Note: DELIMITER is changed due to the change of Bio::FlatFile.
    # DELIMITER	= RS = "*\n"
    #++

    # Creates a new NBRF object. It stores the comment and sequence
    # information from one entry of the NBRF/PIR format string.
    # If the argument contains more than one
    # entry, only the first entry is used.
    def initialize(str)
      str = str.sub(/\A[\r\n]+/, '') # remove first void lines
      line1, line2, rest = str.split(/^/, 3)

      rest = rest.to_s
      rest.sub!(/^>.*/m, '') # remove trailing entries for sure
      @entry_overrun = $&
      rest.sub!(/\*\s*\z/, '') # remove last '*' and "\n"
      @data = rest

      @definition = line2.to_s.chomp
      if /^>?([A-Za-z0-9]{2})\;(.*)/ =~ line1.to_s then
        @seq_type = $1
        @entry_id = $2
      end
    end

    # Returns sequence type described in the entry.
    #  P1 (protein), F1 (protein fragment)
    #  DL (DNA linear), DC (DNA circular)
    #  RL (DNA linear), RC (DNA circular)
    #  N3 (tRNA), N1 (other functional RNA)
    attr_accessor :seq_type

    # Returns ID described in the entry.
    attr_accessor :entry_id
    alias accession entry_id

    # Returns the description line of the NBRF/PIR formatted data.
    attr_accessor :definition

    # sequence data of the entry (???)
    attr_accessor :data

    # piece of next entry. Bio::FlatFile uses it.
    attr_reader :entry_overrun


    # Returns the stored one entry as a NBRF/PIR format. (same as to_s)
    def entry
      @entry = ">#{@seq_type or 'XX'};#{@entry_id}\n#{definition}\n#{@data}*\n"
    end
    alias to_s entry

    # Returns Bio::Sequence::AA, Bio::Sequence::NA, or Bio::Sequence,
    # depending on sequence type.
    def seq_class
      case @seq_type
      when /[PF]1/
        # protein
        Sequence::AA
      when /[DR][LC]/, /N[13]/
        # nucleic
        Sequence::NA
      else
        Sequence
      end
    end

    # Returns sequence data.
    # Returns Bio::Sequence::NA, Bio::Sequence::AA or Bio::Sequence,
    # according to the sequence type.
    def seq
      unless defined?(@seq)
        @seq = seq_class.new(@data.tr(" \t\r\n0-9", '')) # lazy clean up
      end
      @seq
    end

    # Returns sequence length.
    def length
      seq.length
    end

    # Returens the nucleic acid sequence.
    # If you call naseq for protein sequence, RuntimeError will be occurred.
    # Use the method if you know whether the sequence is NA or AA.
    def naseq
      if seq.is_a?(Bio::Sequence::AA) then
        raise 'not nucleic but protein sequence'
      elsif seq.is_a?(Bio::Sequence::NA) then
        seq
      else
        Bio::Sequence::NA.new(seq)
      end
    end
      
    # Returens the length of sequence.
    # If you call nalen for protein sequence, RuntimeError will be occurred.
    # Use the method if you know whether the sequence is NA or AA.
    def nalen
      naseq.length
    end

    # Returens the protein (amino acids) sequence.
    # If you call aaseq for nucleic acids sequence,
    # RuntimeError will be occurred.
    # Use the method if you know whether the sequence is NA or AA.
    def aaseq
      if seq.is_a?(Bio::Sequence::NA) then
        raise 'not nucleic but protein sequence'
      elsif seq.is_a?(Bio::Sequence::AA) then
        seq
      else
        Bio::Sequence::AA.new(seq)
      end
    end

    # Returens the length of protein (amino acids) sequence.
    # If you call aaseq for nucleic acids sequence,
    # RuntimeError will be occurred.
    # Use the method if you know whether the sequence is NA or AA.
    def aalen
      aaseq.length
    end

    #--
    #class method
    #++

    # Creates a NBRF/PIR formatted text.
    # Parameters can be omitted.
    def self.to_nbrf(hash)
      seq_type = hash[:seq_type]
      seq = hash[:seq]
      unless seq_type
        if seq.is_a?(Bio::Sequence::AA) then
          seq_type = 'P1'
        elsif seq.is_a?(Bio::Sequence::NA) then
          seq_type = /u/i =~ seq ? 'RL' : 'DL'
        else
          seq_type = 'XX'
        end
      end
      width = hash.has_key?(:width) ? hash[:width] : 70
      if width then
        seq = seq.to_s + "*"
        seq.gsub!(Regexp.new(".{1,#{width}}"), "\\0\n")
      else
        seq = seq.to_s + "*\n"
      end
      ">#{seq_type};#{hash[:entry_id]}\n#{hash[:definition]}\n#{seq}"
    end

  end #class NBRF
end #module Bio

