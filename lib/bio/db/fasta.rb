#
# bio/db/fasta.rb - FASTA format class
#
#   Copyright (C) 2001 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
#   Copyright (C) 2001, 2002 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: fasta.rb,v 1.7 2002/06/25 13:26:42 k Exp $
#

require 'bio/db'
require 'bio/sequence'

module Bio

  class FastaFormat < DB

    DELIMITER	= RS = "\n>"

    def initialize(str)
      @entry = '>' + str.sub(/^>/, '').sub(/^>.*/m, '')
    end
    attr_reader :entry
    alias :to_s :entry

    def fasta(factory)
      factory.query(@entry)
    end
    alias :blast :fasta

    def definition
      unless @definition
        @definition = @entry[/.*/].sub(/^>/, '').strip		# 1st line
      end
      @definition
    end
    alias :entry_id :definition

    def seq
      unless @seq
        @seq = @entry.sub(/.*/, '').tr(" \t\r\n0-9", '')	# the rest
      end
      @seq
    end

    def length
      seq.length
    end

    def naseq
      Sequence::NA.new(seq)
    end

    def nalen
      self.naseq.length
    end

    def aaseq
      Sequence::AA.new(seq)
    end

    def aalen
      self.aaseq.length
    end

  end

  class FastaNumericFormat < FastaFormat

    undef fasta, seq, naseq, nalen, aaseq, aalen

    def data
      unless @data
	@data = @entry.sub(/.*/, '').strip.split(/\s+/).map {|x| x.to_i}
      end
      @data
    end

    def length
      data.length
    end

    def each
      data.each do |x|
        yield x
      end
    end

    def [](n)
      data[n]
    end

  end

end

if __FILE__ == $0

  f_str = <<END
>sce:YBR160W  CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]
MSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEG
VPSTAIREISLLKELKDDNIVRLYDIVHSDAHKLYLVFEFLDLDLKRYME
GIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQNLLINKDGNL
KLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGC
IFAEMCNRKPIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFP
QWRRKDLSQVVPSLDPRGIDLLDKLLAYDPINRISARRAAIHPYFQES
>sce:YBR274W  CHK1; probable serine/threonine-protein kinase [EC:2.7.1.-] [SP:KB9S_YEAST]
MSLSQVSPLPHIKDVVLGDTVGQGAFACVKNAHLQMDPSIILAVKFIHVP
TCKKMGLSDKDITKEVVLQSKCSKHPNVLRLIDCNVSKEYMWIILEMADG
GDLFDKIEPDVGVDSDVAQFYFQQLVSAINYLHVECGVAHRDIKPENILL
DKNGNLKLADFGLASQFRRKDGTLRVSMDQRGSPPYMAPEVLYSEEGYYA
DRTDIWSIGILLFVLLTGQTPWELPSLENEDFVFFIENDGNLNWGPWSKI
EFTHLNLLRKILQPDPNKRVTLKALKLHPWVLRRASFSGDDGLCNDPELL
AKKLFSHLKVSLSNENYLKFTQDTNSNNRYISTQPIGNELAELEHDSMHF
QTVSNTQRAFTSYDSNTNYNSGTGMTQEAKWTQFISYDIAALQFHSDEND
CNELVKRHLQFNPNKLTKFYTLQPMDVLLPILEKALNLSQIRVKPDLFAN
FERLCELLGYDNVFPLIINIKTKSNGGYQLCGSISIIKIEEELKSVGFER
KTGDPLEWRRLFKKISTICRDIILIPN
END

  f = Bio::FastaFormat.new(f_str)
  p f.entry
  p f.definition
  p f.entry_id
  p f.seq
  p f.seq.type
  p f.length
  p f.aaseq
  p f.aaseq.type
  p f.aaseq.composition
  p f.aalen

  n_str = <<END
>CRA3575282.F 
24 15 23 29 20 13 20 21 21 23 22 25 13 22 17 15 25 27 32 26  
32 29 29 25
END

  n = Bio::FastaNumericFormat.new(n_str)
  p n.definition
  p n.data
  p n.length
  n.each do |x|
    p x/100.0
  end
  p n[0]
  p n[1]
  p n[2]
  p n[-1]

end

=begin

= Bio::FastaFormat

Treats a FASTA formatted entry, such as:

  >id and/or some comments                    <== comment line
  ATGCATGCATGCATGCATGCATGCATGCATGCATGC        <== sequence lines
  ATGCATGCATGCATGCATGCATGCATGCATGCATGC
  ATGCATGCATGC

The precedent '>' can be omitted and the trailing '>' will be removed
automatically.

--- Bio::FastaFormat.new(entry)

      Stores the comment and sequence information from one entry of the
      FASTA format string.  If the argument contains more than one
      entry, only the first entry is used.

--- Bio::FastaFormat#entry

      Returns the stored one entry as a FASTA format. (same as to_s)

--- Bio::FastaFormat#definition
--- Bio::FastaFormat#entry_id

      Returns the comment line of the FASTA formatted data.

--- Bio::FastaFormat#seq

      Returns a joined sequence line as a String.

--- Bio::FastaFormat#fasta(factory)
--- Bio::FastaFormat#blast(factory)

      Executes FASTA/BLAST search by using a Bio::Fasta or a Bio::Blast
      factory object.

        #!/usr/bin/env ruby

        require 'bio'

        factory = Bio::Fasta.local('fasta34', 'db/swissprot.f')
        flatfile = Bio::FlatFile.open(Bio::FastaFormat, 'queries.f')
        flatfile.each do |entry|
          p entry.definition
          result = entry.fasta(factory)
          result.each do |hit|
            print "#{hit.query_id} : #{hit.evalue}\t#{hit.target_id} at "
            p hit.lap_at
          end
        end

--- Bio::FastaFormat#length

      Returns sequence length.

--- Bio::FastaFormat#naseq
--- Bio::FastaFormat#nalen
--- Bio::FastaFormat#aaseq
--- Bio::FastaFormat#aalen

      If you know whether the sequence is NA or AA, use these methods.
      'naseq' and 'aaseq' methods returen the Bio::Sequence::NA or
      Bio::Sequence::AA object respectively. 'nalen' and 'aalen' methods
      return the length of them.


= Bio::FastaNumericFormat

Treats a FASTA formatted numerical entry, such as:

  >id and/or some comments                    <== comment line
  24 15 23 29 20 13 20 21 21 23 22 25 13      <== numerical data
  22 17 15 25 27 32 26 32 29 29 25

The precedent '>' can be omitted and the trailing '>' will be removed
automatically.

--- Bio::FastaNumericFormat.new(entry)

      Stores the comment and the list of the numerical data.

--- Bio::FastaNumericFormat#definition
--- Bio::FastaNumericFormat#entry_id

      The comment line of the FASTA formatted data.

--- Bio::FastaNumericFormat#data

      Returns the list of the numerical data (typically the quality score
      of its corresponding sequence) as an Array.

--- Bio::FastaNumericFormat#length

      Returns the number of elements in the numerical data.

--- Bio::FastaNumericFormat#each

      Yields on each elements of the numerical data.

--- Bio::FastaNumericFormat#[](n)

      Returns the n-th element.

=end


