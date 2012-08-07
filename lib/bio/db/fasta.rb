#
# = bio/db/fasta.rb - FASTA format class
#
# Copyright::  Copyright (C) 2001, 2002
#              Naohisa Goto <ng@bioruby.org>,
#              Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
# 
# == Description
# 
# FASTA format class.
#
# == Examples
#
# See documents of Bio::FastaFormat class.
#
# == References
#
# * FASTA format (WikiPedia)
#   http://en.wikipedia.org/wiki/FASTA_format
#   
# * Fasta format description (NCBI)
#   http://www.ncbi.nlm.nih.gov/BLAST/fasta.shtml
#

require 'bio/db'
require 'bio/sequence'
require 'bio/sequence/dblink'
require 'bio/db/fasta/defline'

module Bio


  # Treats a FASTA formatted entry, such as:
  #
  #   >id and/or some comments                    <== definition line
  #   ATGCATGCATGCATGCATGCATGCATGCATGCATGC        <== sequence lines
  #   ATGCATGCATGCATGCATGCATGCATGCATGCATGC
  #   ATGCATGCATGC
  # 
  # The precedent '>' can be omitted and the trailing '>' will be removed
  # automatically.
  #
  # === Examples
  #
  #   fasta_string = <<END_OF_STRING
  #   >gi|398365175|ref|NP_009718.3| Cdc28p [Saccharomyces cerevisiae S288c]
  #   MSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEGVPSTAIREISLLKELKDDNI
  #   VRLYDIVHSDAHKLYLVFEFLDLDLKRYMEGIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQ
  #   NLLINKDGNLKLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGCIFAEMCNRKP
  #   IFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFPQWRRKDLSQVVPSLDPRGIDLLDKLLAYDP
  #   INRISARRAAIHPYFQES
  #   END_OF_STRING
  #
  #   f = Bio::FastaFormat.new(fasta_string)
  #   
  #   f.entry #=> ">gi|398365175|ref|NP_009718.3| Cdc28p [Saccharomyces cerevisiae S288c]\n"+
  #   # MSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEGVPSTAIREISLLKELKDDNI\n"+
  #   # VRLYDIVHSDAHKLYLVFEFLDLDLKRYMEGIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQ\n"+
  #   # NLLINKDGNLKLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGCIFAEMCNRKP\n"+
  #   # IFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFPQWRRKDLSQVVPSLDPRGIDLLDKLLAYDP\n"+
  #   # INRISARRAAIHPYFQES"
  #   
  # ==== Methods related to the name of the sequence
  # 
  # A larger range of methods for dealing with Fasta definition lines can be found in FastaDefline, accessed through the FastaFormat#identifiers method.
  # 
  #   f.entry_id #=> "gi|398365175"
  #   f.definition #=> "gi|398365175|ref|NP_009718.3| Cdc28p [Saccharomyces cerevisiae S288c]"
  #   f.identifiers #=> Bio::FastaDefline instance
  #   f.accession #=> "NP_009718"
  #   f.accessions #=> ["NP_009718"]
  #   f.acc_version #=> "NP_009718.3"
  #   f.comment #=> nil
  #   
  # ==== Methods related to the actual sequence
  #
  #   f.seq #=> "MSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEGVPSTAIREISLLKELKDDNIVRLYDIVHSDAHKLYLVFEFLDLDLKRYMEGIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQNLLINKDGNLKLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGCIFAEMCNRKPIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFPQWRRKDLSQVVPSLDPRGIDLLDKLLAYDPINRISARRAAIHPYFQES"
  #   f.data #=> "\nMSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEGVPSTAIREISLLKELKDDNI\nVRLYDIVHSDAHKLYLVFEFLDLDLKRYMEGIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQ\nNLLINKDGNLKLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGCIFAEMCNRKP\nIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFPQWRRKDLSQVVPSLDPRGIDLLDKLLAYDP\nINRISARRAAIHPYFQES\n"
  #   f.length #=> 298
  #   f.aaseq #=> "MSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEGVPSTAIREISLLKELKDDNIVRLYDIVHSDAHKLYLVFEFLDLDLKRYMEGIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQNLLINKDGNLKLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGCIFAEMCNRKPIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFPQWRRKDLSQVVPSLDPRGIDLLDKLLAYDPINRISARRAAIHPYFQES"
  #   f.aaseq.composition #=> {"M"=>5, "S"=>15, "G"=>21, "E"=>16, "L"=>36, "A"=>17, "N"=>8, "Y"=>13, "K"=>22, "R"=>20, "V"=>18, "T"=>7, "D"=>23, "P"=>17, "Q"=>10, "I"=>23, "H"=>7, "F"=>12, "C"=>4, "W"=>4}
  #   f.aalen #=> 298
  #
  #
  # === A less structured fasta entry
  #
  #   f.entry #=> ">abc 123 456\nASDF"
  #
  #   f.entry_id #=> "abc"
  #   f.definition #=> "abc 123 456"
  #   f.comment #=> nil
  #   f.accession #=> nil
  #   f.accessions #=> []
  #   f.acc_version #=> nil
  #
  #   f.seq #=> "ASDF"
  #   f.data #=> "\nASDF\n"
  #   f.length #=> 4
  #   f.aaseq #=> "ASDF"
  #   f.aaseq.composition #=> {"A"=>1, "S"=>1, "D"=>1, "F"=>1}
  #   f.aalen #=> 4
  #
  #
  # === References
  #
  # * FASTA format (WikiPedia) 
  #   http://en.wikipedia.org/wiki/FASTA_format
  #
  class FastaFormat < DB

    # Entry delimiter in flatfile text.
    DELIMITER	= RS = "\n>"

    # (Integer) excess read size included in DELIMITER.
    DELIMITER_OVERRUN = 1 # '>'

    # The comment line of the FASTA formatted data.
    attr_accessor :definition

    # The seuqnce lines in text.
    attr_accessor :data

    attr_reader :entry_overrun

    # Stores the comment and sequence information from one entry of the
    # FASTA format string.  If the argument contains more than one
    # entry, only the first entry is used.
    def initialize(str)
      @definition = str[/.*/].sub(/^>/, '').strip	# 1st line
      @data = str.sub(/.*/, '')				# rests
      @data.sub!(/^>.*/m, '')	# remove trailing entries for sure
      @entry_overrun = $&
    end

    # Returns the stored one entry as a FASTA format. (same as to_s)
    def entry
      @entry = ">#{@definition}\n#{@data.strip}\n"
    end
    alias to_s entry


    # Executes FASTA/BLAST search by using a Bio::Fasta or a Bio::Blast
    # factory object.
    #
    #   #!/usr/bin/env ruby
    #   require 'bio'
    #   
    #   factory = Bio::Fasta.local('fasta34', 'db/swissprot.f')
    #   flatfile = Bio::FlatFile.open(Bio::FastaFormat, 'queries.f')
    #   flatfile.each do |entry|
    #     p entry.definition
    #     result = entry.fasta(factory)
    #     result.each do |hit|
    #       print "#{hit.query_id} : #{hit.evalue}\t#{hit.target_id} at "
    #       p hit.lap_at
    #     end
    #   end
    #
    def query(factory)
      factory.query(entry)
    end
    alias fasta query
    alias blast query

    # Returns a joined sequence line as a String.
    def seq
      unless defined?(@seq)
        unless /\A\s*^\#/ =~ @data then
          @seq = Sequence::Generic.new(@data.tr(" \t\r\n0-9", '')) # lazy clean up
        else
          a = @data.split(/(^\#.*$)/)
          i = 0
          cmnt = {}
          s = []
          a.each do |x|
            if /^# ?(.*)$/ =~ x then
              cmnt[i] ? cmnt[i] << "\n" << $1 : cmnt[i] = $1
            else
              x.tr!(" \t\r\n0-9", '') # lazy clean up
              i += x.length
              s << x
            end
          end
          @comment = cmnt
          @seq = Bio::Sequence::Generic.new(s.join(''))
        end
      end
      @seq
    end

    # Returns comments.
    def comment
      seq
      @comment
    end

    # Returns sequence length.
    def length
      seq.length
    end

    # Returens the Bio::Sequence::NA.
    def naseq
      Sequence::NA.new(seq)
    end

    # Returens the length of Bio::Sequence::NA.
    def nalen
      self.naseq.length
    end

    # Returens the Bio::Sequence::AA.
    def aaseq
      Sequence::AA.new(seq)
    end

    # Returens the length of Bio::Sequence::AA.
    def aalen
      self.aaseq.length
    end

    # Returns sequence as a Bio::Sequence object.
    #
    # Note: If you modify the returned Bio::Sequence object,
    # the sequence or definition in this FastaFormat object
    # might also be changed (but not always be changed)
    # because of efficiency.
    # 
    def to_biosequence
      Bio::Sequence.adapter(self, Bio::Sequence::Adapter::FastaFormat)
    end
    alias to_seq to_biosequence

    # Parsing FASTA Defline, and extract IDs.
    # IDs are NSIDs (NCBI standard FASTA sequence identifiers)
    # or ":"-separated IDs.
    # It returns a Bio::FastaDefline instance.
    def identifiers
      unless defined?(@ids) then
        @ids = FastaDefline.new(@definition)
      end
      @ids
    end

    # Parsing FASTA Defline (using #identifiers method), and
    # shows a possibly unique identifier.
    # It returns a string.
    def entry_id
      identifiers.entry_id
    end

    # Parsing FASTA Defline (using #identifiers method), and
    # shows GI/locus/accession/accession with version number.
    # If a entry has more than two of such IDs,
    # only the first ID are shown.
    # It returns a string or nil.
    def gi
      identifiers.gi
    end

    # Returns an accession number.
    def accession
      identifiers.accession
    end

    # Parsing FASTA Defline (using #identifiers method), and
    # shows accession numbers.
    # It returns an array of strings.
    def accessions
      identifiers.accessions
    end

    # Returns accession number with version.
    def acc_version
      identifiers.acc_version
    end

    # Returns locus.
    def locus
      identifiers.locus
    end

  end #class FastaFormat

end #module Bio

