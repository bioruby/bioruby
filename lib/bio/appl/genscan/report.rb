#
# bio/appl/genscan/report.rb - Genscan report classes
#
#   Copyright (C) 2003 Mitsuteru C. Nakao <n@bioruby.org>
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
#  $Id: report.rb,v 1.1 2003/05/30 09:42:16 n Exp $
#

require 'bio/db/fasta'


module Bio

  class Genscan

    class Report
      
      def initialize(report)
	@predictions = []
	@genscan_version = nil
	@date_run        = nil
	@time            = nil
	@query_name = nil
	@length     = nil
	@gccontent  = nil
	@isochore   = nil
	@matrix     = nil

	report.each("\n") {|line|
	  case line
	  when /^GENSCAN/
	    headline_parse(line)
	  when /^Sequence/
	    sequence_parse(line)
	  when /^Parameter/
	    parameter_parse(line)
	  when /^Predicted genes/
	    break
	  end
	}

	# rests
	i = report.index(/^Predicted gene/)
	j = report.index(/^Predicted peptide sequence/)

	# genes/exons
	genes_region = report[i...j]
	genes_region.each("\n") {|line|
	  if /Init|Intr|Term|PlyA|Prom|Sngl/ =~ line
	    gn, en = line.strip.split(" +")[0].split('.').map {|i| i.to_i }
	    add_exon(gn, en, line)
	  end
	}

	# sequences (peptide|CDS)
	sequence_region = report[j...report.size]
	sequence_region.gsub!(/^Predicted .+?:/, '')
	sequence_region.gsub!(/^\s*$/, '')
	sequence_region.split(Bio::FastaFormat::RS).each {|ff|
	  add_seq(Bio::FastaFormat.new(ff))
	}

      end
      attr_reader :genscan_version, :date_run, :time
      attr_reader :query_name, :length, :gccontent, :isochore
      attr_reader :matrix
      attr_reader :predictions
      alias_method :sequence_name, :query_name
      alias_method :name, :query_name
      alias_method :prediction, :predictions
      alias_method :genes, :predictions


      def headline_parse(line)
	tmp = line.chomp.split("\t")
	@genscan_version = tmp[0].split(' ')[1]
	@date_run        = tmp[1].split(': ')[1]
	@time            = tmp[2].split(': ')[1]
      end
      private :headline_parse


      def sequence_parse(line)
	if /^Sequence (\S+) : (\d+) bp : (\d+[\.\d]+)% C\+G : Isochore (\d+.+?)$/ =~ line
	  @query_name = $1
	  @length     = $2.to_i
	  @gccontent  = $3.to_f
	  @isochore   = $4
	else
	  raise "Error: [#{line.inspect}]"
	end
      end
      private :sequence_parse


      def parameter_parse(line)
	if /^Parameter matrix: (\w.+)$/ =~ line.chomp
	  @matrix = $1
	else
	  raise "Error: [#{line}]"	  
	end
      end
      private :parameter_parse


      def add_gene(gn)
	@predictions[gn - 1] = Gene.new(gn)
      end
      private :add_gene


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



      class Gene
	
	def initialize(gn)
	  @number = gn.to_i
	  @aaseq = Bio::FastaFormat.new("")
	  @naseq = Bio::FastaFormat.new("")
	  @promoter = nil
	  @exons    = []
	  @polyA    = nil
	end
	attr_reader :number, :aaseq, :naseq, 
	  :exons, :promoter, :polyA


	def set_aaseq(seq)
	  @aaseq = seq
	end
	

	def set_naseq(seq)
	  @naseq = seq
	end


	def set_promoter(segment)
	  @promoter = segment
	end


	def set_polyA(segment)
	  @polyA = segment
	end

	  
      end # class Gene


      class Exon

	def self.parser(line)
	  e = line.strip.split(" +")
	  case line
	  when /PlyA/, /Prom/
	    e[12] = e[6].clone
	    e[11] = 0
	    [6,7,8,9,10].each {|i| e[i] = nil }
	  end

	  self.new(e[0], e[1], e[2], e[3], e[4], e[5], e[6], 
		   e[7], e[8], e[9], e[10], e[11], e[12])
	end


	TYPES = {
	  'Init' => 'Initial exon', 
	  'Intr' => 'Internal exon',
	  'Term' => 'Terminal exon',
	  'Sngl' => 'Single-exon gene',
	  'Prom' => 'Promoter',
	  'PlyA' => 'poly-A signal'
	}

	def initialize(gnex, t, s, b, e, len, fr, ph, iac, dot, cr, prob, ts)
	  @gene_number, @number = gnex.split(".").map {|n| n.to_i }
	  @exon_type = t
	  @strand  = s
	  @first   = b.to_i
	  @last    = e.to_i
	  @length  = len.to_i
	  @frame   = fr
	  @phase   = ph
	  @i_ac    = iac.to_i
	  @do_t    = dot.to_i
	  @score   = cr.to_i
	  @p_value = prob.to_f
	  @t_score = ts.to_f
	end
	attr_reader :gene_number, :number, :exon_type, :strand,
	  :first, :last, :frame, :phase, :score, :p_value, :t_score
	alias_method( :coding_region_score, :score )

	def exon_type_long
	  TYPES[exon_type]
	end
	

	def range 
	  Range.new(@first, @last)
	end


	def acceptor_score
	  @i_ac
	end
	alias_method( :initiation_score, :acceptor_score )


	def donor_score
	  @do_t
	end
	alias_method( :termination_score, :donor_score )

	
      end # class Exon

    end	# class Report

  end # class Genscan

