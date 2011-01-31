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
  #   >id and/or some comments                    <== comment line
  #   ATGCATGCATGCATGCATGCATGCATGCATGCATGC        <== sequence lines
  #   ATGCATGCATGCATGCATGCATGCATGCATGCATGC
  #   ATGCATGCATGC
  # 
  # The precedent '>' can be omitted and the trailing '>' will be removed
  # automatically.
  #
  # === Examples
  #
  #   f_str = <<END_OF_STRING
  #   >sce:YBR160W  CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]
  #   MSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEG
  #   VPSTAIREISLLKELKDDNIVRLYDIVHSDAHKLYLVFEFLDLDLKRYME
  #   GIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQNLLINKDGNL
  #   KLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGC
  #   IFAEMCNRKPIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFP
  #   QWRRKDLSQVVPSLDPRGIDLLDKLLAYDPINRISARRAAIHPYFQES
  #   >sce:YBR274W  CHK1; probable serine/threonine-protein kinase [EC:2.7.1.-] [SP:KB9S_YEAST]
  #   MSLSQVSPLPHIKDVVLGDTVGQGAFACVKNAHLQMDPSIILAVKFIHVP
  #   TCKKMGLSDKDITKEVVLQSKCSKHPNVLRLIDCNVSKEYMWIILEMADG
  #   GDLFDKIEPDVGVDSDVAQFYFQQLVSAINYLHVECGVAHRDIKPENILL
  #   DKNGNLKLADFGLASQFRRKDGTLRVSMDQRGSPPYMAPEVLYSEEGYYA
  #   DRTDIWSIGILLFVLLTGQTPWELPSLENEDFVFFIENDGNLNWGPWSKI
  #   EFTHLNLLRKILQPDPNKRVTLKALKLHPWVLRRASFSGDDGLCNDPELL
  #   AKKLFSHLKVSLSNENYLKFTQDTNSNNRYISTQPIGNELAELEHDSMHF
  #   QTVSNTQRAFTSYDSNTNYNSGTGMTQEAKWTQFISYDIAALQFHSDEND
  #   CNELVKRHLQFNPNKLTKFYTLQPMDVLLPILEKALNLSQIRVKPDLFAN
  #   FERLCELLGYDNVFPLIINIKTKSNGGYQLCGSISIIKIEEELKSVGFER
  #   KTGDPLEWRRLFKKISTICRDIILIPN
  #   END_OF_STRING
  #
  #   f = Bio::FastaFormat.new(f_str)
  #   puts "### FastaFormat"
  #   puts "# entry"
  #   puts f.entry
  #   puts "# entry_id"
  #   p f.entry_id
  #   puts "# definition"
  #   p f.definition
  #   puts "# data"
  #   p f.data
  #   puts "# seq"
  #   p f.seq
  #   puts "# seq.type"
  #   p f.seq.type
  #   puts "# length"
  #   p f.length
  #   puts "# aaseq"
  #   p f.aaseq
  #   puts "# aaseq.type"
  #   p f.aaseq.type
  #   puts "# aaseq.composition"
  #   p f.aaseq.composition
  #   puts "# aalen"
  #   p f.aalen
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
      factory.query(@entry)
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

