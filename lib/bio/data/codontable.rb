#
# = bio/data/codontable.rb - Codon Table
#
# Copyright::	Copyright (C) 2001, 2004
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
#
# == Data source
#
# Data in this class is converted from the NCBI's genetic codes page.
#
#  * ((<URL:http://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi?mode=t>))
#
# === Examples
#
# Obtain a codon table No.1 -- Standard (Eukaryote)
#
#   table = Bio::CodonTable[1]
#
# Obtain a copy of the codon table No.1 to modify.  In this example,
# reassign a seleno cystein ('U') to the 'tga' codon.
#
#   table = Bio::CodonTable.copy(1)
#   table['tga'] = 'U'
#
# Create a new codon table by your own from the Hash which contains
# pairs of codon and amino acid.  You can also define the table name
# in the second argument.
#
#   hash = { 'ttt' => 'F', 'ttc' => 'ttc', ... }
#   table = Bio::CodonTable.new(hash, "my codon table")
#
# Obtain a translated amino acid by codon.
#
#   table = Bio::CodonTable[1]
#   table['ttt']  # => F
#
# Reverse translation of a amino acid into a list of relevant codons.
#
#   table = Bio::CodonTable[1]
#   table.revtrans("A")  # => ["gcg", "gct", "gca", "gcc"]
#

module Bio

