#
# = bio/appl/genscan/report.rb - Genscan report classes
#
# Copyright::  Copyright (C) 2003 
#              Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: report.rb,v 1.10 2007/04/05 23:35:39 trevor Exp $
#
# == Description
#
#
# == Example
#
# == References
#

require 'bio/db/fasta'


module Bio

# = Bio::Genscan
class Genscan

  # = Bio::Genscan::Report - Class for Genscan report output.
  #
  # Parser for the Genscan report output.
  # * Genscan http://genes.mit.edu/GENSCAN.html
  class Report

    # Returns Genscan version.
    attr_reader :genscan_version

    # Returns
    attr_reader :date_run

    # Returns
    attr_reader :time

    # Returns Name of query sequence.
    attr_reader :query_name
    alias_method :sequence_name, :query_name
    alias_method :name,          :query_name

    # Returns Length of the query sequence.
    attr_reader :length

    # Returns C+G content of the query sequence.
    attr_reader :gccontent

    # Returns
    attr_reader :isochore

    # Returns
    attr_reader :matrix

    # Returns Array of Bio::Genscan::Report::Gene.
    attr_reader :predictions
    alias_method :prediction, :predictions
    alias_method :genes,      :predictions


    # Bio::Genscan::Report.new(str)
    #
    # Parse a Genscan report output string.
    def initialize(report)
      @predictions = []
      @genscan_version = nil
      @date_run   = nil
      @time       = nil
      @query_name = nil
      @length     = nil
      @gccontent  = nil
      @isochore   = nil
      @matrix     = nil

      report.each("\n") do |line|
        case line
        when /^GENSCAN/
          parse_headline(line)
        when /^Sequence/
          parse_sequence(line)
        when /^Parameter/
          parse_parameter(line)
        when /^Predicted genes/
          break
        end
      end

      # rests
      i = report.index(/^Predicted gene/)
      j = report.index(/^Predicted peptide sequence/)

      # genes/exons
      genes_region = report[i...j]
      genes_region.each("\n") do |line|
        if /Init|Intr|Term|PlyA|Prom|Sngl/ =~ line
          gn, en = line.strip.split(" +")[0].split(/\./).map {|i| i.to_i }
          add_exon(gn, en, line)
        end
      end

      # sequences (peptide|CDS)
      sequence_region = report[j...report.size]
      sequence_region.gsub!(/^Predicted .+?:/, '')
      sequence_region.gsub!(/^\s*$/, '')
      sequence_region.split(Bio::FastaFormat::RS).each do |ff|
        add_seq(Bio::FastaFormat.new(ff))
      end
    end


    # Bio::Genscan::Report#parse_headline
    def parse_headline(line)
      tmp = line.chomp.split(/\t/)
      @genscan_version = tmp[0].split(' ')[1]
      @date_run        = tmp[1].split(': ')[1]
      @time            = tmp[2].split(': ')[1]
    end
    private :parse_headline


    # Bio::Genscan::Report#parse_sequence
    def parse_sequence(line)
      if /^Sequence (\S+) : (\d+) bp : (\d+[\.\d]+)% C\+G : Isochore (\d+.+?)$/ =~ line
        @query_name = $1
        @length     = $2.to_i
        @gccontent  = $3.to_f
        @isochore   = $4
      else
        raise "Error: [#{line.inspect}]"
      end
    end
    private :parse_sequence


    # Bio::Genscan::Report#parse_parameter
    def parse_parameter(line)
      if /^Parameter matrix: (\w.+)$/ =~ line.chomp
        @matrix = $1
      else
        raise "Error: [#{line}]"  
      end
    end
    private :parse_parameter


    # Bio::Genscan::Report#add_gene
    def add_gene(gn)
      @predictions[gn - 1] = Gene.new(gn)
    end
    private :add_gene
    

    # Bio::Genscan::Report#add_exon
    def add_exon(gn, en, line)
      exon = Exon.parser(line)
      case line
      when /Prom/
        begin
          @predictions[gn - 1].set_promoter(exon)
        rescue NameError
          add_gene(gn)
          @predictions[gn - 1].set_promoter(exon)
        end
      when /PlyA/
        @predictions[gn - 1].set_polyA(exon)
      else
        begin
          @predictions[gn - 1].exons[en - 1] = exon
        rescue NameError
          add_gene(gn)
          @predictions[gn - 1].exons[en - 1] = exon
        end
      end
    end
    private :add_exon
      

    # Bio::Genscan::Report#add_seq
    def add_seq(seq)
      if /peptide_(\d+)/ =~ seq.definition
        gn = $1.to_i
        @predictions[gn - 1].set_aaseq(seq)
      elsif /CDS_(\d+)/ =~ seq.definition
        gn = $1.to_i
        @predictions[gn - 1].set_naseq(seq)
      end
    end
    private :add_seq


    # = Container class of predicted gene structures.
    class Gene

      # Bio::Genescan::Report::Gene.new(gene_number)
      def initialize(gn)
        @number = gn.to_i
        @aaseq = Bio::FastaFormat.new("")
        @naseq = Bio::FastaFormat.new("")
        @promoter = nil
        @exons    = []
        @polyA    = nil
      end

      # Returns "Gn", gene number field.
      attr_reader :number

      # Returns Bio::FastaFormat object.
      attr_reader :aaseq

      # Returns Bio::FastaFormat object.
      attr_reader :naseq

      # Returns Array of Bio::Genscan::Report::Exon.
      attr_reader :exons

      # Returns Bio::Genscan::Report::Exon object.
      attr_reader :promoter

      # Returns Bio::Genscan::Report::Exon object.
      attr_reader :polyA


      # Bio::Genescan::Report::Gene#seq_aaseq
      def set_aaseq(seq)
        @aaseq = seq
      end

        
      # Bio::Genescan::Report::Gene#seq_naseq
      def set_naseq(seq)
        @naseq = seq
      end


      # Bio::Genescan::Report::Gene#seq_promoter
      def set_promoter(segment)
        @promoter = segment
      end


      # Bio::Genescan::Report::Gene#seq_polyA
      def set_polyA(segment)
        @polyA = segment
      end

    end # class Gene


    # = Container class of a predicted gene structure.
    class Exon

      #
      TYPES = {
        'Init' => 'Initial exon', 
        'Intr' => 'Internal exon',
        'Term' => 'Terminal exon',
        'Sngl' => 'Single-exon gene',
        'Prom' => 'Promoter',
        'PlyA' => 'poly-A signal'
      }


      # Bio::Genescan::Report::Exon.parser
      def self.parser(line)
        e = line.strip.split(/ +/)
        case line
        when /PlyA/, /Prom/
          e[12] = e[6].clone
          e[11] = 0
          [6,7,8,9,10].each {|i| e[i] = nil }
        end
        self.new(e[0], e[1], e[2], e[3], e[4], e[5], e[6], 
                 e[7], e[8], e[9], e[10], e[11], e[12])
      end


      # Returns
      attr_reader :gene_number

      # Returns "Ex", exon number field
      attr_reader :number

      # Returns "Type" field.
      attr_reader :exon_type

      # Returns "S" field.
      attr_reader :strand

      # Returns Returns first position of the region. "Begin" field.
      attr_reader :first

      # Returns Returns last position of the region. "End" field.
      attr_reader :last

      # Returns "Fr" field.
      attr_reader :frame

      # Returns "Ph" field.
      attr_reader :phase

      # Returns "CodRg" field.
      attr_reader :score

      # Returns "P" field.
      attr_reader :p_value

      # Returns "Tscr" field.
      attr_reader :t_score
      alias_method :coding_region_score, :score 

      
      # Bio::Genescan::Report::Exon.new(gene_number, exon_type, strand, first, 
      # end, length, frame, phase, acceptor_score, donor_score, score, p_value, 
      # t_score)
      def initialize(gnex, t, s, b, e, len, fr, ph, iac, dot, cr, prob, ts)
        @gene_number, @number = gnex.split(".").map {|n| n.to_i }
        @exon_type = t
        @strand    = s
        @first     = b.to_i
        @last      = e.to_i
        @length    = len.to_i
        @frame     = fr
        @phase     = ph
        @i_ac      = iac.to_i
        @do_t      = dot.to_i
        @score     = cr.to_i
        @p_value   = prob.to_f
        @t_score   = ts.to_f
      end



      # Bio::Genescan::Report::Exon#exon_type_long      
      #
      # Returns a human-readable "Type" of exon.
      def exon_type_long
        TYPES[exon_type]
      end

        
      # Bio::Genescan::Report::Exon#range
      #
      # Returns Range object of the region.
      def range 
        Range.new(@first, @last)
      end


      # Bio::Genescan::Report::Exon#acceptor_score
      #
      # "I/Ac" field.
      def acceptor_score
        @i_ac
      end
      alias_method :initiation_score, :acceptor_score 


      # Bio::Genescan::Report::Exon#donor_score
      #
      # "Do/T" field.
      def donor_score
        @do_t
      end
      alias_method :termination_score, :donor_score 

    end # class Exon
    
  end # class Report
  
