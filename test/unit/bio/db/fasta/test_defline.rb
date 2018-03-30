#
# test/unit/bio/db/fasta/test_defline.rb - Unit test for Bio::FastaDefline
#
# Copyright::  Copyright (C) 2010 Kazuhiro Hayashi <k.hayashi.info@gmail.com>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/fasta/defline'

module Bio
  class TestBioFastaDefline < Test::Unit::TestCase

    def setup
      #test for all the patterns.
      @rub = Bio::FastaDefline.new('>gi|671595|emb|CAA85678.1| rubisco large subunit [Perovskia abrotanoides]')
      @ckr = Bio::FastaDefline.new(">gi|2495000|sp|Q63931|CCKR_CAVPO CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)\001gi|2147182|pir||I51898 cholecystokinin A receptor - guinea pig\001gi|544724|gb|AAB29504.1| cholecystokinin A receptor; CCK-A receptor [Cavia]") #from an exaple in the class file
      @sce = Bio::FastaDefline.new(">sce:YBR160W  CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]") #from an exaple in the class file
      @emb = Bio::FastaDefline.new(">emb:CACDC28 [X80034] C.albicans CDC28 gene") #from an exaple in the class file
      @abc = Bio::FastaDefline.new(">ABC12345 this is test") #from an exaple in the class file
      @etc = Bio::FastaDefline.new(">fasta1") # In this case, the defline has only a id like string?
      #test for the other formats
    end

    def test_entry_id
      assert_equal("gi|671595", @rub.entry_id)
      assert_equal("gi|2495000", @ckr.entry_id)
      assert_equal("sce:YBR160W", @sce.entry_id)
      assert_equal("emb:CACDC28", @emb.entry_id)
      assert_equal("ABC12345", @abc.entry_id)
      assert_equal("fasta1", @etc.entry_id)
    end

    def test_to_s
      assert_equal("gi|671595|emb|CAA85678.1| rubisco large subunit [Perovskia abrotanoides]", @rub.to_s)
      assert_equal("gi|2495000|sp|Q63931|CCKR_CAVPO CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)\001gi|2147182|pir||I51898 cholecystokinin A receptor - guinea pig\001gi|544724|gb|AAB29504.1| cholecystokinin A receptor; CCK-A receptor [Cavia]", @ckr.to_s)
      assert_equal("sce:YBR160W CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]", @sce.to_s)
      assert_equal("emb:CACDC28 [X80034] C.albicans CDC28 gene", @emb.to_s)
      assert_equal("ABC12345 this is test", @abc.to_s)
      assert_equal("fasta1", @etc.to_s)
    end

    def test_description
      assert_equal("rubisco large subunit [Perovskia abrotanoides]", @rub.description)
      assert_equal("CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)", @ckr.description)
      assert_equal("CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]", @sce.description)
      assert_equal("[X80034] C.albicans CDC28 gene", @emb.description)
      assert_equal("this is test", @abc.description)
      assert_equal("", @etc.description)
    end

    def test_descriptions
      assert_equal(["rubisco large subunit [Perovskia abrotanoides]"], @rub.descriptions)
      assert_equal(["CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)", "cholecystokinin A receptor - guinea pig", "cholecystokinin A receptor; CCK-A receptor [Cavia]"], @ckr.descriptions)
      assert_equal(["CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]"], @sce.descriptions)
      assert_equal(["[X80034] C.albicans CDC28 gene"], @emb.descriptions)
      assert_equal("this is test", @abc.description)
      assert_equal("", @etc.description) #this result that return a string is correct?
    end

    def test_id_strings
      assert_equal(["671595", "CAA85678.1"], @rub.id_strings)
      assert_equal(["2495000", "Q63931", "CCKR_CAVPO", "2147182", "I51898", "544724", "AAB29504.1", "Cavia"], @ckr.id_strings)
      assert_equal(["YBR160W", "2.7.1.-", "CC28_YEAST", "CC28_YEAST", "CDC28"], @sce.id_strings)
      assert_equal(["CACDC28", "X80034", "CDC28", "X80034"] , @emb.id_strings)  #this result that return "X80034" twice is correct?
      assert_equal(["ABC12345"], @abc.id_strings)
      assert_equal(["fasta1"], @etc.id_strings)
    end

    def test_words
      assert_equal(["abrotanoides", "large", "perovskia", "rubisco", "subunit"], @rub.words)
      assert_equal(["cavia", "cck-a", "cck-ar", "cholecystokinin", "guinea", "pig", "receptor", "type"], @ckr.words)
      assert_equal(["catalytic", "cyclin-dependent", "kinase", "srm5", "subunit"], @sce.words)
      assert_equal(["albicans"], @emb.words)  #this result that return "X80034" twice is correct?
      assert_equal(["test"], @abc.words)
      assert_equal([], @etc.words)
      assert_equal(["CCK-A", "CCK-AR", "CHOLECYSTOKININ", "Cavia", "RECEPTOR", "TYPE", "cholecystokinin", "guinea", "pig", "receptor"], @ckr.words(true)) #case sensitive
      #probably, it need not check changes in second and third arguments.
    end
    def test_get
      #get each db from each pattern except the duplicate.
      assert_equal("671595", @rub.get("gi"))
      assert_equal("CCKR_CAVPO", @ckr.get("sp"))
      assert_equal("I51898", @ckr.get("pir"))
      assert_equal("AAB29504.1", @ckr.get("gb"))
      assert_equal("YBR160W", @sce.get("sce"))
      assert_equal("2.7.1.-", @sce.get("EC"))
      assert_equal("CC28_YEAST", @sce.get("SP"))
      assert_equal("CACDC28", @emb.get("emb"))
      #the other dbs
    end
    def test_get_by_type
      #specify each type in each pattern while refering to NSIDs.
      assert_equal("671595", @rub.get_by_type("gi"))
      assert_equal("CAA85678.1", @rub.get_by_type("acc_version"))
      assert_equal(nil, @rub.get_by_type("locus"))
      assert_equal("Q63931", @ckr.get_by_type("accession"))
      assert_equal("CCKR_CAVPO", @ckr.get_by_type("entry_id"))
    end
    
    def test_get_all_by_type
      #specify each type in each pattern while refering to NSIDs.
      assert_equal(["671595", "CAA85678.1"], @rub.get_all_by_type("gi","acc_version","locus"))
      assert_equal(["Q63931", "CCKR_CAVPO", "I51898"], @ckr.get_all_by_type("accession","entry_id"))
    end
    def test_locus
      #Any of the examples don't have the locus information ...
      assert_equal(nil, @rub.locus)

    end
    def test_gi
      assert_equal("671595", @rub.gi)
      assert_equal("2495000", @ckr.gi)
      assert_equal(nil, @sce.gi) #sce dosen't have "gi" in the type.
    end
    def test_acc_version
       assert_equal("CAA85678.1", @rub.acc_version)
       assert_equal("AAB29504.1", @ckr.acc_version)
       assert_equal("CACDC28", @emb.acc_version)
    end

    def test_accessions
      assert_equal(["CACDC28"], @emb.accessions)
      assert_equal(["CAA85678"], @rub.accessions)
      assert_equal(["Q63931", "AAB29504"], @ckr.accessions)
      assert_raise(RuntimeError){@sce.accesions} #sce dosen't have "accession" in the type.
    end
    def test_accession
      assert_equal("CACDC28", @emb.accession)
      assert_equal("CAA85678", @rub.accession)
      assert_equal("AAB29504", @ckr.accession)
      assert_raise(RuntimeError){@sce.accesion} #sce dosen't have "accession" in the type.

      # to cover the else statement
      ckr2 = Bio::FastaDefline.new(">gi|2495000|sp|Q63931|CCKR_CAVPO CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)") #from an exaple in the class file
      assert_equal("Q63931", ckr2.accession)

    end


    def test_method_missing
      #Methods specified with the types are tested only in this test metho.d
      assert_equal("CCKR_CAVPO", @ckr.sp)
      assert_equal("I51898", @ckr.pir)
      assert_equal("AAB29504.1", @ckr.gb)
      assert_equal("YBR160W", @sce.sce)
      assert_equal("2.7.1.-", @sce.EC)
      assert_equal("CC28_YEAST", @sce.SP)
      assert_equal("CACDC28", @emb.emb)
    end

  end #class TestBioFastaDefline
end #module Bio