end # module Bio





# testing code

if __FILE__ == $0

  puts "= class Bio::Genscan::Report "
  rpt = Bio::Genscan::Report.new($<.read)


  puts "==> rpt.genscan_version "
  p rpt.genscan_version
  puts "==> rpt.date_run "
  p rpt.date_run
  puts "==> rpt.time "
  p rpt.time

  puts "==> rpt.query_name "
  p rpt.query_name
  puts "==> rpt.length "
  p rpt.length
  puts "==> rpt.gccontent "
  p rpt.gccontent
  puts "==> rpt.isochore "
  p rpt.isochore

  puts "==> rpt.matrix " 
  p rpt.matrix

  puts "==> rpt.predictions (Array of Bio::Genscan::Report::Gene)  " 
  puts "==> rpt.predictions.size "
  p rpt.predictions.size

  puts "\n== class Bio::Genscan::Report::Gene "
  rpt.predictions.each {|gene|
    puts " ==> gene.number " 
    p gene.number
    puts " ==> gene.aaseq (Bio::FastaFormat)" 
    p gene.aaseq
    puts " ==> gene.naseq (Bio::FastaFormat) " 
    p gene.naseq
    puts " ==> gene.promoter (Bio::Genscan::Report::Exon)" 
    p gene.promoter
    puts " ==> gene.polyA (Bio::Genscan::Report::Exon) " 
    p gene.polyA
    puts " ==> gene.exons (Array of Bio::Genscan::Report::Exon) " 
    puts " ==> gene.exons.size " 
    p gene.exons.size

    puts "\n== class Bio::Genscan::Report::Exon "
    gene.exons.each {|exon|
      puts " ==> exon.number "
      p exon.number
      puts " ==> exon.exon_type "
      p exon.exon_type
      puts " ==> exon.exon_type_long "
      p exon.exon_type_long
      puts " ==> exon.strand "
      p exon.strand
      puts " ==> exon.first "
      p exon.first
      puts " ==> exon.last"
      p exon.last
      puts " ==> exon.range (Range)"
      p exon.range
      puts " ==> exon.frame"
      p exon.frame
      puts " ==> exon.phase"
      p exon.phase
      puts " ==> exon.acceptor_score"
      p exon.acceptor_score
      puts " ==> exon.donor_score"
      p exon.donor_score
      puts " ==> exon.initiation_score"
      p exon.initiation_score
      puts " ==> exon.termination_score"
      p exon.termination_score
      puts " ==> exon.score"
      p exon.score
      puts " ==> exon.p_value"
      p exon.p_value
      puts " ==> exon.t_score"
      p exon.t_score
      puts
    }
    puts
  }

end





=begin

= Bio::Genscan::Report

Parser for the Genscan report output.
* ((Genscan|URL:http://genes.mit.edu/GENSCAN.html)


--- Bio::Genscan::Report.new(report)
--- Bio::Genscan::Report#genscan_version

      Genscan version.

--- Bio::Genscan::Report#date_run
--- Bio::Genscan::Report#time
--- Bio::Genscan::Report#query_name

      Name of query sequence.

--- Bio::Genscan::Report#length

      Length of the query sequence.

--- Bio::Genscan::Report#gccontent

      C+G content of the query sequence.

--- Bio::Genscan::Report#isochore
--- Bio::Genscan::Report#predictions

      Array of Bio::Genscan::Report::Gene.


= Bio::Genscan::Report::Gene

Container class of predicted gene structures.

--- Bio::Genscan::Report::Gene#number

      "Gn", gene number field.

--- Bio::Genscan::Report::Gene#aaseq

      Returns Bio::FastaFormat object. 

--- Bio::Genscan::Report::Gene#naseq

      Returns Bio::FastaFormat object. 

--- Bio::Genscan::Report::Gene#promoter

      Returns Bio::Genscan::Report::Exon object. 

--- Bio::Genscan::Report::Gene#polyA

      Returns Bio::Genscan::Report::Exon object.

--- Bio::Genscan::Report::Gene#exons

      Array of Bio::Genscan::Report::Exon.


= Bio::Genscan::Report::Exon

Container class of a predicted gene structure.

--- Bio::Genscan::Report::Gene#number

      "Ex", exon number field

--- Bio::Genscan::Report::Gene#exon_type

      "Type" field.

--- Bio::Genscan::Report::Gene#exon_type_long

      Returns a human-readable "Type" of exon.

--- Bio::Genscan::Report::Gene#strand

      "S" field.

--- Bio::Genscan::Report::Gene#first

      Returns first position of the region. "Begin" field.

--- Bio::Genscan::Report::Gene#last

      Returns last position of the region. "End" field.

--- Bio::Genscan::Report::Gene#range

      Returns Range object of the region.

--- Bio::Genscan::Report::Gene#frame

      "Fr" field.

--- Bio::Genscan::Report::Gene#phase

      "Ph" field.

--- Bio::Genscan::Report::Gene#acceptor_score

      "I/Ac" field.

--- Bio::Genscan::Report::Gene#donor_score

      "Do/T" field.

--- Bio::Genscan::Report::Gene#initiation_score

      "I/Ac" field.

--- Bio::Genscan::Report::Gene#termination_score

      "Do/T" field.

--- Bio::Genscan::Report::Gene#score

      "CodRg" field.

--- Bio::Genscan::Report::Gene#p_value

      "P" field.

--- Bio::Genscan::Report::Gene#t_score

      "Tscr" field.


=end
