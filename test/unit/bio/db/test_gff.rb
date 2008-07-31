#
# test/unit/bio/db/test_gff.rb - Unit test for Bio::GFF
#
# Copyright::   Copyright (C) 2005, 2008
#               Mitsuteru Nakao <n@bioruby.org>
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#
#  $Id: test_gff.rb,v 1.6 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'digest/sha1'
require 'bio/db/gff'

module Bio
  class TestGFF < Test::Unit::TestCase
    
    def setup
      data = <<END_OF_DATA
I	sgd	CEN	151453	151591	.	+	.	CEN "CEN1" ; Note "CEN1\; Chromosome I Centromere"
I	sgd	gene	147591	151163	.	-	.	Gene "TFC3" ; Note "transcription factor tau (TFIIIC) subunit 138"
I	sgd	gene	147591	151163	.	-	.	Gene "FUN24" ; Note "transcription factor tau (TFIIIC) subunit 138"
I	sgd	gene	147591	151163	.	-	.	Gene "TSV115" ; Note "transcription factor tau (TFIIIC) subunit 138"
I	sgd	ORF	147591	151163	.	-	.	ORF "YAL001C" ; Note "TFC3\; transcription factor tau (TFIIIC) subunit 138"
I	sgd	gene	143998	147528	.	+	.	Gene "VPS8" ; Note "Vps8p is a membrane-associated hydrophilic protein which contains a C-terminal cysteine-rich region that conforms to the H2 variant of the RING finger Zn2+ binding motif."
I	sgd	gene	143998	147528	.	+	.	Gene "FUN15" ; Note "Vps8p is a membrane-associated hydrophilic protein which contains a C-terminal cysteine-rich region that conforms to the H2 variant of the RING finger Zn2+ binding motif."
I	sgd	gene	143998	147528	.	+	.	Gene "VPT8" ; Note "Vps8p is a membrane-associated hydrophilic protein which contains a C-terminal cysteine-rich region that conforms to the H2 variant of the RING finger Zn2+ binding motif."
END_OF_DATA
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

  class TestGFFRecord < Test::Unit::TestCase
    
    def setup
      data =<<END_OF_DATA
I	sgd	gene	151453	151591	.	+	.	Gene "CEN1" ; Note "Chromosome I Centromere"
END_OF_DATA
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

  class TestGFF3 < Test::Unit::TestCase
    def setup
      @data =<<END_OF_DATA
