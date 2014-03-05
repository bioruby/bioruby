#
# = bio/data/aa.rb - Amino Acids
#
# Copyright::	Copyright (C) 2001, 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
# $Id:$
#

module Bio

class AminoAcid

  module Data

    # IUPAC code
    # * http://www.iupac.org/
    # * http://www.chem.qmw.ac.uk/iubmb/newsletter/1999/item3.html
    # * http://www.ebi.ac.uk/RESID/faq.html

    NAMES = {

      'A' => 'Ala',
      'C' => 'Cys',
      'D' => 'Asp',
      'E' => 'Glu',
      'F' => 'Phe',
      'G' => 'Gly',
      'H' => 'His',
      'I' => 'Ile',
      'K' => 'Lys',
      'L' => 'Leu',
      'M' => 'Met',
      'N' => 'Asn',
      'P' => 'Pro',
      'Q' => 'Gln',
      'R' => 'Arg',
      'S' => 'Ser',
      'T' => 'Thr',
      'V' => 'Val',
      'W' => 'Trp',
      'Y' => 'Tyr',
      'B' => 'Asx',	# D/N
      'Z' => 'Glx',	# E/Q
      'J' => 'Xle',	# I/L
      'U' => 'Sec',	# 'uga' (stop)
      'O' => 'Pyl',	# 'uag' (stop)
      'X' => 'Xaa',	# (unknown)
     
      'Ala' => 'alanine',
      'Cys' => 'cysteine',
      'Asp' => 'aspartic acid',
      'Glu' => 'glutamic acid',
      'Phe' => 'phenylalanine',
      'Gly' => 'glycine',
      'His' => 'histidine',
      'Ile' => 'isoleucine',
      'Lys' => 'lysine',
      'Leu' => 'leucine',
      'Met' => 'methionine',
      'Asn' => 'asparagine',
      'Pro' => 'proline',
      'Gln' => 'glutamine',
      'Arg' => 'arginine',
      'Ser' => 'serine',
      'Thr' => 'threonine',
      'Val' => 'valine',
      'Trp' => 'tryptophan',
      'Tyr' => 'tyrosine',
      'Asx' => 'asparagine/aspartic acid [DN]',
      'Glx' => 'glutamine/glutamic acid [EQ]',
      'Xle' => 'isoleucine/leucine [IL]',
      'Sec' => 'selenocysteine',
      'Pyl' => 'pyrrolysine',
      'Xaa' => 'unknown [A-Z]',

    }

    # AAindex FASG760101 - Molecular weight (Fasman, 1976)
    #   Fasman, G.D., ed.
    #   Handbook of Biochemistry and Molecular Biology", 3rd ed.,
    #   Proteins - Volume 1, CRC Press, Cleveland (1976)

    WEIGHT = {

      'A' => 89.09,
      'C' => 121.15,	# 121.16 according to the Wikipedia
      'D' => 133.10,
      'E' => 147.13,
      'F' => 165.19,
      'G' => 75.07,
      'H' => 155.16,
      'I' => 131.17,
      'K' => 146.19,
      'L' => 131.17,
      'M' => 149.21,
      'N' => 132.12,
      'P' => 115.13,
      'Q' => 146.15,
      'R' => 174.20,
      'S' => 105.09,
      'T' => 119.12,
      'U' => 168.06,
      'V' => 117.15,
      'W' => 204.23,
      'Y' => 181.19,
    }

    def weight(x = nil)
      return WEIGHT unless x

      if x.length > 1
        total = 0.0
        x.each_byte do |byte|
          aa = byte.chr.upcase
          if WEIGHT[aa]
            total += WEIGHT[aa]
          else
            raise "Error: invalid amino acid '#{aa}'"
          end
        end
        total -= NucleicAcid.weight[:water] * (x.length - 1)
      else
        WEIGHT[x]
      end
    end

    def [](x)
      NAMES[x]
    end

    # backward compatibility
    def names
      NAMES
    end
    alias aa names

    def name(x)
      str = NAMES[x]
      if str and str.length == 3
        NAMES[str]
      else
        str
      end
    end

    def to_1(x)
      case x.to_s.length
      when 1
        x
      when 3
        three2one(x)
      else
        name2one(x)
      end
    end
    alias one to_1

    def to_3(x)
      case x.to_s.length
      when 1
        one2three(x)
      when 3
        x
      else
        name2three(x)
      end
    end
    alias three to_3

    def one2three(x)
      if x and x.length != 1
        raise ArgumentError
      else
        NAMES[x]
      end
    end

    def three2one(x)
      if x and x.length != 3
        raise ArgumentError
      else
        reverse[x]
      end
    end

    def one2name(x)
      if x and x.length != 1
        raise ArgumentError
      else
        three2name(NAMES[x])
      end
    end

    def name2one(x)
      str = reverse[x.to_s.downcase]
      if str and str.length == 3
        three2one(str)
      else
        str
      end
    end

    def three2name(x)
      if x and x.length != 3
        raise ArgumentError
      else
        NAMES[x]
      end
    end

    def name2three(x)
      reverse[x.downcase]
    end

    def to_re(seq)
      replace = {
        'B' => '[DNB]',
        'Z' => '[EQZ]',
        'J' => '[ILJ]',
        'X' => '[ACDEFGHIKLMNPQRSTVWYUOX]',
      }
      replace.default = '.'

      str = seq.to_s.upcase
      str.gsub!(/[^ACDEFGHIKLMNPQRSTVWYUO]/) { |aa|
        replace[aa]
      }
      Regexp.new(str)
    end


    private


    def reverse
      @reverse ||= NAMES.invert
    end

  end


  # as instance methods
  include Data

  # as class methods
  extend Data


end

end # module Bio


