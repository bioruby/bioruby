#
# test/unit/bio/db/test_fastq.rb - Unit test for Bio::Fastq
#
# Copyright::   Copyright (C) 2009
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/io/flatfile'
require 'bio/db/fastq'

module Bio
  module TestFastq

    TestFastqDataDir = Pathname.new(File.join(BioRubyTestDataPath,
                                              'fastq')).cleanpath.to_s

    # A module providing methods to compare float arrays
    module FloatArrayComparison
      private
      def float_array_equivalent?(expected, actual, *arg)
        assert_equal(expected.size, actual.size, *arg)
        dt = Float::EPSILON * 1024
        (0...(expected.size)).each do |i|
          e = expected[i]
          a = actual[i]
          #assert_equal(e, a)
          assert_in_delta(e, a, e.abs * dt)
        end
      end
    end #module FloatArrayComparison

    # Tests using 'longreads_original_sanger.fastq'
    class TestFastq_longreads_original_sanger < Test::Unit::TestCase
      include FloatArrayComparison

      SEQS =
        [
         'tcagTTAAGATGGGATAATATCCTCAGATTGCGTGATGAACTTTGTTCTGGTGGAGGAGA
          AGGAAGTGCATTCGACGTATGCCCGTTTGTCGATATTTGtatttaaagtaatccgtcaca
          aatcagtgacataaatattatttagatttcgggagcaactttatttattccacaagcagg
          tttaaattttaaatttaaattattgcagaagactttaaattaacctcgttgtcggagtca
          tttgttcggttattggtcgaaagtaaccncgggaagtgccgaaaactaacaaacaaaaga
          agatagtgaaattttaattaaaanaaatagccaaacgtaactaactaaaacggacccgtc
          gaggaactgccaacggacgacacagggagtagnnn',
         'tcagCCAGCAATTCCGACTTAATTGTTCTTCTTCCATCATTCATCTCGACTAACAGTTCT
          ACGATTAATGAGTTTGGCtttaatttgttgttcattattgtcacaattacactactgaga
          ctgccaaggcacncagggataggnn',
         'tcagTTTTCTTAAATTACTTGAATCTGTTGAAGTGGATGTCCACTTTTGTATGCCAAATA
          TGCCCAGCGTATACGATCTTGGCCACATCTCCACATAATCATCAGTCGGATGCAAAAAGC
          GATTAAACTAAAAATGAATGCGTTTTTAGATGAGTAAATAGGTAATACTTTGTTTAAATA
          ATAAATGTCACAAACAGAACGCGGATTACAGTACCTGAAAATAGTTGTACTGTATCTGTG
          CCGGCACTTCCTCGGCCCTGAGAAGTTGTCCCGTTGTTTCCATTCGCACCATCCAATGGC
          CAAAGTTTGCGAAGAATCTGTTCCGTTCCATTACCAATTGTTTTTCCATGctgagactgc
          caaggcacacaggggataggnn',
         'tcagTTTTTGGAGAATTCCGTCAGGGACGGCATGGCATATTTGTGGGTTCGGCACGGCGT
          CCTGGCCAAGAAGAAGAAGACGAATTAGCCCGTTAATTTAATGACACCTTCCCCAATTTT
          GCAGCAATGATTGGTTCATTCTTGGCGGTGCGTTTTTGTGCTTCGTCGAATTGTTGGCCA
          TTTTGGTCCACCGGCCATCATCTTTACGCTATCCGACTGATTGGAAATCACCGCCTAGCA
          TTTTGCCGAAGATTGTTGCGTTGTACGGCCATGTGCTGATTGTTTACATTGGCATTCTTG
          GCAATTTGTCCTTGGTCGGCTTTGACGGCAAATTTGCGGTGTTAAGTctgagactgccaa
          ggcacacagggggatagggnn',
         'tcagTTGACCGGCGTTGTGTAACAATAATTCATTATTCTGAGACGATGCCAATGTAATCG
          ACGGTTTATGCCCAATTATTCCCATCTATGCTTAACTGATCAAATACTATTTGCATTACG
          TCACGAAATTGCGCGAACACCGCCGGCCGACAATAATTTATACCGGACATACCGGAGTTG
          ATGGTAATCGGTAAAGAGTTTTATTTAATTATntattatcnctattaattattgttanca
          acaatgtgcacgctntgccgcccgccgccgccgtgtcggtaggaccccggacggacccgg
          acccggttcgggtacccgttttcgggttcccggaaccgtttttcgggtacccggtttttt
          cggggggccccccggtaaaaaaccggggaaccccctaaaacgggtaaacgtaccgtaagg
          gaccccctaaacgggggccccgaaaaaccgggacccaaaccggggggaaacggttaaagg
          ggggggaagtaggngnnnnnnnnnnnn',
         'tcagTTATTGCAGTCGTTCCGCGCCATCGCCGGTAACCGTCCGCGTGTTATTCTGTGTAT
          CGGCCAACCTTCGTATAACTTCGTATAATGTATGCTATACGAAGTTATTACGATCTATAC
          CGGCGAAACTCAGCCGAAAGGTCTCGCGGTAGAGCCTATGAGCTGCCCGACCGATGCATT
          TAAATTTCCGGGGATCGtcgctgatctgagactgccaaaggcacactagggggataggnn
          nnnnnnnnnnnnnnnnnn',
         'tcagGTTTTAAATCGCTTTCCAAGGAATTTGAGTCTAAATCCGGTGGATCCCATCAGTAC
          AAATGCGGCGACAAGGCCGTGAAAACACTGCTTAATTCTTTGCACTTTTTGGCCACCTTT
          TTGGAAATGTTGTTTTGTGTTCTCAAAATTTTCCATCTCAGAACAAACATTCCATCGGGC
          TGATGTTGTGGCTTTTGGCGCGCGAAGTGCTGCTACTGCGCGGCAAAATCAGTCGCCAGA
          CCGGTTTTGTTGTGGACGACAAAGTGATCATGCCTGACTTGTACTTCTACCGCGATCCGC
          AAGCGCGAATTGGTCACATAGTTATAGAATTTTTGAGCCTTTTTCTTGACATAAAAAGTG
          TGGTTTTAAAAATTTCCTGGCAGGACCCACGCCAACGTTCAGGAATAATATCTTTTAAAA
          AGctgagactgccaaggcacacaggggataggn',
         'tcagTTTAATTTGGTGCTTCCTTTCAATTCCTTAGTTTAAACTTGGCACTGAAGTCTCGC
          ATTTATAACTAGAGCCCGGATTTTAGAGGCTAAAAAGTTTTCCAGATTTCAAAATTTATT
          TCGAAACTATTTTTCTGATTGTGATGTGACGGATTTCTAAATTAAATCGAAATGATGTGT
          ATTGAACTTAACAAGTGATTTTTATCAGATTTTGTCAATGAATAAATTTTAATTTAAATC
          TCTTTCTAACACTTTCATGATTAAAATCTAACAAAGCGCGACCAGTATGTGAGAAGAGCA
          AAAACAACAAAAAGTGCTAGCACTAAAGAAGGTTCGAACCCAACACATAACGTAAGAGTT
          ACCGGGAAGAAAACCACTctgagactgccaaggcacacagggggataggnn',
         'tcagTTTTCAAATTTTCCGAAATTTGCTGTTTGGTAGAAGGCAAATTATTTGATTGAATT
          TTGTATTTATTTAAAACAATTTATTTTAAAATAATAATTTTCCATTGACTTTTTACATTT
          AATTGATTTTATTATGCATTTTATATTTGTTTTCTAAATATTCGTTTGCAAACTCACGTT
          GAAATTGTATTAAACTCGAAATTAGAGTTTTTGAAATTAATTTTTATGTAGCATAATATT
          TTAAACATATTGGAATTTTATAAAACATTATATTTTTctgagactgccaaggcacacagg
          gggataggn',
         'tcagTTTTGATCTTTTAATAATGAATTTTAATGTGTTAAAATGATTGCATTGATGGCATA
          ACCGCATTTAAATTAATTACATGAAGTGTAAGTATGAAATTTTCCTTTCCAAATTGCAAA
          AACTAAAATTTAAAATTTATCGTAAAAATTAACATATATTTTAAACGATTTTAAGAAACA
          TTTGTAAATTATATTTTTGTGAAGCGTTCAAACAAAAATAAACAATAAAATATTTTTCTA
          TTTAATAGCAAAACATTTGACGATGAAAAGGAAAATGCGGGTTTGAAAATGGGCTTTGCC
          ATGCTATTTTCATAATAACATATTTTTATTATGAATAATAAATTTACATACAATATATAC
          AGTCTTAAATTTATTCATAATATTTTTGAGAATctgagactgccaaggcacacaggggat
          aggn'
        ].collect { |x| x.gsub(/\s/, '').freeze }.freeze

      IDLINES =
        [
         'FSRRS4401BE7HA [length=395] [gc=36.46] [flows=800] [phred_min=0] [phred_max=40] [trimmed_length=95]',
         'FSRRS4401BRRTC [length=145] [gc=38.62] [flows=800] [phred_min=0] [phred_max=38] [trimmed_length=74]',
         'FSRRS4401B64ST [length=382] [gc=40.58] [flows=800] [phred_min=0] [phred_max=40] [trimmed_length=346]',
         'FSRRS4401EJ0YH [length=381] [gc=48.29] [flows=800] [phred_min=0] [phred_max=40] [trimmed_length=343]',
         'FSRRS4401BK0IB [length=507] [gc=49.31] [flows=800] [phred_min=0] [phred_max=40] [trimmed_length=208]',
         'FSRRS4401ARCCB [length=258] [gc=46.90] [flows=800] [phred_min=0] [phred_max=38] [trimmed_length=193]',
         'FSRRS4401CM938 [length=453] [gc=44.15] [flows=800] [phred_min=0] [phred_max=40] [trimmed_length=418]',
         'FSRRS4401EQLIK [length=411] [gc=34.31] [flows=800] [phred_min=0] [phred_max=40] [trimmed_length=374]',
         'FSRRS4401AOV6A [length=309] [gc=22.98] [flows=800] [phred_min=0] [phred_max=40] [trimmed_length=273]',
         'FSRRS4401EG0ZW [length=424] [gc=23.82] [flows=800] [phred_min=0] [phred_max=40] [trimmed_length=389]',
        ].collect { |x| x.freeze }.freeze


      ENTRY_IDS = [ 'FSRRS4401BE7HA',
                    'FSRRS4401BRRTC',
                    'FSRRS4401B64ST',
                    'FSRRS4401EJ0YH',
                    'FSRRS4401BK0IB',
                    'FSRRS4401ARCCB',
                    'FSRRS4401CM938',
                    'FSRRS4401EQLIK',
                    'FSRRS4401AOV6A',
                    'FSRRS4401EG0ZW'
                  ].collect { |x| x.freeze }.freeze

      QUALITY_STRINGS = 
        [ <<'_0_', <<'_1_', <<'_2_', <<'_3_', <<'_4_', <<'_5_', <<'_6_', <<'_7_', <<'_8_', <<'_9_' ].collect { |x| x.delete("\r\n").freeze }.freeze
