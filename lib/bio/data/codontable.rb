#
# = bio/data/codontable.rb - Codon Table
#
# Copyright::	Copyright (C) 2001, 2004
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
# $Id: codontable.rb,v 0.18 2007/04/05 23:35:40 trevor Exp $
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
    definition = DEFINITIONS[i]
    start = STARTS[i]
    stop = STOPS[i]
    self.new(hash, definition, start, stop)
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
  def initialize(hash, definition = nil, start = [], stop = [])
    @table = hash
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

  # Translate a codon into a relevant amino acid.  This method is used for
  # translating a DNA sequence into amino acid sequence.
  def [](codon)
    @table[codon]
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
    unless @reverse
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


if __FILE__ == $0

  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  puts "### Bio::CodonTable[1]"
  p ct1 = Bio::CodonTable[1]

  puts ">>> Bio::CodonTable#table"
  p ct1.table

  puts ">>> Bio::CodonTable#each"
  ct1.each do |codon, aa|
    puts "#{codon} -- #{aa}"
  end

  puts ">>> Bio::CodonTable#definition"
  p ct1.definition

  puts ">>> Bio::CodonTable#['atg']"
  p ct1['atg']

  puts ">>> Bio::CodonTable#revtrans('A')"
  p ct1.revtrans('A')

  puts ">>> Bio::CodonTable#start_codon?('atg')"
  p ct1.start_codon?('atg')
  
  puts ">>> Bio::CodonTable#start_codon?('aaa')"
  p ct1.start_codon?('aaa')

  puts ">>> Bio::CodonTable#stop_codon?('tag')"
  p ct1.stop_codon?('tag')
  
  puts ">>> Bio::CodonTable#stop_codon?('aaa')"
  p ct1.stop_codon?('aaa')

  puts ">>> ct1_copy = Bio::CodonTable.copy(1)"
  p ct1_copy = Bio::CodonTable.copy(1)
  puts ">>> ct1_copy['tga'] = 'U'"
  p ct1_copy['tga'] = 'U'
  puts " orig : #{ct1['tga']}"
  puts " copy : #{ct1_copy['tga']}"


  puts "### ct = Bio::CodonTable.new(hash, definition)"
  hash = {
    'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
    'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
    'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'U',
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
  }
  my_ct = Bio::CodonTable.new(hash, "my codon table")

  puts ">>> ct.definition"
  puts my_ct.definition

  puts ">>> ct.definition=(str)"
  my_ct.definition = "selenoproteins (Eukaryote)"
  puts my_ct.definition

  puts ">>> ct['tga']"
  puts my_ct['tga']

  puts ">>> ct.revtrans('U')"
  puts my_ct.revtrans('U')

  puts ">>> ct.stop_codon?('tga')"
  puts my_ct.stop_codon?('tga')

  puts ">>> ct.stop_codon?('tag')"
  puts my_ct.stop_codon?('tag')

end

