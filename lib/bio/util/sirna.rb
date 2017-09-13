#
# = bio/util/sirna.rb - Class for designing small inhibitory RNAs
#
# Copyright::   Copyright (C) 2004-2013
#               Itoshi NIKAIDO <dritoshi@gmail.com>
#               Yuki NAITO <y-naito@rnai.jp>
# License::     The Ruby License
#
# $Id:$
#
# == Bio::SiRNA - Designing siRNA.
#
# This class implements the selection rules described by Kumiko Ui-Tei
# et al. (2004) and Reynolds et al. (2004).
#
# == Example
#
#  seq = Bio::Sequence::NA.new(ARGF.read)
#  
#  sirna = Bio::SiRNA.new(seq)
#  pairs = sirna.design
#  
#  pairs.each do |pair|
#    puts pair.report
#    shrna = Bio::SiRNA::ShRNA.new(pair)
#    shrna.design
#    puts shrna.report
#    
#    puts shrna.top_strand.dna
#    puts shrna.bottom_strand.dna
#  end
#
# == References
# 
# * Kumiko Ui-Tei et al.  Guidelines for the selection of highly effective
#   siRNA sequences for mammalian and chick RNA interference.
#   Nucleic Acids Res. 2004 32: 936-948.
#    
# * Angela Reynolds et al.  Rational siRNA design for RNA interference.
#   Nat. Biotechnol. 2004 22: 326-330.
#

require 'bio/sequence'