FFFDDDDDDDA666?688FFHGGIIIIIIIIIIIIIIIII
IHHHIIIIIIIIIGHGFFFFF====DFFFFFFFFFFFFFF
D???:3104/76=:5...4.3,,,366////4<ABBAAA=
CCFDDDDDDDD:666CDFFFF=<ABA=;:333111<===9
9;B889FFFFFFDDBDBDDD=8844231..,,,-,,,,,,
,,1133..---17111,,,,,22555131121.--.,333
11,.,,3--,,.,,--,3511123..--!,,,,--,----
9,,,,8=,,-,,,-,,,,---26:9:5-..1,,,,11//,
,,,!,,1917--,,,,-3.,--,,17,,,,---+11113.
030000,,,044400036;96662.//;7><;!!!
_0_
FFFFFFFFFDDDDFFFFGFDDDDBAAAAA=<4444@@B=5
55:BBBBB@@?8:8<?<89898<84442;==3,,,514,,
,11,,,.,,21777555513,..--1115758.//34488
><<;;;;9944/!/4,,,57855!!
_1_
IIIICCCCI??666IIIIIIIIIIIIIIIIIIIIIIIIII
IIII6666IAIIIII???IIIICCCIIIIIIIIIIIIIII
IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII66333EI
CE::338=/----,8=>>??:2-////7>CEEIEIHHHII
IIIIIIIE;;9911199B???IBCHIIIIIIHHHIIHHHI
IIIIIIIIIIIIIIIIIBBCCIIIIIIIIIIIIIIIIIII
IIIIIIIIIIIIIIIGGGIIIIIIIIID?===DIIIHHHI
IIIIIIIIHHHIIIIIIIIIIHHHIHHHIIIIIIIIIIII
IIIIIIIIII?>;9988==5----.@@AEGIIIIIIIIIH
H????EIIIFF999;EIIBB!!
_2_
IIII?????IIIIIIIIIIIIIIHHHIIIIIIIIIIIIIH
HHIIHHHIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
IIIIIIIIHHHIIIIIHHHIIIIIIIIIIIAAAAII>>>>
IIIIIIIIIIIIIIIIIIIIIIIIIIEEIEE;33333D7I
IIIIIIIIIIIIIIIIIIIICC@@HHIIIIIIIIIIIIII
IIHHHIIIIIIIIIIIIIIIIIIIHHHIIIIIIIIIIIII
BBBBIHCDCHIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
IIHHHIIIHHCCDIIIIIIHHHIICCCH=CCIIIIIIIII
GGGIIIIIIHHHHHHIIIIIIIIIIIIIIIHHHIIHHE??
>>?EFEE?/////;:80--!!
_3_
FFFA@@FFFFFFFFFFHHB:::@BFFFFGGHIHIIIIIII
IIIIIIIIIIIIIIIIFFFFFFFFF?=BA@11188011<<
88;?AABDDC???DDAAAADA666D?DDD=====AA>?>>
<<<=<11188<<???AA?9555=ABBB@@?=>>?@@1114
2::DDA???DFFFFFFFFFFFFFBAAAA<<0000.22=//
//8,--111111!23--/24!37:6666<;822/..4!46
521177553.-.23!231121112,,-,,211==5-----
-,12,,,,,,-,,,-1,,,,-,,155--,,,,13111.,,
,,,,,,++111..11..1,,,,,,,,,+3,,,,,--22--
---//----55//**/--22--**,,,,**,,,,,,.1.,
*,,,,***,,,,,,,,,,,,,,,,,,,,,,,),,-,,,,,
,),,,,,**//.),,,///,,,,,,,,,,,.))33---,,
,,,,,,,,(0,,,!.!!!!!!!!!!!!
_4_
FFF<8::@DFFFFFFFGGFDCAAAAAB@@000046<;663
22366762243348<<=??4445::>ABAAA@<<==B=:5
55:BBD??=BDDDDFFFCCCCCCCFFCDDDFFFFFDBAA=
=88880004><<<99688;889<889?BBBBA=???DDBB
B@@??88889---237771,,,,,,,,--1152<<00158
A@><<<<<43277711,,,--37===75,----34666!!
!!!!!!!!!!!!!!!!!!
_5_
IIIIICC>>666IIIICCCIIIIIIIIHHHIIIIIG666I
IIIIIIIIIHHHIIIIIIIICCCIIIIIIIIIIIIIIIII
I@@@@IIIIIIIIIIIIIHHHIIII???=;IIEEI::///
//7544:?IBB72244E8EECEBC=@@@@@@@HHIIIIII
IIIIBBBIIIIIIIIIHHHIIIIIIIIIIIIICCCCIIII
IIIIIIIIIIIIIIIIIIIIIIII6666DEIIHEB??D@7
77772222D89EEIIIIIIIHHHIIIIIIIIHHHIIIIII
IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIHHHIIIIII
IIIIIIIII==?==IIIII???=;I63DDD82--,,,38=
=::----,,---+++33066;@6380008/:889<:BGII
IIIIIIIFE<?F5500-----5:;;;:>?@C<<7999EEE
EEE@@@@EEEEE!
_6_
III?666??HHHIIIIIIIIIGGGIIIIIIIIIIIGGGHH
HIIIIIIIIIIIIIIIIIIIIGGGIIIIIIIIIIHHHIII
@@@@IIIIEIE111100----22?=8---:-------,,,
,33---5:3,----:1BBEEEHIIIIIIIIIIIB??A122
000...:?=024GIIIIIIIIIIIIIIIIIIECCHHB=//
-,,21??<5-002=6FBB?:9<=11/4444//-//77??G
EIEEHIACCIIIHHHIIIIIIICCCAIIIHHHHHHIIIII
IIIIIIIIIIIIIIIIIEE1//--822;----.777@EII
IIII???IIIIIIIIIIIHHHIIIIIIIIIIIIIIIIIII
I994227775555AE;IEEEEEIIIII??9755>@==:3,
,,,,33336!!
_7_
IIIICCCCI;;;CCCCIII???HHHIIIIHHHIIIIIIII
IIHHHIIIHHHIIIIIII@@@@IFICCCICAA;;;;ED?B
@@D66445555<<<GII>>AAIIIIIIII;;;::III???
CCCIII;;;;IFFIIIIICCCBIBIEEDC4444?4BBBE?
EIIICHHII;;;HIIIIIIHH;;;HHIIIII;;;IIIIHH
HIIIIII>>??>IEEBGG::1111/46FBFBB?=;=A?97
771119:EAAADDBD7777=/111122DA@@B68;;;I8H
HIIIII;;;;?>IECCCB/////;745=!
_8_
IIA94445EEII===>IIIIIIIIICCCCIIHIIICC;;;
;IIIIIIIIIIIIIIIIIIIIIIIIIF;;666DDIIIIII
IIIIIIIIIIIIIEE94442244@@666CC<<BDDA=---
--2<,,,,659//00===8CIII;>>==HH;;IIIIIICC
@@???III@@@@IC?666HIDDCI?B??CC<EE11111B4
BDDCB;=@B777>////-=323?423,,,/=1,,,,-:4E
;??EIIIIICCCCI>;;;IIIIIII<<@@?=////7=A99
988<<4455IEEEIIIIIIIIIIIII<999HIIIIIIIII
II?????IIIIIIIIIIICAC;55539EIIIIIIIIIIII
IIIIHH999HHHIA=AEEFF@=.....AD@@@DDEEEEFI
II;;;977FFCCC@24449?FDD!
_9_

      QUALITY_SCORES = QUALITY_STRINGS.collect { |str|
        str.unpack('C*').collect { |i| i - 33 }.freeze
      }.freeze

      ERROR_PROBABILITIES = QUALITY_SCORES.collect { |ary|
        ary.collect { |q| 10 ** (- q / 10.0) }.freeze
      }.freeze

      def setup
        fn = File.join(TestFastqDataDir, 'longreads_original_sanger.fastq')
        @ff = Bio::FlatFile.open(Bio::Fastq, fn)
      end

      def test_validate_format
        @ff.each do |e|
          assert(e.validate_format)
        end
        assert(@ff.eof?)
      end

      def test_validate_format_with_array
        @ff.each do |e|
          a = []
          assert(e.validate_format(a))
          assert(a.empty?)
        end
      end

      def test_to_s
        ids = IDLINES.dup
        seqs = SEQS.dup
        qstrs = QUALITY_STRINGS.dup
        ent = []
        while !ids.empty?
          ent.push "@#{ids.shift}\n#{seqs.shift}\n+\n#{qstrs.shift}\n"
        end
        @ff.each do |e|
          assert_equal(ent.shift, e.to_s)
        end
        assert(ent.empty?)
      end

      def test_definition
        ids = IDLINES.dup
        @ff.each do |e|
          assert_equal(ids.shift, e.definition)
        end
        assert(ids.empty?)
      end

      def test_entry_id
        ids = ENTRY_IDS.dup
        @ff.each do |e|
          assert_equal(ids.shift, e.entry_id)
        end
        assert(ids.empty?)
      end

      def test_sequence_string
        seqs = SEQS.dup
        @ff.each do |e|
          s = seqs.shift
          assert_equal(s, e.sequence_string)
        end
        assert(seqs.empty?)
      end

      def test_seq
        seqs = SEQS.collect { |x| Bio::Sequence::Generic.new(x) }
        @ff.each do |e|
          s = seqs.shift
          assert_equal(s, e.seq)
        end
        assert(seqs.empty?)
      end

      def test_naseq
        seqs = SEQS.collect { |x| Bio::Sequence::NA.new(x) }
        @ff.each do |e|
          s = seqs.shift
          assert_equal(s, e.naseq)
        end
        assert(seqs.empty?)
      end

      def test_nalen
        lengths = SEQS.collect { |x| Bio::Sequence::NA.new(x).length }
        @ff.each do |e|
          i = lengths.shift
          assert_equal(i, e.nalen)
        end
        assert(lengths.empty?)
      end

      def test_quality_string
        qualities = QUALITY_STRINGS.dup
        @ff.each do |e|
          assert_equal(qualities.shift, e.quality_string)
        end
        assert(qualities.empty?)
      end

      def test_quality_scores
        qualities = QUALITY_SCORES.dup
        @ff.each do |e|
          assert_equal(qualities.shift, e.quality_scores)
        end
        assert(qualities.empty?)
      end

      def test_error_probabilities
        probs = ERROR_PROBABILITIES.dup
        @ff.each do |e|
          float_array_equivalent?(probs.shift,
                                  e.error_probabilities)
        end
        assert(probs.empty?)
      end

      def test_to_biosequence
        @ff.each_with_index do |e, i|
          s = nil
          assert_nothing_raised { s = e.to_biosequence }
          assert_equal(Bio::Sequence::Generic.new(SEQS[i]), s.seq)
          assert_equal(IDLINES[i], s.definition)
          assert_equal(ENTRY_IDS[i], s.entry_id)
          assert_equal(:phred, s.quality_score_type)
          assert_equal(QUALITY_SCORES[i], s.quality_scores)
          float_array_equivalent?(ERROR_PROBABILITIES[i],
                                  s.error_probabilities)
        end
      end

      def test_to_biosequence_and_output
        @ff.each_with_index do |e, i|
          id_line = IDLINES[i]
          seq_line = SEQS[i]
          qual_line = QUALITY_STRINGS[i]
          # Changed default width to nil (no wrapping)
          expected = "@#{id_line}\n#{seq_line}\n+\n#{qual_line}\n"
          actual = e.to_biosequence.output(:fastq_sanger)
          assert_equal(expected, actual)
        end
      end

      def test_roundtrip
        @ff.each_with_index do |e, i|
          str_orig = @ff.entry_raw
          s = e.to_biosequence
          str = s.output(:fastq_sanger,
                         { :repeat_title => true, :width => 80 })
          assert_equal(str_orig, str)
          e2 = Bio::Fastq.new(str)
          assert_equal(e.sequence_string, e2.sequence_string)
          assert_equal(e.quality_string, e2.quality_string)
          assert_equal(e.definition, e2.definition)
          assert_equal(e.quality_scores, e2.quality_scores)
          float_array_equivalent?(e.error_probabilities,
                                  e2.error_probabilities)
        end
      end

    end #class TestFastq_longreads_original_sanger

    # common methods to read *_full_range_as_*.fastq and test quality scores
    # and error probabilities
    module TestFastq_full_range
      include FloatArrayComparison

      private
      def read_file(fn, format)
        path = File.join(TestFastqDataDir, fn)
        entries = Bio::FlatFile.open(Bio::Fastq, path) { |ff| ff.to_a }
        entries.each { |e| e.format=format }
        entries
      end

      def scores_through(range)
        range.to_a
      end

      def scores_phred2solexa(range)
        min = -5
        max = 62
        sc = range.collect do |q|
          tmp = 10 ** (q / 10.0) - 1
          if tmp <= 0 then
            min
          else
            r = (10 * Math.log10(tmp)).round
            if r < min then
              min
            elsif r > max then
              max
            else
              r
            end
          end
        end
        sc
      end

      def scores_phred2illumina(range)
        min = 0
        max = 62
        sc = range.collect do |q|
          if q < min then
            min
          elsif q > max then
            max
          else
            q
          end
        end
        sc
      end

      def scores_phred2sanger(range)
        min = 0
        max = 93
        sc = range.collect do |q|
          if q < min then
            min
          elsif q > max then
            max
          else
            q
          end
        end
        sc
      end

      def scores_solexa2phred(range)
        sc = range.collect do |q|
          r = 10 * Math.log10(10 ** (q / 10.0) + 1)
          r.round
        end
        sc
      end

      def scores_solexa2sanger(range)
        scores_phred2sanger(scores_solexa2phred(range))
      end

      def scores_solexa2illumina(range)
        scores_phred2illumina(scores_solexa2phred(range))
      end

      def common_test_quality_scores(scores, filename, format)
        entries = read_file(filename, format)
        assert_equal(scores, entries[0].quality_scores)
        assert_equal(scores.reverse, entries[1].quality_scores)
      end

      def common_test_error_probabilities(probabilities, filename, format)
        entries = read_file(filename, format)
        float_array_equivalent?(probabilities,
                                entries[0].error_probabilities)
        float_array_equivalent?(probabilities.reverse,
                                entries[1].error_probabilities)
      end

      def common_test_validate_format(filename, format)
        entries = read_file(filename, format)
        assert(entries[0].validate_format)
        assert(entries[1].validate_format)
      end

      def phred_q2p(scores)
        scores.collect { |q| 10 ** (-q / 10.0) }
      end

      def solexa_q2p(scores)
        scores.collect do |q|
          t = 10 ** (-q / 10.0)
          t / (1.0 + t)
        end
      end

      public
      def test_validate_format
        common_test_validate_format(self.class::FILENAME_AS_SANGER,
                                    'fastq-sanger')
        common_test_validate_format(self.class::FILENAME_AS_SOLEXA,
                                    'fastq-solexa')
        common_test_validate_format(self.class::FILENAME_AS_ILLUMINA,
                                    'fastq-illumina')
      end

      def test_quality_scores_as_sanger
        scores = scores_to_sanger(self.class::RANGE)
        common_test_quality_scores(scores,
                                   self.class::FILENAME_AS_SANGER,
                                   'fastq-sanger')
      end

      def test_error_probabilities_as_sanger
        scores = scores_to_sanger(self.class::RANGE)
        probs = phred_q2p(scores)
        common_test_error_probabilities(probs,
                                        self.class::FILENAME_AS_SANGER,
                                        'fastq-sanger')
      end

      def test_quality_scores_as_solexa
        scores = scores_to_solexa(self.class::RANGE)
        common_test_quality_scores(scores,
                                   self.class::FILENAME_AS_SOLEXA,
                                   'fastq-solexa')
      end

      def test_error_probabilities_as_solexa
        scores = scores_to_solexa(self.class::RANGE)
        probs = solexa_q2p(scores)
        common_test_error_probabilities(probs,
                                        self.class::FILENAME_AS_SOLEXA,
                                        'fastq-solexa')
      end

      def test_quality_scores_as_illumina
        scores = scores_to_illumina(self.class::RANGE)
        common_test_quality_scores(scores,
                                   self.class::FILENAME_AS_ILLUMINA,
                                   'fastq-illumina')
      end

      def test_error_probabilities_as_illumina
        scores = scores_to_illumina(self.class::RANGE)
        probs = phred_q2p(scores)
        common_test_error_probabilities(probs,
                              self.class::FILENAME_AS_ILLUMINA,
                              'fastq-illumina')
      end
    end #module TestFastq_full_range


    class TestFastq_sanger_full_range < Test::Unit::TestCase
      include TestFastq_full_range

      RANGE = 0..93
      FILENAME_AS_SANGER   = 'sanger_full_range_as_sanger.fastq'
      FILENAME_AS_SOLEXA   = 'sanger_full_range_as_solexa.fastq'
      FILENAME_AS_ILLUMINA = 'sanger_full_range_as_illumina.fastq'

      alias scores_to_sanger   scores_through
      alias scores_to_solexa   scores_phred2solexa
      alias scores_to_illumina scores_phred2illumina
    end #class TestFastq_sanger_full_range


    class TestFastq_solexa_full_range < Test::Unit::TestCase
      include TestFastq_full_range

      RANGE = (-5)..62
      FILENAME_AS_SANGER   = 'solexa_full_range_as_sanger.fastq'
      FILENAME_AS_SOLEXA   = 'solexa_full_range_as_solexa.fastq'
      FILENAME_AS_ILLUMINA = 'solexa_full_range_as_illumina.fastq'

      alias scores_to_sanger   scores_solexa2sanger
      alias scores_to_solexa   scores_through
      alias scores_to_illumina scores_solexa2illumina
    end #class TestFastq_solexa_full_range


    class TestFastq_illumina_full_range < Test::Unit::TestCase
      include TestFastq_full_range

      RANGE = 0..62
      FILENAME_AS_SANGER   = 'illumina_full_range_as_sanger.fastq'
      FILENAME_AS_SOLEXA   = 'illumina_full_range_as_solexa.fastq'
      FILENAME_AS_ILLUMINA = 'illumina_full_range_as_illumina.fastq'

      alias scores_to_sanger   scores_phred2sanger
      alias scores_to_solexa   scores_phred2solexa
      alias scores_to_illumina scores_through
    end #class TestFastq_illumina_full_range


    # common methods for testing error_*.fastq
    module TestFastq_error

      FILENAME = nil
      PRE_SKIP = 2
      POST_SKIP = 2
      ERRORS = []

      def do_test_validate_format(ff)
        e = ff.next_entry
        #p e
        a = []
        assert_equal(false, e.validate_format(a))
        assert_equal(self.class::ERRORS.size, a.size)
        self.class::ERRORS.each do |ex|
          obj = a.shift
          assert_kind_of(ex.class, obj)
          assert_equal(ex.message, obj.message)
        end
      end
      private :do_test_validate_format

      def test_validate_format
        path = File.join(TestFastqDataDir, self.class::FILENAME)
        Bio::FlatFile.open(Bio::Fastq, path) do |ff|
          self.class::PRE_SKIP.times { ff.next_entry }
          do_test_validate_format(ff)
          self.class::POST_SKIP.times { ff.next_entry }
          assert(ff.eof?)
        end
      end
    end #module TestFastq_error

    class TestFastq_error_diff_ids < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_diff_ids.fastq'
      PRE_SKIP = 2
      POST_SKIP = 2
      ERRORS = [ Bio::Fastq::Error::Diff_ids.new ]
    end #class TestFastq_error_diff_ids

    class TestFastq_error_double_qual < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_double_qual.fastq'
      PRE_SKIP = 2
      POST_SKIP = 2
      ERRORS = [ Bio::Fastq::Error::Long_qual.new ]
    end #class TestFastq_error_double_qual

    class TestFastq_error_double_seq < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_double_seq.fastq'
      PRE_SKIP = 3
      POST_SKIP = 0
      ERRORS = [ Bio::Fastq::Error::Long_qual.new ]
    end #class TestFastq_error_double_seq

    class TestFastq_error_long_qual < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_long_qual.fastq'
      PRE_SKIP = 3
      POST_SKIP = 1
      ERRORS = [ Bio::Fastq::Error::Long_qual.new ]
    end #class TestFastq_error_long_qual

    class TestFastq_error_no_qual < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_no_qual.fastq'
      PRE_SKIP = 0
      POST_SKIP = 0

      private
      def do_test_validate_format(ff)
        2.times do
          e = ff.next_entry
          a = []
          e.validate_format(a)
          assert_equal(1, a.size)
          assert_kind_of(Bio::Fastq::Error::Long_qual, a[0])
        end
        1.times do
          e = ff.next_entry
          a = []
          e.validate_format(a)
          assert_equal(1, a.size)
          assert_kind_of(Bio::Fastq::Error::Short_qual, a[0])
        end
      end
    end #class TestFastq_error_no_qual

    class TestFastq_error_qual_del < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_qual_del.fastq'
      PRE_SKIP = 3
      POST_SKIP = 1
      ERRORS = [ Bio::Fastq::Error::Qual_char.new(12) ]
    end #class TestFastq_error_qual_del

    class TestFastq_error_qual_escape < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_qual_escape.fastq'
      PRE_SKIP = 4
      POST_SKIP = 0
      ERRORS = [ Bio::Fastq::Error::Qual_char.new(7) ]
    end #class TestFastq_error_qual_escape

    class TestFastq_error_qual_null < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_qual_null.fastq'
      PRE_SKIP = 0
      POST_SKIP = 4
      ERRORS = [ Bio::Fastq::Error::Qual_char.new(3) ]
    end #class TestFastq_error_qual_null

    class TestFastq_error_qual_space < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_qual_space.fastq'
      PRE_SKIP = 3
      POST_SKIP = 1
      ERRORS = [ Bio::Fastq::Error::Qual_char.new(18) ]
    end #class TestFastq_error_qual_space

    class TestFastq_error_qual_tab < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_qual_tab.fastq'
      PRE_SKIP = 4
      POST_SKIP = 0
      ERRORS = [ Bio::Fastq::Error::Qual_char.new(10) ]
    end #class TestFastq_error_qual_tab

    class TestFastq_error_qual_unit_sep < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_qual_unit_sep.fastq'
      PRE_SKIP = 2
      POST_SKIP = 2
      ERRORS = [ Bio::Fastq::Error::Qual_char.new(5) ]
    end #class TestFastq_error_qual_unit_sep

    class TestFastq_error_qual_vtab < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_qual_vtab.fastq'
      PRE_SKIP = 0
      POST_SKIP = 4
      ERRORS = [ Bio::Fastq::Error::Qual_char.new(10) ]
    end #class TestFastq_error_qual_vtab

    class TestFastq_error_short_qual < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_short_qual.fastq'
      PRE_SKIP = 2
      POST_SKIP = 1
      ERRORS = [ Bio::Fastq::Error::Long_qual.new ]
    end #class TestFastq_error_short_qual

    module TemplateTestFastq_error_spaces
      include TestFastq_error

      FILENAME = 'error_spaces.fastq'
      PRE_SKIP = 0
      POST_SKIP = 0
      ERRORS = [ Bio::Fastq::Error::Seq_char.new(9),
                 Bio::Fastq::Error::Seq_char.new(20),
                 Bio::Fastq::Error::Qual_char.new(9),
                 Bio::Fastq::Error::Qual_char.new(20)
               ]

      private
      def do_test_validate_format(ff)
        5.times do
          e = ff.next_entry
          a = []
          e.validate_format(a)
          assert_equal(4, a.size)
          self.class::ERRORS.each do |ex|
            obj = a.shift
            assert_kind_of(ex.class, obj)
            assert_equal(ex.message, obj.message)
          end
        end
      end
    end #module TemplateTestFastq_error_spaces

    class TestFastq_error_spaces < Test::Unit::TestCase
      include TemplateTestFastq_error_spaces
    end #class TestFastq_error_spaces

    class TestFastq_error_tabs < Test::Unit::TestCase
      include TemplateTestFastq_error_spaces
      FILENAME = 'error_tabs.fastq'
    end #class TestFastq_error_tabs

    module TemplateTestFastq_error_trunc_at_plus
      include TestFastq_error

      FILENAME = 'error_trunc_at_plus.fastq'
      PRE_SKIP = 4
      POST_SKIP = 0
      ERRORS = [ Bio::Fastq::Error::No_qual.new ]
    end #module TemplateTestFastq_error_trunc_at_plus

    class TestFastq_error_trunc_at_plus < Test::Unit::TestCase
      include TemplateTestFastq_error_trunc_at_plus
    end #class TestFastq_error_trunc_at_plus

    class TestFastq_error_trunc_at_qual < Test::Unit::TestCase
      include TemplateTestFastq_error_trunc_at_plus
      FILENAME = 'error_trunc_at_qual.fastq'
    end #class TestFastq_error_trunc_at_qual

    class TestFastq_error_trunc_at_seq < Test::Unit::TestCase
      include TestFastq_error

      FILENAME = 'error_trunc_at_seq.fastq'
      PRE_SKIP = 4
      POST_SKIP = 0
      ERRORS = [ Bio::Fastq::Error::No_qual.new ]
    end #class TestFastq_error_trunc_at_seq

    # Unit tests for Bio::Fastq#mask.
    class TestFastq_mask < Test::Unit::TestCase
      def setup
        fn = File.join(TestFastqDataDir, 'wrapping_original_sanger.fastq')
        Bio::FlatFile.open(Bio::Fastq, fn) do |ff|
          @entry = ff.next_entry
        end
        @entry.format = :fastq_sanger
      end

      def test_mask_60
        expected = 'n' * 135
        assert_equal(expected, @entry.mask(60).seq)
      end

      def test_mask_20
        expected = "GAAnTTnCAGGnCCACCTTTnnnnnGATAGAATAATGGAGAAnnTTAAAnGCTGTACATATACCAATGAACAATAAnTCAATACATAAAnnnGGAGAAGTnGGAACCGAAnGGnTTnGAnTTCAAnCCnTTnCGn"
        assert_equal(expected, @entry.mask(20).seq)
      end

      def test_mask_20_with_x
        expected = "GAAxTTxCAGGxCCACCTTTxxxxxGATAGAATAATGGAGAAxxTTAAAxGCTGTACATATACCAATGAACAATAAxTCAATACATAAAxxxGGAGAAGTxGGAACCGAAxGGxTTxGAxTTCAAxCCxTTxCGx"
        assert_equal(expected, @entry.mask(20, 'x').seq)
      end

      def test_mask_20_with_empty_string
        expected = "GAATTCAGGCCACCTTTGATAGAATAATGGAGAATTAAAGCTGTACATATACCAATGAACAATAATCAATACATAAAGGAGAAGTGGAACCGAAGGTTGATTCAACCTTCG"
        assert_equal(expected, @entry.mask(20, '').seq)
      end
        
      def test_mask_20_with_longer_string
        expected = "GAA-*-TT-*-CAGG-*-CCACCTTT-*--*--*--*--*-GATAGAATAATGGAGAA-*--*-TTAAA-*-GCTGTACATATACCAATGAACAATAA-*-TCAATACATAAA-*--*--*-GGAGAAGT-*-GGAACCGAA-*-GG-*-TT-*-GA-*-TTCAA-*-CC-*-TT-*-CG-*-"
        assert_equal(expected, @entry.mask(20, '-*-').seq)
      end

    end #class TestFastq_mask

  end #module TestFastq
end #module Bio

