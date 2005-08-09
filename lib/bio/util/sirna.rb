#
# bio/util/sirna.rb - Class for designing small inhibitory RNAs
#
#   Copyright (C) 2004, 2005  Itoshi NIKAIDO <dritoshi@gmail.com>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
# $Id: sirna.rb,v 1.3 2005/08/09 05:40:44 k Exp $
#

require 'bio/sequence'

module Bio

  class SiRNA

    def initialize(seq, antisense_size = 21, max_gc_percent = 60.0, min_gc_percent = 40.0)
      @seq = seq.rna!
      @pairs = Array.new
      @antisense_size = antisense_size
      @max_gc_percent = max_gc_percent
      @min_gc_percent = min_gc_percent
    end
    attr_accessor :antisense_size, :max_gc_percent, :min_gc_percent

    def uitei?(target)
      return false unless /^.{2}[GC]/i =~ target
      return false unless /[AU].{2}$/i =~ target
      return false if     /[GC]{9}/i   =~ target

      one_third  = target.size * 1 / 3
      start_pos  = @target_size - one_third - 1
      remain_seq = target.subseq(start_pos, @target_size - 2)
      gc_number  = remain_seq.scan(/[AU]/i).size
      return false if gc_number < 5
  
      return true
    end

    def reynolds?(target)
      return false if /[GC]{9}/i =~ target
      return false unless /^.{4}A.{6}U.{2}[AUC].{5}[AU].{2}$/i =~ target
      return true
    end

    def uitei
      design('uitei')
    end

    def reynolds
      design('reynolds')
    end

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


    class Pair

      def initialize(target, sense, antisense, start, stop, rule, gc_percent)
	@target     = target
	@sense      = sense
	@antisense  = antisense
	@start      = start
	@stop       = stop
	@rule       = rule
	@gc_percent = gc_percent
      end
      attr_accessor :target, :sense, :antisense, :start, :stop, :rule, :gc_percent

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

    end #class Pair

    
    class ShRNA
    
      def initialize(pair)
        @pair = pair
      end
      attr_accessor :top_strand, :bottom_strand

      def design(method = 'BLOCK-iT')
        case method
        when 'BLOCK-iT'
	  block_it
	else
          raise NotImplementedError
        end
      end

      def block_it(method = 'piGENE')
        top = Bio::Sequence::NA.new('CACC')	# top_strand_shrna_overhang
        bot = Bio::Sequence::NA.new('AAAA')	# bottom_strand_shrna_overhang
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
      
      def report
        report = "### shRNA\n"
        report << "Top strand shRNA (#{@top_strand.length} nt):\n"
        report << "  5'-#{@top_strand.upcase}-3'\n"
        report << "Bottom strand shRNA (#{@bottom_strand.length} nt):\n"
        report << "      3'-#{@bottom_strand.reverse.upcase}-5'\n"
      end

    end #class ShRNA

  end #class SiRNA

end #module bio


if __FILE__ == $0
  
  seq = Bio::Sequence::NA.new(ARGF.read)

  sirna = Bio::SiRNA.new(seq)
  pairs = sirna.design		# or .design('uitei') or .uitei or .reynolds

  pairs.each do |pair|
    puts pair.report

    shrna = Bio::SiRNA::ShRNA.new(pair)
    shrna.design		# or .design('BLOCK-iT') or .block_it
    puts shrna.report

    puts "# as DNA"
    puts shrna.top_strand.dna
    puts shrna.bottom_strand.dna
  end

end  

=begin

= Bio::SiRNA

    Designing siRNA.
    
    Input is a Bio::Sequence::NA object (the target sequence).
    Output is a list of Bio::SiRNA::Pair object.
    
    This class implements the selection rules described by Kumiko Ui-Tei
    et al. (2004) and Reynolds et al. (2004)

    Kumiko Ui-Tei et al.  Guidelines for the selection of highly effective
    siRNA sequences for mammalian and chick RNA interference.
    Nucl. Acids. Res. 2004 32: 936-948.
    
    Angela Reynolds et al.  Rational siRNA design for RNA interference.
    Nature Biotech. 2004 22: 326-330.

--- Bio::SiRNA.new(seq, antisense_size, max_gc_percent, min_gc_percent)

--- Bio::SiRNA#design(rule)

  rule can be one of 'uitei' (default) and 'reynolds'.

--- Bio::SiRNA#uitei

  same as design('uitei')

--- Bio::SiRNA#reynolds

  same as design('reynolds')

--- Bio::SiRNA#antisense_size
--- Bio::SiRNA#max_gc_percent
--- Bio::SiRNA#min_gc_percent

== Bio::SiRNA::Pair

--- Bio::SiRNA::Pair.new(target, sense, antisense, target_start, target_stop, rule, antisense_gc_percent)

--- Bio::SiRNA::Pair#target
--- Bio::SiRNA::Pair#sense
--- Bio::SiRNA::Pair#antisense
--- Bio::SiRNA::Pair#start
--- Bio::SiRNA::Pair#stop
--- Bio::SiRNA::Pair#rule
--- Bio::SiRNA::Pair#report

== Bio::SiRNA::ShRNA

    Input is a Bio::SiRNA::Pair object (the target sequence).

--- Bio::ShRNA.new(pair)

--- Bio::ShRNA#design(rule)

  only the 'BLOCK-iT' rule is implemented for now

--- Bio::ShRNA#block_it(method)

  same as design('BLOCK-iT').
  method can be one of 'piGENE' (default) and 'BLOCK-iT'.

--- Bio::ShRNA#top_strand
--- Bio::ShRNA#bottom_strand
--- Bio::ShRNA#report


=== ChangeLog

  2005/03/21 Itoshi NIKAIDO <itoshi.nikaido@nifty.com>
  Bio::SiRNA#ShRNA_designer method was changed design method.

  2004/06/25
  Bio::ShRNA class was added.

  2004/06/17 Itoshi NIKAIDO <itoshi.nikaido@nifty.com>
  We can use shRNA loop sequence from piGene document.

=end