class CodonTable

  # Select a codon table by number.  This method will return one of the
  # hard coded codon tables in this class as a Bio::CodonTable object.
  def self.[](i)
    hash = TABLES[i]
    raise "ERROR: Unknown codon table No.#{i}" unless hash
    if AMBIGUITY_CODON_TABLES != nil
      atable = AMBIGUITY_CODON_TABLES[i]
    else
      atable = nil
    end
    definition = DEFINITIONS[i]
    start = STARTS[i]
    stop = STOPS[i]
    self.new(hash, definition, start, stop, atable)
  end

  # Similar to Bio::CodonTable[num] but returns a copied codon table.
  # You can modify the codon table without influencing hard coded tables.
  def self.copy(i)
    ct = self[i]
    return Marshal.load(Marshal.dump(ct))
  end

  # Create your own codon table by giving a Hash table of codons and relevant
  # amino acids.  You can also able to define the table's name as a second
  # argument.
  #
  # Two Arrays 'start' and 'stop' can be specified which contains a list of
  # start and stop codons used by 'start_codon?' and 'stop_codon?' methods.
  def initialize(hash, definition = nil, start = [], stop = [], atable = nil)
    @table = hash
    if atable == nil
      @atable = gen_ambiguity_map(hash)
    else
      @atable = atable
    end
    @definition = definition
    @start = start
    @stop = stop.empty? ? generate_stop : stop
  end

  # Accessor methods for a Hash of the currently selected codon table.
  attr_accessor :table

  # Accessor methods for the name of the currently selected table.
  attr_accessor :definition

  # Accessor methods for an Array which contains a list of start or stop
  # codons respectively.
  attr_accessor :start, :stop

  # Compute possible ambiguity nucleotide code to amino acid conversion
  # the codon is defined when all decomposed codon translates to the
  # same amino acid / stop codon
  def gen_ambiguity_map(hash)
    nucleotide_sets={
      'a'       => ['a'],
      't'       => ['t'],
      'g'       => ['g'],
      'c'       => ['c'],

      'y'       => ['t','c'],
      'r'       => ['a','g'],
      'w'       => ['a','t'],
      's'       => ['g','c'],
      'k'       => ['t','g'],
      'm'       => ['a','c'],

      'b'       => ['t','g','c'],
      'd'       => ['a','t','g'],
      'h'       => ['a','t','c'],
      'v'       => ['a','g','c'],

      'n'       => ['a','t','g','c'],
    }
    atable=Hash.new
    nucleotide_sets.keys.each{|n1|
      nucleotide_sets.keys.each{|n2|
        nucleotide_sets.keys.each{|n3|
          a = Array.new
          nucleotide_sets[n1].each{|c1|
            nucleotide_sets[n2].each{|c2|
              nucleotide_sets[n3].each{|c3|
                a << hash["#{c1}#{c2}#{c3}"]
              }
            }
          }
          a.uniq!
          atable["#{n1}#{n2}#{n3}"] = a.to_a[0] if a.size== 1
        }
      }
    }
    atable
  end

  # Translate a codon into a relevant amino acid.  This method is used for
  # translating a DNA sequence into amino acid sequence.
  def [](codon)
    @atable=gen_ambiguity_map(@table) if @atable == nil
    @atable[codon]
  end

  # Modify the codon table.  Use with caution as it may break hard coded
  # tables.  If you want to modify existing table, you should use copy
  # method instead of [] method to generate CodonTable object to be modified.
  #
  #   # This is OK.
  #   table = Bio::CodonTable.copy(1)
  #   table['tga'] = 'U'
  #
  #   # Not recommended as it overrides the hard coded table
  #   table = Bio::CodonTable[1]
  #   table['tga'] = 'U'
  #
  def []=(codon, aa)
    @table[codon] = aa
    @atable = nil
  end

  # Iterates on codon table hash.
  #
  #   table = Bio::CodonTable[1]
  #   table.each do |codon, aa|
  #     puts "#{codon} -- #{aa}"
  #    end
  #
  def each(&block)
    @table.each(&block)
  end

  # Reverse translation of a amino acid into a list of relevant codons.
  #
  #   table = Bio::CodonTable[1]
  #   table.revtrans("A")	# => ["gcg", "gct", "gca", "gcc"]
  #
  def revtrans(aa)
    unless (defined? @reverse) && @reverse
      @reverse = {}
      @table.each do |k, v|
        @reverse[v] ||= []
        @reverse[v] << k
      end
    end
    @reverse[aa.upcase]
  end

  # Returns true if the codon is a start codon in the currently selected
  # codon table, otherwise false.
  def start_codon?(codon)
    @start.include?(codon.downcase)
  end

  # Returns true if the codon is a stop codon in the currently selected
  # codon table, otherwise false.
  def stop_codon?(codon)
    @stop.include?(codon.downcase)
  end

  def generate_stop
    list = []
    @table.each do |codon, aa|
      if aa == '*'
        list << codon
      end
    end
    return list
  end
  private :generate_stop

  DEFINITIONS = {

    1	=> "Standard (Eukaryote)",
    2	=> "Vertebrate Mitochondrial",
    3	=> "Yeast Mitochondorial",
    4	=> "Mold, Protozoan, Coelenterate Mitochondrial and Mycoplasma/Spiroplasma",
    5	=> "Invertebrate Mitochondrial",
    6	=> "Ciliate Macronuclear and Dasycladacean",
    9	=> "Echinoderm Mitochondrial",
    10	=> "Euplotid Nuclear",
    11	=> "Bacteria",
    12	=> "Alternative Yeast Nuclear",
    13	=> "Ascidian Mitochondrial",
    14	=> "Flatworm Mitochondrial",
    15	=> "Blepharisma Macronuclear",
    16	=> "Chlorophycean Mitochondrial",
    21	=> "Trematode Mitochondrial",
    22	=> "Scenedesmus obliquus mitochondrial",
    23	=> "Thraustochytrium Mitochondrial",

  }


  STARTS = {
    1	=> %w(ttg ctg atg gtg),		# gtg added (cf. NCBI #SG1 document)
    2	=> %w(att atc ata atg gtg),
    3	=> %w(ata atg),
    4	=> %w(tta ttg ctg att atc ata atg gtg),
    5	=> %w(ttg att atc ata atg gtg),
    6	=> %w(atg),
    9	=> %w(atg gtg),
    10	=> %w(atg),
    11	=> %w(ttg ctg att atc ata atg gtg),
    12	=> %w(ctg atg),
    13	=> %w(atg),
    14	=> %w(atg),
    15	=> %w(atg),
    16	=> %w(atg),
    21	=> %w(atg gtg),
    22	=> %w(atg),
    23	=> %w(att atg gtg),
  }


  STOPS = {
    1	=> %w(taa tag tga),
    2	=> %w(taa tag aga agg),
    3	=> %w(taa tag),
    4	=> %w(taa tag),
    5	=> %w(taa tag),
    6	=> %w(tga),
    9	=> %w(taa tag),
    10	=> %w(taa tag),
    11	=> %w(taa tag tga),
    12	=> %w(taa tag tga),
    13	=> %w(taa tag),
    14	=> %w(tag),
    15	=> %w(taa tga),
    16	=> %w(taa tga),
    21	=> %w(taa tag),
    22	=> %w(tca taa tga),
    23	=> %w(tta taa tag tga),
  }


  TABLES = {

    # codon table 1
    1 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 2
    2 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => '*',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => '*',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },


    # codon table 3
    3 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'T', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'T', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'T', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'T', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 4
    4 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 5
    5 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'S',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 6
    6 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => 'Q', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => 'Q', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 9
    9 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'N', 'aga' => 'S',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 10
    10 => {

      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'C',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 11
    11 => {
      'ttt' => 'F', 'tct' => 'S', 'tat'	=> 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac'	=> 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa'	=> '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag'	=> '*', 'tgg' => 'W',
       	
      'ctt' => 'L', 'cct' => 'P', 'cat'	=> 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac'	=> 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa'	=> 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag'	=> 'Q', 'cgg' => 'R',
       	
      'att' => 'I', 'act' => 'T', 'aat'	=> 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac'	=> 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa'	=> 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag'	=> 'K', 'agg' => 'R',
       	
      'gtt' => 'V', 'gct' => 'A', 'gat'	=> 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac'	=> 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa'	=> 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag'	=> 'E', 'ggg' => 'G',
    },

    # codon table 12
    12 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'S', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 13
    13 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'G',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'G',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 14
    14 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => 'Y', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'N', 'aga' => 'S',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 15
    15 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => 'Q', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 16
    16 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => 'L', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 21
    21 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'M', 'aca' => 'T', 'aaa' => 'N', 'aga' => 'S',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 22
    22 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => '*', 'taa' => '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => 'L', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 23
    23 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => '*', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

  }

