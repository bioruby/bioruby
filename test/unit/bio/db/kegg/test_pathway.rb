#
# test/unit/bio/db/kegg/test_pathway.rb - Unit test for Bio::KEGG::PATHWAY
#
# Copyright::  Copyright (C) 2010 Kozo Nishida <kozo-ni@is.naist.jp>
#              Copyright (C) 2010 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/kegg/pathway'

module Bio
  class TestKeggPathway_map00052 < Test::Unit::TestCase

    def setup
      testdata_kegg = Pathname.new(File.join(BioRubyTestDataPath, 'KEGG')).cleanpath.to_s
      entry = File.read(File.join(testdata_kegg, "map00052.pathway"))
      @obj = Bio::KEGG::PATHWAY.new(entry)
    end

    def test_entry_id
      assert_equal('map00052', @obj.entry_id)
    end

    def test_name
      assert_equal('Galactose metabolism', @obj.name)
    end

    def test_keggclass
      assert_equal('Metabolism; Carbohydrate Metabolism', @obj.keggclass)
    end

    def test_modules_as_hash
      expected = {
        "M00097"=>"UDP-glucose and UDP-galactose biosynthesis, Glc-1P/Gal-1P => UDP-Glc/UDP-Gal",
        "M00614"=>"PTS system, N-acetylgalactosamine-specific II component",
        "M00616"=>"PTS system, galactitol-specific II component",
        "M00618"=>"PTS system, lactose-specific II component",
        "M00624"=>"PTS system, galactosamine-specific II component"
      }
      assert_equal(expected, @obj.modules_as_hash)
      assert_equal(expected, @obj.modules)
    end

    def test_modules_as_strings
      expected =
        [ "M00097  UDP-glucose and UDP-galactose biosynthesis, Glc-1P/Gal-1P => UDP-Glc/UDP-Gal",
          "M00614  PTS system, N-acetylgalactosamine-specific II component",
          "M00616  PTS system, galactitol-specific II component",
          "M00618  PTS system, lactose-specific II component",
          "M00624  PTS system, galactosamine-specific II component"
        ]
      assert_equal(expected, @obj.modules_as_strings)
    end

    def test_rel_pathways_as_strings
      expected = [ "map00010  Glycolysis / Gluconeogenesis",
                   "map00040  Pentose and glucuronate interconversions",
                   "map00051  Fructose and mannose metabolism",
                   "map00520  Amino sugar and nucleotide sugar metabolism"
                 ]
      assert_equal(expected, @obj.rel_pathways_as_strings)
    end

    def test_rel_pathways_as_hash
      expected = {
        "map00010"=>"Glycolysis / Gluconeogenesis",
        "map00040"=>"Pentose and glucuronate interconversions",
        "map00051"=>"Fructose and mannose metabolism",
        "map00520"=>"Amino sugar and nucleotide sugar metabolism"
      }
      assert_equal(expected, @obj.rel_pathways_as_hash)
      assert_equal(expected, @obj.rel_pathways)
    end

    def test_references
      assert_equal([], @obj.references)
    end

    def test_dblinks_as_strings
      assert_equal([], @obj.dblinks_as_strings)
    end

    def test_dblinks_as_hash
      assert_equal({}, @obj.dblinks_as_hash)
    end

    def test_pathways_as_strings
      expected = ["map00052  Galactose metabolism"]
      assert_equal(expected, @obj.pathways_as_strings)
    end

    def test_pathways_as_hash
      expected = {"map00052"=>"Galactose metabolism"}
      assert_equal(expected, @obj.pathways_as_hash)
    end

    def test_orthologs_as_strings
      assert_equal([], @obj.orthologs_as_strings)
    end

    def test_orthologs_as_hash
      assert_equal({}, @obj.orthologs_as_hash)
    end

    def test_genes_as_strings
      assert_equal([], @obj.genes_as_strings)
    end

    def test_genes_as_hash
      assert_equal({}, @obj.genes_as_hash)
    end

    def test_diseases_as_strings
      assert_equal([], @obj.diseases_as_strings)
    end

    def test_diseases_as_hash
      assert_equal({}, @obj.diseases_as_hash)
    end

    def test_enzymes_as_strings
      assert_equal([], @obj.enzymes_as_strings)
    end

    def test_reactions_as_strings
      assert_equal([], @obj.reactions_as_strings)
    end

    def test_reactions_as_hash
      assert_equal({}, @obj.reactions_as_hash)
    end

    def test_compounds_as_strings
      assert_equal([], @obj.compounds_as_strings)
    end

    def test_compounds_as_hash
      assert_equal({}, @obj.compounds_as_hash)
    end

    def test_description
      assert_equal("", @obj.description)
    end

    def test_organism
      assert_equal("", @obj.organism)
    end

    def test_ko_pathway
      assert_equal("", @obj.ko_pathway)
    end

  end #class TestKeggPathway_map00052

  class TestBioKEGGPATHWAY_map00030 < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'KEGG/map00030.pathway')
      @obj = Bio::KEGG::PATHWAY.new(File.read(filename))
    end

    def test_references
      data =
        [ { "authors"  => [ "Nishizuka Y (ed)." ],
            "comments" => [ "(map 3)" ],
            "journal"  => "Tokyo Kagaku Dojin",
            "title"    => "[Metabolic Maps] (In Japanese)",
            "year"     => "1980"
          },
          { "authors"  => [ "Nishizuka Y", "Seyama Y", "Ikai A",
                            "Ishimura Y", "Kawaguchi A (eds)." ],
            "comments" => [ "(map 4)" ],
            "journal"  => "Tokyo Kagaku Dojin",
            "title"=>"[Cellular Functions and Metabolic Maps] (In Japanese)",
            "year"     => "1997"
          },
          { "authors" => [ "Michal G." ],
            "journal" => "Wiley",
            "title"   => "Biochemical Pathways",
            "year"    => "1999"
          },
          { "authors" => [ "Hove-Jensen B", "Rosenkrantz TJ",
                           "Haldimann A", "Wanner BL." ],
            "journal" => "J Bacteriol",
            "pages"   => "2793-801",
            "pubmed"  => "12700258",
            "title"   => "Escherichia coli phnN, encoding ribose 1,5-bisphosphokinase activity (phosphoribosyl diphosphate forming): dual role in phosphonate degradation and NAD biosynthesis pathways.",
            "volume"  => "185",
            "year"    => "2003"
          }
        ]
      expected = data.collect { |h| Bio::Reference.new(h) }
      assert_equal(expected, @obj.references)
    end

    def test_new
      assert_instance_of(Bio::KEGG::PATHWAY, @obj)
    end

    def test_entry_id
      assert_equal("map00030", @obj.entry_id)
    end

    def test_name
      assert_equal("Pentose phosphate pathway", @obj.name)
    end

    def test_description
      expected = "The pentose phosphate pathway is a process of glucose turnover that produces NADPH as reducing equivalents and pentoses as essential parts of nucleotides. There are two different phases in the pathway. One is irreversible oxidative phase in which glucose-6P is converted to ribulose-5P by oxidative decarboxylation, and NADPH is generated [MD:M00006]. The other is reversible non-oxidative phase in which phosphorylated sugars are interconverted to generate xylulose-5P, ribulose-5P, and ribose-5P [MD:M00007]. Phosphoribosyl pyrophosphate (PRPP) formed from ribose-5P [MD:M00005] is an activated compound used in the biosynthesis of histidine and purine/pyrimidine nucleotides. This pathway map also shows the Entner-Doudoroff pathway where 6-P-gluconate is dehydrated and then cleaved into pyruvate and glyceraldehyde-3P [MD:M00008]."
      assert_equal(expected, @obj.description)
    end

    def test_keggclass
      expected = "Metabolism; Carbohydrate Metabolism"
      assert_equal(expected, @obj.keggclass)
    end

    def test_modules_as_strings
      expected =
        [ "M00004  Pentose phosphate pathway (Pentose phosphate cycle) [PATH:map00030]",
          "M00005  PRPP biosynthesis, ribose 5P -> PRPP [PATH:map00030]",
          "M00006  Pentose phosphate pathway, oxidative phase, glucose 6P => ribulose 5P [PATH:map00030]",
          "M00007  Pentose phosphate pathway, non-oxidative phase, fructose 6P => ribose 5P [PATH:map00030]",
          "M00008  Entner-Doudoroff pathway, glucose-6P => glyceraldehyde-3P + pyruvate [PATH:map00030]",
          "M00680  Semi-phosphorylative Entner-Doudoroff pathway, gluconate => glyceraldehyde-3P + pyruvate [PATH:map00030]",
          "M00681  Non-phosphorylative Entner-Doudoroff pathway, gluconate => glyceraldehyde + pyruvate [PATH:map00030]"
        ]
      assert_equal(expected, @obj.modules_as_strings)
    end

    def test_modules_as_hash
      expected = {
        "M00008" => "Entner-Doudoroff pathway, glucose-6P => glyceraldehyde-3P + pyruvate [PATH:map00030]",
        "M00680" => "Semi-phosphorylative Entner-Doudoroff pathway, gluconate => glyceraldehyde-3P + pyruvate [PATH:map00030]",
        "M00681" => "Non-phosphorylative Entner-Doudoroff pathway, gluconate => glyceraldehyde + pyruvate [PATH:map00030]",
        "M00004" => "Pentose phosphate pathway (Pentose phosphate cycle) [PATH:map00030]",
        "M00005" => "PRPP biosynthesis, ribose 5P -> PRPP [PATH:map00030]",
        "M00006" => "Pentose phosphate pathway, oxidative phase, glucose 6P => ribulose 5P [PATH:map00030]",
        "M00007" => "Pentose phosphate pathway, non-oxidative phase, fructose 6P => ribose 5P [PATH:map00030]"
      }
      assert_equal(expected, @obj.modules_as_hash)
      assert_equal(expected, @obj.modules)
    end

    def test_rel_pathways_as_strings
      expected = [ "map00010  Glycolysis / Gluconeogenesis",
                   "map00040  Pentose and glucuronate interconversions",
                   "map00230  Purine metabolism",
                   "map00240  Pyrimidine metabolism",
                   "map00340  Histidine metabolism" ]
      assert_equal(expected, @obj.rel_pathways_as_strings)
    end

    def test_rel_pathways_as_hash
      expected = {
        "map00240" => "Pyrimidine metabolism",
        "map00340" => "Histidine metabolism",
        "map00230" => "Purine metabolism",
        "map00010" => "Glycolysis / Gluconeogenesis",
        "map00040" => "Pentose and glucuronate interconversions"
      }
      assert_equal(expected, @obj.rel_pathways_as_hash)
      assert_equal(expected, @obj.rel_pathways)
    end

    def test_dblinks_as_strings
      assert_equal(["GO: 0006098"], @obj.dblinks_as_strings)
    end

    def test_dblinks_as_hash
      assert_equal({"GO"=>["0006098"]}, @obj.dblinks_as_hash)
    end

    def test_pathways_as_strings
      expected = ["map00030  Pentose phosphate pathway"]
      assert_equal(expected, @obj.pathways_as_strings)
    end

    def test_pathways_as_hash
      expected = {"map00030"=>"Pentose phosphate pathway"}
      assert_equal(expected, @obj.pathways_as_hash)
    end

    def test_orthologs_as_strings
      assert_equal([], @obj.orthologs_as_strings)
    end

    def test_orthologs_as_hash
      assert_equal({}, @obj.orthologs_as_hash)
    end

    def test_genes_as_strings
      assert_equal([], @obj.genes_as_strings)
    end

    def test_genes_as_hash
      assert_equal({}, @obj.genes_as_hash)
    end

    def test_diseases_as_strings
      expected = ["H00196  Phosphoribosylpyrophosphate synthetase I superactivity"]
      assert_equal(expected, @obj.diseases_as_strings)
    end

    def test_diseases_as_hash
      expected = {"H00196"=>"Phosphoribosylpyrophosphate synthetase I superactivity"}
      assert_equal(expected, @obj.diseases_as_hash)
    end

    def test_enzymes_as_strings
      assert_equal([], @obj.enzymes_as_strings)
    end

    def test_reactions_as_strings
      assert_equal([], @obj.reactions_as_strings)
    end

    def test_reactions_as_hash
      assert_equal({}, @obj.reactions_as_hash)
    end

    def test_compounds_as_strings
      assert_equal([], @obj.compounds_as_strings)
    end

    def test_compounds_as_hash
      assert_equal({}, @obj.compounds_as_hash)
    end

    def test_organism
      assert_equal("", @obj.organism)
    end

    def test_ko_pathway
      assert_equal("ko00030", @obj.ko_pathway)
    end

  end #class TestBioKEGGPATHWAY

  class TestBioKeggPathway_rn00250 < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'KEGG', 'rn00250.pathway')
      @obj = Bio::KEGG::PATHWAY.new(File.read(filename))
    end

    def test_dblinks_as_hash
      expected = {"GO"=>["0006522", "0006531", "0006536"]}
      assert_equal(expected, @obj.dblinks_as_hash)
    end

    def test_pathways_as_hash
      expected = {"rn00250"=>"Alanine, aspartate and glutamate metabolism"}
      assert_equal(expected, @obj.pathways_as_hash)
    end

    def test_orthologs_as_hash
      assert_equal({}, @obj.orthologs_as_hash)
    end

    def test_genes_as_hash
      assert_equal({}, @obj.genes_as_hash)
    end

    def test_references
      data =
        [ { "authors"  => [ "Nishizuka Y", "Seyama Y", "Ikai A",
                            "Ishimura Y", "Kawaguchi A (eds)." ],
            "journal"  => "Tokyo Kagaku Dojin",
            "title"=>"[Cellular Functions and Metabolic Maps] (In Japanese)",
            "year"     => "1997"
          },
          { "authors" => [ "Wu G" ],
            "journal" => "J Nutr",
            "pages"   => "1249-52",
            "pubmed"  => "9687539",
            "title"   => "Intestinal mucosal amino acid catabolism.",
            "volume"  => "128",
            "year"    => "1998"
          }
        ]
      expected = data.collect { |h| Bio::Reference.new(h) }
      assert_equal(expected, @obj.references)
    end

    def test_modules_as_hash
      expected = {
        "M00019"=>
        "Glutamate biosynthesis, oxoglutarete => glutamate (glutamate synthase) [PATH:rn00250]",
        "M00021"=>
        "Aspartate biosynthesis, oxaloacetate => aspartate [PATH:rn00250]",
        "M00044"=>
        "Aspartate degradation, aspartate => fumarate [PATH:rn00250]",
        "M00022"=>
        "Asparagine biosynthesis, aspartate => asparagine [PATH:rn00250]",
        "M00045"=>
        "Aspartate degradation, aspartate => oxaloacetate [PATH:rn00250]",
        "M00046"=>
        "Asparagine degradation, asparagine => aspartate +NH3 [PATH:rn00250]",
        "M00026"=>
        "Alanine biosynthesis, pyruvate => alanine [PATH:rn00250]",
        "M00038"=>
        "Glutamine degradation, glutamine => glutamate + NH3 [PATH:rn00250]",
        "M00040"=>
        "GABA (gamma-Aminobutyrate) shunt [PATH:rn00250]",
        "M00017"=>
        "Glutamate biosynthesis, oxoglutarate => glutamate (glutamate dehydrogenase) [PATH:rn00250]",
        "M00018"=>
        "Glutamine biosynthesis, glutamate => glutamine [PATH:rn00250]"
      }
      assert_equal(expected, @obj.modules_as_hash)
    end

    def test_new
      assert_kind_of(Bio::KEGG::PATHWAY, @obj)
    end

    def test_entry_id
      assert_equal("rn00250", @obj.entry_id)
    end

    def test_name
      expected = "Alanine, aspartate and glutamate metabolism"
      assert_equal(expected, @obj.name)
    end

    def test_description
      assert_equal("", @obj.description)
    end

    def test_keggclass
      expected = "Metabolism; Amino Acid Metabolism"
      assert_equal(expected, @obj.keggclass)
    end

    def test_pathways_as_strings
      expected = ["rn00250  Alanine, aspartate and glutamate metabolism"]
      assert_equal(expected, @obj.pathways_as_strings)
    end

    def test_modules_as_strings
      expected =
        [ "M00017  Glutamate biosynthesis, oxoglutarate => glutamate (glutamate dehydrogenase) [PATH:rn00250]",
          "M00018  Glutamine biosynthesis, glutamate => glutamine [PATH:rn00250]",
          "M00019  Glutamate biosynthesis, oxoglutarete => glutamate (glutamate synthase) [PATH:rn00250]",
          "M00021  Aspartate biosynthesis, oxaloacetate => aspartate [PATH:rn00250]",
          "M00022  Asparagine biosynthesis, aspartate => asparagine [PATH:rn00250]",
          "M00026  Alanine biosynthesis, pyruvate => alanine [PATH:rn00250]",
          "M00038  Glutamine degradation, glutamine => glutamate + NH3 [PATH:rn00250]",
          "M00040  GABA (gamma-Aminobutyrate) shunt [PATH:rn00250]",
          "M00044  Aspartate degradation, aspartate => fumarate [PATH:rn00250]",
          "M00045  Aspartate degradation, aspartate => oxaloacetate [PATH:rn00250]",
          "M00046  Asparagine degradation, asparagine => aspartate +NH3 [PATH:rn00250]"
        ]
      assert_equal(expected, @obj.modules_as_strings)
    end

    def test_diseases_as_strings
      expected = [ "H00074  Canavan disease (CD)",
                   "H00185  Citrullinemia (CTLN)",
                   "H00197  Adenylosuccinate lyase deficiency" ]
      assert_equal(expected, @obj.diseases_as_strings)
    end

    def test_diseases_as_hash
      expected = {
        "H00197"=>"Adenylosuccinate lyase deficiency",
        "H00074"=>"Canavan disease (CD)",
        "H00185"=>"Citrullinemia (CTLN)"
      }
      assert_equal(expected, @obj.diseases_as_hash)
    end

    def test_dblinks_as_strings
      expected = ["GO: 0006522 0006531 0006536"]
      assert_equal(expected, @obj.dblinks_as_strings)
    end

    def test_orthologs_as_strings
      assert_equal([], @obj.orthologs_as_strings)
    end

    def test_organism
      assert_equal("", @obj.organism)
    end

    def test_genes_as_strings
      assert_equal([], @obj.genes_as_strings)
    end

    def test_enzymes_as_strings
      assert_equal([], @obj.enzymes_as_strings)
    end

    def test_reactions_as_strings
      expected =
        [ "R00093  L-glutamate:NAD+ oxidoreductase (transaminating)",
          "R00114  L-Glutamate:NADP+ oxidoreductase (transaminating)",
          "R00149  Carbon-dioxide:ammonia ligase (ADP-forming,carbamate-phosphorylating)",
          "R00243  L-Glutamate:NAD+ oxidoreductase (deaminating)",
          "R00248  L-Glutamate:NADP+ oxidoreductase (deaminating)",
          "R00253  L-Glutamate:ammonia ligase (ADP-forming)",
          "R00256  L-Glutamine amidohydrolase",
          "R00258  L-Alanine:2-oxoglutarate aminotransferase",
          "R00261  L-glutamate 1-carboxy-lyase (4-aminobutanoate-forming)",
          "R00269  2-Oxoglutaramate amidohydrolase",
          "R00348  2-Oxosuccinamate amidohydrolase",
          "R00355  L-Aspartate:2-oxoglutarate aminotransferase",
          "R00357  L-Aspartic acid:oxygen oxidoreductase (deaminating)",
          "R00359  D-Aspartate:oxygen oxidoreductase (deaminating)",
          "R00369  L-Alanine:glyoxylate aminotransferase",
          "R00396  L-Alanine:NAD+ oxidoreductase (deaminating)",
          "R00397  L-aspartate 4-carboxy-lyase (L-alanine-forming)",
          "R00400  L-alanine:oxaloacetate aminotransferase",
          "R00483  L-aspartate:ammonia ligase (AMP-forming)",
          "R00484  N-Carbamoyl-L-aspartate amidohydrolase",
          "R00485  L-Asparagine amidohydrolase",
          "R00487  Acetyl-CoA:L-aspartate N-acetyltransferase",
          "R00488  N-Acetyl-L-aspartate amidohydrolase",
          "R00490  L-Aspartate ammonia-lyase",
          "R00491  aspartate racemase",
          "R00575  hydrogen-carbonate:L-glutamine amido-ligase (ADP-forming, carbamate-phosphorylating)",
          "R00576  L-Glutamine:pyruvate aminotransferase",
          "R00578  L-aspartate:L-glutamine amido-ligase (AMP-forming)",
          "R00707  (S)-1-pyrroline-5-carboxylate:NAD+ oxidoreductase",
          "R00708  (S)-1-pyrroline-5-carboxylate:NADP+ oxidoreductase",
          "R00713  Succinate-semialdehyde:NAD+ oxidoreductase",
          "R00714  Succinate-semialdehyde:NADP+ oxidoreductase",
          "R00768  L-glutamine:D-fructose-6-phosphate isomerase (deaminating)",
          "R01072  5-phosphoribosylamine:diphosphate phospho-alpha-D-ribosyltransferase (glutamate-amidating)",
          "R01083  N6-(1,2-dicarboxyethyl)AMP AMP-lyase (fumarate-forming)",
          "R01086  2-(Nomega-L-arginino)succinate arginine-lyase (fumarate-forming)",
          "R01135  IMP:L-aspartate ligase (GDP-forming)",
          "R01346  L-Asparagine:2-oxo-acid aminotransferase",
          "R01397  carbamoyl-phosphate:L-aspartate carbamoyltransferase",
          "R01648  4-Aminobutanoate:2-oxoglutarate aminotransferase",
          "R01954  L-Citrulline:L-aspartate ligase (AMP-forming)"
        ]
      assert_equal(expected, @obj.reactions_as_strings)
    end

    def test_reactions_as_hash
      expected = {
        "R01648"=>"4-Aminobutanoate:2-oxoglutarate aminotransferase",
        "R00485"=>"L-Asparagine amidohydrolase",
        "R00397"=>"L-aspartate 4-carboxy-lyase (L-alanine-forming)",
        "R00243"=>"L-Glutamate:NAD+ oxidoreductase (deaminating)",
        "R01397"=>"carbamoyl-phosphate:L-aspartate carbamoyltransferase",
        "R00707"=>"(S)-1-pyrroline-5-carboxylate:NAD+ oxidoreductase",
        "R00575"=>
        "hydrogen-carbonate:L-glutamine amido-ligase (ADP-forming, carbamate-phosphorylating)",
        "R00487"=>"Acetyl-CoA:L-aspartate N-acetyltransferase",
        "R00355"=>"L-Aspartate:2-oxoglutarate aminotransferase",
        "R00256"=>"L-Glutamine amidohydrolase",
        "R01135"=>"IMP:L-aspartate ligase (GDP-forming)",
        "R00708"=>"(S)-1-pyrroline-5-carboxylate:NADP+ oxidoreductase",
        "R00576"=>"L-Glutamine:pyruvate aminotransferase",
        "R00488"=>"N-Acetyl-L-aspartate amidohydrolase",
        "R00400"=>"L-alanine:oxaloacetate aminotransferase",
        "R00114"=>"L-Glutamate:NADP+ oxidoreductase (transaminating)",
        "R00093"=>"L-glutamate:NAD+ oxidoreductase (transaminating)",
        "R00490"=>"L-Aspartate ammonia-lyase",
        "R00357"=>"L-Aspartic acid:oxygen oxidoreductase (deaminating)",
        "R00269"=>"2-Oxoglutaramate amidohydrolase",
        "R00258"=>"L-Alanine:2-oxoglutarate aminotransferase",
        "R01346"=>"L-Asparagine:2-oxo-acid aminotransferase",
        "R01083"=>"N6-(1,2-dicarboxyethyl)AMP AMP-lyase (fumarate-forming)",
        "R01072"=>
        "5-phosphoribosylamine:diphosphate phospho-alpha-D-ribosyltransferase (glutamate-amidating)",
        "R00578"=>"L-aspartate:L-glutamine amido-ligase (AMP-forming)",
        "R00491"=>"aspartate racemase",
        "R00369"=>"L-Alanine:glyoxylate aminotransferase",
        "R00248"=>"L-Glutamate:NADP+ oxidoreductase (deaminating)",
        "R00149"=>
        "Carbon-dioxide:ammonia ligase (ADP-forming,carbamate-phosphorylating)",
        "R00359"=>"D-Aspartate:oxygen oxidoreductase (deaminating)",
        "R00348"=>"2-Oxosuccinamate amidohydrolase",
        "R00261"=>"L-glutamate 1-carboxy-lyase (4-aminobutanoate-forming)",
        "R01954"=>"L-Citrulline:L-aspartate ligase (AMP-forming)",
        "R01086"=>"2-(Nomega-L-arginino)succinate arginine-lyase (fumarate-forming)",
        "R00768"=>"L-glutamine:D-fructose-6-phosphate isomerase (deaminating)",
        "R00713"=>"Succinate-semialdehyde:NAD+ oxidoreductase",
        "R00483"=>"L-aspartate:ammonia ligase (AMP-forming)",
        "R00714"=>"Succinate-semialdehyde:NADP+ oxidoreductase",
        "R00484"=>"N-Carbamoyl-L-aspartate amidohydrolase",
        "R00396"=>"L-Alanine:NAD+ oxidoreductase (deaminating)",
        "R00253"=>"L-Glutamate:ammonia ligase (ADP-forming)"
      }
      assert_equal(expected, @obj.reactions_as_hash)
    end

    def test_compounds_as_strings
      expected =
        [ "C00014  NH3",
          "C00022  Pyruvate",
          "C00025  L-Glutamate",
          "C00026  2-Oxoglutarate",
          "C00036  Oxaloacetate",
          "C00041  L-Alanine",
          "C00042  Succinate",
          "C00049  L-Aspartate",
          "C00064  L-Glutamine",
          "C00122  Fumarate",
          "C00152  L-Asparagine",
          "C00169  Carbamoyl phosphate",
          "C00232  Succinate semialdehyde",
          "C00334  4-Aminobutanoate",
          "C00352  D-Glucosamine 6-phosphate",
          "C00402  D-Aspartate",
          "C00438  N-Carbamoyl-L-aspartate",
          "C00940  2-Oxoglutaramate",
          "C01042  N-Acetyl-L-aspartate",
          "C02362  2-Oxosuccinamate",
          "C03090  5-Phosphoribosylamine",
          "C03406  N-(L-Arginino)succinate",
          "C03794  N6-(1,2-Dicarboxyethyl)-AMP",
          "C03912  (S)-1-Pyrroline-5-carboxylate"
        ]
      assert_equal(expected, @obj.compounds_as_strings)
    end

    def test_compounds_as_hash
      expected = {
        "C02362"=>"2-Oxosuccinamate",
        "C01042"=>"N-Acetyl-L-aspartate",
        "C00041"=>"L-Alanine",
        "C03912"=>"(S)-1-Pyrroline-5-carboxylate",
        "C03406"=>"N-(L-Arginino)succinate",
        "C00438"=>"N-Carbamoyl-L-aspartate",
        "C00152"=>"L-Asparagine",
        "C00064"=>"L-Glutamine",
        "C00042"=>"Succinate",
        "C00352"=>"D-Glucosamine 6-phosphate",
        "C00022"=>"Pyruvate",
        "C03794"=>"N6-(1,2-Dicarboxyethyl)-AMP",
        "C03090"=>"5-Phosphoribosylamine",
        "C00232"=>"Succinate semialdehyde",
        "C00122"=>"Fumarate",
        "C00036"=>"Oxaloacetate",
        "C00025"=>"L-Glutamate",
        "C00014"=>"NH3",
        "C00334"=>"4-Aminobutanoate",
        "C00169"=>"Carbamoyl phosphate",
        "C00026"=>"2-Oxoglutarate",
        "C00940"=>"2-Oxoglutaramate",
        "C00049"=>"L-Aspartate",
        "C00402"=>"D-Aspartate"
      }
      assert_equal(expected, @obj.compounds_as_hash)
    end

    def test_rel_pathways_as_strings
      expected =
        [ "rn00010  Glycolysis / Gluconeogenesis",
          "rn00020  Citrate cycle (TCA cycle)",
          "rn00230  Purine metabolism",
          "rn00240  Pyrimidine metabolism",
          "rn00253  Tetracycline biosynthesis",
          "rn00260  Glycine, serine and threonine metabolism",
          "rn00300  Lysine biosynthesis",
          "rn00330  Arginine and proline metabolism",
          "rn00340  Histidine metabolism",
          "rn00410  beta-Alanine metabolism",
          "rn00460  Cyanoamino acid metabolism",
          "rn00471  D-Glutamine and D-glutamate metabolism",
          "rn00473  D-Alanine metabolism",
          "rn00480  Glutathione metabolism",
          "rn00650  Butanoate metabolism",
          "rn00660  C5-Branched dibasic acid metabolism",
          "rn00760  Nicotinate and nicotinamide metabolism",
          "rn00770  Pantothenate and CoA biosynthesis",
          "rn00860  Porphyrin and chlorophyll metabolism",
          "rn00910  Nitrogen metabolism"
        ]
      assert_equal(expected, @obj.rel_pathways_as_strings)
    end

    def test_rel_pathways_as_hash
      expected = {
        "rn00770"=>"Pantothenate and CoA biosynthesis",
        "rn00660"=>"C5-Branched dibasic acid metabolism",
        "rn00473"=>"D-Alanine metabolism",
        "rn00330"=>"Arginine and proline metabolism",
        "rn00253"=>"Tetracycline biosynthesis",
        "rn00760"=>"Nicotinate and nicotinamide metabolism",
        "rn00650"=>"Butanoate metabolism",
        "rn00860"=>"Porphyrin and chlorophyll metabolism",
        "rn00410"=>"beta-Alanine metabolism",
        "rn00300"=>"Lysine biosynthesis",
        "rn00480"=>"Glutathione metabolism",
        "rn00260"=>"Glycine, serine and threonine metabolism",
        "rn00910"=>"Nitrogen metabolism",
        "rn00471"=>"D-Glutamine and D-glutamate metabolism",
        "rn00460"=>"Cyanoamino acid metabolism",
        "rn00240"=>"Pyrimidine metabolism",
        "rn00020"=>"Citrate cycle (TCA cycle)",
        "rn00340"=>"Histidine metabolism",
        "rn00230"=>"Purine metabolism",
        "rn00010"=>"Glycolysis / Gluconeogenesis"}
      assert_equal(expected, @obj.rel_pathways_as_hash)
    end

    def test_ko_pathway
      assert_equal("ko00250", @obj.ko_pathway)
    end

  end #class TestBioKeggPathway_rn00250

  class TestBioKEGGPATHWAY_ec00072 < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'KEGG', 'ec00072.pathway')
      @obj = Bio::KEGG::PATHWAY.new(File.read(filename))
    end

    def test_dblinks_as_hash
      assert_equal({}, @obj.dblinks_as_hash)
    end

    def test_pathways_as_hash
      expected = {"ec00072"=>"Synthesis and degradation of ketone bodies"}
      assert_equal(expected, @obj.pathways_as_hash)
    end

    def test_orthologs_as_hash
      assert_equal({}, @obj.orthologs_as_hash)
    end

    def test_genes_as_hash
      assert_equal({}, @obj.genes_as_hash)
    end

    def test_references
      assert_equal([], @obj.references)
    end

    def test_modules_as_hash
      expected = { "M00177" =>
        "Ketone body biosynthesis, acetyl-CoA => acetoacetate/3-hydroxybutyrate/acetone [PATH:ec00072]" }
      assert_equal(expected, @obj.modules_as_hash)
    end

    def test_new
      assert_kind_of(Bio::KEGG::PATHWAY, @obj)
    end

    def test_entry_id
      assert_equal("ec00072", @obj.entry_id)
    end

    def test_name
      expected = "Synthesis and degradation of ketone bodies"
      assert_equal(expected, @obj.name)
    end

    def test_description
      assert_equal("", @obj.description)
    end

    def test_keggclass
      expected = "Metabolism; Lipid Metabolism"
      assert_equal(expected, @obj.keggclass)
    end

    def test_pathways_as_strings
      expected = ["ec00072  Synthesis and degradation of ketone bodies"]
      assert_equal(expected, @obj.pathways_as_strings)
    end

    def test_modules_as_strings
      expected = ["M00177  Ketone body biosynthesis, acetyl-CoA => acetoacetate/3-hydroxybutyrate/acetone [PATH:ec00072]"]
      assert_equal(expected, @obj.modules_as_strings)
    end

    def test_diseases_as_strings
      assert_equal([], @obj.diseases_as_strings)
    end

    def test_diseases_as_hash
      assert_equal({}, @obj.diseases_as_hash)
    end

    def test_dblinks_as_strings
      assert_equal([], @obj.dblinks_as_strings)
    end

    def test_orthologs_as_strings
      assert_equal([], @obj.orthologs_as_strings)
    end

    def test_organism
      assert_equal("", @obj.organism)
    end

    def test_genes_as_strings
      assert_equal([], @obj.genes_as_strings)
    end

    def test_enzymes_as_strings
      expected = [ "1.1.1.30", "2.3.1.9", "2.3.3.10", "2.8.3.5",
                   "4.1.1.4", "4.1.3.4" ]
      assert_equal(expected, @obj.enzymes_as_strings)
    end

    def test_reactions_as_strings
      assert_equal([], @obj.reactions_as_strings)
    end

    def test_reactions_as_hash
      assert_equal({}, @obj.reactions_as_hash)
    end

    def test_compounds_as_strings
      expected =
        [ "C00024  Acetyl-CoA",
          "C00164  Acetoacetate",
          "C00207  Acetone",
          "C00332  Acetoacetyl-CoA",
          "C00356  (S)-3-Hydroxy-3-methylglutaryl-CoA",
          "C01089  (R)-3-Hydroxybutanoate"
        ]
      assert_equal(expected, @obj.compounds_as_strings)
    end

    def test_compounds_as_hash
      expected = {
        "C00207"=>"Acetone",
        "C00164"=>"Acetoacetate",
        "C01089"=>"(R)-3-Hydroxybutanoate",
        "C00332"=>"Acetoacetyl-CoA",
        "C00024"=>"Acetyl-CoA",
        "C00356"=>"(S)-3-Hydroxy-3-methylglutaryl-CoA"
      }
      assert_equal(expected, @obj.compounds_as_hash)
    end

    def test_rel_pathways_as_strings
      expected =
        [ "ec00010  Glycolysis / Gluconeogenesis",
          "ec00071  Fatty acid metabolism",
          "ec00620  Pyruvate metabolism",
          "ec00650  Butanoate metabolism"
        ]
      assert_equal(expected, @obj.rel_pathways_as_strings)
    end

    def test_rel_pathways_as_hash
      expected = {
        "ec00620"=>"Pyruvate metabolism",
        "ec00071"=>"Fatty acid metabolism",
        "ec00010"=>"Glycolysis / Gluconeogenesis",
        "ec00650"=>"Butanoate metabolism"
      }
      assert_equal(expected, @obj.rel_pathways_as_hash)
    end

    def test_ko_pathway
      assert_equal("ko00072", @obj.ko_pathway)
    end

  end #class TestBioKEGGPATHWAY_ec00072

  class TestBioKEGGPATHWAY_hsa00790 < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'KEGG', 'hsa00790.pathway')
      @obj = Bio::KEGG::PATHWAY.new(File.read(filename))
    end

    def test_dblinks_as_hash
      assert_equal({"GO"=>["0046656"]}, @obj.dblinks_as_hash)
    end

    def test_pathways_as_hash
      expected = {"hsa00790"=>"Folate biosynthesis"}
      assert_equal(expected, @obj.pathways_as_hash)
    end

    def test_orthologs_as_hash
      assert_equal({}, @obj.orthologs_as_hash)
    end

    def test_genes_as_hash
      expected = {
        "248"  => "ALPI, IAP [KO:K01077] [EC:3.1.3.1]",
        "6697" => "SPR, SDR38C1 [KO:K00072] [EC:1.1.1.153]",
        "249"  =>
        "ALPL, AP-TNAP, APTNAP, FLJ40094, FLJ93059, HOPS, MGC161443, MGC167935, TNAP, TNSALP [KO:K01077] [EC:3.1.3.1]",
        "2356" => "FPGS [KO:K01930] [EC:6.3.2.17]",
        "250"  => "ALPP, ALP, FLJ61142, PALP, PLAP [KO:K01077] [EC:3.1.3.1]",
        "1719" => "DHFR, DHFRP1, DYR [KO:K00287] [EC:1.5.1.3]",
        "251"  => "ALPPL2, ALPG, ALPPL, GCAP [KO:K01077] [EC:3.1.3.1]",
        "2643" =>
        "GCH1, DYT14, DYT5, DYT5a, GCH, GTP-CH-1, GTPCH1, HPABH4B [KO:K01495] [EC:3.5.4.16]",
        "8836" => "GGH, GH [KO:K01307] [EC:3.4.19.9]",
        "5860" =>
        "QDPR, DHPR, FLJ42391, PKU2, SDR33C1 [KO:K00357] [EC:1.5.1.34]",
        "5805" => "PTS, FLJ97081, PTPS [KO:K01737] [EC:4.2.3.12]"
      }
      assert_equal(expected, @obj.genes_as_hash)
    end

    def test_references
      assert_equal([], @obj.references)
    end

    def test_modules_as_hash
      expected = {
        "M00251"=>"Folate biosynthesis, GTP => THF [PATH:hsa00790]",
        "M00304"=>"Methanogenesis [PATH:hsa00790]"
      }
      assert_equal(expected, @obj.modules_as_hash)
    end

    def test_new
      assert_instance_of(Bio::KEGG::PATHWAY, @obj)
    end

    def test_entry_id
      assert_equal("hsa00790", @obj.entry_id)
    end

    def test_name
      expected = "Folate biosynthesis - Homo sapiens (human)"
      assert_equal(expected, @obj.name)
    end

    def test_description
      assert_equal("", @obj.description)
    end

    def test_keggclass
      expected = "Metabolism; Metabolism of Cofactors and Vitamins"
      assert_equal(expected, @obj.keggclass)
    end

    def test_pathways_as_strings
      expected = ["hsa00790  Folate biosynthesis"]
      assert_equal(expected, @obj.pathways_as_strings)
    end

    def test_modules_as_strings
      expected = ["M00251  Folate biosynthesis, GTP => THF [PATH:hsa00790]",
 "M00304  Methanogenesis [PATH:hsa00790]"]
      assert_equal(expected, @obj.modules_as_strings)
    end

    def test_diseases_as_strings
      expected = [ "H00167  Phenylketonuria (PKU)",
                   "H00213  Hypophosphatasia" ]
      assert_equal(expected, @obj.diseases_as_strings)
    end

    def test_diseases_as_hash
      expected = {
        "H00167"=>"Phenylketonuria (PKU)",
        "H00213"=>"Hypophosphatasia"
      }
      assert_equal(expected, @obj.diseases_as_hash)
    end

    def test_dblinks_as_strings
      assert_equal(["GO: 0046656"], @obj.dblinks_as_strings)
    end

    def test_orthologs_as_strings
      assert_equal([], @obj.orthologs_as_strings)
    end

    def test_organism
      expected = "Homo sapiens (human) [GN:hsa]"
      assert_equal(expected, @obj.organism)
    end

    def test_genes_as_strings
      expected =
        [ "2643  GCH1, DYT14, DYT5, DYT5a, GCH, GTP-CH-1, GTPCH1, HPABH4B [KO:K01495] [EC:3.5.4.16]",
          "248  ALPI, IAP [KO:K01077] [EC:3.1.3.1]",
          "249  ALPL, AP-TNAP, APTNAP, FLJ40094, FLJ93059, HOPS, MGC161443, MGC167935, TNAP, TNSALP [KO:K01077] [EC:3.1.3.1]",
          "250  ALPP, ALP, FLJ61142, PALP, PLAP [KO:K01077] [EC:3.1.3.1]",
          "251  ALPPL2, ALPG, ALPPL, GCAP [KO:K01077] [EC:3.1.3.1]",
          "1719  DHFR, DHFRP1, DYR [KO:K00287] [EC:1.5.1.3]",
          "2356  FPGS [KO:K01930] [EC:6.3.2.17]",
          "8836  GGH, GH [KO:K01307] [EC:3.4.19.9]",
          "5805  PTS, FLJ97081, PTPS [KO:K01737] [EC:4.2.3.12]",
          "6697  SPR, SDR38C1 [KO:K00072] [EC:1.1.1.153]",
          "5860  QDPR, DHPR, FLJ42391, PKU2, SDR33C1 [KO:K00357] [EC:1.5.1.34]"
        ]
      assert_equal(expected, @obj.genes_as_strings)
    end

    def test_enzymes_as_strings
      assert_equal([], @obj.enzymes_as_strings)
    end

    def test_reactions_as_strings
      assert_equal([], @obj.reactions_as_strings)
    end

    def test_reactions_as_hash
      assert_equal({}, @obj.reactions_as_hash)
    end

    def test_compounds_as_strings
      expected =
        [ "C00044  GTP",
          "C00101  Tetrahydrofolate",
          "C00251  Chorismate",
          "C00266  Glycolaldehyde",
          "C00268  Dihydrobiopterin",
          "C00272  Tetrahydrobiopterin",
          "C00415  Dihydrofolate",
          "C00504  Folate",
          "C00568  4-Aminobenzoate",
          "C00921  Dihydropteroate",
          "C01217  5,6,7,8-Tetrahydromethanopterin",
          "C01300  2-Amino-4-hydroxy-6-hydroxymethyl-7,8-dihydropteridine",
          "C03541  Tetrahydrofolyl-[Glu](n)",
          "C03684  6-Pyruvoyltetrahydropterin",
          "C04244  6-Lactoyl-5,6,7,8-tetrahydropterin",
          "C04807  2-Amino-7,8-dihydro-4-hydroxy-6-(diphosphooxymethyl)pteridine",
          "C04874  2-Amino-4-hydroxy-6-(D-erythro-1,2,3-trihydroxypropyl)-7,8-dihydropteridine",
          "C04895  2-Amino-4-hydroxy-6-(erythro-1,2,3-trihydroxypropyl)dihydropteridine triphosphate",
          "C05922  Formamidopyrimidine nucleoside triphosphate",
          "C05923  2,5-Diaminopyrimidine nucleoside triphosphate",
          "C05924  Molybdopterin",
          "C05925  Dihydroneopterin phosphate",
          "C05926  Neopterin",
          "C05927  7,8-Dihydromethanopterin",
          "C06148  2,5-Diamino-6-(5'-triphosphoryl-3',4'-trihydroxy-2'-oxopentyl)-amino-4-oxopyrimidine",
          "C06149  6-(3'-Triphosphoryl-1'-methylglyceryl)-7-methyl-7,8-dihydrobiopterin",
          "C09332  Tetrahydrofolyl-[Glu](2)",
          "C11355  4-Amino-4-deoxychorismate"
        ]
      assert_equal(expected, @obj.compounds_as_strings)
    end

    def test_compounds_as_hash
      expected = {
        "C05925"=>"Dihydroneopterin phosphate",
        "C04244"=>"6-Lactoyl-5,6,7,8-tetrahydropterin",
        "C01217"=>"5,6,7,8-Tetrahydromethanopterin",
        "C00568"=>"4-Aminobenzoate",
        "C05926"=>"Neopterin",
        "C00921"=>"Dihydropteroate",
        "C00415"=>"Dihydrofolate",
        "C00272"=>"Tetrahydrobiopterin",
        "C05927"=>"7,8-Dihydromethanopterin",
        "C04895"=>
        "2-Amino-4-hydroxy-6-(erythro-1,2,3-trihydroxypropyl)dihydropteridine triphosphate",
        "C04807"=>"2-Amino-7,8-dihydro-4-hydroxy-6-(diphosphooxymethyl)pteridine",
        "C00504"=>"Folate",
        "C00251"=>"Chorismate",
        "C06148"=>
        "2,5-Diamino-6-(5'-triphosphoryl-3',4'-trihydroxy-2'-oxopentyl)-amino-4-oxopyrimidine",
        "C04874"=>
        "2-Amino-4-hydroxy-6-(D-erythro-1,2,3-trihydroxypropyl)-7,8-dihydropteridine",
        "C06149"=>
        "6-(3'-Triphosphoryl-1'-methylglyceryl)-7-methyl-7,8-dihydrobiopterin",
        "C00044"=>"GTP",
        "C03684"=>"6-Pyruvoyltetrahydropterin",
        "C03541"=>"Tetrahydrofolyl-[Glu](n)",
        "C01300"=>"2-Amino-4-hydroxy-6-hydroxymethyl-7,8-dihydropteridine",
        "C00266"=>"Glycolaldehyde",
        "C00101"=>"Tetrahydrofolate",
        "C05922"=>"Formamidopyrimidine nucleoside triphosphate",
        "C00268"=>"Dihydrobiopterin",
        "C11355"=>"4-Amino-4-deoxychorismate",
        "C05923"=>"2,5-Diaminopyrimidine nucleoside triphosphate",
        "C09332"=>"Tetrahydrofolyl-[Glu](2)",
        "C05924"=>"Molybdopterin"
      }
      assert_equal(expected, @obj.compounds_as_hash)
    end

    def test_rel_pathways_as_strings
      expected =
        [ "hsa00230  Purine metabolism",
          "hsa00400  Phenylalanine, tyrosine and tryptophan biosynthesis",
          "hsa00670  One carbon pool by folate",
          "hsa00680  Methane metabolism"
        ]
      assert_equal(expected, @obj.rel_pathways_as_strings)
    end

    def test_rel_pathways_as_hash
      expected = {
        "hsa00680"=>"Methane metabolism",
        "hsa00670"=>"One carbon pool by folate",
        "hsa00230"=>"Purine metabolism",
        "hsa00400"=>"Phenylalanine, tyrosine and tryptophan biosynthesis"
      }
      assert_equal(expected, @obj.rel_pathways_as_hash)
    end

    def test_ko_pathway
      assert_equal("ko00790", @obj.ko_pathway)
    end

  end #class TestBioKEGGPATHWAY_hsa00790

  class TestBioKEGGPATHWAY_ko00312 < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'KEGG', 'ko00312.pathway')
      @obj = Bio::KEGG::PATHWAY.new(File.read(filename))
    end

    def test_dblinks_as_hash
      assert_equal({}, @obj.dblinks_as_hash)
    end

    def test_pathways_as_hash
      expected = {"ko00312"=>"beta-Lactam resistance"}
      assert_equal(expected, @obj.pathways_as_hash)
    end

    def test_orthologs_as_hash
      expected = {
        "K02545"=>"penicillin-binding protein 2 prime",
        "K02172"=>"bla regulator protein blaR1",
        "K02546"=>"methicillin resistance regulatory protein",
        "K02547"=>"methicillin resistance protein",
        "K02352"=>"drp35",
        "K01467"=>"beta-lactamase [EC:3.5.2.6]",
        "K02171"=>"penicillinase repressor"
      }
      assert_equal(expected, @obj.orthologs_as_hash)
    end

    def test_genes_as_hash
      assert_equal({}, @obj.genes_as_hash)
    end

    def test_references
      assert_equal([], @obj.references)
    end

    def test_modules_as_hash
      assert_equal({}, @obj.modules_as_hash)
    end

    def test_new
      assert_instance_of(Bio::KEGG::PATHWAY, @obj)
    end

    def test_entry_id
      assert_equal("ko00312", @obj.entry_id)
    end

    def test_name
      assert_equal("beta-Lactam resistance", @obj.name)
    end

    def test_description
      assert_equal("", @obj.description)
    end

    def test_keggclass
      expected = "Metabolism; Biosynthesis of Other Secondary Metabolites"
      assert_equal(expected, @obj.keggclass)
    end

    def test_pathways_as_strings
      expected = ["ko00312  beta-Lactam resistance"]
      assert_equal(expected, @obj.pathways_as_strings)
    end

    def test_modules_as_strings
      assert_equal([], @obj.modules_as_strings)
    end

    def test_diseases_as_strings
      assert_equal([], @obj.diseases_as_strings)
    end

    def test_diseases_as_hash
      assert_equal({}, @obj.diseases_as_hash)
    end

    def test_dblinks_as_strings
      assert_equal([], @obj.dblinks_as_strings)
    end

    def test_orthologs_as_strings
      expected =
        [ "K02172  bla regulator protein blaR1",
          "K02171  penicillinase repressor",
          "K01467  beta-lactamase [EC:3.5.2.6]",
          "K02352  drp35",
          "K02547  methicillin resistance protein",
          "K02546  methicillin resistance regulatory protein",
          "K02545  penicillin-binding protein 2 prime"
        ]
      assert_equal(expected, @obj.orthologs_as_strings)
    end

    def test_organism
      assert_equal("", @obj.organism)
    end

    def test_genes_as_strings
      assert_equal([], @obj.genes_as_strings)
    end

    def test_enzymes_as_strings
      assert_equal([], @obj.enzymes_as_strings)
    end

    def test_reactions_as_strings
      assert_equal([], @obj.reactions_as_strings)
    end

    def test_reactions_as_hash
      assert_equal({}, @obj.reactions_as_hash)
    end

    def test_compounds_as_strings
      expected = ["C00039  DNA", "C03438  beta-Lactam antibiotics"]
      assert_equal(expected, @obj.compounds_as_strings)
    end

    def test_compounds_as_hash
      expected = {"C03438"=>"beta-Lactam antibiotics", "C00039"=>"DNA"}
      assert_equal(expected, @obj.compounds_as_hash)
    end

    def test_rel_pathways_as_strings
      expected = ["ko00311  Penicillin and cephalosporin biosynthesis"]
      assert_equal(expected, @obj.rel_pathways_as_strings)
    end

    def test_rel_pathways_as_hash
      expected = {"ko00311"=>"Penicillin and cephalosporin biosynthesis"}
      assert_equal(expected, @obj.rel_pathways_as_hash)
    end

    def test_ko_pathway
      assert_equal("", @obj.ko_pathway)
    end

  end #class TestBioKEGGPATHWAY_ko00312

end #module Bio