module Bio

  # = Bio::SiRNA
  # Designing siRNA.
  #
  # This class implements the selection rules described by Kumiko Ui-Tei
  # et al. (2004) and Reynolds et al. (2004).
  class SiRNA

    # A parameter of size of antisense.
    attr_accessor :antisense_size

    # A parameter of maximal %GC.
    attr_accessor :max_gc_percent

    # A parameter of minimum %GC.
    attr_accessor :min_gc_percent

    # Input is a Bio::Sequence::NA object (the target sequence).
    # Output is a list of Bio::SiRNA::Pair object.
    def initialize(seq, antisense_size = 21, max_gc_percent = 60.0, min_gc_percent = 40.0)
      @seq = seq.rna!
      @pairs = Array.new
      @antisense_size = antisense_size
      @max_gc_percent = max_gc_percent
      @min_gc_percent = min_gc_percent
    end

    # Ui-Tei's rule.
    def uitei?(target)
      return false if target.length != 23  # 21 nt target + 2 nt overhang

      seq19 = target[2..20]  # 19 nt double-stranded region of siRNA

      # criteria i
      return false unless seq19[18..18].match(/[AU]/i)

      # criteria ii
      return false unless seq19[0..0].match(/[GC]/i)

      # criteria iii
      au_number = seq19[12..18].scan(/[AU]/i).size
      return false unless au_number >= 4

      # criteria iv
      return false if seq19.match(/[GC]{10}/i)

      return true
    end

    # Reynolds' rule.
    def reynolds?(target)
      return false if target.length != 23  # 21 nt target + 2 nt overhang

      seq19 = target[2..20]  # 19 nt double-stranded region of siRNA
      score = 0

      # criteria I
      gc_number = seq19.scan(/[GC]/i).size
      score += 1 if (7 <= gc_number and gc_number <= 10)

      # criteria II
      au_number = seq19[14..18].scan(/[AU]/i).size
      score += au_number

      # criteria III
      # NotImpremented: Tm

      # criteria IV
      score += 1 if seq19[18..18].match(/A/i)

      # criteria V
      score += 1 if seq19[2..2].match(/A/i)

      # criteria VI
      score += 1 if seq19[9..9].match(/[U]/i)

      # criteria VII
      score -= 1 if seq19[18..18].match(/[GC]/i)

      # criteria VIII
      score -= 1 if seq19[12..12].match(/G/i)

      if score >= 6
        return score
      else
        return false
      end
    end

    # same as design('uitei').
    def uitei
      design('uitei')
    end

    # same as design('reynolds').
    def reynolds
      design('reynolds')
    end

    #  rule can be one of 'uitei' (default) and 'reynolds'.
    def design(rule = 'uitei')
      @target_size = @antisense_size + 2

      target_start = 0
      @seq.window_search(@target_size) do |target|
        antisense = target.subseq(1, @target_size - 2).complement.rna
        sense     = target.subseq(3, @target_size)

        target_start += 1
        target_stop  = target_start + @target_size

        antisense_gc_percent = antisense.gc_percent
        next if antisense_gc_percent > @max_gc_percent
        next if antisense_gc_percent < @min_gc_percent
        
        case rule
        when 'uitei'
          next unless uitei?(target)
        when 'reynolds'
          next unless reynolds?(target)
        else
          raise NotImplementedError
        end

        pair = Bio::SiRNA::Pair.new(target, sense, antisense, target_start, target_stop, rule, antisense_gc_percent)
        @pairs.push(pair)
      end
      return @pairs
    end

    # = Bio::SiRNA::Pair
    class Pair

      attr_accessor :target

      attr_accessor :sense

      attr_accessor :antisense

      attr_accessor :start

      attr_accessor :stop

      attr_accessor :rule

      attr_accessor :gc_percent

      def initialize(target, sense, antisense, start, stop, rule, gc_percent)
        @target     = target
        @sense      = sense
        @antisense  = antisense
        @start      = start
        @stop       = stop
        @rule       = rule
        @gc_percent = gc_percent
      end

      # human readable report
      def report
        report =  "### siRNA\n"
        report << 'Start: ' + @start.to_s + "\n"
        report << 'Stop:  ' + @stop.to_s  + "\n"
        report << 'Rule:  ' + @rule.to_s  + "\n"
        report << 'GC %:  ' + @gc_percent.to_s  + "\n"
        report << 'Target:    '        + @target.upcase + "\n"
        report << 'Sense:     ' + '  ' + @sense.upcase  + "\n"
        report << 'Antisense: '        + @antisense.reverse.upcase + "\n"
      end

      # computer parsable report
      #def to_s
      #  [ @antisense, @start, @stop ].join("\t")
      #end

    end # class Pair


    # = Bio::SiRNA::ShRNA
    # Designing shRNA.
    class ShRNA

      # Bio::Sequence::NA
      attr_accessor :top_strand

      # Bio::Sequence::NA
      attr_accessor :bottom_strand

      # Input is a Bio::SiRNA::Pair object (the target sequence).    
      def initialize(pair)
        @pair = pair
      end

      # only the 'BLOCK-iT' rule is implemented for now.
      def design(method = 'BLOCK-iT')
        case method
        when 'BLOCK-iT'
          block_it
        else
          raise NotImplementedError
        end
      end


      # same as design('BLOCK-iT').
      # method can be one of 'piGENE' (default) and 'BLOCK-iT'.
      def block_it(method = 'piGENE')
        top = Bio::Sequence::NA.new('CACC') # top_strand_shrna_overhang
        bot = Bio::Sequence::NA.new('AAAA') # bottom_strand_shrna_overhang
        fwd = @pair.sense
        rev = @pair.sense.complement

        case method
        when 'BLOCK-iT'
          # From BLOCK-iT's manual
          loop_fwd = Bio::Sequence::NA.new('CGAA')
          loop_rev = loop_fwd.complement
        when 'piGENE'
          # From piGENE document
          loop_fwd = Bio::Sequence::NA.new('GTGTGCTGTCC')
          loop_rev = loop_fwd.complement
        else
          raise NotImplementedError
        end

        if /^G/i =~ fwd
          @top_strand    = top + fwd + loop_fwd + rev
          @bottom_strand = bot + fwd + loop_rev + rev
        else
          @top_strand    = top + 'G' + fwd + loop_fwd + rev
          @bottom_strand = bot + fwd + loop_rev + rev + 'C'
        end
      end
      
      # human readable report
      def report
        # raise NomethodError for compatibility
        raise NoMethodError if !defined?(@top_strand) || !@top_strand
        report = "### shRNA\n"
        report << "Top strand shRNA (#{@top_strand.length} nt):\n"
        report << "  5'-#{@top_strand.upcase}-3'\n"
        report << "Bottom strand shRNA (#{@bottom_strand.length} nt):\n"
        report << "      3'-#{@bottom_strand.reverse.upcase}-5'\n"
      end

    end # class ShRNA

  end # class SiRNA

end # module Bio

=begin

= ChangeLog

  2013/04/03 Yuki NAITO <y-naito@rnai.jp>
  Modified siRNA design rules:

  - Ui-Tei's rule:
    - Restricted target length to 23 nt (21 nt plus 2 nt overhang)
      for selecting functional siRNAs.
    - Avoided contiguous GCs 10 nt or more. (not 9 nt or more)

  - Reynolds' rule:
    - Restricted target length to 23 nt (21 nt plus 2 nt overhang)
      for selecting functional siRNAs.
    - Reynolds' rule does not require to fulfill all the criteria
      simultaneously. Total score of eight criteria is calculated
      and used for the siRNA efficacy prediction. This change may
      significantly alter an output.
    - Returns total score of eight criteria for functional siRNA,
      instead of returning 'true'.
    - Returns 'false' for non-functional siRNA, as usual.

  2005/03/21 Itoshi NIKAIDO <itoshi.nikaido@nifty.com>
  Bio::SiRNA#ShRNA_designer method was changed design method.

  2004/06/25
  Bio::ShRNA class was added.

  2004/06/17 Itoshi NIKAIDO <itoshi.nikaido@nifty.com>
  We can use shRNA loop sequence from piGene document.

=end
