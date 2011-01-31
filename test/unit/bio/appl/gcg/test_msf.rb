#
# = test/unit/bio/appl/gcg/test_msf.rb - Unit test for Bio::GCG::Msf
#
# Copyright::  Copyright (C) 2009 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/sequence'
require 'bio/alignment'
require 'bio/appl/gcg/seq'
require 'bio/appl/gcg/msf'

module Bio

  module TestGCGMsfData

    Filename_PileupAA = Pathname.new(File.join(BioRubyTestDataPath, 'gcg', 'pileup-aa.msf')).cleanpath.to_s

    PileupAA = File.read(Filename_PileupAA).freeze

    mfst = <<__END_OF_MFST__
>xx_3183087
~MAFLGLFSLLVLQSMATGA.TGEDENILFQKEIRHSMGYDSLKNGE.EF
SNYINKWVENNTRTFSF.TKDDEVQIPMMYQQGEFYYGEFSDGSNEAGGI
YQVLEIPYEGDEISMMLVLSRQEVPLATLEPLVKAQLVEEWANSVKKQKV
EVYLPRFTVEQEIDLKDVLKALGITEIFIKD.ANLTG....LSDNKEIFL
SKAIHKSFLEVNEEGSEAAAVSGMIAISRMAVLYP.....QVIVDHPFFF
LIRNRRTGTILFMGRVMHPETMNTSGHDFEEL
>xx_3183086
~MYFLGLLSLLVLPSKAFKA.AREDENILFLKEIRHSLGFDSLKNGE.EF
TTHINKWVENNTRTFSF.TKDDEVQIPMMYQQGEFYYGEFSDGSNEAGGI
YQVLEIPYEGDEISMMIVLSRQEVPLVTLEPLVKASLINEWANSVKKQKV
EVYLPRFTVEQEIDLKDVLKGLGITEVFSRS.ADLTA....MSDNKELYL
AKAFHKAFLEVNEEGSEAAAASGMIAISRMAVLYP.....QVIVDHPFFF
LVRNRRTGTVLFMGRVMHPEAMNTSGHDFEEL
>xx_192453532
MLLLVVLPPLLLLRGCFCQAISSGEENIIFLQEIRQAVGYSHFREDE.EF
SERINSWVLNNTRTFSF.TRDDGVQTLMMYQQGDFYYGEFSDGTTEAGGV
YQVLEMLYEGEDMSMMIVLPRQEVPLASLEPIIKAPLLEEWANNVKRQKV
EVYLPRFKVEQKIDLRESLQQLGIRSIFSKD.ADLSAMTAQMTDGQDLFI
GKAVQKAYLEVTEEGAEGAAGSGMIALTRTLVLYP.....QVMADHPFFF
IIRNRKTGSILFMGRVMNPELIDPFDNNFDM~
>xx_72157730
~~~~~~~~MAFSKQQDISGQDERRGTNLFFATQIADVFRFNQVDQDQLHG
TKSINDWVSKNTTQETFKVLDERVPVSLMIQKGKYALAV..DNTNDC...
.LVLEMPYQGRNLSLLIALPVKDDGLGQLETKLSADILQSWDAGLKSRQV
NVLLPKFKLEAQFQLKEFLQRMGMSDAFDEDRANFEGISG...DRE.LHI
SAVIHKAFVDVNEEGSEAAAATAVVMMRRCAPPREPEKPILFRADHPFIF
MIRHRPTKSVLFMGRMMDPS~~~~~~~~~~~~
>xx_210090185
~~~~~~~~~~~~~MRSSTSQEKDHPENIFFAQQMSRVLRFHKMDASDLHM
RQTINSWVEERTRLGTFHI.SRDVEVPMMHQQGRFKLAY..DEDLNC...
.QILEMPYRGKHLSMVVVLPDKMDDLSAIETSLTPDLLRHWRKSMSEEST
MVQIPKFKVEQDFLLKEKLAEMGMTDLFSMADADLSGITG...SRD.LHV
SHVVHKAFVEVNEEGSEAAAATAVNMMKRSL...DGE...MFFADHPFLF
LIRDNDSNSVLFLGRLVRPEGHTTKDEL~~~~
>xx_45552463
~~~~~~~~~~~~~MADAAGQKP..GENIVFATQLDQGLGLASSDPEQ...
.ATINNWVEQLTRPDTFH.LDGEVQVPMMSLKERFRYAD..LPALDA...
.MALELPYKDSDLSMLIVLPNTKTGLPALEEKLRLTTLSQITQSLYETKV
ALKLPRFKAEFQVELSEVFQKLGMSRMFS.DQAEFGKMLQ...SPEPLKV
SAIIHKAFIEVNEEGTEAAAATGMVMCYASMLTFEPQ.PVQFHVQHPFNY
YIINKDS.TILFAGRINKF~~~~~~~~~~~~~
__END_OF_MFST__

    seqs = mfst.split(/^\>.*/).collect { |x| x.gsub(/\s+/, '').freeze }
    seqs.shift # removes the first empty string
    names = mfst.scan(/^\>.*/).collect { |x| x.sub(/\A\>/, '').freeze }

    PileupAA_seqs = seqs.freeze
    PileupAA_names = names.freeze

  end #module TestGCGMsfData

  class TestGCGMsf < Test::Unit::TestCase

    def setup
      @paa = Bio::GCG::Msf.new(TestGCGMsfData::PileupAA)
    end

    def test_alignment
      seqs = TestGCGMsfData::PileupAA_seqs.dup
      names = TestGCGMsfData::PileupAA_names
 
      aln = nil
      assert_nothing_raised { aln = @paa.alignment }
      assert_equal(names, aln.keys)
      aln.each do |s|
        assert_equal(seqs.shift, s)
      end
      assert(seqs.empty?)
    end

    def test_checksum
      assert_equal(5701, @paa.checksum)
    end

    def test_date
      assert_equal('April 22, 2009 22:31', @paa.date)
    end

    def test_description
      assert_equal("PileUp of: @/home/ngoto/.seqlab-localhost/pileup_24.list\n\n Symbol comparison table: GenRunData:blosum62.cmp  CompCheck: 1102\n\n                   GapWeight: 8\n             GapLengthWeight: 2 \n\n", @paa.description)
    end

    def test_entry_id
      assert_equal('pileup_24.msf', @paa.entry_id)
    end

    def test_heading
      assert_equal('!!AA_MULTIPLE_ALIGNMENT 1.0', @paa.heading)
    end

    def test_length
      assert_equal(282, @paa.length)
    end

    def test_seq_type
      assert_equal('P', @paa.seq_type)
    end

    def test_compcheck
      assert_equal(1102, @paa.compcheck)
    end

    def test_gap_length_weight
      assert_equal("2", @paa.gap_length_weight)
    end

    def test_gap_weight
      assert_equal("8", @paa.gap_weight)
    end

    def test_symbol_comparison_table
      assert_equal('GenRunData:blosum62.cmp', @paa.symbol_comparison_table)
    end

    def test_validate_checksum
      assert_equal(true, @paa.validate_checksum)
    end

  end #class TestGCGMsf_PileupAA

end #module Bio