end # class Genscan

end # module Bio





# testing code

if __FILE__ == $0

  if $<.filename != '-'
    report = $<.read
  else
    report = File.open(__FILE__,  'r').read.scan(/^>>>> (.+)$/).join("\n")
  end


  puts "= class Bio::Genscan::Report "
  report = Bio::Genscan::Report.new(report)


  print " report.genscan_version #=> "
  p report.genscan_version
  print " report.date_run #=> "
  p report.date_run
  print " report.time #=> "
  p report.time

  print " report.query_name #=> "
  p report.query_name
  print " report.length #=> "
  p report.length
  print " report.gccontent #=> "
  p report.gccontent
  print " report.isochore #=> "
  p report.isochore

  print " report.matrix #=> " 
  p report.matrix

  puts " report.predictions (Array of Bio::Genscan::Report::Gene)  " 
  print " report.predictions.size #=> "
  p report.predictions.size


  report.predictions.each {|gene|
    puts "\n== class Bio::Genscan::Report::Gene "
    print " gene.number #=> " 
    p gene.number
    print " gene.aaseq (Bio::FastaFormat) #=> " 
    p gene.aaseq
    print " gene.naseq (Bio::FastaFormat) #=> " 
    p gene.naseq
    print " ene.promoter (Bio::Genscan::Report::Exon) #=> " 
    p gene.promoter
    print " gene.polyA (Bio::Genscan::Report::Exon) #=> " 
    p gene.polyA
    puts " gene.exons (Array of Bio::Genscan::Report::Exon) " 
    print " gene.exons.size #=> " 
    p gene.exons.size


    gene.exons.each {|exon|
      puts "\n== class Bio::Genscan::Report::Exon "
      print " exon.number #=> "
      p exon.number
      print " exon.exon_type #=> "
      p exon.exon_type
      print " exon.exon_type_long #=> "
      p exon.exon_type_long
      print " exon.strand #=> "
      p exon.strand
      print " exon.first #=> "
      p exon.first
      print " exon.last #=> "
      p exon.last
      print " exon.range (Range) #=> "
      p exon.range
      print " exon.frame #=> "
      p exon.frame
      print " exon.phase #=> "
      p exon.phase
      print " exon.acceptor_score #=> "
      p exon.acceptor_score
      print " exon.donor_score #=> "
      p exon.donor_score
      print " exon.initiation_score #=> "
      p exon.initiation_score
      print " exon.termination_score #=> "
      p exon.termination_score
      print " exon.score #=> "
      p exon.score
      print " exon.p_value #=> "
      p exon.p_value
      print " exon.t_score #=> "
      p exon.t_score
      puts
    }
    puts
  }

