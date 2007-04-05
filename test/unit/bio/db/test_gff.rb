#
# test/unit/bio/db/test_gff.rb - Unit test for Bio::GFF
#
# Copyright::   Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::     The Ruby License
#
#  $Id: test_gff.rb,v 1.6 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db/gff'

module Bio
  class TestGFF < Test::Unit::TestCase
    
    def setup
      data = <<END
I	sgd	CEN	151453	151591	.	+	.	CEN "CEN1" ; Note "CEN1\; Chromosome I Centromere"
I	sgd	gene	147591	151163	.	-	.	Gene "TFC3" ; Note "transcription factor tau (TFIIIC) subunit 138"
I	sgd	gene	147591	151163	.	-	.	Gene "FUN24" ; Note "transcription factor tau (TFIIIC) subunit 138"
I	sgd	gene	147591	151163	.	-	.	Gene "TSV115" ; Note "transcription factor tau (TFIIIC) subunit 138"
I	sgd	ORF	147591	151163	.	-	.	ORF "YAL001C" ; Note "TFC3\; transcription factor tau (TFIIIC) subunit 138"
I	sgd	gene	143998	147528	.	+	.	Gene "VPS8" ; Note "Vps8p is a membrane-associated hydrophilic protein which contains a C-terminal cysteine-rich region that conforms to the H2 variant of the RING finger Zn2+ binding motif."
I	sgd	gene	143998	147528	.	+	.	Gene "FUN15" ; Note "Vps8p is a membrane-associated hydrophilic protein which contains a C-terminal cysteine-rich region that conforms to the H2 variant of the RING finger Zn2+ binding motif."
I	sgd	gene	143998	147528	.	+	.	Gene "VPT8" ; Note "Vps8p is a membrane-associated hydrophilic protein which contains a C-terminal cysteine-rich region that conforms to the H2 variant of the RING finger Zn2+ binding motif."
END
      @obj = Bio::GFF.new(data)
    end

    def test_records
      assert_equal(8, @obj.records.size)
    end

    def test_record_class
      assert_equal(Bio::GFF::Record, @obj.records[0].class)
    end

  end # class TestGFF


  class TestGFF2 < Test::Unit::TestCase
    def test_version
      assert_equal(2, Bio::GFF::GFF2::VERSION)
    end
  end


  class TestGFF3 < Test::Unit::TestCase
    def test_version
      assert_equal(3, Bio::GFF::GFF3::VERSION)
    end
  end


  class TestGFFRecord < Test::Unit::TestCase
    
    def setup
      data =<<END
I	sgd	gene	151453	151591	.	+	.	Gene "CEN1" ; Note "Chromosome I Centromere"
END
      @obj = Bio::GFF::Record.new(data)
    end

    def test_seqname
      assert_equal('I', @obj.seqname)
    end

    def test_source
      assert_equal('sgd', @obj.source)
    end

    def test_feature
      assert_equal('gene', @obj.feature)
    end

    def test_start
      assert_equal('151453', @obj.start)
    end

    def test_end
      assert_equal('151591', @obj.end)
    end

    def test_score
      assert_equal('.', @obj.score)
    end

    def test_strand
      assert_equal('+', @obj.strand)
    end

    def test_frame
      assert_equal('.', @obj.frame)
    end

    def test_attributes
      at = {"Note"=>'"Chromosome I Centromere"', "Gene"=>'"CEN1"'}
      assert_equal(at, @obj.attributes)
    end

    def test_comments
      assert_equal(nil, @obj.comments)
    end

  end # class TestGFFRecord
  
  
  class TestGFFRecordConstruct < Test::Unit::TestCase

    def setup
      @obj = Bio::GFF.new
    end

    def test_add_seqname
      name = "test"
      record = Bio::GFF::Record.new("")
      record.seqname = name
      @obj.records << record
      assert_equal(name, @obj.records[0].seqname)
    end

  end # class TestGFFRecordConstruct
end
