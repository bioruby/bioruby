# encoding: utf-8
#
#
# = bio/appl/protparam.rb - A Class to Calculate Protein Parameters.
#
# Copyright:: Copyright (C) 2012
#             Hiroyuki Nakamura <hiroyuki@1vq9.com>
# License::   The Ruby License
#
require 'rational'

module Bio
  ##
  # == Description
  #
  # Bio::Protparam is a class for calculating protein paramesters. This class
  # has a similer interface to BioPerl's Bio::Tools::Protparam. However, it
  # calculate parameters instead of throwing a query to Expasy's {Protparam
  # tool}[http://web.expasy.org/protparam/]{[1]}[rdoc-label:1] as Bio::Tools::Protparam does.
  #
  class Protparam

    # {IUPAC codes}[http://www.bioinformatics.org/sms2/iupac.html] for amino acids.
    IUPAC_CODE = {
      :I => "Ile",
      :V => "Val",
      :L => "Leu",
      :F => "Phe",
      :C => "Cys",
      :M => "Met",
      :A => "Ala",
      :G => "Gly",
      :T => "Thr",
      :W => "Trp",
      :S => "Ser",
      :Y => "Tyr",
      :P => "Pro",
      :H => "His",
      :E => "Glu",
      :Q => "Gln",
      :D => "Asp",
      :N => "Asn",
      :K => "Lys",
      :R => "Arg",
      :U => "Sec",
      :O => "Pyl",
      :B => "Asx",
      :Z => "Glx",
      :X => "Xaa"
    }

    # Dipeptide instability weight value for calculating instability index of proteins {[10]}[rdoc-label:10].
    DIWV = {
      :W => {
        :W => 1.0,   :C => 1.0,   :M => 24.68, :H => 24.68, :Y => 1.0, :F => 1.0,    :Q => 1.0,
        :N => 13.34, :I => 1.0,   :R => 1.0,   :D => 1.0,   :P => 1.0, :T => -14.03, :K => 1.0,
        :E => 1.0,   :V => -7.49, :S => 1.0,   :G => -9.37, :A => -14.03, :L => 13.34
      },
      :C => {
        :W => 24.68, :C => 1.0, :M => 33.6, :H => 33.6, :Y => 1.0, :F => 1.0, :Q => -6.54, :N => 1.0,
        :I => 1.0, :R => 1.0, :D => 20.26, :P => 20.26, :T => 33.6, :K => 1.0, :E => 1.0, :V => -6.54,
        :S => 1.0, :G => 1.0, :A => 1.0, :L => 20.26
      },
      :M => {
        :W => 1.0, :C => 1.0, :M => -1.88, :H => 58.28, :Y => 24.68, :F => 1.0, :Q => -6.54,
        :N => 1.0, :I => 1.0, :R => -6.54, :D => 1.0, :P => 44.94, :T => -1.88, :K => 1.0, :E => 1.0,
        :V => 1.0, :S => 44.94, :G => 1.0, :A => 13.34, :L => 1.0
      },
      :H => {
        :W => -1.88, :C => 1.0, :M => 1.0, :H => 1.0, :Y => 44.94, :F => -9.37, :Q => 1.0,
        :N => 24.68, :I => 44.94, :R => 1.0, :D => 1.0, :P => -1.88, :T => -6.54, :K => 24.68,
        :E => 1.0, :V => 1.0, :S => 1.0, :G => -9.37, :A => 1.0, :L => 1.0
      },
      :Y => {
        :W => -9.37, :C => 1.0, :M => 44.94, :H => 13.34, :Y => 13.34, :F => 1.0, :Q => 1.0,
        :N => 1.0, :I => 1.0, :R => -15.91, :D => 24.68, :P => 13.34, :T => -7.49, :K => 1.0,
        :E => -6.54, :V => 1.0, :S => 1.0, :G => -7.49, :A => 24.68, :L => 1.0
      },
      :F => {
        :W => 1.0, :C => 1.0, :M => 1.0, :H => 1.0, :Y => 33.6, :F => 1.0, :Q => 1.0, :N => 1.0,
        :I => 1.0, :R => 1.0, :D => 13.34, :P => 20.26, :T => 1.0, :K => -14.03, :E => 1.0,
        :V => 1.0, :S => 1.0, :G => 1.0, :A => 1.0, :L => 1.0
      },
      :Q => {
        :W => 1.0, :C => -6.54, :M => 1.0, :H => 1.0, :Y => -6.54, :F => -6.54, :Q => 20.26,
        :N => 1.0, :I => 1.0, :R => 1.0, :D => 20.26, :P => 20.26, :T => 1.0, :K => 1.0, :E => 20.26,
        :V => -6.54, :S => 44.94, :G => 1.0, :A => 1.0, :L => 1.0
      },
      :N => {
        :W => -9.37, :C => -1.88, :M => 1.0, :H => 1.0,    :Y => 1.0,   :F => -14.03, :Q => -6.54,
        :N => 1.0,   :I => 44.94, :R => 1.0, :D => 1.0,    :P => -1.88, :T => -7.49,  :K => 24.68,
        :E => 1.0,   :V => 1.0,   :S => 1.0, :G => -14.03, :A => 1.0,   :L => 1.0
      },
      :I => {
        :W => 1.0,   :C => 1.0, :M => 1.0, :H => 13.34, :Y => 1.0, :F => 1.0,   :Q => 1.0, :N => 1.0,
        :I => 1.0,   :R => 1.0, :D => 1.0, :P => -1.88, :T => 1.0, :K => -7.49, :E => 44.94,
        :V => -7.49, :S => 1.0, :G => 1.0, :A => 1.0,   :L => 20.26
      },
      :R => {
        :W => 58.28, :C => 1.0, :M => 1.0, :H => 20.26, :Y => -6.54, :F => 1.0, :Q => 20.26,
        :N => 13.34, :I => 1.0, :R => 58.28, :D => 1.0, :P => 20.26, :T => 1.0, :K => 1.0, :E => 1.0,
        :V => 1.0, :S => 44.94, :G => -7.49, :A => 1.0, :L => 1.0
      },
      :D => {
        :W => 1.0, :C => 1.0, :M => 1.0, :H => 1.0, :Y => 1.0, :F => -6.54, :Q => 1.0, :N => 1.0,
        :I => 1.0, :R => -6.54, :D => 1.0, :P => 1.0, :T => -14.03, :K => -7.49, :E => 1.0,
        :V => 1.0, :S => 20.26, :G => 1.0, :A => 1.0, :L => 1.0
      },
      :P => {
        :W => -1.88, :C => -6.54, :M => -6.54, :H => 1.0, :Y => 1.0, :F => 20.26, :Q => 20.26,
        :N => 1.0, :I => 1.0, :R => -6.54, :D => -6.54, :P => 20.26, :T => 1.0, :K => 1.0, :E => 18.38,
        :V => 20.26, :S => 20.26, :G => 1.0, :A => 20.26, :L => 1.0
      },
      :T => {
        :W => -14.03, :C => 1.0, :M => 1.0, :H => 1.0, :Y => 1.0, :F => 13.34, :Q => -6.54,
        :N => -14.03, :I => 1.0, :R => 1.0, :D => 1.0, :P => 1.0, :T => 1.0, :K => 1.0, :E => 20.26,
        :V => 1.0, :S => 1.0, :G => -7.49, :A => 1.0, :L => 1.0
      },
      :K => {
        :W => 1.0, :C => 1.0, :M => 33.6, :H => 1.0, :Y => 1.0, :F => 1.0, :Q => 24.68, :N => 1.0,
        :I => -7.49, :R => 33.6, :D => 1.0, :P => -6.54, :T => 1.0, :K => 1.0, :E => 1.0, :V => -7.49,
        :S => 1.0, :G => -7.49, :A => 1.0, :L => -7.49
      },
      :E => {
        :W => -14.03, :C => 44.94, :M => 1.0, :H => -6.54, :Y => 1.0, :F => 1.0, :Q => 20.26,
        :N => 1.0, :I => 20.26, :R => 1.0, :D => 20.26, :P => 20.26, :T => 1.0, :K => 1.0, :E => 33.6,
        :V => 1.0, :S => 20.26, :G => 1.0, :A => 1.0, :L => 1.0
      },
      :V => {
        :W => 1.0, :C => 1.0, :M => 1.0, :H => 1.0, :Y => -6.54, :F => 1.0, :Q => 1.0, :N => 1.0,
        :I => 1.0, :R => 1.0, :D => -14.03, :P => 20.26, :T => -7.49, :K => -1.88, :E => 1.0,
        :V => 1.0, :S => 1.0, :G => -7.49, :A => 1.0, :L => 1.0
      },
      :S => {
        :W => 1.0, :C => 33.6, :M => 1.0, :H => 1.0, :Y => 1.0, :F => 1.0, :Q => 20.26, :N => 1.0,
        :I => 1.0, :R => 20.26, :D => 1.0, :P => 44.94, :T => 1.0, :K => 1.0, :E => 20.26, :V => 1.0,
        :S => 20.26, :G => 1.0, :A => 1.0, :L => 1.0
      },
      :G => {
        :W => 13.34, :C => 1.0, :M => 1.0, :H => 1.0, :Y => -7.49, :F => 1.0, :Q => 1.0, :N => -7.49,
        :I => -7.49, :R => 1.0, :D => 1.0, :P => 1.0, :T => -7.49, :K => -7.49, :E => -6.54,
        :V => 1.0, :S => 1.0, :G => 13.34, :A => -7.49, :L => 1.0
      },
      :A => {
        :W => 1.0, :C => 44.94, :M => 1.0, :H => -7.49, :Y => 1.0, :F => 1.0, :Q => 1.0, :N => 1.0,
        :I => 1.0, :R => 1.0, :D => -7.49, :P => 20.26, :T => 1.0, :K => 1.0, :E => 1.0, :V => 1.0,
        :S => 1.0, :G => 1.0, :A => 1.0, :L => 1.0
      },
      :L => {
        :W => 24.68, :C => 1.0, :M => 1.0, :H => 1.0, :Y => 1.0, :F => 1.0, :Q => 33.6, :N => 1.0,
        :I => 1.0, :R => 20.26, :D => 1.0, :P => 20.26, :T => 1.0, :K => -7.49, :E => 1.0, :V => 1.0,
        :S => 1.0, :G => 1.0, :A => 1.0, :L => 1.0
      }
    }

    # Estemated half-life of N-terminal residue of a protein.
    HALFLIFE = {
      :ecoli => {
        :I => 600,
        :V => 600,
        :L => 2,
        :F => 2,
        :C => 600,
        :M => 600,
        :A => 600,
        :G => 600,
        :T => 600,
        :W => 2,
        :S => 600,
        :Y => 2,
        :P => 600,
        :H => 600,
        :E => 600,
        :Q => 600,
        :D => 600,
        :N => 600,
        :K => 2,
        :R => 2,
        :U => 600
      },
      :mammalian => {
        :A => 264,
        :R => 60,
        :N => 84,
        :D => 66,
        :C => 72,
        :Q => 48,
        :E => 60,
        :G => 30,
        :H => 210,
        :I => 1200,
        :L => 330,
        :K => 78,
        :M => 1800,
        :F => 66,
        :P => 1200,
        :S => 114,
        :T => 432,
        :W => 168,
        :Y => 168,
        :V => 6000
      },
      :yeast => {
        :A => 1200,
        :R => 2,
        :N => 3,
        :D => 3,
        :C => 1200,
        :Q => 10,
        :E => 30,
        :G => 1200,
        :H => 10,
        :I => 30,
        :L => 3,
        :K => 3,
        :M => 1200,
        :F => 3,
        :P => 1200,
        :S => 1200,
        :T => 1200,
        :W => 3,
        :Y => 10,
        :V => 1200
      }
    }

    ##  TOP-IDP
    ##
    ##  http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2676888/
    ##
    # TOP_IDP = {
    #   :I => -0.486,
    #   :V => -0.121,
    #   :L => -0.326,
    #   :F => -0.697,
    #   :C => 0.02,
    #   :M => -0.397,
    #   :A => 0.06,
    #   :G => 0.166,
    #   :T => 0.059,
    #   :W => -0.884,
    #   :S => 0.341,
    #   :Y => -0.510,
    #   :P => 0.987,
    #   :H => 0.303,
    #   :E => 0.736,
    #   :Q => 0.318,
    #   :D => 0.192,
    #   :N => 0.007,
    #   :K => 0.586,
    #   :R => 0.180,
    #   :U => 0.02
    # }

    # Hydropathy values for amino acids {[12]}[rdoc-label:12].
    HYDROPATHY = {
      :I => 4.5 ,
      :V => 4.2 ,
      :L => 3.8 ,
      :F => 2.8 ,
      :C => 2.5 ,
      :M => 1.9 ,
      :A => 1.8 ,
      :G => -0.4,
      :T => -0.7,
      :W => -0.9,
      :S => -0.8,
      :Y => -1.3,
      :P => -1.6,
      :H => -3.2,
      :E => -3.5,
      :Q => -3.5,
      :D => -3.5,
      :N => -3.5,
      :K => -3.9,
      :R => -4.5,
      :U => 2.5
    }

    # {Average isotopic masses of amino acids}[http://web.expasy.org/findmod/findmod_masses.html#AA]
    AVERAGE_MASS = {
      :I => 113.1594,
      :V => 99.1326,
      :L => 113.1594,
      :F => 147.1766,
      :C => 103.1388,
      :M => 131.1926,
      :A => 71.0788,
      :G => 57.0519,
      :T => 101.1051,
      :W => 186.2132,
      :S => 87.0782,
      :Y => 163.1760,
      :P => 97.1167,
      :H => 137.1411,
      :E => 129.1155,
      :Q => 128.1307,
      :D => 115.0886,
      :N => 114.1038,
      :K => 128.1741,
      :R => 156.1875,
      :U => 150.0388
    }
    WATER_MASS = 18.01524

    # Atomic composition of amino acids.
    ATOM = {
      :I => {:C => 6, :H => 13, :O => 2, :N => 1, :S => 0}, # C6H13NO2
      :V => {:C => 5, :H => 11, :O => 2, :N => 1, :S => 0}, # C5H11NO2
      :L => {:C => 6, :H => 13, :O => 2, :N => 1, :S => 0}, # C6H13NO2
      :F => {:C => 9, :H => 11, :O => 2, :N => 1, :S => 0}, # C9H11NO2
      :C => {:C => 3, :H => 7 , :O => 2, :N => 1, :S => 1}, # C3H7NO2S
      :M => {:C => 5, :H => 11 ,:O => 2, :N => 1, :S => 1}, # C5H11NO2S
      :A => {:C => 3, :H => 7 , :O => 2, :N => 1, :S => 0}, # C3H7NO2
      :G => {:C => 2, :H => 5 , :O => 2, :N => 1, :S => 0}, # C2H5NO2
      :T => {:C => 4, :H => 9 , :O => 3, :N => 1, :S => 0}, # C4H9NO3
      :W => {:C => 11,:H => 12, :O => 2, :N => 2, :S => 0}, # C11H12N2O2
      :S => {:C => 3, :H => 7 , :O => 3, :N => 1, :S => 0}, # C3H7NO3
      :Y => {:C => 9, :H => 11, :O => 3, :N => 1, :S => 0}, # C9H11NO3
      :P => {:C => 5, :H => 9 , :O => 2, :N => 1, :S => 0}, # C5H9NO2
      :H => {:C => 6, :H => 9 , :O => 2, :N => 3, :S => 0}, # C6H9N3O2
      :E => {:C => 5, :H => 9 , :O => 4, :N => 1, :S => 0}, # C5H9NO4
      :Q => {:C => 5, :H => 10, :O => 3, :N => 2, :S => 0}, # C5H10N2O3
      :D => {:C => 4, :H => 7 , :O => 4, :N => 1, :S => 0}, # C4H7NO4
      :N => {:C => 4, :H => 8 , :O => 3, :N => 2, :S => 0}, # C4H8N2O3
      :K => {:C => 6, :H => 14, :O => 2, :N => 2, :S => 0}, # C6H14N2O2
      :R => {:C => 6, :H => 14, :O => 2, :N => 4, :S => 0}, # C6H14N4O2
    }

    ##
    #
    # pK value from Bjellqvist, et al {[13]}[rdoc-label:13].
    # Taking into account the decrease in pK differences
    # between acids and bases when going from water
    # to 8 M urea, a value of 7.5 has been assigned to the
    # N-terminal residue .
    #
    PK = {
      :cterm => {
        :normal => 3.55, :D => 4.55, :E => 4.75
      },
      :nterm => {
        :A => 7.59, :M => 7.00, :S => 6.93,  :P => 8.36,
        :T => 6.82, :V => 7.44, :E => 7.70 , :G => 7.50
      },
      :internal => {
        :D => 4.05, :E => 4.45, :H => 5.98, :C => 9.0,
        :Y => 10.0, :K => 10.0, :R => 12.0
      }
    }

    def initialize(seq)
      if seq.kind_of?(String) && Bio::Sequence.guess(seq) == Bio::Sequence::AA
        # TODO: has issue.
        @seq = Bio::Sequence::AA.new seq
      elsif seq.kind_of? Bio::Sequence::AA
        @seq = seq
      elsif seq.kind_of?(Bio::Sequence) &&
        seq.guess.kind_of?(Bio::Sequence::AA)
        @seq = seq.guess
      else
        raise ArgumentError, "sequence must be an AA sequence"
      end
    end

    ##
    #
    # Return the number of negative amino acids (D and E) in an AA sequence.
    #
    def num_neg
      @num_neg ||= @seq.count("DE")
    end

    ##
    #
    # Return the number of positive amino acids (R and K) in an AA sequence.
    #
    def num_pos
      @num_neg ||= @seq.count("RK")
    end

    ##
    #
    # Return the number of residues in an AA sequence.
    #
    def amino_acid_number
      @seq.length
    end

    ##
    #
    # Return the number of atoms in a sequence. If type is given, return the
    # number of specific atoms in a sequence.
    #
    def total_atoms(type=nil)
      if !type.nil?
        type = type.to_sym
        if /^(?:C|H|O|N|S){1}$/ !~ type.to_s
          raise ArgumentError, "type must be C/H/O/N/S/nil(all)"
        end
      end
      num_atom = {:C => 0,
                  :H => 0,
                  :O => 0,
                  :N => 0,
                  :S => 0}
      each_aa do |aa|
        ATOM[aa].each do |t, num|
          num_atom[t] += num
        end
      end
      num_atom[:H] = num_atom[:H] - 2 * (amino_acid_number - 1)
      num_atom[:O] = num_atom[:O] - (amino_acid_number - 1)
      if type.nil?
        num_atom.values.inject(0){|prod, num| prod += num }
      else
        num_atom[type]
      end
    end

    ##
    #
    # Return the number of carbons.
    #
    def num_carbon
      @num_carbon ||= total_atoms :C
    end

    def num_hydrogen
      @num_hydrogen ||= total_atoms :H
    end

    ##
    #
    # Return the number of nitrogens.
    #
    def num_nitro
      @num_nitro ||= total_atoms :N
    end

    ##
    #
    # Return the number of oxygens.
    #
    def num_oxygen
      @num_oxygen ||= total_atoms :O
    end

    ##
    #
    # Return the number of sulphurs.
    #
    def num_sulphur
      @num_sulphur ||= total_atoms :S
    end

    ##
    #
    # Calculate molecular weight of an AA sequence.
    #
    # _Protein Mw is calculated by the addition of average isotopic masses of
    # amino acids in the protein and the average isotopic mass of one water
    # molecule._
    #
    def molecular_weight
      @mw ||= begin
                mass = WATER_MASS
                each_aa do |aa|
                  mass += AVERAGE_MASS[aa.to_sym]
                end
                (mass * 10).floor().to_f / 10
              end
    end

    ##
    #
    # Claculate theoretical pI for an AA sequence with bisect algorithm.
    # pK value by Bjelqist, et al. is used to calculate pI.
    #
    def theoretical_pI
      charges = []
      residue_count().each do |residue|
        charges << charge_proc(residue[:positive],
                               residue[:pK],
                               residue[:num])
      end
      round(solve_pI(charges), 2)
    end

    ##
    #
    # Return estimated half_life of an AA sequence.
    #
    # _The half-life is a prediction of the time it takes for half of the
    # amount of protein in a cell to disappear after its synthesis in the
    # cell. ProtParam relies on the "N-end rule", which relates the half-life
    # of a protein to the identity of its N-terminal residue; the prediction
    # is given for 3 model organisms (human, yeast and E.coli)._
    #
    def half_life(species=nil)
      n_end = @seq[0].chr.to_sym
      if species
        HALFLIFE[species][n_end]
      else
        {
          :ecoli     => HALFLIFE[:ecoli][n_end],
          :mammalian => HALFLIFE[:mammalian][n_end],
          :yeast     => HALFLIFE[:yeast][n_end]
        }
      end
    end

    ##
    #
    # Calculate instability index of an AA sequence.
    #
    # _The instability index provides an estimate of the stability of your
    # protein in a test tube. Statistical analysis of 12 unstable and 32
    # stable proteins has revealed [7] that there are certain dipeptides, the
    # occurence of which is significantly different in the unstable proteins
    # compared with those in the stable ones. The authors of this method have
    # assigned a weight value of instability to each of the 400 different
    # dipeptides (DIWV)._
    #
    def instability_index
      @instability_index ||=
        begin
          instability_sum = 0.0
          i = 0
          while @seq[i+1] != nil
            aa, next_aa = [@seq[i].chr.to_sym, @seq[i+1].chr.to_sym]
            if DIWV.key?(aa) && DIWV[aa].key?(next_aa)
              instability_sum += DIWV[aa][next_aa]
            end
            i += 1
          end
          round((10.0/amino_acid_number.to_f) * instability_sum, 2)
        end
    end

    ##
    #
    # Return wheter the sequence is stable or not as String (stable/unstable).
    #
    # _Protein whose instability index is smaller than 40 is predicted as
    # stable, a value above 40 predicts that the protein may be unstable._
    #
    #
    def stability
      (instability_index <= 40) ? "stable" : "unstable"
    end

    ##
    #
    # Return true if the sequence is stable.
    #
    def stable?
      (instability_index <= 40) ? true : false
    end

    ##
    #
    # Calculate aliphatic index of an AA sequence.
    #
    # _The aliphatic index of a protein is defined as the relative volume
    # occupied by aliphatic side chains (alanine, valine, isoleucine, and
    # leucine). It may be regarded as a positive factor for the increase of
    # thermostability of globular proteins._
    #
    def aliphatic_index
      aa_map = aa_comp_map
      @aliphatic_index ||=  round(aa_map[:A]        +
                                  2.9 * aa_map[:V]  +
                                  (3.9 * (aa_map[:I] + aa_map[:L])), 2)
    end

    ##
    #
    # Calculate GRAVY score of an AA sequence.
    #
    # _The GRAVY(Grand Average of Hydropathy) value for a peptide or protein
    # is calculated as the sum of hydropathy values [9] of all the amino acids,
    # divided by the number of residues in the sequence._
    #
    def gravy
      @gravy ||= begin
                   hydropathy_sum = 0.0
                   each_aa do |aa|
                     hydropathy_sum += HYDROPATHY[aa]
                   end
                   round(hydropathy_sum / @seq.length.to_f, 3)
                 end
    end

    ##
    #
    # Calculate the percentage composition of an AA sequence as a Hash object.
    # It return percentage of a given amino acid if aa_code is not nil.
    #
    def aa_comp(aa_code=nil)
      if aa_code.nil?
        aa_map = {}
        IUPAC_CODE.keys.each do |k|
          aa_map[k] = 0.0
        end
        aa_map.update(aa_comp_map){|k,_,v| round(v, 1) }
      else
        round(aa_comp_map[aa_code], 1)
      end
    end

    private

    def aa_comp_map
      @aa_comp_map ||=
        begin
          aa_map  = {}
          aa_comp = {}
          sum = 0
          each_aa do |aa|
            if aa_map.key? aa
              aa_map[aa] += 1
            else
              aa_map[aa] = 1
            end
            sum += 1
          end
          aa_map.each {|aa, count| aa_comp[aa] = (Rational(count,sum) * 100).to_f }
          aa_comp
        end
    end

    def each_aa
      @seq.each_byte do |x|
        yield x.chr.to_sym
      end
    end

    def positive? residue
      (residue == "H" || residue == "R" || residue == "K")
    end

    #
    # Return proc calculating charge of a residue.
    #
    def charge_proc positive, pK, num
      if positive
        lambda {|ph|
          num.to_f / (1.0 + 10.0 ** (ph - pK))
        }
      else
        lambda {|ph|
          (-1.0 * num.to_f) / (1.0 + 10.0 ** (pK - ph))
        }
      end
    end

    #
    # Transform AA sequence into residue count
    #
    def residue_count
      counted = []
      # N-terminal
      n_term = @seq[0].chr
      if PK[:nterm].key? n_term.to_sym
        counted << {
          :num => 1,
          :residue => n_term.to_sym,
          :pK => PK[:nterm][n_term.to_sym],
          :positive => positive?(n_term)
        }
      elsif PK[:normal].key? n_term.to_sym
        counted << {
          :num => 1,
          :residue => n_term.to_sym,
          :pK => PK[:normal][n_term.to_sym],
          :positive => positive?(n_term)
        }
      end
      # Internal
      tmp_internal = {}
      @seq[1,(@seq.length-2)].each_byte do |x|
        aa = x.chr.to_sym
        if PK[:internal].key? aa
          if tmp_internal.key? aa
            tmp_internal[aa][:num] += 1
          else
            tmp_internal[aa] = {
              :num => 1,
              :residue => aa,
              :pK => PK[:internal][aa],
              :positive => positive?(aa.to_s)
            }
          end
        end
      end
      tmp_internal.each do |aa, val|
        counted << val
      end
      # C-terminal
      c_term = @seq[-1].chr
      if PK[:cterm].key? c_term.to_sym
        counted << {
          :num => 1,
          :residue => c_term.to_sym,
          :pK => PK[:cterm][c_term.to_sym],
          :positive => positive?(c_term)
        }
      end
      counted
    end

    #
    # Solving pI value with bisect algorithm.
    #
    def solve_pI charges
      state = {
        :ph => 0.0,
        :charges => charges,
        :pI => nil,
        :ph_prev => 0.0,
        :ph_next => 14.0,
        :net_charge => 0.0
      }
      error = false
      # epsilon means precision [pI = pH +_ E]
      epsilon = 0.001

      loop do
        # Reset net charge
        state[:net_charge] = 0.0
        # Calculate net charge
        state[:charges].each do |charge_proc|
          state[:net_charge] += charge_proc.call state[:ph]
        end

        # Something is wrong - pH is higher than 14
        if state[:ph] >= 14.0
          error = true
          break
        end

        # Making decision
        temp_ph = 0.0
        if state[:net_charge] <= 0.0
          temp_ph    = state[:ph]
          state[:ph] = state[:ph] - ((state[:ph] - state[:ph_prev]) / 2.0)
          state[:ph_next] = temp_ph
        else
          temp_ph    = state[:ph]
          state[:ph] = state[:ph] + ((state[:ph_next] - state[:ph]) / 2.0)
          state[:ph_prev] = temp_ph
        end

        if (state[:ph] - state[:ph_prev] < epsilon) &&
          (state[:ph_next] - state[:ph] < epsilon)
          state[:pI] = state[:ph]
          break
        end
      end

      if !state[:pI].nil? && !error
        state[:pI]
      else
        raise "Failed to Calc pI: pH is higher than 14"
      end
    end

    def round(num, ndigits=0)
      (num * (10 ** ndigits)).round().to_f / (10 ** ndigits).to_f
    end

    # --------------------------------
    # :section: References
    #
    #
    # 1. Protein Identification and Analysis Tools on the ExPASy Server;
    #    Gasteiger E., Hoogland C., Gattiker A., Duvaud S., Wilkins M.R.,
    #    Appel R.D., Bairoch A.; (In) John M. Walker (ed): The Proteomics
    #    Protocols Handbook, Humana Press (2005). pp. 571-607
    # 2. Pace, C.N., Vajdos, F., Fee, L., Grimsley, G., and Gray, T. (1995)
    #    How to measure and predict the molar absorption coefficient of a
    #    protein. Protein Sci. 11, 2411-2423.
    # 3. Edelhoch, H. (1967) Spectroscopic determination of tryptophan and
    #    tyrosine in proteins. Biochemistry 6, 1948-1954.
    # 4. Gill, S.C. and von Hippel, P.H. (1989) Calculation of protein
    #    extinction coefficients from amino acid sequence data. Anal. Biochem.
    #    182:319-326(1989).
    # 5. Bachmair, A., Finley, D. and Varshavsky, A. (1986) In vivo half-life
    #    of a protein is a function of its amino-terminal residue. Science 234,
    #    179-186.
    # 6. Gonda, D.K., Bachmair, A., Wunning, I., Tobias, J.W., Lane, W.S. and
    #    Varshavsky, A. J. (1989) Universality and structure of the N-end rule.
    #    J. Biol. Chem. 264, 16700-16712.
    # 7. Tobias, J.W., Shrader, T.E., Rocap, G. and Varshavsky, A. (1991) The
    #    N-end rule in bacteria. Science 254, 1374-1377.
    # 8. Ciechanover, A. and Schwartz, A.L. (1989) How are substrates
    #    recognized by the ubiquitin-mediated proteolytic system? Trends Biochem.
    #    Sci. 14, 483-488.
    # 9. Varshavsky, A. (1997) The N-end rule pathway of protein degradation.
    #    Genes Cells 2, 13-28.
    # 10. Guruprasad, K., Reddy, B.V.B. and Pandit, M.W. (1990) Correlation
    #     between stability of a protein and its dipeptide composition: a novel
    #     approach for predicting in vivo stability of a protein from its primary
    #     sequence. Protein Eng. 4,155-161.
    # 11. Ikai, A.J. (1980) Thermostability and aliphatic index of globular
    #     proteins. J. Biochem. 88, 1895-1898.
    # 12. Kyte, J. and Doolittle, R.F. (1982) A simple method for displaying
    #     the hydropathic character of a protein. J. Mol. Biol. 157, 105-132.
    # 13. Bjellqvist, B.,Hughes, G.J., Pasquali, Ch., Paquet, N., Ravier, F.,
    #     Sanchez, J.-Ch., Frutiger, S. & Hochstrasser, D.F. The focusing positions
    #     of polypeptides in immobilized pH gradients can be predicted from their
    #     amino acid sequences. Electrophoresis 1993, 14, 1023-1031.
    #
    # --------------------------------
  end
end
