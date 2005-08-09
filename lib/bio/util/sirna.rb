#
# bio/util/sirna.rb - Class for Designing small inhibitory RNAs
#
#   Copyright (C) 2004 Itoshi NIKAIDO <itoshi.nikaido@nifty.com>
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
# $Id: sirna.rb,v 1.1 2005/08/09 03:50:36 k Exp $
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
    attr_accessor :antisense_size
    
    def uitei?(target)
      return false unless /^.{2}[G|C]/i =~ target.to_s
      return false unless /[A|U].{2}$/i =~ target.to_s

      one_third  = target.size * 1 / 3
      start = @target_size - one_third - 1
      one_third_seq = target.subseq(start, @target_size - 2)
      gc = 0
      one_third_seq.scan(/[A|U]/i) { gc += 1 }
      return false if gc < 5
  
      return false if /[G|C]{9}/i =~ target
      return false if /[G|C]{9}/i =~ target.complement.rna
      return true
    end
    
    def reynolds?(target)
      return false if /[G|C]{9}/i =~ target
      return false if /[G|C]{9}/i =~ target.complement.rna
      if /^.{4}A.{6}U.{2}[A|U|C].{5}[A|U].{2}$/i =~ target.to_s
        return true
      else
	return false
      end
    end

    def design(rule = 'uitei')
      @target_size = @antisense_size + 2
      bp = 0
      @seq.window_search(@target_size) do |target|
        bp += 1

        antisense = target.subseq(1, @target_size - 2).complement.rna
        sense     = target.subseq(3, @target_size)

        target_start = bp
        target_stop  = bp + @target_size
	antisense_gc_percent = antisense.gc_percent
	next if antisense_gc_percent > @max_gc_percent
	next if antisense_gc_percent < @min_gc_percent
	
        if rule == 'uitei'
  	  next if uitei?(target) == false
	elsif rule == 'reynolds'
    	  next if reynolds?(target) == false
        else
	  next
	end

        pair = Bio::SiRNA::Pair.new(target, sense, antisense, target_start, target_stop, rule, antisense_gc_percent)
	@pairs.push(pair)
	
      end #window_search
      return @pairs
    end #design

    class Pair

      def initialize(target, sense, antisense, start, stop, rule, gc_percent)
	@target    = target
	@sense     = sense
	@antisense = antisense
	@start = start
	@stop  = stop
	@rule  = rule
	@gc_percent = gc_percent
      end
      
      attr_accessor :target
      attr_accessor :sense
      attr_accessor :antisense
      attr_accessor :start, :stop
      attr_accessor :rule
      attr_accessor :gc_percent

      def as_human_readable_text
        # human readable report
	report =  "--\n"
	report << 'start: ' + @start.to_s + "\n"
	report << 'stop:  ' + @stop.to_s  + "\n"
	report << 'rule:  ' + @rule.to_s  + "\n"
	report << 'gc_percent:  ' + @gc_percent.to_s  + "\n"
	report << 'target:    '        + @target.upcase + "\n"
	report << 'sense:     ' + '  ' + @sense.upcase  + "\n"
	report << 'antisense: '        + @antisense.reverse.upcase + "\n"

        # computer parseble
        # puts antisense
        # puts target_start
        # puts target_stop
      end
      alias :to_s :as_human_readable_text

    end #class Bio::SiRNA::Pair
    
    class ShRNA
    
      def initialize(pair, method_name)
        @pair = pair
        @method_name = method_name		
	@top_strand_shrna    = nil
	@bottom_strand_shrna = nil
	@loop = nil
      end
      attr_accessor :method_name
      attr_accessor :top_strand_shrna
      attr_accessor :bottom_strand_shrna
      attr_accessor :loop
      
      def design
        if @method_name == 'BLOCK-iT'
	  block_it
	else
          raise NotImplementedError
        end
      end
      
      def block_it
        top_strand_shrna_overhang    = Bio::Sequence::NA.new('CACC')
        bottom_strand_shrna_overhang = Bio::Sequence::NA.new('AAAA')