##gff-version 3
##sequence-region test01 1 400
test01	RANDOM	contig	1	400	.	+	.	ID=test01;Note=this is test
test01	.	mRNA	101	230	.	+	.	ID=mrna01;Name=testmRNA;Note=this is test mRNA
test01	.	mRNA	101	280	.	+	.	ID=mrna01a;Name=testmRNAalterative;Note=test of alternative splicing variant
test01	.	exon	101	160	.	+	.	ID=exon01;Name=exon01;Alias=exon 1;Parent=mrna01,mrna01a
test01	.	exon	201	230	.	+	.	ID=exon02;Name=exon02;Alias=exon 2;Parent=mrna01
test01	.	exon	251	280	.	+	.	ID=exon02a;Name=exon02a;Alias=exon 2a;Parent=mrna01a
test01	.	Match	101	123	.	.	.	ID=match01;Name=match01;Target=EST101 1 21;Gap=M8 D3 M6 I1 M6
##FASTA
>test01
ACGAAGATTTGTATGACTGATTTATCCTGGACAGGCATTGGTCAGATGTCTCCTTCCGTATCGTCGTTTA
GTTGCAAATCCGAGTGTTCGGGGGTATTGCTATTTGCCACCTAGAAGCGCAACATGCCCAGCTTCACACA
CCATAGCGAACACGCCGCCCCGGTGGCGACTATCGGTCGAAGTTAAGACAATTCATGGGCGAAACGAGAT
AATGGGTACTGCACCCCTCGTCCTGTAGAGACGTCACAGCCAACGTGCCTTCTTATCTTGATACATTAGT
GCCCAAGAATGCGATCCCAGAAGTCTTGGTTCTAAAGTCGTCGGAAAGATTTGAGGAACTGCCATACAGC
CCGTGGGTGAAACTGTCGACATCCATTGTGCGAATAGGCCTGCTAGTGAC
END_OF_DATA
      @gff3 = Bio::GFF::GFF3.new(@data)
    end

    def test_const_version
      assert_equal(3, Bio::GFF::GFF3::VERSION)
    end

    def test_sequence_regions
      region = Bio::GFF::GFF3::SequenceRegion.new('test01', 1, 400)
      assert_equal([ region ], @gff3.sequence_regions)
    end

    def test_gff_version
      assert_equal('3', @gff3.gff_version)
    end

    def test_records
      assert_equal(7, @gff3.records.size)
      r_test01 = Bio::GFF::GFF3::Record.new('test01',
                                            'RANDOM',
                                            'contig',
                                            1, 400, nil, '+', nil,
                                            { 'ID' => 'test01',
                                              'Note' => 'this is test' })
      r_mrna01 = Bio::GFF::GFF3::Record.new('test01',
                                            nil,
                                            'mRNA',
                                            101, 230, nil, '+', nil,
                                            { 'ID' => 'mrna01',
                                              'Name' => 'testmRNA',
                                              'Note' => 'this is test mRNA' })
      r_exon01 = Bio::GFF::GFF3::Record.new('test01',
                                            nil,
                                            'exon',
                                            101, 160, nil, '+', nil,
                                            { 'ID' => 'exon01',
                                              'Name' => 'exon01',
                                              'Alias' => 'exon 1',
                                              'Parent' =>
                                              [ 'mrna01', 'mrna01a'] })

      target = Bio::GFF::GFF3::Record::Target.new('EST101', 1, 21)
      gap = Bio::GFF::GFF3::Record::Gap.new('M8 D3 M6 I1 M6')
      r_match01 =Bio::GFF::GFF3::Record.new('test01',
                                            nil,
                                            'Match',
                                            101, 123, nil, nil, nil,
                                            { 'ID' => 'match01',
                                              'Name' => 'match01',
                                              'Target' => target,
                                              'Gap' => gap })
      assert_equal(r_test01, @gff3.records[0])
      assert_equal(r_mrna01, @gff3.records[1])
      assert_equal(r_exon01, @gff3.records[3])
      assert_equal(r_match01, @gff3.records[6])
    end

    def test_sequences
      assert_equal(1, @gff3.sequences.size)
      assert_equal('test01', @gff3.sequences[0].entry_id)
      assert_equal('3510a3c4f66f9c2ab8d4d97446490aced7ed1fa4',
                   Digest::SHA1.hexdigest(@gff3.sequences[0].seq.to_s))
    end

    def test_to_s
      assert_equal(@data, @gff3.to_s)
    end

  end #class TestGFF3

  class TestGFF3Record < Test::Unit::TestCase
    
    def setup
      data =<<END_OF_DATA
chrI	SGD	centromere	151467	151584	.	+	.	ID=CEN1;Name=CEN1;gene=CEN1;Alias=CEN1,test%3B0001;Note=Chromosome%20I%20centromere;dbxref=SGD:S000006463;Target=test%2002 123 456 -,test%2C03 159 314;memo%3Dtest%3Battr=99.9%25%09match
END_OF_DATA
      @obj = Bio::GFF::GFF3::Record.new(data)
    end

    def test_seqname
      assert_equal('chrI', @obj.seqname)
    end

    def test_source
      assert_equal('SGD', @obj.source)
    end

    def test_feature
      assert_equal('centromere', @obj.feature)
    end

    def test_start
      assert_equal(151467, @obj.start)
    end

    def test_end
      assert_equal(151584, @obj.end)
    end

    def test_score
      assert_equal(nil, @obj.score)
    end

    def test_strand
      assert_equal('+', @obj.strand)
    end

    def test_frame
      assert_equal(nil, @obj.frame)
    end

    def test_attributes
      attr = {
        'ID'     => 'CEN1',
        'Name'   => 'CEN1',
        'gene'   => 'CEN1',
        'Alias'  => [ 'CEN1', 'test;0001' ],
        'Note'   => 'Chromosome I centromere',
        'dbxref' => 'SGD:S000006463',
        'Target' =>
        [ Bio::GFF::GFF3::Record::Target.new('test 02', 123, 456, '-'),
          Bio::GFF::GFF3::Record::Target.new('test,03', 159, 314)
        ],
        'memo=test;attr' => "99.9%\tmatch",
      }
      assert_equal(attr, @obj.attributes)
    end

    def test_to_s
      str = <<END_OF_STR