end





=begin


= Sample Genscan report with '^>>>> '.


>>>> GENSCAN 1.0	Date run: 30-May-103	Time: 14:06:28
>>>> 
>>>> Sequence HUMRASH : 12942 bp : 68.17% C+G : Isochore 4 (57 - 100 C+G%)
>>>> 
>>>> Parameter matrix: HumanIso.smat
>>>> 
>>>> Predicted genes/exons:
>>>> 
>>>> Gn.Ex Type S .Begin ...End .Len Fr Ph I/Ac Do/T CodRg P.... Tscr..
>>>> ----- ---- - ------ ------ ---- -- -- ---- ---- ----- ----- ------
>>>> 
>>>>  1.01 Init +   1664   1774  111  1  0   94   83   212 0.997  21.33
>>>>  1.02 Intr +   2042   2220  179  1  2  104   66   408 0.997  40.12
>>>>  1.03 Intr +   2374   2533  160  1  1   89   94   302 0.999  32.08
>>>>  1.04 Term +   3231   3350  120  2  0  115   48   202 0.980  18.31
>>>>  1.05 PlyA +   3722   3727    6                              -5.80
>>>> 
>>>>  2.00 Prom +   6469   6508   40                              -7.92
>>>>  2.01 Init +   8153   8263  111  1  0   94   83   212 0.998  21.33
>>>>  2.02 Intr +   8531   8709  179  1  2  104   66   408 0.997  40.12
>>>>  2.03 Intr +   8863   9022  160  1  1   89   94   302 0.999  32.08
>>>>  2.04 Term +   9720   9839  120  2  0  115   48   202 0.961  18.31
>>>> 
>>>> Predicted peptide sequence(s):
>>>> 
>>>> Predicted coding sequence(s):
>>>> 
>>>> 
>>>> >HUMRASH|GENSCAN_predicted_peptide_1|189_aa
>>>> MTEYKLVVVGAGGVGKSALTIQLIQNHFVDEYDPTIEDSYRKQVVIDGETCLLDILDTAG
>>>> QEEYSAMRDQYMRTGEGFLCVFAINNTKSFEDIHQYREQIKRVKDSDDVPMVLVGNKCDL
>>>> AARTVESRQAQDLARSYGIPYIETSAKTRQGVEDAFYTLVREIRQHKLRKLNPPDESGPG
>>>> CMSCKCVLS
>>>> 
>>>> >HUMRASH|GENSCAN_predicted_CDS_1|570_bp
>>>> atgacggaatataagctggtggtggtgggcgccggcggtgtgggcaagagtgcgctgacc
>>>> atccagctgatccagaaccattttgtggacgaatacgaccccactatagaggattcctac
>>>> cggaagcaggtggtcattgatggggagacgtgcctgttggacatcctggataccgccggc
>>>> caggaggagtacagcgccatgcgggaccagtacatgcgcaccggggagggcttcctgtgt
>>>> gtgtttgccatcaacaacaccaagtcttttgaggacatccaccagtacagggagcagatc
>>>> aaacgggtgaaggactcggatgacgtgcccatggtgctggtggggaacaagtgtgacctg
>>>> gctgcacgcactgtggaatctcggcaggctcaggacctcgcccgaagctacggcatcccc
>>>> tacatcgagacctcggccaagacccggcagggagtggaggatgccttctacacgttggtg
>>>> cgtgagatccggcagcacaagctgcggaagctgaaccctcctgatgagagtggccccggc
>>>> tgcatgagctgcaagtgtgtgctctcctga
>>>> 
>>>> >HUMRASH|GENSCAN_predicted_peptide_2|189_aa
>>>> MTEYKLVVVGAGGVGKSALTIQLIQNHFVDEYDPTIEDSYRKQVVIDGETCLLDILDTAG
>>>> QEEYSAMRDQYMRTGEGFLCVFAINNTKSFEDIHQYREQIKRVKDSDDVPMVLVGNKCDL
>>>> AARTVESRQAQDLARSYGIPYIETSAKTRQGVEDAFYTLVREIRQHKLRKLNPPDESGPG
>>>> CMSCKCVLS
>>>> 
>>>> >HUMRASH|GENSCAN_predicted_CDS_2|570_bp
>>>> atgacggaatataagctggtggtggtgggcgccggcggtgtgggcaagagtgcgctgacc
>>>> atccagctgatccagaaccattttgtggacgaatacgaccccactatagaggattcctac
>>>> cggaagcaggtggtcattgatggggagacgtgcctgttggacatcctggataccgccggc
>>>> caggaggagtacagcgccatgcgggaccagtacatgcgcaccggggagggcttcctgtgt
>>>> gtgtttgccatcaacaacaccaagtcttttgaggacatccaccagtacagggagcagatc
>>>> aaacgggtgaaggactcggatgacgtgcccatggtgctggtggggaacaagtgtgacctg
>>>> gctgcacgcactgtggaatctcggcaggctcaggacctcgcccgaagctacggcatcccc
>>>> tacatcgagacctcggccaagacccggcagggagtggaggatgccttctacacgttggtg
>>>> cgtgagatccggcagcacaagctgcggaagctgaaccctcctgatgagagtggccccggc
>>>> tgcatgagctgcaagtgtgtgctctcctga

=end
