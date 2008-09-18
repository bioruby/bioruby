#
# test/unit/bio/appl/blast/test_rpsblast.rb - Unit test for Bio::Blast::RPSBlast::Report
#
# Copyright::  Copyright (C) 2008
#              Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'digest/sha1'
require 'bio/io/flatfile'
require 'bio/appl/blast/rpsblast'

module Bio
module TestRPSBlast
  bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
  TestFileName = Pathname.new(File.join(bioruby_root, 'test', 'data', 'rpsblast', 'misc.rpsblast')).cleanpath.to_s

  class TestRPSBlastSplitter < Test::Unit::TestCase
    def setup
      @io = File.open(TestFileName)
      @bstream = Bio::FlatFile::BufferedInputStream.new(@io, TestFileName)
      @klass = Bio::Blast::RPSBlast::Report
      @splitter = Bio::Blast::RPSBlast::RPSBlastSplitter.new(@klass, @bstream)
    end

    def teardown
      @io.close
    end

    def test_skip_leader
      assert_equal(nil, @splitter.skip_leader)
      assert_equal(0, @bstream.pos)
      # force to push back white spaces
      @bstream.ungets("          \n\n  \t\t  \n")
      assert_equal(nil, @splitter.skip_leader)
      assert_equal("RPS-BLAST 2.2.18 [Mar-02-2008]\n", @bstream.gets)
    end

    def test_rewind
      assert_nothing_raised { @splitter.rewind }
    end

    def test_get_entry
      assert(raw = @splitter.get_entry)
      assert_equal(4388, raw.size)
      assert_equal('12201ff286b16f8578e2a3b0778c721438ac8278',
                   Digest::SHA1.hexdigest(raw))

      assert(raw = @splitter.get_entry)
      assert_equal(245, raw.size)
      assert_equal('f5fb1ac1aa62ba65a68c5c7c8240c0a9fc047a46',
                   Digest::SHA1.hexdigest(raw))

      assert(raw = @splitter.get_entry)
      assert_equal(3144, raw.size)
      assert_equal('db0ff4bf9901186758b2a0d6e94734a53733631f',
                   Digest::SHA1.hexdigest(raw))

      assert_nil(@splitter.get_entry)
    end

    def test_entry_pos
      @splitter.entry_pos_flag = true
      @splitter.get_entry
      assert_equal(0,    @splitter.entry_start_pos)
      assert_equal(4388, @splitter.entry_ended_pos)

      @splitter.get_entry
      assert_equal(4388, @splitter.entry_start_pos)
      assert_equal(4461, @splitter.entry_ended_pos)

      @splitter.get_entry
      assert_equal(4461, @splitter.entry_start_pos)
      assert_equal(7433, @splitter.entry_ended_pos)
    end
  end #class TestRPSBlastSplitter

  class TestRPSBlastReport < Test::Unit::TestCase
    def setup
      @flatfile = Bio::FlatFile.open(Bio::Blast::RPSBlast::Report,
                                     TestFileName)
      @obj = @flatfile.next_entry
    end

    def teardown
      @flatfile.close
    end

    def test_program
      assert_equal('RPS-BLAST', @obj.program)
    end

    def test_version
      exp = 'RPS-BLAST 2.2.18 [Mar-02-2008]'
      assert_equal(exp, @obj.version)
    end

    def test_version_number
      assert_equal('2.2.18', @obj.version_number)
    end

    def test_version_date
      assert_equal('Mar-02-2008', @obj.version_date)
    end
      
    def test_db
      assert_equal('Pfam.v.22.0', @obj.db)
    end

    def test_query_def
      ary =
        [
         'TestSequence mixture of globin and rhodopsin (computationally randomly concatenated)',
         'randomseq3',
         'gi|6013469|gb|AAD49229.2|AF159462_1 EHEC factor for adherence [Escherichia coli]'
        ]
      @flatfile.rewind
      @flatfile.each do |rep|
        assert_equal(ary.shift, rep.query_def)
      end
      assert(ary.empty?)
    end

    def test_query_len
      ary = [ 495, 1087, 3223 ]
      @flatfile.rewind
      @flatfile.each do |rep|
        assert_equal(ary.shift, rep.query_len)
      end
      assert(ary.empty?)
    end

    def test_hits_size
      ary = [ 3, 0, 2 ]
      @flatfile.rewind
      @flatfile.each do |rep|
        assert_equal(ary.shift, rep.hits.size)
      end
      assert(ary.empty?)
    end

    def test_iterations_size
      ary = [ 1, 1, 1 ]
      @flatfile.rewind
      @flatfile.each do |rep|
        assert_equal(ary.shift, rep.iterations.size)
      end
      assert(ary.empty?)
    end
  end #class TestRPSBlastReport

  class TestRPSBlastReportHit < Test::Unit::TestCase
    def setup
      flatfile = Bio::FlatFile.open(Bio::Blast::RPSBlast::Report,
                                     TestFileName)
      @hits = flatfile.next_entry.hits
      flatfile.close
    end

    def test_hsps_size
      ary = [ 1, 2, 1 ]
      @hits.each do |h|
        assert_equal(ary.shift, h.hsps.size)
      end
      assert(ary.empty?)
    end

    def test_len
      assert_equal(110, @hits[0].len)
      assert_equal(258, @hits[1].len)
      assert_equal(336, @hits[2].len)
    end

    def test_target_len
      assert_equal(110, @hits[0].target_len)
      assert_equal(258, @hits[1].target_len)
      assert_equal(336, @hits[2].target_len)
    end

    def test_target_def
      assert_equal('gnl|CDD|84466 pfam00042, Globin, Globin..',
                   @hits[0].target_def)
      assert_equal("gnl|CDD|84429 pfam00001, 7tm_1, 7 transmembrane receptor (rhodopsin family). This" \
                   " family contains, amongst other G-protein-coupled" \
                   " receptors (GCPRs), members of the opsin family, which" \
                   " have been considered to be typical members of the" \
                   " rhodopsin superfamily. They share several motifs, mainly" \
                   " the seven transmembrane helices, GCPRs of the rhodopsin" \
                   " superfamily. All opsins bind a chromophore, such as" \
                   " 11-cis-retinal. The function of most opsins other than" \
                   " the photoisomerases is split into two steps: light" \
                   " absorption and G-protein activation. Photoisomerases, on" \
                   " the other hand, are not coupled to G-proteins - they are" \
                   " thought to generate and supply the chromophore that is" \
                   " used by visual opsins..",
                   @hits[1].target_def)
      assert_equal("gnl|CDD|87195 pfam06976, DUF1300, Protein of unknown function (DUF1300). This" \
                   " family represents a conserved region approximately 80" \
                   " residues long within a number of proteins of unknown" \
                   " function that seem to be specific to C. elegans. Some" \
                   " family members contain more than one copy of this" \
                   " region..",
                   @hits[2].target_def)
    end

    def test_definition
      assert_equal('gnl|CDD|84466 pfam00042, Globin, Globin..',
                   @hits[0].definition)
      assert_equal("gnl|CDD|84429 pfam00001, 7tm_1, 7 transmembrane receptor (rhodopsin family). This" \
                   " family contains, amongst other G-protein-coupled" \
                   " receptors (GCPRs), members of the opsin family, which" \
                   " have been considered to be typical members of the" \
                   " rhodopsin superfamily. They share several motifs, mainly" \
                   " the seven transmembrane helices, GCPRs of the rhodopsin" \
                   " superfamily. All opsins bind a chromophore, such as" \
                   " 11-cis-retinal. The function of most opsins other than" \
                   " the photoisomerases is split into two steps: light" \
                   " absorption and G-protein activation. Photoisomerases, on" \
                   " the other hand, are not coupled to G-proteins - they are" \
                   " thought to generate and supply the chromophore that is" \
                   " used by visual opsins..",
                   @hits[1].definition)
      assert_equal("gnl|CDD|87195 pfam06976, DUF1300, Protein of unknown function (DUF1300). This" \
                   " family represents a conserved region approximately 80" \
                   " residues long within a number of proteins of unknown" \
                   " function that seem to be specific to C. elegans. Some" \
                   " family members contain more than one copy of this" \
                   " region..",
                   @hits[2].definition)
    end

    def test_evalue
      assert_equal(2.0e-25, @hits[0].evalue)
      assert_equal(2.0e-19, @hits[1].evalue)
      assert_equal(0.003,   @hits[2].evalue)
    end

    def test_bit_score
      assert_equal(110.0, @hits[0].bit_score)
      assert_equal(90.8,  @hits[1].bit_score)
      assert_equal(37.1,  @hits[2].bit_score)
    end

    def test_identity
      assert_equal(50, @hits[0].identity)
      assert_equal(37, @hits[1].identity)
      assert_equal(32, @hits[2].identity)
    end

    def test_overlap
      assert_equal(110, @hits[0].overlap)
      assert_equal(162, @hits[1].overlap)
      assert_equal(145, @hits[2].overlap)
    end

    def test_query_seq
      assert_equal("EKQLITGLWGKV--NVAECGAEALARLLIVYPWTQRFFASFGNLSSPTAILGNPMVRAHGKKVLTSFGDAVKNLDN---IKNTFSQLSELHCDKLHVDPENFRLLGDILI", @hits[0].query_seq)
      assert_equal("HAIMGVAFTWVMALACAAPPLAGWSRY-IPEGLQCSCGIDYYTLKPEVNNESFVIYMFVVHFTIPMIIIFFCYGQLVFTV----KEAAAQQQESATTQKAEKEVTRMVIIMVIAFLICWVPYASVAFY--IFTHQGSNFGPIFMTIPAFFAKSAAIYNPVIY", @hits[1].query_seq)
      assert_equal("IDYYTLKPEVNNESFVIYMFV--VHFT-IPMIIIFFCYGQLVFTVKEAAAQQQESATTQKAEKEVTRMVIIMVIAFLICWVPYASVAFYIFTHQGSNFGPIFMTIPAFFAKSAAIYNPVIYIM----MNKQFRNCMLTTICCGKN", @hits[2].query_seq)
    end

    def test_target_seq
      assert_equal("QKALVKASWGKVKGNAPEIGAEILARLFTAYPDTKAYFPKFGDLSTAEALKSSPKFKAHGKKVLAALGEAVKHLDDDGNLKAALKKLGARHAKRGHVDPANFKLFGEALL", @hits[0].target_seq)
      assert_equal("RAKVLILLVWVLALLLSLPPLLFSWLRTVEEGNVTTCLIDFPEESLLR---SYTLLSTLLGFVLPLLVILVCYTRILRTLRRRARSGASIARSLKRRSSSERKAAKMLLVVVVVFVLCWLPYHIVLLLDSLCLLSIIRVLPTALLITLWLAYVNSCLNPIIY", @hits[1].target_seq)
      assert_equal("IEYIIETTELFGSSYEILLLIEGILFKLIPSIILPIATILLIFQLKKNKKVSSRSSTSSSSNDRSTKLVTFVTISFLIATVPLGILYLIKFFVFEYEGLVMIIDKLAIIFTFLSTINGTIHFLICYFMSSQYRNTVREMFGRKKK", @hits[2].target_seq)
    end

    def test_midline
      assert_equal("+K L+   WGKV  N  E GAE LARL   YP T+ +F  FG+LS+  A+  +P  +AHGKKVL + G+AVK+LD+   +K    +L   H  + HVDP NF+L G+ L+", @hits[0].midline)
      assert_equal(" A + +   WV+AL  + PPL       + EG   +C ID+          S+ +   ++ F +P+++I  CY +++ T+    +  A+  +       +E++  +M++++V+ F++CW+PY  V     +         P  + I  + A   +  NP+IY", @hits[1].midline)
      assert_equal("I+Y     E+   S+ I + +  + F  IP II+      L+F +K+       S+T+  +    T++V  + I+FLI  VP   +    F         + +   A      +  N  I+ +    M+ Q+RN +       K ", @hits[2].midline)
    end

    def test_query_start
      assert_equal(148, @hits[0].query_start)
      assert_equal(299, @hits[1].query_start)
      assert_equal(336, @hits[2].query_start)
    end

    def test_query_end
      assert_equal(252, @hits[0].query_end)
      assert_equal(453, @hits[1].query_end)
      assert_equal(473, @hits[2].query_end)
    end

    def test_target_start
      assert_equal(1,   @hits[0].target_start)
      assert_equal(100, @hits[1].target_start)
      assert_equal(192, @hits[2].target_start)
    end

    def test_target_end
      assert_equal(110, @hits[0].target_end)
      assert_equal(258, @hits[1].target_end)
      assert_equal(336, @hits[2].target_end)
    end

    def test_lap_at
      assert_equal([148, 252,   1, 110], @hits[0].lap_at)
      assert_equal([299, 453, 100, 258], @hits[1].lap_at)
      assert_equal([336, 473, 192, 336], @hits[2].lap_at)
    end
  end #class TestRPSBlastHit

  class TestRPSBlastHSP < Test::Unit::TestCase
    def setup
      flatfile = Bio::FlatFile.open(Bio::Blast::RPSBlast::Report,
                                     TestFileName)
      @hsps = flatfile.next_entry.hits[1].hsps
      flatfile.close
    end

    def test_bit_score
      assert_equal(90.8, @hsps[0].bit_score)
      assert_equal(73.4, @hsps[1].bit_score)
    end

    def test_score
      assert_equal(225, @hsps[0].score)
      assert_equal(180, @hsps[1].score)
    end

    def test_evalue
      assert_equal(2.0e-19, @hsps[0].evalue)
      assert_equal(3.0e-14, @hsps[1].evalue)
    end

    def test_identity
      assert_equal(37, @hsps[0].identity)
      assert_equal(32, @hsps[1].identity)
    end

    def test_gaps
      assert_equal(10,  @hsps[0].gaps)
      assert_equal(nil, @hsps[1].gaps)
    end

    def test_positive
      assert_equal(76, @hsps[0].positive)
      assert_equal(47, @hsps[1].positive)
    end

    def test_align_len
      assert_equal(162, @hsps[0].align_len)
      assert_equal(86,  @hsps[1].align_len)
    end

    def test_query_from
      assert_equal(299, @hsps[0].query_from)
      assert_equal(55,  @hsps[1].query_from)
    end

    def test_query_to
      assert_equal(453, @hsps[0].query_to)
      assert_equal(140, @hsps[1].query_to)
    end

    def test_hit_from
      assert_equal(100, @hsps[0].hit_from)
      assert_equal(2,   @hsps[1].hit_from)
    end

    def test_hit_to
      assert_equal(258, @hsps[0].hit_to)
      assert_equal(87,  @hsps[1].hit_to)
    end

    def test_qseq
      assert_equal("HAIMGVAFTWVMALACAAPPLAGWSRY-IPEGLQCSCGIDYYTLKPEVNNESFVIYMFVVHFTIPMIIIFFCYGQLVFTV----KEAAAQQQESATTQKAEKEVTRMVIIMVIAFLICWVPYASVAFY--IFTHQGSNFGPIFMTIPAFFAKSAAIYNPVIY", @hsps[0].qseq)
      assert_equal("NFLTLYVTVQHKKLRTPLNYILLNLAVADLFMVLGGFTSTLYTSLHGYFVFGPTGCNLEGFFATLGGEIALWSLVVLAIERYVVVC", @hsps[1].qseq)
    end

    def test_hseq
      assert_equal("RAKVLILLVWVLALLLSLPPLLFSWLRTVEEGNVTTCLIDFPEESLLR---SYTLLSTLLGFVLPLLVILVCYTRILRTLRRRARSGASIARSLKRRSSSERKAAKMLLVVVVVFVLCWLPYHIVLLLDSLCLLSIIRVLPTALLITLWLAYVNSCLNPIIY", @hsps[0].hseq)
      assert_equal("NLLVILVILRTKRLRTPTNIFLLNLAVADLLFLLTLPPWALYYLVGGDWPFGDALCKLVGALFVVNGYASILLLTAISIDRYLAIV", @hsps[1].hseq)
    end

    def test_midline
      assert_equal(" A + +   WV+AL  + PPL       + EG   +C ID+          S+ +   ++ F +P+++I  CY +++ T+    +  A+  +       +E++  +M++++V+ F++CW+PY  V     +         P  + I  + A   +  NP+IY", @hsps[0].midline)
      assert_equal("N L + V ++ K+LRTP N  LLNLAVADL  +L      LY  + G + FG   C L G    + G  ++  L  ++I+RY+ + ", @hsps[1].midline)
    end

    def test_percent_identity
      assert_equal(22, @hsps[0].percent_identity)
      assert_equal(37, @hsps[1].percent_identity)
    end
  end #class TestRPSBlastHSP

end #module TestRPSBlast
end #module Bio

