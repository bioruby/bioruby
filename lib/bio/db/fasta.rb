#
# bio/db/fasta.rb - FASTA format class
#
#   Copyright (C) 2001 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>,
#                      KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: fasta.rb,v 1.5 2002/02/05 08:00:44 katayama Exp $
#

require 'bio/db'
require 'bio/sequence'

module Bio

  class FastaFormat < DB

    DELIMITER	= RS = "\n>"

    def initialize(str)
      # 1st definition (comment) line 
      @definition = str[/.*/].sub(/^>/, '').strip

      # rests are the sequence lines
      @seq = str.sub(/.*/, '')
      @seq.sub!(/^>.*/m, '')		# clean up
      @seq.tr!(" \t\r\n0-9", '')
    end
    attr_accessor :definition, :seq
    alias entry_id definition

    def fasta(factory)
      factory.query(">#{definition}\n#{seq}")
    end

    def length
      @seq.length
    end

    def naseq
      @naseq = Sequence::NA.new(@seq) unless @naseq
      @naseq
    end

    def nalen
      self.naseq.length
    end

    def aaseq
      @aaseq = Sequence::AA.new(@seq) unless @aaseq
      @aaseq
    end

    def aalen
      self.aaseq.length
    end

  end

  class FastaNumericFormat < DB

    DELIMITER	= RS = "\n>"

    def initialize(str)
      @definition = str[/.*/].sub(/^>/, '').strip
      @data = str.sub(/.*/, '').strip.split(/\s+/).map {|x| x.to_i}
    end
    attr_accessor :definition, :data
    alias entry_id definition

    def length
      @data.length
    end

    def each
      @data.each do |x|
        yield x
      end
    end

    def [](n)
      @data[n]
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
  p f.definition
  p f.definition += " hogehoge"
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

      Store the comment and sequence information from one entry of the
      FASTA format string.  If the argument contains more than one
      entry, only the first entry is used.

--- Bio::FastaFormat#definition
--- Bio::FastaFormat#definition=
--- Bio::FastaFormat#entry_id

      The comment line of the FASTA format data.  You can change the contents
      by the accessor method (definition = "new comment").

      * 'entry_id' is an alias of 'definition' method

--- Bio::FastaFormat#seq
--- Bio::FastaFormat#seq=

      Returns joined sequence lines as a String.

--- Bio::FastaFormat#fasta(factory)

      Execute FASTA search by Bio::Fasta factory object.

        #!/usr/bin/env ruby

        require 'bio'; include Bio

        factory = Fasta.local('fasta33', 'db/swissprot.f')
        ff = FlatFile.open(FastaFormat, 'query.f')
        ff.each do |entry|
          p entry.definition
          fasta_res = entry.fasta(factory)
          fasta_res.threshold(0.001).each do |r|
            print "evalue #{r.evalue} : #{r.q_id} => #{r.t_id} at "
            p r.lap_at
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

Treats a FASTA formatted entry, such as:

  >id and/or some comments                    <== comment line
  24 15 23 29 20 13 20 21 21 23 22 25 13      <== numerical data
  22 17 15 25 27 32 26 32 29 29 25

The precedent '>' can be omitted and the trailing '>' will be removed
automatically.

--- Bio::FastaNumericFormat.new(entry)

      Store the comment and the list of the numerical data.

--- Bio::FastaNumericFormat#definition
--- Bio::FastaNumericFormat#definition=
--- Bio::FastaNumericFormat#entry_id

      The comment line of the FASTA format data.  You can change the contents
      by the accessor method (definition = "new comment").

      * 'entry_id' is an alias of 'definition' method

--- Bio::FastaNumericFormat#data
--- Bio::FastaNumericFormat#data=

      Returns the list of numerical data (typically the quality score of the
      corresponding sequence) as an Array.

--- Bio::FastaNumericFormat#length

      Returns the number of the elements in numerical data.

--- Bio::FastaNumericFormat#each

      Yields on each elements of the numerical data.

--- Bio::FastaNumericFormat#[](n)

      Returns the n-th element.

=end