chrI	SGD	centromere	151467	151584	.	+	.	ID=CEN1;Name=CEN1;Alias=CEN1,test%3B0001;Target=test%2002 123 456 -,test%2C03 159 314;Note=Chromosome I centromere;dbxref=SGD:S000006463;gene=CEN1;memo%3Dtest%3Battr=99.9%25%09match
END_OF_STR
      assert_equal(str, @obj.to_s)
    end
  end #class TestGFF3Record

  class TestGFF3RecordMisc < Test::Unit::TestCase
    def test_attributes_none
      # test blank with tab
      data =<<END_OF_DATA
I	sgd	gene	151453	151591	.	+	.	
END_OF_DATA
      obj = Bio::GFF::GFF3::Record.new(data)
      assert_equal({}, obj.attributes)
      
      # test blank with no tab at end
      data =<<END_OF_DATA
I	sgd	gene	151453	151591	.	+	.
END_OF_DATA
      obj = Bio::GFF::GFF3::Record.new(data)
      assert_equal({}, obj.attributes)
    end
    
    def test_attributes_one
      data =<<END_OF_DATA
I	sgd	gene	151453	151591	.	+	.	ID=CEN1
END_OF_DATA
      obj = Bio::GFF::GFF3::Record.new(data)
      at = { "ID" => 'CEN1' }
      assert_equal(at, obj.attributes)
    end
    
    def test_attributes_with_escaping
      data =<<END_OF_DATA
I	sgd	gene	151453	151591	.	+	.	ID=CEN1;gene=CEN1%3Boh;Note=Chromosome I Centromere
END_OF_DATA
      obj = Bio::GFF::GFF3::Record.new(data)
      at = { 'ID' => 'CEN1', "Note" => 'Chromosome I Centromere',
        "gene" => 'CEN1;oh' }
      assert_equal(at, obj.attributes)      
    end
    
    def test_score
      data =<<END_OF_DATA
ctg123	src	match	456	788	1e-10	-	.	ID=test01
END_OF_DATA
      obj = Bio::GFF::GFF3::Record.new(data)
      assert_equal(1e-10, obj.score)
      obj.score = 0.5
      assert_equal(0.5, obj.score)
    end

    def test_phase
      data =<<END_OF_DATA
