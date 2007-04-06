#
# = bio/data/na.rb - Nucleic Acids
#
# Copyright::	Copyright (C) 2001, 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
# $Id: na.rb,v 0.23 2007/04/06 04:41:28 k Exp $
#
# == Synopsis
#
# Bio::NucleicAcid class contains data related to nucleic acids.
#
# == Usage
#
# Examples:
#
#   require 'bio'
#
#   puts "### na = Bio::NucleicAcid.new"
#   na = Bio::NucleicAcid.new
#
#   puts "# na.to_re('yrwskmbdhvnatgc')"
#   p na.to_re('yrwskmbdhvnatgc')
#
#   puts "# Bio::NucleicAcid.to_re('yrwskmbdhvnatgc')"
#   p Bio::NucleicAcid.to_re('yrwskmbdhvnatgc')
#
#   puts "# na.weight('A')"
#   p na.weight('A')
#
#   puts "# Bio::NucleicAcid.weight('A')"
#   p Bio::NucleicAcid.weight('A')
#
#   puts "# na.weight('atgc')"
#   p na.weight('atgc')
#
#   puts "# Bio::NucleicAcid.weight('atgc')"
#   p Bio::NucleicAcid.weight('atgc')
#

module Bio

class NucleicAcid

  module Data

    # IUPAC code
    # * Faisst and Meyer (Nucleic Acids Res. 20:3-26, 1992)
    # * http://www.ncbi.nlm.nih.gov/collab/FT/

    NAMES = {

      'y'	=> '[tc]',
      'r'	=> '[ag]',
      'w'	=> '[at]',
      's'	=> '[gc]',
      'k'	=> '[tg]',
      'm'	=> '[ac]',

      'b'	=> '[tgc]',
      'd'	=> '[atg]',
      'h'	=> '[atc]',
      'v'	=> '[agc]',

      'n'	=> '[atgc]',

      'a'	=> 'a',
      't'	=> 't',
      'g'	=> 'g',
      'c'	=> 'c',
      'u'	=> 'u',

      'A'	=> 'Adenine',
      'T'	=> 'Thymine',
      'G'	=> 'Guanine',
      'C'	=> 'Cytosine',
      'U'	=> 'Uracil',

      'Y'	=> 'pYrimidine',
      'R'	=> 'puRine',
      'W'	=> 'Weak',
      'S'	=> 'Strong',
      'K'	=> 'Keto',
      'M'	=> 'aroMatic',

      'B'	=> 'not A',
      'D'	=> 'not C',
      'H'	=> 'not G',
      'V'	=> 'not T',
    }

    WEIGHT = {

      # Calculated by BioPerl's Bio::Tools::SeqStats.pm :-)

      'a'	=> 135.15,
      't'	=> 126.13,
      'g'	=> 151.15,
      'c'	=> 111.12,
      'u'	=> 112.10,

      :adenine	=> 135.15,
      :thymine	=> 126.13,
      :guanine	=> 151.15,
      :cytosine	=> 111.12,
      :uracil	=> 112.10,

      :deoxyribose_phosphate	=> 196.11,
      :ribose_phosphate		=> 212.11,

      :hydrogen	=> 1.00794,
      :water	=> 18.015,

    }

    def weight(x = nil, rna = nil)
      if x
        if x.length > 1
          if rna
            phosphate = WEIGHT[:ribose_phosphate]
          else
            phosphate = WEIGHT[:deoxyribose_phosphate]
          end
          hydrogen    = WEIGHT[:hydrogen]
          water       = WEIGHT[:water]

          total = 0.0
          x.each_byte do |byte|
            base = byte.chr.downcase
            if WEIGHT[base]
              total += WEIGHT[base] + phosphate - hydrogen * 2
            else
              raise "Error: invalid nucleic acid '#{base}'"
            end
          end
          total -= water * (x.length - 1)
        else
          WEIGHT[x.to_s.downcase]
        end
      else
        WEIGHT
      end
    end

    def [](x)
      NAMES[x]
    end

    # backward compatibility
    def names
      NAMES
    end
    alias na names

    def name(x)
      NAMES[x.to_s.upcase]
    end

    def to_re(seq, rna = false)
      replace = {
        'y' => '[tcy]',
        'r' => '[agr]',
        'w' => '[atw]',
        's' => '[gcw]',
        'k' => '[tgk]',
        'm' => '[acm]',
        'b' => '[tgcyskb]',
        'd' => '[atgrwkd]',
        'h' => '[atcwmyh]',
        'v' => '[agcmrsv]',
        'n' => '[atgcyrwskmbdhvn]'
      }
      replace.default = '.'

      str = seq.to_s.downcase
      str.gsub!(/[^atgcu]/) { |na|
        replace[na]
      }
      if rna
        str.tr!("t", "u")
      end
      Regexp.new(str)
    end

  end


  # as instance methods
  include Data

  # as class methods
  extend Data

end

end # module Bio


if __FILE__ == $0

  puts "### na = Bio::NucleicAcid.new"
  na = Bio::NucleicAcid.new

  puts "# na.to_re('yrwskmbdhvnatgc')"
  p na.to_re('yrwskmbdhvnatgc')

  puts "# Bio::NucleicAcid.to_re('yrwskmbdhvnatgc')"
  p Bio::NucleicAcid.to_re('yrwskmbdhvnatgc')

  puts "# na.weight('A')"
  p na.weight('A')

  puts "# Bio::NucleicAcid.weight('A')"
  p Bio::NucleicAcid.weight('A')

  puts "# na.weight('atgc')"
  p na.weight('atgc')

  puts "# Bio::NucleicAcid.weight('atgc')"
  p Bio::NucleicAcid.weight('atgc')

end
