#
# bio/sequence.rb - biological sequence class
#
#   Copyright (C) 2000, 2001 KATAYAMA Toshiaki <k@bioruby.org>
#

# Nucleic/Amino Acid sequence

class Sequence < String

  def initialize(str)
    super
  end

end


# Nucleic Acid sequence

class NAseq < Sequence

  def initialize(str)
    super.downcase!
    super.tr!('u', 't')
  end

  NucleicAcids = {
    # IUPAC code : Faisst and Meyer (Nucleic Acids Res. 20:3-26, 1992)

    "w"=>/[at]/, "s"=>/[gc]/,
    "r"=>/[ag]/, "y"=>/[tc]/,
    "m"=>/[ac]/, "k"=>/[tg]/,

    "d"=>/[atg]/,
    "h"=>/[atc]/,
    "v"=>/[agc]/,
    "b"=>/[tgc]/,

    "n"=>/[atgc]/,

    "a"=>"adenine",
    "t"=>"thymine",
    "g"=>"guanine",
    "c"=>"cytosine",

    "u"=>"uracil",
  }

  CodonTable = [
    # codon table 0
    {},

    # codon table 1
    {
      "ttt"=>"F", "tct"=>"S", "tat"=>"Y", "tgt"=>"C",
      "ttc"=>"F", "tcc"=>"S", "tac"=>"Y", "tgc"=>"C",
      "tta"=>"L", "tca"=>"S", "taa"=>"*", "tga"=>"*",
      "ttg"=>"L", "tcg"=>"S", "tag"=>"*", "tgg"=>"W",

      "ctt"=>"L", "cct"=>"P", "cat"=>"H", "cgt"=>"R",
      "ctc"=>"L", "ccc"=>"P", "cac"=>"H", "cgc"=>"R",
      "cta"=>"L", "cca"=>"P", "caa"=>"Q", "cga"=>"R",
      "ctg"=>"L", "ccg"=>"P", "cag"=>"Q", "cgg"=>"R",

      "att"=>"I", "act"=>"T", "aat"=>"N", "agt"=>"S",
      "atc"=>"I", "acc"=>"T", "aac"=>"N", "agc"=>"S",
      "ata"=>"I", "aca"=>"T", "aaa"=>"K", "aga"=>"R",
      "atg"=>"M", "acg"=>"T", "aag"=>"K", "agg"=>"R",

      "gtt"=>"V", "gct"=>"A", "gat"=>"D", "ggt"=>"G",
      "gtc"=>"V", "gcc"=>"A", "gac"=>"D", "ggc"=>"G",
      "gta"=>"V", "gca"=>"A", "gaa"=>"E", "gga"=>"G",
      "gtg"=>"V", "gcg"=>"A", "gag"=>"E", "ggg"=>"G",
    },

    # codon table 2
    {},

    # codon table 3
    {},

    # codon table 4
    {},

    # codon table 5
    {},

    # codon table 6
    {},

    # codon table 7
    {},

    # codon table 8
    {},

    # codon table 9
    {},

    # codon table 10
    {},

    # codon table 11
    {
      "ttt"=>"F", "tct"=>"S", "tat"=>"Y", "tgt"=>"C",
      "ttc"=>"F", "tcc"=>"S", "tac"=>"Y", "tgc"=>"C",
      "tta"=>"L", "tca"=>"S", "taa"=>"*", "tga"=>"*",
      "ttg"=>"L", "tcg"=>"S", "tag"=>"*", "tgg"=>"W",

      "ctt"=>"L", "cct"=>"P", "cat"=>"H", "cgt"=>"R",
      "ctc"=>"L", "ccc"=>"P", "cac"=>"H", "cgc"=>"R",
      "cta"=>"L", "cca"=>"P", "caa"=>"Q", "cga"=>"R",
      "ctg"=>"L", "ccg"=>"P", "cag"=>"Q", "cgg"=>"R",

      "att"=>"I", "act"=>"T", "aat"=>"N", "agt"=>"S",
      "atc"=>"I", "acc"=>"T", "aac"=>"N", "agc"=>"S",
      "ata"=>"I", "aca"=>"T", "aaa"=>"K", "aga"=>"R",
      "atg"=>"M", "acg"=>"T", "aag"=>"K", "agg"=>"R",

      "gtt"=>"V", "gct"=>"A", "gat"=>"D", "ggt"=>"G",
      "gtc"=>"V", "gcc"=>"A", "gac"=>"D", "ggc"=>"G",
      "gta"=>"V", "gca"=>"A", "gaa"=>"E", "gga"=>"G",
      "gtg"=>"V", "gcg"=>"A", "gag"=>"E", "ggg"=>"G",
    },
  ]

  def subseq(s = 1, e = self.length)
    s -= 1
    e -= 1
    return NAseq.new(self[s..e])
  end

  def count(base)
    b = base.downcase[0]
    n = 0
    self.each_byte do |x|
      n += 1 if x == b
    end
    return n
  end

  def complement
    str = self.reverse
    str.tr!("atgc", "tacg")
    return NAseq.new(str)
  end

  def translate(frame = 1, table = 1)
    frame -= 1
    aaseq = AAseq.new('')
    frame.step(self.length - 3, 3) do |i|
      codon = self[i,3]
      if CodonTable[table][codon]
	aaseq << CodonTable[table][codon]
      else
	aaseq << "X"
      end
    end
    return aaseq
  end

  def gc_percent
    count = Hash.new(0)
    self.scan(/./) do |b|
      count[b] += 1
    end
    at = count['a'] + count['t']
    gc = count['g'] + count['c']
    gc = sprintf("%.1f", gc.to_f / (at + gc) * 100)
    return gc
  end
  alias gc gc_percent

  def illegal_bases
    a = self.scan(/[^atgc]/).sort.uniq
    return a
  end
  alias ib illegal_bases

end


# Amino Acid sequence

class AAseq < Sequence

  def initialize(str)
    super.upcase!
  end

  AminoAcids = {
    "A"=>"Ala", "C"=>"Cys", "D"=>"Asp", "E"=>"Glu",
    "F"=>"Phe", "G"=>"Gly", "H"=>"His", "I"=>"Ile",
    "K"=>"Lys", "L"=>"Leu", "M"=>"Met", "N"=>"Asn",
    "P"=>"Pro", "Q"=>"Gln", "R"=>"Arg", "S"=>"Ser",
    "T"=>"Thr", "V"=>"Val", "W"=>"Trp", "Y"=>"Tyr",

    "Ala"=>"alanine",
    "Cys"=>"cysteine",
    "Asp"=>"aspartic acid",
    "Glu"=>"glutamic acid",
    "Phe"=>"phenylalanine",
    "Gly"=>"glycine",
    "His"=>"histidine",
    "Ile"=>"isoleucine",
    "Lys"=>"lysine",
    "Leu"=>"leucine",
    "Met"=>"methionine",
    "Asn"=>"asparagine",
    "Pro"=>"proline",
    "Gln"=>"glutamine",
    "Arg"=>"arginine",
    "Ser"=>"serine",
    "Thr"=>"threonine",
    "Val"=>"valine",
    "Trp"=>"tryptophan",
    "Tyr"=>"tyrosine",
  }

  def subseq(s = 1, e = self.length)
    s -= 1
    e -= 1
    return AAseq.new(self[s..e])
  end

  def count(amino)
    a = amino.upcase[0]
    n = 0
    str.each_byte do |x|
      n += 1 if x == a
    end
    return n
  end

  def to_list
    array = []
    self.each_byte do |x|
      array.push(AminoAcids[x.chr])
    end
    return array
  end

end

