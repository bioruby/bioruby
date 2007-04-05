#
# = bio/db/transfac.rb - TRANSFAC database class
#
# Copyright::	Copyright (C) 2001
#		Shuichi Kawashima <shuichi@hgc.jp>
# License::	The Ruby License
#
# $Id: transfac.rb,v 1.12 2007/04/05 23:35:40 trevor Exp $
#

require "bio/db"
require "matrix"

module Bio

class TRANSFAC < EMBLDB

  DELIMITER	= RS = "\n//\n"
  TAGSIZE	= 4

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # AC  Accession number                   (1 per entry)
  #
  #  AC  T00001   in the case of FACTOR
  #  AC  M00001   in the case of MATRIX
  #  AC  R00001   in the case of SITE
  #  AC  G000001  in the case of GENE
  #  AC  C00001   in the case of CLASS
  #  AC  00001    in the case of CELL 
  #
  def ac
    unless @data['AC']
      @data['AC'] = fetch('AC')
    end
    @data['AC']
  end
  alias entry_id ac

  # DT  Date                               (1 per entry)
  #
  #  DT  DD.MM.YYYY (created); ewi.
  #  DT  DD.MM.YYYY (updated); mpr.
  #
  def dt
    field_fetch('DT')
  end
  alias date dt

  def cc
    field_fetch('CC')
  end
  alias comment cc

  def os
    field_fetch('OS')
  end
  alias org_species os

  def oc
    field_fetch('OC')
  end
  alias org_class oc

  def rn
    field_fetch('RN')
  end
  alias ref_no rn

  def ra
    field_fetch('RA')
  end
  alias ref_authors ra

  def rt
    field_fetch('RT')
  end
  alias ref_title rt

  def rl
    field_fetch('RL')
  end
  alias ref_data rl


  class MATRIX < TRANSFAC

    def initialize(entry)
      super(entry)
    end

    # NA      Name of the binding factor
    def na
      field_fetch('NA')
    end

    # DE      Short factor description
    def de
      field_fetch('DE')
    end

    # BF      List of linked factor entries
    def bf
      field_fetch('bf')
    end


    def ma
      ma_dat = {}
      ma_ary = []
      key = ''
      @orig.each do |k, v|
        if k =~ /^0*(\d+)/
          key = $1.to_i
          ma_dat[key] = fetch(k) unless ma_dat[key]
        end
      end
      ma_dat.keys.sort.each_with_index do |k, i|
        rep_nt = ma_dat[k].slice!(-1, 1)
        ma_dat[k].slice!(-1, 1)
        ma_ary[i] = ma_dat[k].split(/\s+/)
        ma_ary[i].each_with_index do |x, j|
          ma_ary[i][j] = x.to_i
        end
      end
      Matrix[*ma_ary]
    end

    # BA      Statistical basis
    def ba
      field_fetch('BA')
    end

  end


  class SITE < TRANSFAC

    def initialize(entry)
      super(entry)
    end

    def ty
      field_fetch('TY')
    end

    def de
      field_fetch('DE')
    end

    def re
      field_fetch('RE')
    end

    def sq
      field_fetch('SQ')
    end

    def el
      field_fetch('EL')
    end

    def sf
      field_fetch('SF')
    end

    def st
      field_fetch('ST')
    end

    def s1
      field_fetch('S1')
    end

    def bf
      field_fetch('BF')
    end

    def so 
      field_fetch('SO')
    end

    def mm
      field_fetch('MM')
    end

    # DR  Cross-references to other databases     (>=0 per entry)
    def dr
      field_fetch('DR')
    end

  end


  class FACTOR < TRANSFAC

    def initialize(entry)
      super(entry)
    end

    # FA      Factor name
    def fa
      field_fetch('FA')
    end

    # SY      Synonyms
    def sy
      field_fetch('SY')
    end

    # DR  Cross-references to other databases     (>=0 per entry)
    def dr
      field_fetch('DR')
    end

    # HO      Homologs (suggested)
    def ho
      field_fetch('HO')
    end

    # CL      Classification (class accession no.; class identifier; decimal 
    # CL      classification number.)
    def cl
      field_fetch('CL')
    end

    # SZ      Size (length (number of amino acids); calculated molecular mass 
    # SZ      in kDa; experimental molecular mass (or range) in kDa 
    # SZ      (experimental method) [Ref]
    def sz
      field_fetch('SZ')
    end

    # SQ      Sequence
    def sq
      field_fetch('SQ')
    end

    # SC      Sequence comment, i. e. source of the protein sequence
    def sc
      field_fetch('SC')
    end

    # FT      Feature table (1st position     last position    feature)
    def ft
      field_fetch('FT')
    end

    # SF      Structural features
    def sf
      field_fetch('SF')
    end

    # CP      Cell specificity (positive)
    def cp
      field_fetch('CP')
    end

    # CN      Cell specificity (negative)
    def cn
      field_fetch('CN')
    end

    # FF      Functional features
    def ff
      field_fetch('FF')
    end

    # IN      Interacting factors (factor accession no.; factor name; 
    # IN      biological species.)
    def in
      field_fetch('IN')
    end

    # MX      Matrix (matrix accession no.; matrix identifier)
    def mx
      field_fetch('MX')
    end

    # BS      Bound sites (site accession no.; site ID; quality: N; biological
    # BS      species)
    def bs
      field_fetch('BS')
    end

  end


  class CELL < TRANSFAC

    def initialize(entry)
      super(entry)
    end

    # CD   Cell description
    def cd
      field_fetch('CD')
    end

  end


  class CLASS < TRANSFAC

    def initialize(entry)
      super(entry)
    end

    # CL      Class
    def cl
      field_fetch('CL')
    end

    # SD      Structure description
    def sd
      field_fetch('SD')
    end

    # BF      Factors belonging to this class
    def bf
      field_fetch('BF')
    end

    # DR      PROSITE accession numbers
    def dr
      field_fetch('DR')
    end

  end


  class GENE < TRANSFAC

    def initialize(entry)
      super(entry)
    end

    # SD      Short description/name of the gene
    def sd
      field_fetch('SD')
    end

    # DE
    def de
      field_fetch('DE')
    end

    # BC      Bucher promoter
    def bc
      field_fetch('BC')
    end

    # BS      TRANSFAC SITE positions and accession numbers
    def bs
      field_fetch('BS')
    end

    # CO      COMPEL accession number
    def co
      field_fetch('CO')
    end

    # TR      TRRD accession number
    def tr
      field_fetch('TR')
    end

  end

end # class TRANSFAC

end # module Bio