end # CodonTable

end # module Bio

module Bio
class CodonTable
AMBIGUITY_CODON_TABLES = {
1 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"I", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atw"=>"I", "atm"=>"I", "ath"=>"I", "aga"=>"R", "agt"=>"S", "agg"=>"R", "agc"=>"S", "agy"=>"S", "agr"=>"R", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"*", "tac"=>"Y", "tay"=>"Y", "tar"=>"*", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"*", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "tra"=>"*", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yta"=>"L", "ytg"=>"L", "ytr"=>"L", "mga"=>"R", "mgg"=>"R", "mgr"=>"R"}, 
2 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"M", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atr"=>"M", "aga"=>"*", "agt"=>"S", "agg"=>"*", "agc"=>"S", "agy"=>"S", "agr"=>"*", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"*", "tac"=>"Y", "tay"=>"Y", "tar"=>"*", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"W", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tgr"=>"W", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yta"=>"L", "ytg"=>"L", "ytr"=>"L"}, 
3 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"M", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atr"=>"M", "aga"=>"R", "agt"=>"S", "agg"=>"R", "agc"=>"S", "agy"=>"S", "agr"=>"R", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"*", "tac"=>"Y", "tay"=>"Y", "tar"=>"*", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"W", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tgr"=>"W", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"T", "ctt"=>"T", "ctg"=>"T", "ctc"=>"T", "cty"=>"T", "ctr"=>"T", "ctw"=>"T", "cts"=>"T", "ctk"=>"T", "ctm"=>"T", "ctb"=>"T", "ctd"=>"T", "cth"=>"T", "ctv"=>"T", "ctn"=>"T", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "mga"=>"R", "mgg"=>"R", "mgr"=>"R"}, 
4 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"I", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atw"=>"I", "atm"=>"I", "ath"=>"I", "aga"=>"R", "agt"=>"S", "agg"=>"R", "agc"=>"S", "agy"=>"S", "agr"=>"R", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"*", "tac"=>"Y", "tay"=>"Y", "tar"=>"*", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"W", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tgr"=>"W", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yta"=>"L", "ytg"=>"L", "ytr"=>"L", "mga"=>"R", "mgg"=>"R", "mgr"=>"R"}, 
5 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"M", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atr"=>"M", "aga"=>"S", "agt"=>"S", "agg"=>"S", "agc"=>"S", "agy"=>"S", "agr"=>"S", "agw"=>"S", "ags"=>"S", "agk"=>"S", "agm"=>"S", "agb"=>"S", "agd"=>"S", "agh"=>"S", "agv"=>"S", "agn"=>"S", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"*", "tac"=>"Y", "tay"=>"Y", "tar"=>"*", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"W", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tgr"=>"W", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yta"=>"L", "ytg"=>"L", "ytr"=>"L"}, 
6 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"I", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atw"=>"I", "atm"=>"I", "ath"=>"I", "aga"=>"R", "agt"=>"S", "agg"=>"R", "agc"=>"S", "agy"=>"S", "agr"=>"R", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"Q", "tat"=>"Y", "tag"=>"Q", "tac"=>"Y", "tay"=>"Y", "tar"=>"Q", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"*", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yaa"=>"Q", "yag"=>"Q", "yar"=>"Q", "yta"=>"L", "ytg"=>"L", "ytr"=>"L", "mga"=>"R", "mgg"=>"R", "mgr"=>"R"}, 
9 =>
{"aaa"=>"N", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aaw"=>"N", "aam"=>"N", "aah"=>"N", "ata"=>"I", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atw"=>"I", "atm"=>"I", "ath"=>"I", "aga"=>"S", "agt"=>"S", "agg"=>"S", "agc"=>"S", "agy"=>"S", "agr"=>"S", "agw"=>"S", "ags"=>"S", "agk"=>"S", "agm"=>"S", "agb"=>"S", "agd"=>"S", "agh"=>"S", "agv"=>"S", "agn"=>"S", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"*", "tac"=>"Y", "tay"=>"Y", "tar"=>"*", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"W", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tgr"=>"W", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yta"=>"L", "ytg"=>"L", "ytr"=>"L"}, 
10 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"I", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atw"=>"I", "atm"=>"I", "ath"=>"I", "aga"=>"R", "agt"=>"S", "agg"=>"R", "agc"=>"S", "agy"=>"S", "agr"=>"R", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"*", "tac"=>"Y", "tay"=>"Y", "tar"=>"*", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"C", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tgw"=>"C", "tgm"=>"C", "tgh"=>"C", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yta"=>"L", "ytg"=>"L", "ytr"=>"L", "mga"=>"R", "mgg"=>"R", "mgr"=>"R"}, 
11 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"I", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atw"=>"I", "atm"=>"I", "ath"=>"I", "aga"=>"R", "agt"=>"S", "agg"=>"R", "agc"=>"S", "agy"=>"S", "agr"=>"R", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"*", "tac"=>"Y", "tay"=>"Y", "tar"=>"*", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"*", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "tra"=>"*", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yta"=>"L", "ytg"=>"L", "ytr"=>"L", "mga"=>"R", "mgg"=>"R", "mgr"=>"R"}, 
12 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"I", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atw"=>"I", "atm"=>"I", "ath"=>"I", "aga"=>"R", "agt"=>"S", "agg"=>"R", "agc"=>"S", "agy"=>"S", "agr"=>"R", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"*", "tac"=>"Y", "tay"=>"Y", "tar"=>"*", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"*", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "tra"=>"*", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"S", "ctc"=>"L", "cty"=>"L", "ctw"=>"L", "ctm"=>"L", "cth"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yta"=>"L", "mga"=>"R", "mgg"=>"R", "mgr"=>"R"}, 
13 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"M", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atr"=>"M", "aga"=>"G", "agt"=>"S", "agg"=>"G", "agc"=>"S", "agy"=>"S", "agr"=>"G", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"*", "tac"=>"Y", "tay"=>"Y", "tar"=>"*", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"W", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tgr"=>"W", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yta"=>"L", "ytg"=>"L", "ytr"=>"L", "rga"=>"G", "rgg"=>"G", "rgr"=>"G"}, 
14 =>
{"aaa"=>"N", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aaw"=>"N", "aam"=>"N", "aah"=>"N", "ata"=>"I", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atw"=>"I", "atm"=>"I", "ath"=>"I", "aga"=>"S", "agt"=>"S", "agg"=>"S", "agc"=>"S", "agy"=>"S", "agr"=>"S", "agw"=>"S", "ags"=>"S", "agk"=>"S", "agm"=>"S", "agb"=>"S", "agd"=>"S", "agh"=>"S", "agv"=>"S", "agn"=>"S", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"Y", "tat"=>"Y", "tag"=>"*", "tac"=>"Y", "tay"=>"Y", "taw"=>"Y", "tam"=>"Y", "tah"=>"Y", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"W", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tgr"=>"W", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yta"=>"L", "ytg"=>"L", "ytr"=>"L"}, 
15 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"I", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atw"=>"I", "atm"=>"I", "ath"=>"I", "aga"=>"R", "agt"=>"S", "agg"=>"R", "agc"=>"S", "agy"=>"S", "agr"=>"R", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"Q", "tac"=>"Y", "tay"=>"Y", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"*", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "tra"=>"*", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yag"=>"Q", "yta"=>"L", "ytg"=>"L", "ytr"=>"L", "mga"=>"R", "mgg"=>"R", "mgr"=>"R"}, 
16 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"I", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atw"=>"I", "atm"=>"I", "ath"=>"I", "aga"=>"R", "agt"=>"S", "agg"=>"R", "agc"=>"S", "agy"=>"S", "agr"=>"R", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"L", "tac"=>"Y", "tay"=>"Y", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"*", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "tra"=>"*", "twg"=>"L", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yta"=>"L", "ytg"=>"L", "ytr"=>"L", "mga"=>"R", "mgg"=>"R", "mgr"=>"R"}, 
21 =>
{"aaa"=>"N", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aaw"=>"N", "aam"=>"N", "aah"=>"N", "ata"=>"M", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atr"=>"M", "aga"=>"S", "agt"=>"S", "agg"=>"S", "agc"=>"S", "agy"=>"S", "agr"=>"S", "agw"=>"S", "ags"=>"S", "agk"=>"S", "agm"=>"S", "agb"=>"S", "agd"=>"S", "agh"=>"S", "agv"=>"S", "agn"=>"S", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"*", "tac"=>"Y", "tay"=>"Y", "tar"=>"*", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"W", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tgr"=>"W", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yta"=>"L", "ytg"=>"L", "ytr"=>"L"}, 
22 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"I", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atw"=>"I", "atm"=>"I", "ath"=>"I", "aga"=>"R", "agt"=>"S", "agg"=>"R", "agc"=>"S", "agy"=>"S", "agr"=>"R", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"L", "tac"=>"Y", "tay"=>"Y", "tta"=>"L", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "ttr"=>"L", "tga"=>"*", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tca"=>"*", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcs"=>"S", "tck"=>"S", "tcb"=>"S", "tra"=>"*", "twg"=>"L", "tsa"=>"*", "tma"=>"*", "tva"=>"*", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "yta"=>"L", "ytg"=>"L", "ytr"=>"L", "mga"=>"R", "mgg"=>"R", "mgr"=>"R"}, 
23 =>
{"aaa"=>"K", "aat"=>"N", "aag"=>"K", "aac"=>"N", "aay"=>"N", "aar"=>"K", "ata"=>"I", "att"=>"I", "atg"=>"M", "atc"=>"I", "aty"=>"I", "atw"=>"I", "atm"=>"I", "ath"=>"I", "aga"=>"R", "agt"=>"S", "agg"=>"R", "agc"=>"S", "agy"=>"S", "agr"=>"R", "aca"=>"T", "act"=>"T", "acg"=>"T", "acc"=>"T", "acy"=>"T", "acr"=>"T", "acw"=>"T", "acs"=>"T", "ack"=>"T", "acm"=>"T", "acb"=>"T", "acd"=>"T", "ach"=>"T", "acv"=>"T", "acn"=>"T", "taa"=>"*", "tat"=>"Y", "tag"=>"*", "tac"=>"Y", "tay"=>"Y", "tar"=>"*", "tta"=>"*", "ttt"=>"F", "ttg"=>"L", "ttc"=>"F", "tty"=>"F", "tga"=>"*", "tgt"=>"C", "tgg"=>"W", "tgc"=>"C", "tgy"=>"C", "tca"=>"S", "tct"=>"S", "tcg"=>"S", "tcc"=>"S", "tcy"=>"S", "tcr"=>"S", "tcw"=>"S", "tcs"=>"S", "tck"=>"S", "tcm"=>"S", "tcb"=>"S", "tcd"=>"S", "tch"=>"S", "tcv"=>"S", "tcn"=>"S", "tra"=>"*", "twa"=>"*", "tka"=>"*", "tda"=>"*", "gaa"=>"E", "gat"=>"D", "gag"=>"E", "gac"=>"D", "gay"=>"D", "gar"=>"E", "gta"=>"V", "gtt"=>"V", "gtg"=>"V", "gtc"=>"V", "gty"=>"V", "gtr"=>"V", "gtw"=>"V", "gts"=>"V", "gtk"=>"V", "gtm"=>"V", "gtb"=>"V", "gtd"=>"V", "gth"=>"V", "gtv"=>"V", "gtn"=>"V", "gga"=>"G", "ggt"=>"G", "ggg"=>"G", "ggc"=>"G", "ggy"=>"G", "ggr"=>"G", "ggw"=>"G", "ggs"=>"G", "ggk"=>"G", "ggm"=>"G", "ggb"=>"G", "ggd"=>"G", "ggh"=>"G", "ggv"=>"G", "ggn"=>"G", "gca"=>"A", "gct"=>"A", "gcg"=>"A", "gcc"=>"A", "gcy"=>"A", "gcr"=>"A", "gcw"=>"A", "gcs"=>"A", "gck"=>"A", "gcm"=>"A", "gcb"=>"A", "gcd"=>"A", "gch"=>"A", "gcv"=>"A", "gcn"=>"A", "caa"=>"Q", "cat"=>"H", "cag"=>"Q", "cac"=>"H", "cay"=>"H", "car"=>"Q", "cta"=>"L", "ctt"=>"L", "ctg"=>"L", "ctc"=>"L", "cty"=>"L", "ctr"=>"L", "ctw"=>"L", "cts"=>"L", "ctk"=>"L", "ctm"=>"L", "ctb"=>"L", "ctd"=>"L", "cth"=>"L", "ctv"=>"L", "ctn"=>"L", "cga"=>"R", "cgt"=>"R", "cgg"=>"R", "cgc"=>"R", "cgy"=>"R", "cgr"=>"R", "cgw"=>"R", "cgs"=>"R", "cgk"=>"R", "cgm"=>"R", "cgb"=>"R", "cgd"=>"R", "cgh"=>"R", "cgv"=>"R", "cgn"=>"R", "cca"=>"P", "cct"=>"P", "ccg"=>"P", "ccc"=>"P", "ccy"=>"P", "ccr"=>"P", "ccw"=>"P", "ccs"=>"P", "cck"=>"P", "ccm"=>"P", "ccb"=>"P", "ccd"=>"P", "cch"=>"P", "ccv"=>"P", "ccn"=>"P", "ytg"=>"L", "mga"=>"R", "mgg"=>"R", "mgr"=>"R"}, 
}
end #CodonTable
end #Bio