ctg123	src	CDS	456	788	.	-	2	ID=test02
END_OF_DATA
      obj = Bio::GFF::GFF3::Record.new(data)
      assert_equal(2, obj.phase)
      assert_equal(2, obj.frame)
      obj.phase = 1
      assert_equal(1, obj.phase)
      assert_equal(1, obj.frame)
    end

    def test_initialize_9
      obj = Bio::GFF::GFF3::Record.new('test01',
                                       'testsrc',
                                       'exon',
                                       1, 400, nil, '+', nil,
                                       { 'ID' => 'test01',
                                         'Note' => 'this is test' })
      assert_equal('test01', obj.seqid)
    end

    def test_to_s_void
      obj = Bio::GFF::GFF3::Record.new
      assert_equal(".\t.\t.\t.\t.\t.\t.\t.\t.\n", obj.to_s)
    end

  end #class TestGFF3RecordMisc

  class TestGFF3RecordEscape < Test::Unit::TestCase
    def setup
      @obj = Object.new.extend(Bio::GFF::GFF3::Escape)
      @str = "A>B\tC=100%;d=e,f,g h"
    end

    def test_escape
      str = @str
      assert_equal('A>B%09C=100%25;d=e,f,g h',
                   @obj.instance_eval { escape(str) })
    end

    def test_escape_attribute
      str = @str
      assert_equal('A>B%09C%3D100%25%3Bd%3De%2Cf%2Cg h',
                   @obj.instance_eval { escape_attribute(str) })
    end

    def test_escape_seqid
      str = @str
      assert_equal('A%3EB%09C%3D100%25%3Bd%3De%2Cf%2Cg%20h',
                   @obj.instance_eval { escape_seqid(str) })
    end

    def test_unescape
      escaped_str = 'A%3EB%09C%3D100%25%3Bd%3De%2Cf%2Cg%20h'
      assert_equal(@str,
                   @obj.instance_eval {
                     unescape(escaped_str) })
    end
  end #class TestGFF3RecordEscape

  class TestGFF3RecordTarget < Test::Unit::TestCase

    def setup
      @target =
        [ Bio::GFF::GFF3::Record::Target.new('ABCD1234', 123, 456, '+'),
          Bio::GFF::GFF3::Record::Target.new(">X Y=Z;P%,Q\tR", 78, 90),
          Bio::GFF::GFF3::Record::Target.new(nil, nil, nil),
        ]
    end

    def test_parse
      strings = 
        [ 'ABCD1234 123 456 +',
          '%3EX%20Y%3DZ%3BP%25%2CQ%09R 78 90',
          ''
        ]
      @target.each do |target|
        str = strings.shift
        assert_equal(target, Bio::GFF::GFF3::Record::Target.parse(str))
      end
    end

    def test_target_id
      assert_equal('ABCD1234', @target[0].target_id)
      assert_equal(">X Y=Z;P%,Q\tR", @target[1].target_id)
      assert_equal(nil, @target[2].target_id)
    end

    def test_start
      assert_equal(123, @target[0].start)
      assert_equal(78, @target[1].start)
      assert_nil(@target[2].start)
    end

    def test_end
      assert_equal(456, @target[0].end)
      assert_equal(90, @target[1].end)
      assert_nil(@target[2].end)
    end

    def test_strand
      assert_equal('+', @target[0].strand)
      assert_nil(@target[1].strand)
      assert_nil(@target[2].strand)
    end

    def test_to_s
      assert_equal('ABCD1234 123 456 +', @target[0].to_s)
      assert_equal('%3EX%20Y%3DZ%3BP%25%2CQ%09R 78 90', @target[1].to_s)
      assert_equal('. . .', @target[2].to_s)
    end

  end #class TestGFF3RecordTarget

  class TestGFF3RecordGap < Test::Unit::TestCase
    def setup
      # examples taken from http://song.sourceforge.net/gff3.shtml
      @gaps_src = [ 'M8 D3 M6 I1 M6',
                    'M3 I1 M2 F1 M4',
                    'M3 I1 M2 R1 M4' ]
      @gaps = @gaps_src.collect { |x| Bio::GFF::GFF3::Record::Gap.new(x) }
    end

    def test_to_s
      @gaps_src.each do |src|
        assert_equal(src, @gaps.shift.to_s)
      end
    end

    def test_eqeq
      gap = Bio::GFF::GFF3::Record::Gap.new('M8 D3 M6 I1 M6')
      assert(gap == @gaps[0])
      assert_equal(false, gap == @gaps[1])
    end

    def test_process_sequences_na
      ref = 'CAAGACCTAAACTGGATTCCAAT'
      tgt = 'CAAGACCTCTGGATATCCAAT'
      ref_aligned = 'CAAGACCTAAACTGGAT-TCCAAT'
      tgt_aligned = 'CAAGACCT---CTGGATATCCAAT'
      assert_equal([ ref_aligned, tgt_aligned ],
                   @gaps[0].process_sequences_na(ref, tgt))
    end

    def test_process_sequences_na_tooshort
      ref = 'CAAGACCTAAACTGGATTCCAA'
      tgt = 'CAAGACCTCTGGATATCCAA'
      assert_raise(RuntimeError) { @gaps[0].process_sequences_na(ref, tgt) }
      ref = 'c'
      tgt = 'c'
      assert_raise(RuntimeError) { @gaps[0].process_sequences_na(ref, tgt) }
    end

    def test_process_sequences_na_aa
      ref1 = 'atgaaggaggttattgaatgtcggcggt'
      tgt1 = 'MKEVVINVGG'
      ref1_aligned = 'atgaaggag---gttattgaatgtcggcggt'
      tgt1_aligned = 'M  K  E  V  V  I  >N  V  G  G  '
      assert_equal([ ref1_aligned, tgt1_aligned ],
                   @gaps[1].process_sequences_na_aa(ref1, tgt1))
    end

    def test_process_sequences_na_aa_reverse_frameshift
      ref2 = 'atgaaggaggttataatgtcggcggt'
      tgt2 = 'MKEVVINVGG'
      ref2_aligned = 'atgaaggag---gttat<aatgtcggcggt'
      tgt2_aligned = 'M  K  E  V  V  I  N  V  G  G  '
      assert_equal([ ref2_aligned, tgt2_aligned ],
                   @gaps[2].process_sequences_na_aa(ref2, tgt2))
    end

    def test_process_sequences_na_aa_reverse_frameshift_more
      gap = Bio::GFF::GFF3::Record::Gap.new("M3 R3 M3")
      ref = 'atgaagattaatgtc'
      tgt = 'MKIINV'
      ref_aligned = 'atgaag<<<attaatgtc'
      tgt_aligned = 'M  K  I  I  N  V  '
      assert_equal([ ref_aligned, tgt_aligned ],
                   gap.process_sequences_na_aa(ref, tgt))
    end

    def test_process_sequences_na_aa_tooshort
      ref2 = 'atgaaggaggttataatgtcggcgg'
      tgt2 = 'MKEVVINVG'
      assert_raise(RuntimeError) do
        @gaps[2].process_sequences_na_aa(ref2, tgt2)
      end

      ref2 = 'atg'
      tgt2 = 'M'
      assert_raise(RuntimeError) do
        @gaps[2].process_sequences_na_aa(ref2, tgt2)
      end
    end

    def test___scan_gap
      str1 = 'CAAGACCT---CTGGATATCCAAT'
      str2 = '-aaaaaaa-a-a---ggag--'
      c = Bio::GFF::GFF3::Record::Gap::Code
      data1 = [ c.new(:M, 8), c.new(:I, 3), c.new(:M, 13) ]
      data2 = [ c.new(:I, 1), c.new(:M, 7), c.new(:I, 1), 
                c.new(:M, 1), c.new(:I, 1), c.new(:M, 1),
                c.new(:I, 3), c.new(:M, 4), c.new(:I, 2) ]

      assert_equal(data1, @gaps[0].instance_eval { __scan_gap(str1) })
      assert_equal(data2, @gaps[0].instance_eval { __scan_gap(str2) })
    end

    def test_new_from_sequences_na
      ref_aligned = 'CAAGACCTAAACTGGAT-TCCAAT'
      tgt_aligned = 'CAAGACCT---CTGGATATCCAAT'
      
      assert_equal(@gaps[0], Bio::GFF::GFF3::Record::Gap.new_from_sequences_na(ref_aligned, tgt_aligned))
    end

    def test_new_from_sequences_na_aa
      ref = 'atgaaggag---gttattgaatgtcggcggt'
      tgt = 'M  K  E  V  V  I  >N  V  G  G  '
      assert_equal(@gaps[1],
                   Bio::GFF::GFF3::Record::Gap.new_from_sequences_na_aa(ref,
                                                                        tgt))
    end

    def test_new_from_sequences_na_aa_reverse_frameshift
      ref = 'atgaaggag---gttat<aatgtcggcggt'
      tgt = 'M  K  E  V  V  I  N  V  G  G  '
      assert_equal(@gaps[2],
                   Bio::GFF::GFF3::Record::Gap.new_from_sequences_na_aa(ref,
                                                                        tgt))
    end

    def test_new_from_sequences_na_aa_reverse_frameshift_more
      gap = Bio::GFF::GFF3::Record::Gap.new("M3 R3 M3")
      ref = 'atgaag<<<attaatgtc'
      tgt = 'M  K  I  I  N  V  '
      assert_equal(gap,
                   Bio::GFF::GFF3::Record::Gap.new_from_sequences_na_aa(ref,
                                                                        tgt))
    end

    def test_new_from_sequences_na_aa_boundary_gap
      g = Bio::GFF::GFF3::Record::Gap

      ref = '---atgatg'
      tgt = 'K  M  M  '
      assert_equal(Bio::GFF::GFF3::Record::Gap.new('I1 M2'),
                   g.new_from_sequences_na_aa(ref, tgt))

      ref = 'atgatg---'
      tgt = 'M  M  K  '
      assert_equal(Bio::GFF::GFF3::Record::Gap.new('M2 I1'),
                   g.new_from_sequences_na_aa(ref, tgt))

      ref = 'atgatgatg'
      tgt = '-  M  M  '
      assert_equal(Bio::GFF::GFF3::Record::Gap.new('D1 M2'),
                   g.new_from_sequences_na_aa(ref, tgt))

      ref = 'atgatgatg'
      tgt = 'M  M  -  '
      assert_equal(Bio::GFF::GFF3::Record::Gap.new('M2 D1'),
                   g.new_from_sequences_na_aa(ref, tgt))
    end

    def test_new_from_sequences_na_aa_example
      gap = Bio::GFF::GFF3::Record::Gap.new('M2 R1 M1 F2 M1')
      ref1 = 'atgg-taagac-att'
      tgt1 = 'M  V  K  -  I  '
      ref2 = 'atggt<aagacatt'
      tgt2 = 'M  V  K  >>I  '
      gap1 = Bio::GFF::GFF3::Record::Gap.new_from_sequences_na_aa(ref1, tgt1)
      assert_equal(gap, gap1)
      gap2 = Bio::GFF::GFF3::Record::Gap.new_from_sequences_na_aa(ref2, tgt2)
      assert_equal(gap, gap2)
    end
  end #class TestGFF3RecordGap

  class TestGFF3SequenceRegion < Test::Unit::TestCase

    def setup
      @data =
        [ Bio::GFF::GFF3::SequenceRegion.new('ABCD1234', 123, 456),
          Bio::GFF::GFF3::SequenceRegion.new(">X Y=Z;P%,Q\tR", 78, 90),
          Bio::GFF::GFF3::SequenceRegion.new(nil, nil, nil),
        ]
    end

    def test_parse
      strings = 
        [ '##sequence-region ABCD1234 123 456',
          '##sequence-region %3EX%20Y%3DZ%3BP%25%2CQ%09R 78 90',
          '##sequence-region'
        ]
      @data.each do |reg|
        str = strings.shift
        assert_equal(reg, Bio::GFF::GFF3::SequenceRegion.parse(str))
      end
    end

    def test_seqid
      assert_equal('ABCD1234', @data[0].seqid)
      assert_equal(">X Y=Z;P%,Q\tR", @data[1].seqid)
      assert_equal(nil, @data[2].seqid)
    end

    def test_start
      assert_equal(123, @data[0].start)
      assert_equal(78, @data[1].start)
      assert_nil(@data[2].start)
    end

    def test_end
      assert_equal(456, @data[0].end)
      assert_equal(90, @data[1].end)
      assert_nil(@data[2].end)
    end

    def test_to_s
      assert_equal("##sequence-region ABCD1234 123 456\n", @data[0].to_s)
      assert_equal("##sequence-region %3EX%20Y%3DZ%3BP%25%2CQ%09R 78 90\n",
                   @data[1].to_s)
      assert_equal("##sequence-region . . .\n", @data[2].to_s)
    end

  end #class TestGFF3SequenceRegion

  class TestGFF3MetaData < Test::Unit::TestCase

    def setup
      @data =
        Bio::GFF::GFF3::MetaData.new('feature-ontology',
                                     'http://song.cvs.sourceforge.net/*checkout*/song/ontology/sofa.obo?revision=1.12')
    end

    def test_parse
      assert_equal(@data,
                   Bio::GFF::GFF3::MetaData.parse('##feature-ontology http://song.cvs.sourceforge.net/*checkout*/song/ontology/sofa.obo?revision=1.12'))
    end

    def test_directive
      assert_equal('feature-ontology', @data.directive)
    end

    def test_data
      assert_equal('http://song.cvs.sourceforge.net/*checkout*/song/ontology/sofa.obo?revision=1.12', @data.data)
    end
  end #class TestGFF3MetaData

end #module Bio


