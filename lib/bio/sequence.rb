#
# bio/sequence.rb - biological sequence class
#
#   Copyright (c) 2000 KATAYAMA Toshiaki <k@bioruby.org>
#

# Nucleic/Amino Acid sequence

class Sequence < String

  def subseq(str, s, e)
    s += 1
    e += 1
    return str[s..e]
  end

end


# Nucleic Acid sequence

class NAseq < Sequence

  def initialize(str)
    str.downcase!
    return str
  end

  NucleicAcids = {
    # IUPAC code : Faisst and Meyer (Nucleic Acids Res. 20:3-26, 1992)

    "w"=>"[at]", "s"=>"[gc]",
    "r"=>"[ag]", "y"=>"[tc]",
    "m"=>"[ac]", "k"=>"[tg]",

    "d"=>"[atg]",
    "h"=>"[atc]",
    "v"=>"[agc]",
    "b"=>"[tgc]",

    "n"=>"[atgc]",

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

  def count(str, na)
    na.downcase!
    num = 0
    str.each_byte do |x|
      num += 1 if x == na
    end
    return num
  end

  def complement(str)
    str.reverse!
    str.tr!("ATGCatgc", "TACGtagc")
    return str
  end

  def translate(str, frame = 1, table = 1)
    num = frame - 1
    while num < str.length
      codon = str[num,3]
      aaseq += CodonTable[table][codon]
      num += 3
    end
    return aaseq
  end

  def gc_percent(str)
    num_a = num_t = num_g = num_c = num_o = 0
    str.each_byte do |x|
      case x
      when a
	num_a += 1
      when t
	num_t += 1
      when g
	num_g += 1
      when c
	num_c += 1
      else
	num_o += 1
      end
    end
    num_gc = num_g + num_c
    num_atgc = num_a + num_t + num_g + num_c
    gc = sprintf("%.1f", num_gc / num_atgc * 100)
    return gc
  end

  def illegal_bases(str)
    str.scan("^[atgc]").sort.squeeze!
    return str
  end

end


# Amino Acid sequence

class AAseq < Sequence

  def initialize(str)
    str.upcase!
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

  def count(str, aa)
    aa.upcase!
    num = 0
    str.each_byte do |x|
      num += 1 if x == aa
    end
    return num
  end

  def to_list(str)
    array = Array.new
    str.each_byte do |x|
      array.push(AminoAcids[x])
    end
    return array
  end

end

