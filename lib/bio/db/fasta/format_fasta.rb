#
# = bio/db/fasta/format_fasta.rb - Fasta format generater
#
# Copyright::   Copyright (C) 2006-2008
#               Toshiaki Katayama <k@bioruby.org>,
#               Naohisa Goto <ng@bioruby.org>,
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::    The Ruby License
#
# $Id: format_fasta.rb,v 1.1.2.1 2008/03/04 11:26:59 ngoto Exp $
#

require 'bio/sequence/format'

module Bio::Sequence::Format::Formatter

  # INTERNAL USE ONLY, YOU SHOULD NOT USE THIS CLASS.
  # Simple Fasta format output class for Bio::Sequence.
  class Fasta < Bio::Sequence::Format::FormatterBase

    # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD.
    #
    # Creates a new Fasta format generater object from the sequence.
    #
    # ---
    # *Arguments*:
    # * _sequence_: Bio::Sequence object
    # * (optional) :header => _header_: String (default nil)
    # * (optional) :width => _width_: Fixnum (default 70)
    def initialize; end if false # dummy for RDoc

    # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD.
    #
    # Output the FASTA format string of the sequence.  
    #
    # Currently, this method is used in Bio::Sequence#output like so,
    #
    #   s = Bio::Sequence.new('atgc')
    #   puts s.output(:fasta)                   #=> "> \natgc\n"
    # ---
    # *Returns*:: String object
    def output
      header = @options[:header]
      width = @options.has_key?(:width) ? @options[:width] : 70
      seq = @sequence.seq
      entry_id = @sequence.entry_id || 
        "#{@sequence.primary_accession}.#{@sequence.sequence_version}"
      definition = @sequence.definition
      header ||= "#{entry_id} #{definition}"

      ">#{header}\n" +
        if width
          seq.to_s.gsub(Regexp.new(".{1,#{width}}"), "\\0\n")
        else
          seq.to_s + "\n"
        end
    end
  end #class Fasta

  # INTERNAL USE ONLY, YOU SHOULD NOT USE THIS CLASS.
  # NCBI-Style Fasta format output class for Bio::Sequence.
  # (like "ncbi" format in EMBOSS)
  #
  # Note that this class is under construction.
  class Fasta_ncbi < Bio::Sequence::Format::FormatterBase

    # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD.
    #
    # Output the FASTA format string of the sequence.  
    #
    # Currently, this method is used in Bio::Sequence#output like so,
    #
    #   s = Bio::Sequence.new('atgc')
    #   puts s.output(:ncbi)                   #=> "> \natgc\n"
    # ---
    # *Returns*:: String object
    def output
      width = 70
      seq = @sequence.seq
      #gi = @sequence.gi_number
      dbname = 'lcl'
      if @sequence.primary_accession.to_s.empty? then
        idstr = @sequence.entry_id
      else
        idstr = "#{@sequence.primary_accession}.#{@sequence.sequence_version}"
      end

      definition = @sequence.definition
      header = "#{dbname}|#{idstr} #{definition}"

      ">#{header}\n" + seq.to_s.gsub(Regexp.new(".{1,#{width}}"), "\\0\n")
    end
  end #class Ncbi

end #module Bio::Sequence::Format::Formatter


