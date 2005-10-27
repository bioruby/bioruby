#
# test/unit/bio/db/test_gff.rb - Unit test for Bio::GFF
#
#   Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
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
#  $Id: test_gff.rb,v 1.1 2005/10/27 09:27:52 nakao Exp $
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
      assert_equal(@obj.records.size, 8)
      assert_equal(@obj.records[0].class, Bio::GFF::Record)
    end

  end # class TestGFF


  class TestGFF2 < Test::Unit::TestCase
    def test_version
      assert_equal(Bio::GFF2::VERSION, 2)
    end
  end


  class TestGFF3 < Test::Unit::TestCase
    def test_version
      assert_equal(Bio::GFF3::VERSION, 3)
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
      assert_equal(@obj.seqname, 'I')
    end

    def test_source
      assert_equal(@obj.source, 'sgd')
    end

    def test_feature
      assert_equal(@obj.feature, 'gene')
    end

    def test_start
      assert_equal(@obj.start, '151453')
    end

    def test_end
      assert_equal(@obj.end, '151591')
    end

    def test_score
      assert_equal(@obj.score, '.')
    end

    def test_strand
      assert_equal(@obj.strand, '+')
    end

    def test_frame
      assert_equal(@obj.frame, '.')
    end

    def test_attributes
      at = {"Note"=>"Chromosome I Centromere", "Gene"=>"CEN1"}
      assert_equal(@obj.attributes, at)
    end

    def test_comments
      assert_equal(@obj.comments, '')
    end

  end # class TestGFFRecord
  
  
  class TestGFFRecordConstruct < Test::Unit::TestCase

    def setup
      @obj = Bio::GFF.new
    end

    def test_add_seqname
      name = "test"
      record = Bio::GFF::Record.new
      record.seqname = name
      @obj.records << record
      assert_equal(@obj.records[0].seqname, name)
    end

  end # class TestGFFRecordConstruct
end