#        loop = Bio::Sequence::NA.new('CGAA')  # From BLOCK-iT's manual
        @loop = Bio::Sequence::NA.new('GTGTGCTGTCC')   # From piGENE document

        if /^[G|g]/ =~ @pair.sense
  	  @top_strand_shrna    = top_strand_shrna_overhang    + @pair.sense + loop + @pair.sense.complement
	  @bottom_strand_shrna = bottom_strand_shrna_overhang + @pair.sense + loop.complement + @pair.sense.complement
	else
  	  @top_strand_shrna    = top_strand_shrna_overhang    + 'G' + @pair.sense + loop            + @pair.sense.complement
	  @bottom_strand_shrna = bottom_strand_shrna_overhang +       @pair.sense + loop.complement + @pair.sense.complement + 'C'
	end
	
#	@top_strand_shrna    = Bio::Sequence::NA.new(@top_strand_shrna).dna!
#	@bottom_strand_shrna = Bio::Sequence::NA.new(@bottom_strand_shrna).dna!
      end
      
      def as_human_readable_text
        report = ''
#        report << 'Top Strand shRNA:    ' + @top_strand_shrna.upcase.gsub(/G/, 'g') + "\n"
#        report << 'Bottom Strand shRNA: ' + @bottom_strand_shrna.upcase.gsub(/G/, 'g') + "\n"
        report << 'Top Strand shRNA:    ' + @top_strand_shrna.upcase    + "\n"
        report << 'Bottom Strand shRNA: ' + @bottom_strand_shrna.upcase + "\n"
        report << 'Size of Top Strand shRNA:    ' + @top_strand_shrna.size.to_s    + ' nt' + "\n"
        report << 'Size of Bottom Strand shRNA: ' + @bottom_strand_shrna.size.to_s + ' nt' + "\n"
        report << "5'-" + @top_strand_shrna.upcase            + "-3'" + "\n"
        report << "    3'-" + @bottom_strand_shrna.reverse.upcase + "-5'" + "\n"
      end
      alias :to_s :as_human_readable_text

    end #class Bio::SiRNA::ShRNA
  end #class SiRNA
end #module bio

if __FILE__ == $0
  
  input_seq = ARGF.read
  seq = Bio::Sequence::NA.new(input_seq)
  sirna_designer = Bio::SiRNA.new(seq)
  pairs = sirna_designer.design(rule = 'uitei') # or (rule = 'reynolds')  
  pairs.each do |pair|
    shRNA = Bio::SiRNA::ShRNA.new(pair, 'BLOCK-iT')
    shRNA.design

    puts pair.as_human_readable_text            
    puts shRNA.as_human_readable_text
    puts [shRNA.top_strand_shrna.dna!, shRNA.bottom_strand_shrna.dna!].join("\t")
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

-- Bio::SiRNA.new(seq, antisense_size, max_gc_percent, min_gc_percent)

-- Bio::SiRNA#design(rule)
-- Bio::SiRNA#antisense_size
-- Bio::SiRNA#max_gc_percent
-- Bio::SiRNA#min_gc_percent

== Bio::SiRNA::Pair

--- Bio::SiRNA::Pair.new(target, sense, antisense, target_start, target_stop, rule, antisense_gc_percent)

--- Bio::SiRNA::Pair#target
--- Bio::SiRNA::Pair#sense
--- Bio::SiRNA::Pair#antisense
--- Bio::SiRNA::Pair#start
--- Bio::SiRNA::Pair#stop
--- Bio::SiRNA::Pair#as_human_readable_text

= Bio::ShRNA

    Input is a Bio::SiRNA::Pair object (the target sequence).
    Output is a list of Bio::SiRNA::Pair object.

-- Bio::ShRNA.new(pair, 'design rule name')

-- Bio::ShRNA#design(rule)
-- Bio::ShRNA#antisense_size
-- Bio::ShRNA#max_gc_percent
-- Bio::ShRNA#min_gc_percent


-- ChangeLog

  2005/03/21 Itoshi NIKAIDO <itoshi.nikaido@nifty.com>
  Bio::SiRNA#ShRNA_designer method was changed design method.

  2004/06/25
  Bio::ShRNA class was added.

  2004/06/17 Itoshi NIKAIDO <itoshi.nikaido@nifty.com>
  We can use shRNA loop sequence from piGene document.

=end
