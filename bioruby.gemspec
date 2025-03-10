# This file is automatically generated from bioruby.gemspec.erb and
# should NOT be edited by hand.
# 
Gem::Specification.new do |s|
  s.name = 'bio'
  s.version = "2.0.6"

  s.author = "BioRuby project"
  s.email = "staff@bioruby.org"
  s.homepage = "http://bioruby.org/"
  s.license = "Ruby"

  s.summary = "Bioinformatics library"
  s.description = "BioRuby is a library for bioinformatics (biology + information science)."

  s.platform = Gem::Platform::RUBY
  s.files = [
    ".github/workflows/ruby.yml",
    ".gitignore",
    "BSDL",
    "COPYING",
    "COPYING.ja",
    "ChangeLog",
    "GPL",
    "Gemfile",
    "KNOWN_ISSUES.rdoc",
    "LEGAL",
    "LGPL",
    "README.rdoc",
    "README_DEV.rdoc",
    "RELEASE_NOTES.rdoc",
    "Rakefile",
    "appveyor.yml",
    "bioruby.gemspec",
    "bioruby.gemspec.erb",
    "doc/ChangeLog-1.4.3",
    "doc/ChangeLog-1.5.0",
    "doc/ChangeLog-before-1.3.1",
    "doc/ChangeLog-before-1.4.2",
    "doc/Changes-0.7.rd",
    "doc/Changes-1.3.rdoc",
    "doc/RELEASE_NOTES-1.4.0.rdoc",
    "doc/RELEASE_NOTES-1.4.1.rdoc",
    "doc/RELEASE_NOTES-1.4.2.rdoc",
    "doc/RELEASE_NOTES-1.4.3.rdoc",
    "doc/RELEASE_NOTES-1.5.0.rdoc",
    "doc/Tutorial.md",
    "doc/Tutorial.rd",
    "doc/Tutorial.rd.html",
    "doc/Tutorial.rd.ja",
    "doc/Tutorial.rd.ja.html",
    "doc/Tutorial_ja.md",
    "doc/bioruby.css",
    "etc/bioinformatics/seqdatabase.ini",
    "lib/bio.rb",
    "lib/bio/alignment.rb",
    "lib/bio/appl/bl2seq/report.rb",
    "lib/bio/appl/blast.rb",
    "lib/bio/appl/blast/format0.rb",
    "lib/bio/appl/blast/format8.rb",
    "lib/bio/appl/blast/genomenet.rb",
    "lib/bio/appl/blast/ncbioptions.rb",
    "lib/bio/appl/blast/remote.rb",
    "lib/bio/appl/blast/report.rb",
    "lib/bio/appl/blast/rexml.rb",
    "lib/bio/appl/blast/rpsblast.rb",
    "lib/bio/appl/blast/wublast.rb",
    "lib/bio/appl/blat/report.rb",
    "lib/bio/appl/clustalw.rb",
    "lib/bio/appl/clustalw/report.rb",
    "lib/bio/appl/emboss.rb",
    "lib/bio/appl/fasta.rb",
    "lib/bio/appl/fasta/format10.rb",
    "lib/bio/appl/gcg/msf.rb",
    "lib/bio/appl/gcg/seq.rb",
    "lib/bio/appl/genscan/report.rb",
    "lib/bio/appl/hmmer.rb",
    "lib/bio/appl/hmmer/report.rb",
    "lib/bio/appl/iprscan/report.rb",
    "lib/bio/appl/mafft.rb",
    "lib/bio/appl/mafft/report.rb",
    "lib/bio/appl/meme/mast.rb",
    "lib/bio/appl/meme/mast/report.rb",
    "lib/bio/appl/meme/motif.rb",
    "lib/bio/appl/muscle.rb",
    "lib/bio/appl/paml/baseml.rb",
    "lib/bio/appl/paml/baseml/report.rb",
    "lib/bio/appl/paml/codeml.rb",
    "lib/bio/appl/paml/codeml/rates.rb",
    "lib/bio/appl/paml/codeml/report.rb",
    "lib/bio/appl/paml/common.rb",
    "lib/bio/appl/paml/common_report.rb",
    "lib/bio/appl/paml/yn00.rb",
    "lib/bio/appl/paml/yn00/report.rb",
    "lib/bio/appl/phylip/alignment.rb",
    "lib/bio/appl/phylip/distance_matrix.rb",
    "lib/bio/appl/probcons.rb",
    "lib/bio/appl/psort.rb",
    "lib/bio/appl/psort/report.rb",
    "lib/bio/appl/pts1.rb",
    "lib/bio/appl/sim4.rb",
    "lib/bio/appl/sim4/report.rb",
    "lib/bio/appl/sosui/report.rb",
    "lib/bio/appl/spidey/report.rb",
    "lib/bio/appl/targetp/report.rb",
    "lib/bio/appl/tcoffee.rb",
    "lib/bio/appl/tmhmm/report.rb",
    "lib/bio/command.rb",
    "lib/bio/compat/features.rb",
    "lib/bio/compat/references.rb",
    "lib/bio/data/aa.rb",
    "lib/bio/data/codontable.rb",
    "lib/bio/data/na.rb",
    "lib/bio/db.rb",
    "lib/bio/db/aaindex.rb",
    "lib/bio/db/embl/common.rb",
    "lib/bio/db/embl/embl.rb",
    "lib/bio/db/embl/embl_to_biosequence.rb",
    "lib/bio/db/embl/format_embl.rb",
    "lib/bio/db/embl/sptr.rb",
    "lib/bio/db/embl/swissprot.rb",
    "lib/bio/db/embl/trembl.rb",
    "lib/bio/db/embl/uniprot.rb",
    "lib/bio/db/embl/uniprotkb.rb",
    "lib/bio/db/fantom.rb",
    "lib/bio/db/fasta.rb",
    "lib/bio/db/fasta/defline.rb",
    "lib/bio/db/fasta/fasta_to_biosequence.rb",
    "lib/bio/db/fasta/format_fasta.rb",
    "lib/bio/db/fasta/format_qual.rb",
    "lib/bio/db/fasta/qual.rb",
    "lib/bio/db/fasta/qual_to_biosequence.rb",
    "lib/bio/db/fastq.rb",
    "lib/bio/db/fastq/fastq_to_biosequence.rb",
    "lib/bio/db/fastq/format_fastq.rb",
    "lib/bio/db/genbank/common.rb",
    "lib/bio/db/genbank/ddbj.rb",
    "lib/bio/db/genbank/format_genbank.rb",
    "lib/bio/db/genbank/genbank.rb",
    "lib/bio/db/genbank/genbank_to_biosequence.rb",
    "lib/bio/db/genbank/genpept.rb",
    "lib/bio/db/genbank/refseq.rb",
    "lib/bio/db/gff.rb",
    "lib/bio/db/go.rb",
    "lib/bio/db/kegg/brite.rb",
    "lib/bio/db/kegg/common.rb",
    "lib/bio/db/kegg/compound.rb",
    "lib/bio/db/kegg/drug.rb",
    "lib/bio/db/kegg/enzyme.rb",
    "lib/bio/db/kegg/expression.rb",
    "lib/bio/db/kegg/genes.rb",
    "lib/bio/db/kegg/genome.rb",
    "lib/bio/db/kegg/glycan.rb",
    "lib/bio/db/kegg/keggtab.rb",
    "lib/bio/db/kegg/kgml.rb",
    "lib/bio/db/kegg/module.rb",
    "lib/bio/db/kegg/orthology.rb",
    "lib/bio/db/kegg/pathway.rb",
    "lib/bio/db/kegg/reaction.rb",
    "lib/bio/db/lasergene.rb",
    "lib/bio/db/litdb.rb",
    "lib/bio/db/medline.rb",
    "lib/bio/db/nbrf.rb",
    "lib/bio/db/newick.rb",
    "lib/bio/db/nexus.rb",
    "lib/bio/db/pdb.rb",
    "lib/bio/db/pdb/atom.rb",
    "lib/bio/db/pdb/chain.rb",
    "lib/bio/db/pdb/chemicalcomponent.rb",
    "lib/bio/db/pdb/model.rb",
    "lib/bio/db/pdb/pdb.rb",
    "lib/bio/db/pdb/residue.rb",
    "lib/bio/db/pdb/utils.rb",
    "lib/bio/db/prosite.rb",
    "lib/bio/db/rebase.rb",
    "lib/bio/db/sanger_chromatogram/abif.rb",
    "lib/bio/db/sanger_chromatogram/chromatogram.rb",
    "lib/bio/db/sanger_chromatogram/chromatogram_to_biosequence.rb",
    "lib/bio/db/sanger_chromatogram/scf.rb",
    "lib/bio/db/soft.rb",
    "lib/bio/db/transfac.rb",
    "lib/bio/feature.rb",
    "lib/bio/io/das.rb",
    "lib/bio/io/fastacmd.rb",
    "lib/bio/io/fetch.rb",
    "lib/bio/io/flatfile.rb",
    "lib/bio/io/flatfile/autodetection.rb",
    "lib/bio/io/flatfile/bdb.rb",
    "lib/bio/io/flatfile/buffer.rb",
    "lib/bio/io/flatfile/index.rb",
    "lib/bio/io/flatfile/indexer.rb",
    "lib/bio/io/flatfile/splitter.rb",
    "lib/bio/io/hinv.rb",
    "lib/bio/io/ncbirest.rb",
    "lib/bio/io/pubmed.rb",
    "lib/bio/io/registry.rb",
    "lib/bio/io/togows.rb",
    "lib/bio/location.rb",
    "lib/bio/map.rb",
    "lib/bio/pathway.rb",
    "lib/bio/reference.rb",
    "lib/bio/sequence.rb",
    "lib/bio/sequence/aa.rb",
    "lib/bio/sequence/adapter.rb",
    "lib/bio/sequence/common.rb",
    "lib/bio/sequence/compat.rb",
    "lib/bio/sequence/dblink.rb",
    "lib/bio/sequence/format.rb",
    "lib/bio/sequence/format_raw.rb",
    "lib/bio/sequence/generic.rb",
    "lib/bio/sequence/na.rb",
    "lib/bio/sequence/quality_score.rb",
    "lib/bio/sequence/sequence_masker.rb",
    "lib/bio/tree.rb",
    "lib/bio/tree/output.rb",
    "lib/bio/util/color_scheme.rb",
    "lib/bio/util/color_scheme/buried.rb",
    "lib/bio/util/color_scheme/helix.rb",
    "lib/bio/util/color_scheme/hydropathy.rb",
    "lib/bio/util/color_scheme/nucleotide.rb",
    "lib/bio/util/color_scheme/strand.rb",
    "lib/bio/util/color_scheme/taylor.rb",
    "lib/bio/util/color_scheme/turn.rb",
    "lib/bio/util/color_scheme/zappo.rb",
    "lib/bio/util/contingency_table.rb",
    "lib/bio/util/restriction_enzyme.rb",
    "lib/bio/util/restriction_enzyme/analysis.rb",
    "lib/bio/util/restriction_enzyme/analysis_basic.rb",
    "lib/bio/util/restriction_enzyme/cut_symbol.rb",
    "lib/bio/util/restriction_enzyme/dense_int_array.rb",
    "lib/bio/util/restriction_enzyme/double_stranded.rb",
    "lib/bio/util/restriction_enzyme/double_stranded/aligned_strands.rb",
    "lib/bio/util/restriction_enzyme/double_stranded/cut_location_pair.rb",
    "lib/bio/util/restriction_enzyme/double_stranded/cut_location_pair_in_enzyme_notation.rb",
    "lib/bio/util/restriction_enzyme/double_stranded/cut_locations.rb",
    "lib/bio/util/restriction_enzyme/double_stranded/cut_locations_in_enzyme_notation.rb",
    "lib/bio/util/restriction_enzyme/enzymes.yaml",
    "lib/bio/util/restriction_enzyme/range/cut_range.rb",
    "lib/bio/util/restriction_enzyme/range/cut_ranges.rb",
    "lib/bio/util/restriction_enzyme/range/horizontal_cut_range.rb",
    "lib/bio/util/restriction_enzyme/range/sequence_range.rb",
    "lib/bio/util/restriction_enzyme/range/sequence_range/calculated_cuts.rb",
    "lib/bio/util/restriction_enzyme/range/sequence_range/fragment.rb",
    "lib/bio/util/restriction_enzyme/range/sequence_range/fragments.rb",
    "lib/bio/util/restriction_enzyme/range/vertical_cut_range.rb",
    "lib/bio/util/restriction_enzyme/single_strand.rb",
    "lib/bio/util/restriction_enzyme/single_strand/cut_locations_in_enzyme_notation.rb",
    "lib/bio/util/restriction_enzyme/single_strand_complement.rb",
    "lib/bio/util/restriction_enzyme/sorted_num_array.rb",
    "lib/bio/util/restriction_enzyme/string_formatting.rb",
    "lib/bio/util/sirna.rb",
    "lib/bio/version.rb",
    "sample/any2fasta.rb",
    "sample/benchmark_clustalw_report.rb",
    "sample/biofetch.rb",
    "sample/color_scheme_aa.rb",
    "sample/color_scheme_na.rb",
    "sample/demo_aaindex.rb",
    "sample/demo_aminoacid.rb",
    "sample/demo_bl2seq_report.rb",
    "sample/demo_blast_report.rb",
    "sample/demo_codontable.rb",
    "sample/demo_das.rb",
    "sample/demo_fasta_remote.rb",
    "sample/demo_fastaformat.rb",
    "sample/demo_genbank.rb",
    "sample/demo_genscan_report.rb",
    "sample/demo_gff1.rb",
    "sample/demo_go.rb",
    "sample/demo_hmmer_report.rb",
    "sample/demo_kegg_compound.rb",
    "sample/demo_kegg_drug.rb",
    "sample/demo_kegg_genome.rb",
    "sample/demo_kegg_glycan.rb",
    "sample/demo_kegg_orthology.rb",
    "sample/demo_kegg_reaction.rb",
    "sample/demo_litdb.rb",
    "sample/demo_locations.rb",
    "sample/demo_ncbi_rest.rb",
    "sample/demo_nucleicacid.rb",
    "sample/demo_pathway.rb",
    "sample/demo_prosite.rb",
    "sample/demo_psort.rb",
    "sample/demo_psort_report.rb",
    "sample/demo_pubmed.rb",
    "sample/demo_sequence.rb",
    "sample/demo_sirna.rb",
    "sample/demo_sosui_report.rb",
    "sample/demo_targetp_report.rb",
    "sample/demo_tmhmm_report.rb",
    "sample/enzymes.rb",
    "sample/fasta2tab.rb",
    "sample/fastagrep.rb",
    "sample/fastasort.rb",
    "sample/fastq2html.cwl",
    "sample/fastq2html.rb",
    "sample/fastq2html.testdata.yaml",
    "sample/fsplit.rb",
    "sample/gb2fasta.rb",
    "sample/gb2tab.rb",
    "sample/gbtab2mysql.rb",
    "sample/genes2nuc.rb",
    "sample/genes2pep.rb",
    "sample/genes2tab.rb",
    "sample/genome2rb.rb",
    "sample/genome2tab.rb",
    "sample/goslim.rb",
    "sample/gt2fasta.rb",
    "sample/na2aa.cwl",
    "sample/na2aa.rb",
    "sample/na2aa.testdata.yaml",
    "sample/pmfetch.rb",
    "sample/pmsearch.rb",
    "sample/rev_comp.cwl",
    "sample/rev_comp.rb",
    "sample/rev_comp.testdata.yaml",
    "sample/seqdatabase.ini",
    "sample/ssearch2tab.rb",
    "sample/tdiary.rb",
    "sample/test_restriction_enzyme_long.rb",
    "sample/tfastx2tab.rb",
    "sample/vs-genes.rb",
    "test/bioruby_test_helper.rb",
    "test/data/HMMER/hmmpfam.out",
    "test/data/HMMER/hmmsearch.out",
    "test/data/KEGG/1.1.1.1.enzyme",
    "test/data/KEGG/C00025.compound",
    "test/data/KEGG/D00063.drug",
    "test/data/KEGG/G00024.glycan",
    "test/data/KEGG/G01366.glycan",
    "test/data/KEGG/K02338.orthology",
    "test/data/KEGG/M00118.module",
    "test/data/KEGG/R00006.reaction",
    "test/data/KEGG/T00005.genome",
    "test/data/KEGG/T00070.genome",
    "test/data/KEGG/b0529.gene",
    "test/data/KEGG/ec00072.pathway",
    "test/data/KEGG/hsa00790.pathway",
    "test/data/KEGG/ko00312.pathway",
    "test/data/KEGG/map00030.pathway",
    "test/data/KEGG/map00052.pathway",
    "test/data/KEGG/rn00250.pathway",
    "test/data/KEGG/test.kgml",
    "test/data/SOSUI/sample.report",
    "test/data/TMHMM/sample.report",
    "test/data/aaindex/DAYM780301",
    "test/data/aaindex/PRAM900102",
    "test/data/bl2seq/cd8a_cd8b_blastp.bl2seq",
    "test/data/bl2seq/cd8a_p53_e-5blastp.bl2seq",
    "test/data/blast/2.2.15.blastp.m7",
    "test/data/blast/b0002.faa",
    "test/data/blast/b0002.faa.m0",
    "test/data/blast/b0002.faa.m7",
    "test/data/blast/b0002.faa.m8",
    "test/data/blast/blastp-multi.m7",
    "test/data/clustalw/example1-seqnos.aln",
    "test/data/clustalw/example1.aln",
    "test/data/command/echoarg2.bat",
    "test/data/command/echoarg2.sh",
    "test/data/embl/AB090716.embl",
    "test/data/embl/AB090716.embl.rel89",
    "test/data/fasta/EFTU_BACSU.fasta",
    "test/data/fasta/example1.txt",
    "test/data/fasta/example2.txt",
    "test/data/fastq/README.txt",
    "test/data/fastq/error_diff_ids.fastq",
    "test/data/fastq/error_double_qual.fastq",
    "test/data/fastq/error_double_seq.fastq",
    "test/data/fastq/error_long_qual.fastq",
    "test/data/fastq/error_no_qual.fastq",
    "test/data/fastq/error_qual_del.fastq",
    "test/data/fastq/error_qual_escape.fastq",
    "test/data/fastq/error_qual_null.fastq",
    "test/data/fastq/error_qual_space.fastq",
    "test/data/fastq/error_qual_tab.fastq",
    "test/data/fastq/error_qual_unit_sep.fastq",
    "test/data/fastq/error_qual_vtab.fastq",
    "test/data/fastq/error_short_qual.fastq",
    "test/data/fastq/error_spaces.fastq",
    "test/data/fastq/error_tabs.fastq",
    "test/data/fastq/error_trunc_at_plus.fastq",
    "test/data/fastq/error_trunc_at_qual.fastq",
    "test/data/fastq/error_trunc_at_seq.fastq",
    "test/data/fastq/error_trunc_in_plus.fastq",
    "test/data/fastq/error_trunc_in_qual.fastq",
    "test/data/fastq/error_trunc_in_seq.fastq",
    "test/data/fastq/error_trunc_in_title.fastq",
    "test/data/fastq/illumina_full_range_as_illumina.fastq",
    "test/data/fastq/illumina_full_range_as_sanger.fastq",
    "test/data/fastq/illumina_full_range_as_solexa.fastq",
    "test/data/fastq/illumina_full_range_original_illumina.fastq",
    "test/data/fastq/longreads_as_illumina.fastq",
    "test/data/fastq/longreads_as_sanger.fastq",
    "test/data/fastq/longreads_as_solexa.fastq",
    "test/data/fastq/longreads_original_sanger.fastq",
    "test/data/fastq/misc_dna_as_illumina.fastq",
    "test/data/fastq/misc_dna_as_sanger.fastq",
    "test/data/fastq/misc_dna_as_solexa.fastq",
    "test/data/fastq/misc_dna_original_sanger.fastq",
    "test/data/fastq/misc_rna_as_illumina.fastq",
    "test/data/fastq/misc_rna_as_sanger.fastq",
    "test/data/fastq/misc_rna_as_solexa.fastq",
    "test/data/fastq/misc_rna_original_sanger.fastq",
    "test/data/fastq/sanger_full_range_as_illumina.fastq",
    "test/data/fastq/sanger_full_range_as_sanger.fastq",
    "test/data/fastq/sanger_full_range_as_solexa.fastq",
    "test/data/fastq/sanger_full_range_original_sanger.fastq",
    "test/data/fastq/solexa_full_range_as_illumina.fastq",
    "test/data/fastq/solexa_full_range_as_sanger.fastq",
    "test/data/fastq/solexa_full_range_as_solexa.fastq",
    "test/data/fastq/solexa_full_range_original_solexa.fastq",
    "test/data/fastq/wrapping_as_illumina.fastq",
    "test/data/fastq/wrapping_as_sanger.fastq",
    "test/data/fastq/wrapping_as_solexa.fastq",
    "test/data/fastq/wrapping_original_sanger.fastq",
    "test/data/gcg/pileup-aa.msf",
    "test/data/genbank/CAA35997.gp",
    "test/data/genbank/SCU49845.gb",
    "test/data/genscan/sample.report",
    "test/data/go/selected_component.ontology",
    "test/data/go/selected_gene_association.sgd",
    "test/data/go/selected_wikipedia2go",
    "test/data/iprscan/merged.raw",
    "test/data/iprscan/merged.txt",
    "test/data/litdb/1717226.litdb",
    "test/data/medline/20146148_modified.medline",
    "test/data/meme/db",
    "test/data/meme/mast",
    "test/data/meme/mast.out",
    "test/data/meme/meme.out",
    "test/data/paml/codeml/control_file.txt",
    "test/data/paml/codeml/models/aa.aln",
    "test/data/paml/codeml/models/aa.dnd",
    "test/data/paml/codeml/models/aa.ph",
    "test/data/paml/codeml/models/alignment.phy",
    "test/data/paml/codeml/models/results0-3.txt",
    "test/data/paml/codeml/models/results7-8.txt",
    "test/data/paml/codeml/output.txt",
    "test/data/paml/codeml/rates",
    "test/data/pir/CRAB_ANAPL.pir",
    "test/data/prosite/prosite.dat",
    "test/data/refseq/nm_126355.entret",
    "test/data/rpsblast/misc.rpsblast",
    "test/data/sanger_chromatogram/test_chromatogram_abif.ab1",
    "test/data/sanger_chromatogram/test_chromatogram_scf_v2.scf",
    "test/data/sanger_chromatogram/test_chromatogram_scf_v3.scf",
    "test/data/sim4/complement-A4.sim4",
    "test/data/sim4/simple-A4.sim4",
    "test/data/sim4/simple2-A4.sim4",
    "test/data/soft/GDS100_partial.soft",
    "test/data/soft/GSE3457_family_partial.soft",
    "test/data/uniprot/P03589.uniprot",
    "test/data/uniprot/P28907.uniprot",
    "test/data/uniprot/P49144.uniprot",
    "test/data/uniprot/p53_human.uniprot",
    "test/functional/bio/sequence/test_output_embl.rb",
    "test/functional/bio/test_command.rb",
    "test/network/bio/appl/blast/test_remote.rb",
    "test/network/bio/appl/test_blast.rb",
    "test/network/bio/appl/test_pts1.rb",
    "test/network/bio/db/kegg/test_genes_hsa7422.rb",
    "test/network/bio/io/test_pubmed.rb",
    "test/network/bio/io/test_togows.rb",
    "test/network/bio/test_command.rb",
    "test/runner.rb",
    "test/unit/bio/appl/bl2seq/test_report.rb",
    "test/unit/bio/appl/blast/test_ncbioptions.rb",
    "test/unit/bio/appl/blast/test_report.rb",
    "test/unit/bio/appl/blast/test_rpsblast.rb",
    "test/unit/bio/appl/clustalw/test_report.rb",
    "test/unit/bio/appl/gcg/test_msf.rb",
    "test/unit/bio/appl/genscan/test_report.rb",
    "test/unit/bio/appl/hmmer/test_report.rb",
    "test/unit/bio/appl/iprscan/test_report.rb",
    "test/unit/bio/appl/mafft/test_report.rb",
    "test/unit/bio/appl/meme/mast/test_report.rb",
    "test/unit/bio/appl/meme/test_mast.rb",
    "test/unit/bio/appl/meme/test_motif.rb",
    "test/unit/bio/appl/paml/codeml/test_rates.rb",
    "test/unit/bio/appl/paml/codeml/test_report.rb",
    "test/unit/bio/appl/paml/codeml/test_report_single.rb",
    "test/unit/bio/appl/paml/test_codeml.rb",
    "test/unit/bio/appl/sim4/test_report.rb",
    "test/unit/bio/appl/sosui/test_report.rb",
    "test/unit/bio/appl/targetp/test_report.rb",
    "test/unit/bio/appl/test_blast.rb",
    "test/unit/bio/appl/test_fasta.rb",
    "test/unit/bio/appl/test_pts1.rb",
    "test/unit/bio/appl/tmhmm/test_report.rb",
    "test/unit/bio/data/test_aa.rb",
    "test/unit/bio/data/test_codontable.rb",
    "test/unit/bio/data/test_na.rb",
    "test/unit/bio/db/embl/test_common.rb",
    "test/unit/bio/db/embl/test_embl.rb",
    "test/unit/bio/db/embl/test_embl_rel89.rb",
    "test/unit/bio/db/embl/test_embl_to_bioseq.rb",
    "test/unit/bio/db/embl/test_uniprot.rb",
    "test/unit/bio/db/embl/test_uniprotkb.rb",
    "test/unit/bio/db/embl/test_uniprotkb_P03589.rb",
    "test/unit/bio/db/embl/test_uniprotkb_P28907.rb",
    "test/unit/bio/db/embl/test_uniprotkb_P49144.rb",
    "test/unit/bio/db/embl/test_uniprotkb_new_part.rb",
    "test/unit/bio/db/fasta/test_defline.rb",
    "test/unit/bio/db/fasta/test_defline_misc.rb",
    "test/unit/bio/db/fasta/test_format_qual.rb",
    "test/unit/bio/db/genbank/test_common.rb",
    "test/unit/bio/db/genbank/test_genbank.rb",
    "test/unit/bio/db/genbank/test_genpept.rb",
    "test/unit/bio/db/kegg/test_compound.rb",
    "test/unit/bio/db/kegg/test_drug.rb",
    "test/unit/bio/db/kegg/test_enzyme.rb",
    "test/unit/bio/db/kegg/test_genes.rb",
    "test/unit/bio/db/kegg/test_genome.rb",
    "test/unit/bio/db/kegg/test_glycan.rb",
    "test/unit/bio/db/kegg/test_kgml.rb",
    "test/unit/bio/db/kegg/test_module.rb",
    "test/unit/bio/db/kegg/test_orthology.rb",
    "test/unit/bio/db/kegg/test_pathway.rb",
    "test/unit/bio/db/kegg/test_reaction.rb",
    "test/unit/bio/db/pdb/test_pdb.rb",
    "test/unit/bio/db/sanger_chromatogram/test_abif.rb",
    "test/unit/bio/db/sanger_chromatogram/test_scf.rb",
    "test/unit/bio/db/test_aaindex.rb",
    "test/unit/bio/db/test_fasta.rb",
    "test/unit/bio/db/test_fastq.rb",
    "test/unit/bio/db/test_gff.rb",
    "test/unit/bio/db/test_go.rb",
    "test/unit/bio/db/test_lasergene.rb",
    "test/unit/bio/db/test_litdb.rb",
    "test/unit/bio/db/test_medline.rb",
    "test/unit/bio/db/test_nbrf.rb",
    "test/unit/bio/db/test_newick.rb",
    "test/unit/bio/db/test_nexus.rb",
    "test/unit/bio/db/test_prosite.rb",
    "test/unit/bio/db/test_qual.rb",
    "test/unit/bio/db/test_rebase.rb",
    "test/unit/bio/db/test_soft.rb",
    "test/unit/bio/io/flatfile/test_autodetection.rb",
    "test/unit/bio/io/flatfile/test_buffer.rb",
    "test/unit/bio/io/flatfile/test_splitter.rb",
    "test/unit/bio/io/test_fastacmd.rb",
    "test/unit/bio/io/test_flatfile.rb",
    "test/unit/bio/io/test_togows.rb",
    "test/unit/bio/sequence/test_aa.rb",
    "test/unit/bio/sequence/test_common.rb",
    "test/unit/bio/sequence/test_compat.rb",
    "test/unit/bio/sequence/test_dblink.rb",
    "test/unit/bio/sequence/test_na.rb",
    "test/unit/bio/sequence/test_quality_score.rb",
    "test/unit/bio/sequence/test_ruby3.rb",
    "test/unit/bio/sequence/test_sequence_masker.rb",
    "test/unit/bio/test_alignment.rb",
    "test/unit/bio/test_command.rb",
    "test/unit/bio/test_db.rb",
    "test/unit/bio/test_feature.rb",
    "test/unit/bio/test_location.rb",
    "test/unit/bio/test_map.rb",
    "test/unit/bio/test_pathway.rb",
    "test/unit/bio/test_reference.rb",
    "test/unit/bio/test_sequence.rb",
    "test/unit/bio/test_tree.rb",
    "test/unit/bio/util/restriction_enzyme/analysis/test_calculated_cuts.rb",
    "test/unit/bio/util/restriction_enzyme/analysis/test_cut_ranges.rb",
    "test/unit/bio/util/restriction_enzyme/analysis/test_sequence_range.rb",
    "test/unit/bio/util/restriction_enzyme/double_stranded/test_aligned_strands.rb",
    "test/unit/bio/util/restriction_enzyme/double_stranded/test_cut_location_pair.rb",
    "test/unit/bio/util/restriction_enzyme/double_stranded/test_cut_location_pair_in_enzyme_notation.rb",
    "test/unit/bio/util/restriction_enzyme/double_stranded/test_cut_locations.rb",
    "test/unit/bio/util/restriction_enzyme/double_stranded/test_cut_locations_in_enzyme_notation.rb",
    "test/unit/bio/util/restriction_enzyme/single_strand/test_cut_locations_in_enzyme_notation.rb",
    "test/unit/bio/util/restriction_enzyme/test_analysis.rb",
    "test/unit/bio/util/restriction_enzyme/test_cut_symbol.rb",
    "test/unit/bio/util/restriction_enzyme/test_dense_int_array.rb",
    "test/unit/bio/util/restriction_enzyme/test_double_stranded.rb",
    "test/unit/bio/util/restriction_enzyme/test_single_strand.rb",
    "test/unit/bio/util/restriction_enzyme/test_single_strand_complement.rb",
    "test/unit/bio/util/restriction_enzyme/test_sorted_num_array.rb",
    "test/unit/bio/util/restriction_enzyme/test_string_formatting.rb",
    "test/unit/bio/util/test_color_scheme.rb",
    "test/unit/bio/util/test_contingency_table.rb",
    "test/unit/bio/util/test_restriction_enzyme.rb",
    "test/unit/bio/util/test_sirna.rb"
  ]

  s.extra_rdoc_files = [ 
    "KNOWN_ISSUES.rdoc",
    "README.rdoc",
    "README_DEV.rdoc",
    "RELEASE_NOTES.rdoc",
    "doc/Changes-1.3.rdoc",
    "doc/RELEASE_NOTES-1.4.0.rdoc",
    "doc/RELEASE_NOTES-1.4.1.rdoc",
    "doc/RELEASE_NOTES-1.4.2.rdoc",
    "doc/RELEASE_NOTES-1.4.3.rdoc",
    "doc/RELEASE_NOTES-1.5.0.rdoc"
  ]
  s.rdoc_options << '--main' << 'README.rdoc'
  s.rdoc_options << '--title' << 'BioRuby API documentation'
  s.rdoc_options << '--exclude' << '\.yaml\z'
  s.rdoc_options << '--line-numbers' << '--inline-source'

  s.require_path = 'lib'
end
