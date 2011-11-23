#
# test/functional/bio/io/test_ensembl.rb - Functional test for Bio::Ensembl
#
# Copyright::   Copyright (C) 2007
#               Mitsuteru C. Nakao <n@bioruby.org>
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
require 'bio/io/ensembl'

module Bio

class FuncTestEnsembl < Test::Unit::TestCase
  def setup
    @serv = Bio::Ensembl.new('Homo_sapiens')
  end
  
  def test_class
    assert_equal(Bio::Ensembl, @serv.class)
  end
end

class FuncTestEnsemblHuman < Test::Unit::TestCase
  def setup
    @serv = Bio::Ensembl.human
  end 

  def test_organism
    assert_equal("Homo_sapiens", @serv.organism)
  end
  
  def test_server
    assert_equal("http://www.ensembl.org", @serv.server)
  end
end

class FuncTestEnsemblHumanExportView < Test::Unit::TestCase
  def setup
    @serv = Bio::Ensembl.new('Homo_sapiens',
                             'http://jul2008.archive.ensembl.org')
  end

  def test_fna_exportview
    seq = ">4 dna:chromosome chromosome:NCBI36:4:1149206:1149209:1\nGAGA\n"
    fna = @serv.exportview(4, 1149206, 1149209)
    assert_equal(seq, fna)
  end

  def test_fasta_exportview_with_hash_4th_params
    fna = @serv.exportview(4, 1149206, 1149209, :upstream => 10)
    fna10 = @serv.exportview(4, 1149196, 1149209)
    assert_equal(fna10, fna)
  end

  def test_fna_exportview_with_named_args
    seq = ">4 dna:chromosome chromosome:NCBI36:4:1149206:1149209:1\nGAGA\n"
    fna = @serv.exportview(:seq_region_name => 4,
                           :anchor1 => 1149206,
                           :anchor2 => 1149209)
    assert_equal(seq, fna)
  end 

  def test_fasta_exportview_with_named_args_and_hash_4th_params
    fna = @serv.exportview(:seq_region_name => 4, 
                           :anchor1 => 1149206, 
                           :anchor2 => 1149209, 
                           :upstream => 10)
    fna10 = @serv.exportview(:seq_region_name => 4, 
                             :anchor1 => 1149196, 
                             :anchor2 => 1149209)
    assert_equal(fna10, fna)
  end

   def test_gff_exportview_for_empty_result
     gff = @serv.exportview(4, 1149206, 1149209, ['gene'])
     assert_equal('', gff)
   end

   def test_gff_exportview
     # OR1A1 (Olfactory receptor 1A1)
     lines = [ [ "17",
                 "Ensembl",
                 "Gene",
                 "3065665",
                 "3066594",
                 ".",
                 "+",
                 "1",
                 "gene_id=ENSG00000172146; transcript_id=ENST00000304094; exon_id=ENSE00001137815; gene_type=KNOWN_protein_coding"
               ],
               [ "17",
                 "Vega",
                 "Gene",
                 "3065665",
                 "3066594",
                 ".",
                 "+",
                 "1",
                 "gene_id=OTTHUMG00000090637; transcript_id=OTTHUMT00000207292; exon_id=OTTHUME00001080001; gene_type=KNOWN_protein_coding"
               ]
             ]
     line = lines.collect { |x| x.join("\t") + "\n" }.join('')
     gff = @serv.exportview(17, 3065665, 3066594, ['gene'])
     assert_equal(line, gff)
   end

   def test_gff_exportview_with_named_args_for_empty_result
     gff = @serv.exportview(:seq_region_name => 4,
                            :anchor1 => 1149206,
                            :anchor2 => 1149209, 
                            :options => ['gene'])
     assert_equal('', gff)
   end 

   def test_gff_exportview_with_named_args
     # OR1A1 (Olfactory receptor 1A1)
     lines = [ [ "17",
                 "Ensembl",
                 "Gene",
                 "3065665",
                 "3066594",
                 ".",
                 "+",
                 "1",
                 "gene_id=ENSG00000172146; transcript_id=ENST00000304094; exon_id=ENSE00001137815; gene_type=KNOWN_protein_coding"
               ],
               [ "17",
                 "Vega",
                 "Gene",
                 "3065665",
                 "3066594",
                 ".",
                 "+",
                 "1",
                 "gene_id=OTTHUMG00000090637; transcript_id=OTTHUMT00000207292; exon_id=OTTHUME00001080001; gene_type=KNOWN_protein_coding"
               ]
             ]
     line = lines.collect { |x| x.join("\t") + "\n" }.join('')
     gff = @serv.exportview(:seq_region_name => 17,
                            :anchor1 => 3065665,
                            :anchor2 => 3066594, 
                            :options => ['gene'])
     assert_equal(line, gff)
   end 

   def test_tab_exportview_with_named_args_for_empty_result
     line = ["seqname",
             "source",
             "feature",
             "start",
             "end",
             "score",
             "strand",
             "frame",
             "gene_id",
             "transcript_id",
             "exon_id",
             "gene_type"].join("\t") + "\n"
     gff = @serv.exportview(:seq_region_name => 4,
                            :anchor1 => 1149206,
                            :anchor2 => 1149209, 
                            :options => ['gene'],
                            :format => 'tab')
     assert_equal(line, gff)
   end 

   def test_tab_exportview_with_named_args
     # OR1A1 (Olfactory receptor 1A1)
     lines = [ [ "seqname",
                 "source",
                 "feature",
                 "start",
                 "end",
                 "score",
                 "strand",
                 "frame",
                 "gene_id",
                 "transcript_id",
                 "exon_id",
                 "gene_type"
               ],
               [ "17",
                 "Ensembl",
                 "Gene",
                 "3065665",
                 "3066594",
                 ".",
                 "+",
                 "1",
                 "ENSG00000172146",
                 "ENST00000304094",
                 "ENSE00001137815",
                 "KNOWN_protein_coding"
               ],
               [ "17",
                 "Vega",
                 "Gene",
                 "3065665",
                 "3066594",
                 ".",
                 "+",
                 "1",
                 "OTTHUMG00000090637",
                 "OTTHUMT00000207292",
                 "OTTHUME00001080001",
                 "KNOWN_protein_coding"
               ]
             ]
     line = lines.collect { |x| x.join("\t") + "\n" }.join('')
     gff = @serv.exportview(:seq_region_name => 17,
                            :anchor1 => 3065665,
                            :anchor2 => 3066594, 
                            :options => ['gene'],
                            :format => 'tab')
     assert_equal(line, gff)
   end 


end

end # module Bio
