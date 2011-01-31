#
# test/unit/bio/db/fasta/test_defline_misc.rb - Unit test for Bio::FastaDefline
#
# Copyright::  Copyright (C) 2010
#              John Prince <jtprince@byu.edu> 
#
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
require 'bio/db/fasta/defline'

module Bio

  class TestFastaDeflineGI1 < Test::Unit::TestCase

    def setup
      definition_line = '>gi|671595|emb|CAA85678.1| rubisco large subunit [Perovskia abrotanoides]'
      @defline = FastaDefline.new(definition_line)
    end

    def test_entry_id
      assert_equal('gi|671595', @defline.entry_id)
    end

    def test_emb
      assert_equal('CAA85678.1', @defline.emb)
    end

    def test_get_emb
      assert_equal('CAA85678.1', @defline.get('emb'))
    end

    def test_gi
      assert_equal('671595', @defline.gi)
    end

    def test_accession
      assert_equal('CAA85678', @defline.accession)
    end

    def test_accessions
      assert_equal(['CAA85678'], @defline.accessions)
    end

    def test_acc_version
      assert_equal('CAA85678.1', @defline.acc_version)
    end

    def test_locus
      assert_equal(nil, @defline.locus)
    end

    def test_list_ids
      assert_equal([["gi", "671595"], ["emb", "CAA85678.1", nil], ["Perovskia abrotanoides"]], @defline.list_ids)
    end

    def test_description
      assert_equal('rubisco large subunit [Perovskia abrotanoides]', @defline.description)
    end

    def test_descriptions
      assert_equal(['rubisco large subunit [Perovskia abrotanoides]'], @defline.descriptions)
    end

    def test_words
      assert_equal(["abrotanoides", "large", "perovskia", "rubisco", "subunit"], @defline.words)
    end

    def test_id_strings
      assert_equal(["671595", "CAA85678.1"], @defline.id_strings)
    end

    def test_get_all_by_type
      assert_equal([],  @defline.get_all_by_type)
    end
  end

  class TestFastaDeflineGIMultiple < Test::Unit::TestCase

    def setup
      definition_line = ">gi|2495000|sp|Q63931|CCKR_CAVPO CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)\001gi|2147182|pir||I51898 cholecystokinin A receptor - guinea pig\001gi|544724|gb|AAB29504.1| cholecystokinin A receptor; CCK-A receptor [Cavia]"
      @defline = FastaDefline.new(definition_line)
    end

    def test_entry_id
      assert_equal("gi|2495000", @defline.entry_id)
    end

    def test_gi
      assert_equal("2495000", @defline.gi)
    end

    def test_accession
      assert_equal("AAB29504", @defline.accession)
    end

    def test_accessions
      assert_equal(["Q63931", "AAB29504"], @defline.accessions)
    end

    def test_acc_version
      assert_equal("AAB29504.1", @defline.acc_version)
    end

    def test_locus
      assert_equal(nil, @defline.locus)
    end

    def test_list_ids
      assert_equal([["gi", "2495000"], ["sp", "Q63931", "CCKR_CAVPO"], ["gi", "2147182"], ["pir", nil, "I51898"], ["gi", "544724"], ["gb", "AAB29504.1", nil], ["Cavia"]], @defline.list_ids)
    end

    def test_description
      assert_equal("CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)", @defline.description)
    end

    def test_descriptions
      assert_equal(["CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)", "cholecystokinin A receptor - guinea pig", "cholecystokinin A receptor; CCK-A receptor [Cavia]"], @defline.descriptions)
    end

    def test_words
      assert_equal(["cavia", "cck-a", "cck-ar", "cholecystokinin", "guinea", "pig", "receptor", "type"], @defline.words)
    end

    def test_id_strings
      assert_equal(["2495000", "Q63931", "CCKR_CAVPO", "2147182", "I51898", "544724", "AAB29504.1", "Cavia"], @defline.id_strings)
    end

    def test_get_all_by_type
      assert_equal([], @defline.get_all_by_type)
    end
  end

  class TestFastaDeflineGI2 < Test::Unit::TestCase

    def setup
      definition_line = '>gi|9910844|sp|Q9UWG2|RL3_METVA 50S ribosomal protein L3P'
      @defline = FastaDefline.new(definition_line)
    end

    def test_entry_id
      assert_equal("gi|9910844", @defline.entry_id)
    end

    def test_gi
      assert_equal("9910844", @defline.gi)
    end

    def test_sp
      assert_equal('RL3_METVA', @defline.sp)
    end

    def test_accession
      assert_equal("Q9UWG2", @defline.accession)
    end

    def test_accessions
      assert_equal(["Q9UWG2"], @defline.accessions)
    end

    def test_acc_version
      assert_equal(nil, @defline.acc_version)
    end

    def test_locus
      assert_equal(nil, @defline.locus)
    end

    def test_list_ids
      assert_equal([["gi", "9910844"], ["sp", "Q9UWG2", "RL3_METVA"]], @defline.list_ids)
    end

    def test_description
      assert_equal("50S ribosomal protein L3P", @defline.description)
    end

    def test_descriptions
      assert_equal(["50S ribosomal protein L3P"], @defline.descriptions)
    end

    def test_words
      assert_equal(["50s", "ribosomal"], @defline.words)
    end

    def test_id_strings
      assert_equal(["9910844", "Q9UWG2", "RL3_METVA", "L3P"], @defline.id_strings)
    end

    def test_get_all_by_type
      assert_equal([], @defline.get_all_by_type)
    end
  end
  class TestFastaDeflineSce < Test::Unit::TestCase

    def setup
      definition_line = '>sce:YBR160W  CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]'
      @defline = FastaDefline.new(definition_line)
    end

    def test_entry_id
      assert_equal("sce:YBR160W", @defline.entry_id)
    end

    def test_gi
      assert_equal(nil, @defline.gi)
    end

    def test_accession
      assert_equal(nil, @defline.accession)
    end

    def test_accessions
      assert_equal([], @defline.accessions)
    end

    def test_acc_version
      assert_equal(nil, @defline.acc_version)
    end

    def test_locus
      assert_equal(nil, @defline.locus)
    end

    def test_list_ids
      assert_equal([["sce", "YBR160W"], ["EC", "2.7.1.-"], ["SP", "CC28_YEAST"]], @defline.list_ids)
    end

    def test_description
      assert_equal("CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]", @defline.description)
    end

    def test_descriptions
      assert_equal(["CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]"], @defline.descriptions)
    end

    def test_words
      assert_equal(["catalytic", "cyclin-dependent", "kinase", "srm5", "subunit"], @defline.words)
    end

    def test_id_strings
      assert_equal(["YBR160W", "2.7.1.-", "CC28_YEAST", "CC28_YEAST", "CDC28"], @defline.id_strings)
    end

    def test_get_all_by_type
      assert_equal([], @defline.get_all_by_type)
    end
  end

  class TestFastaDeflineEmb < Test::Unit::TestCase

    def setup
      definition_line = '>emb:CACDC28 [X80034] C.albicans CDC28 gene'
      @defline = FastaDefline.new(definition_line)
    end

    def test_entry_id
      assert_equal("emb:CACDC28", @defline.entry_id)
    end

    def test_gi
      assert_equal(nil, @defline.gi)
    end

    def test_accession
      assert_equal("CACDC28", @defline.accession)
    end

    def test_accessions
      assert_equal(["CACDC28"], @defline.accessions)
    end

    def test_acc_version
      assert_equal("CACDC28", @defline.acc_version)
    end

    def test_locus
      assert_equal(nil, @defline.locus)
    end

    def test_list_ids
      assert_equal([["emb", "CACDC28"], ["X80034"]], @defline.list_ids)
    end

    def test_description
      assert_equal("[X80034] C.albicans CDC28 gene", @defline.description)
    end

    def test_descriptions
      assert_equal(["[X80034] C.albicans CDC28 gene"], @defline.descriptions)
    end

    def test_words
      assert_equal(["albicans"], @defline.words)
    end

    def test_id_strings
      assert_equal(["CACDC28", "X80034", "CDC28", "X80034"], @defline.id_strings)
    end

    def test_get_all_by_type
      assert_equal([], @defline.get_all_by_type)
    end
  end

  class TestFastaDeflineSimple < Test::Unit::TestCase

    def setup
      definition_line = '>ABC12345 this is test'
      @defline = FastaDefline.new(definition_line)
    end

    def test_entry_id
      assert_equal("ABC12345", @defline.entry_id)
    end

    def test_gi
      assert_equal(nil, @defline.gi)
    end

    def test_accession
      assert_equal(nil, @defline.accession)
    end

    def test_accessions
      assert_equal([], @defline.accessions)
    end

    def test_acc_version
      assert_equal(nil, @defline.acc_version)
    end

    def test_locus
      assert_equal(nil, @defline.locus)
    end

    def test_list_ids
      assert_equal([["ABC12345"]], @defline.list_ids)
    end

    def test_description
      assert_equal("this is test", @defline.description)
    end

    def test_descriptions
      assert_equal(["this is test"], @defline.descriptions)
    end

    def test_words
      assert_equal(["test"], @defline.words)
    end

    def test_id_strings
      assert_equal(["ABC12345"], @defline.id_strings)
    end

    def test_get_all_by_type
      assert_equal([], @defline.get_all_by_type)
    end
  end

  class TestFastaDeflineSwissProt < Test::Unit::TestCase

    def setup
      definition_line = '>sp|P05100|3MG1_ECOLI DNA-3-methyladenine glycosylase 1 OS=Escherichia coli (strain K12) GN=tag PE=1 SV=1'
      @defline = FastaDefline.new(definition_line)
    end

    def test_entry_id 
      assert_equal('sp|P05100|3MG1_ECOLI', @defline.entry_id )
    end

    def test_get 
      assert_equal('3MG1_ECOLI', @defline.get('sp') )
    end

    def test_sp 
      assert_equal('3MG1_ECOLI', @defline.sp )
    end

    def test_accession
      assert_equal("P05100", @defline.accession)
    end

    def test_accessions
      assert_equal(["P05100"], @defline.accessions)
    end

    def test_acc_version
      assert_equal(nil, @defline.acc_version)
    end

    def test_locus
      assert_equal(nil, @defline.locus)
    end

    def test_list_ids
      assert_equal([["sp", "P05100", "3MG1_ECOLI"]], @defline.list_ids)
    end

    def test_description
      assert_equal("DNA-3-methyladenine glycosylase 1 OS=Escherichia coli (strain K12) GN=tag PE=1 SV=1", @defline.description)
    end

    def test_descriptions
      assert_equal(["DNA-3-methyladenine glycosylase 1 OS=Escherichia coli (strain K12) GN=tag PE=1 SV=1"], @defline.descriptions)
    end

    def test_words
      assert_equal(["coli", "dna-3-methyladenine", "glycosylase", "gn=tag", "os=escherichia", "pe=1", "sv=1"], @defline.words)
    end

    def test_id_strings
      assert_equal(["P05100", "3MG1_ECOLI", "K12"], @defline.id_strings)
    end

    def test_get_all_by_type
      assert_equal([], @defline.get_all_by_type)
    end
  end

  class TestFastaDeflineTrembl < Test::Unit::TestCase

    def setup
      definition_line = '>tr|C8URF0|C8URF0_ECO1A Conserved predicted plasmid protein ECsL50 OS=Escherichia coli O111:H- (strain 11128 / EHEC) GN=ECO111_p3-39 PE=4 SV=1'
      @defline = Bio::FastaDefline.new(definition_line)
    end

    def test_entry_id 
      assert_equal('tr|C8URF0|C8URF0_ECO1A', @defline.entry_id )
    end

    def test_get 
      assert_equal('C8URF0_ECO1A', @defline.get('tr') )
    end

    def test_tr 
      assert_equal('C8URF0_ECO1A', @defline.tr )
    end

    def test_accession
      assert_equal("C8URF0", @defline.accession)
    end

    def test_accessions
      assert_equal(["C8URF0"], @defline.accessions)
    end

    def test_acc_version
      assert_equal(nil, @defline.acc_version)
    end

    def test_locus
      assert_equal(nil, @defline.locus)
    end

    def test_list_ids
      assert_equal([["tr", "C8URF0", "C8URF0_ECO1A"]], @defline.list_ids)
    end

    def test_description
      assert_equal("Conserved predicted plasmid protein ECsL50 OS=Escherichia coli O111:H- (strain 11128 / EHEC) GN=ECO111_p3-39 PE=4 SV=1", @defline.description)
    end

    def test_descriptions
      assert_equal(["Conserved predicted plasmid protein ECsL50 OS=Escherichia coli O111:H- (strain 11128 / EHEC) GN=ECO111_p3-39 PE=4 SV=1"], @defline.descriptions)
    end

    def test_words
      assert_equal(["11128", "coli", "conserved", "ehec", "gn=eco111_p3-39", "os=escherichia", "pe=4", "plasmid", "predicted", "sv=1"], @defline.words)
    end

    def test_id_strings
      assert_equal(["C8URF0", "C8URF0_ECO1A",  "ECsL50", "O111"], @defline.id_strings)
    end

    def test_get_all_by_type
      assert_equal([], @defline.get_all_by_type)
    end
  end 
end

