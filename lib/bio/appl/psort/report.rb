#
# bio/appl/psort/report.rb - PSORT systems report classes
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
#  $Id: report.rb,v 1.3 2003/06/27 02:16:56 n Exp $
#

require 'bio/sequence'


module Bio

  class PSORT

    class PSORT2

      SclNames = { 
	'csk' => 'cytoskeletal',
	'cyt' => 'cytoplasmic',
	'nuc' => 'nuclear',
	'mit' => 'mitochondrial',
	'ves' => 'vesicles of secretory system',
	'end' => 'endoplasmic reticulum',
	'gol' => 'Golgi',
	'vac' => 'vacuolar',
	'pla' => 'plasma membrane',
	'pox' => 'peroxisomal',
	'exc' => 'extracellular, including cell wall',
	'---' => 'other'
      }
    
      Features = [
	'psg',  # PSG: PSG score
	'gvh',  # GvH: GvH score
	'alm',  # ALOM: $xmax
	'tms',  # ALOM: $count
	'top',  # MTOP: Charge difference: $mtopscr
	'mit',  # MITDISC: Score: $score
	'mip',  # Gavel: motif at $isite
	'nuc',  # NUCDISC: NLS Score: $score
	'erl',  # KDEL: ($seg|none)
	'erm',  # ER Membrane Retention Signals: ($cseg|none) $scr
	'pox',  # SKL: ($pat|none) $scr
	'px2',  # PTS2: (found|none)              ($#match < 0) ? 0 : ($#match+1);
	'vac',  # VAC: (found|none)               ($#match < 0) ? 0 : ($#match+1);
	'rnp',  # RNA-binding motif: (found|none) ($#match < 0) ? 0 : ($#match+1);
	'act',  # Actinin-type actin-binding motif: (found|none)  $hit
	'caa',  # Prenylation motif: (2|1|0) CaaX,CXC,CC,nil
	'yqr',  # memYQRL: (found|none) $scr
	'tyr',  # Tyrosines in the tail: (none|\S+[,])  
	        # 10 * scalar(@ylist) / ($end - $start + 1);
	'leu',  # Dileucine motif in the tail: (none|found) $scr
	'gpi',  # >>> Seem to be GPI anchored
	'myr',  # NMYR: (none|\w) $scr
	'dna',  # checking 63 PROSITE DNA binding motifs:              $hit
	'rib',  # checking 71 PROSITE ribosomal protein motifs:        $hit
	'bac',  # checking 33 PROSITE prokaryotic DNA binding motifs:  $hit
	'm1a',  # $mtype eq '1a'  
	'm1b',  # $mtype eq '1b'
	'm2',   # $mtype eq '2 '
	'mNt',  # $mtype eq 'Nt'
	'm3a',  # $mtype eq '3a' 
	'm3b',  # $mtype eq '3b'  
	'm_',   # $mtype eq '__'  tms == 0
	'ncn',  # NNCN: ($NetOutput[1] > $NetOutput[0]) ? $output : (-$output);
	'lps',  # COIL: $count
	'len'   # $leng
      ]
      
      FeaturesLong = {
	'psg' => 'PSG',  
	'gvh' => 'GvH',
	'tms' => 'ALOM',
	'alm' => 'ALOM',
	'top' => 'MTOP',
	'mit' => 'MITDISC',
	'mip' => 'Gavel',
	'nuc' => 'NUCDISC',
	'erl' => 'KDEL',
	'erm' => 'ER Membrane Retention Signals',
	'pox' => 'SKL',
	'px2' => 'PTS2', 
	'vac' => 'VAC', 
	'rnp' => 'RNA-binding motif',
	'act' => 'Actinin-type actin-binding motif',
	'caa' => 'Prenylation motif',
	'yqr' => 'memYQRL', 
	'tyr' => 'Tyrosines in the tail',
	'leu' => 'Dileucine motif in the tail',
	'gpi' => '>>> Seems to be GPI anchored',
	'myr' => 'NMYR', 
	'dna' => 'checking 63 PROSITE DNA binding motifs',
	'rib' => 'checking 71 PROSITE ribosomal protein motifs',
	'bac' => 'ochecking 33 PROSITE prokaryotic DNA binding motifs:', 
	'm1a' => '', 
	'm1b' => '', 
	'm2'  => '', 
	'mNt' => '', 
	'm3a' => '', 
	'm3b' => '', 
	'm_'  => '', 
	'ncn' => 'NNCN', 
	'lps' => 'COIL',
	'len' => 'AA'       # length of input sequence
      }


      class Report

	BOUNDARY  = '-' * 75
	DELIMITER = "\)\n\n#{BOUNDARY}"

	def initialize(entry_id = nil, scl = nil, definition = nil, seq = nil, 
		       k = nil, features = {}, prob = {}, pred = nil)
	  @entry_id   = entry_id
	  @scl        = scl
	  @definition = definition
	  @seq        = seq
	  @features   = features
	  @prob       = prob
	  @pred       = pred
	  @k          = k
	end
	attr_accessor :entry_id, :scl, :definition, :seq, 
	  :k, :features, :prob, :pred
	
	# format auto detection
	def self.parser(str)
	  case str
	  when /^ psg:/ 
	    self.default_parser(str)
	  when /^PSG:/
	    self.v_parser(str)
	  when /: too short length /
	    self.too_short_parser(str)
	  when /PSORT II server/
	    tmp = self.new('QUERY')
	  else
	    raise ArgumentError, "invalid format\n[#{str}]"
	  end
	end


	# $id: too short length ($leng), skipped\n";
	def self.too_short_parser(ent)
	  report = self.new
	  if ent =~ /^(.+)?: too short length/
	    report.entry_id = $1
	    report.scl = '---'
	  end
	  report
	end


	# default report
	# ``psort test.faa'' output
	def self.default_parser(ent)
	  report = self.new
	  ent = ent.split("\n\n").map {|e| e.chomp }

	  report.set_header_line(ent[0])

	  # feature matrix
	  ent[1].gsub(/\n/,' ').strip.split('  ').map {|fe|
	    pair = fe.split(': ')
	    report.features[pair[0].strip] = pair[1].strip.to_f
	  }

	  report.prob = self.set_kNN_prob(ent[2])
	  report.set_prediction(ent[3])	         

	  return report
	end


	def set_header_line(str)
	  str.sub!(/^-+\n/,'')
	  tmp = str.split(/\t| /)
	  self.entry_id   = tmp.shift.sub(/^-+/,'').strip
	  case tmp.join(' ').chomp
	  when /\(\d+ aa\) (.+)$/
	    self.definition = $1
	  else
	    self.definition = tmp.join(' ').chomp
	  end
	  scl = self.definition.split(' ')[0]

	  self.scl = scl if SclNames.keys.index(scl)
	end


	def self.set_kNN_prob(str)
	  prob = Hash.new
	  Bio::PSORT::PSORT2::SclNames.keys.each {|a| 
	    prob.update( {a => 0.0} )
	  }
	  str.gsub("\t",'').split("\n").each {|a|
	    val,scl = a.strip.split(' %: ')
	    key = Bio::PSORT::PSORT2::SclNames.index(scl)
	    prob[key] = val.to_f
	  }
	  prob
	end


	def set_prediction(str)
	  case str
	  when /prediction for (\S+?) is (\w{3}) \(k=(\d+)\)/
	    @entry_id ||= $1
	    @pred = $2
	    @k    = $3
	  else
	    raise ArgumentError, 
	      "Invalid format at(#{self.entry_id}):\n[#{str}]\n"
	  end
	end


	# ``psort -v report'' and WWW server output
	def self.v_parser(ent)
	  report = Bio::PSORT::PSORT2::Report.new

	  ent = ent.split(/\n\n/).map {|e| e.chomp }
	  ent.each_with_index {|e, i|
	    unless /^(\w|-|\>|\t)/ =~ e
	      ent[i - 1] += e
	      ent[i] = nil
	    end
	    if /^none/ =~ e    # for psort output bug
	      ent[i - 1] += e
	      ent[i] = nil
	    end
	  }
	  ent.compact!
	  # ent.each_with_index {|e,i| p [i.to_s.ljust(2), e] }

	  if /^ PSORT II server/ =~ ent[0] # for WWW version
	    ent.shift 
	    delline = ''
	    ent.each {|e| delline = e if /^Results of Subprograms/ =~ e }
	    i = ent.index(delline)
	    ent.delete(delline)
	    ent.delete_at(i - 1)
	  end

	  report.set_header_line(ent.shift)	  
	  report.seq = Bio::Sequence::AA.new(ent.shift)

	  fent,pent = self.divent(ent)
	  report.set_features(fent)	          
	  report.prob = self.set_kNN_prob(pent[0].strip)	  
	  report.set_prediction(pent[1].strip)	

	  return report
	end


	# divide entry body
	def self.divent(ent)
	  boundary = ent.index(BOUNDARY)
	  return ent[0..(boundary - 1)], ent[(boundary + 2)..ent.length]
	end

	#
	def set_features(fary)
	  fary.each {|fent|
	    key = fent.split(":( |\n)")[0].strip
	    
	    self.features[key] = fent # unless /^\>/ =~ key
	  }
	  self.features['AA'] = self.seq.length
	end
	
      end # class Report
 
    end # class PSORT2      

  end # class PSORT

end # module Bio





# testing code

if __FILE__ == $0


  while entry = $<.gets(Bio::PSORT::PSORT2::Report::DELIMITER)

    puts "\n ==> a = Bio::PSORT::PSORT2::Report.parser(entry)"
    a = Bio::PSORT::PSORT2::Report.parser(entry)

    puts "\n ==> a.entry_id "
    p a.entry_id
    puts "\n ==> a.scl "
    p a.scl
    puts "\n ==> a.pred "
    p a.pred
    puts "\n ==> a.prob "
    p a.prob
    p a.prob.keys.sort.map {|k| k.rjust(4)}.inspect.gsub('"','')
    p a.prob.keys.sort.map {|k| a.prob[k].to_s.rjust(4) }.inspect.gsub('"','')

    puts "\n ==> a.k "
    p a.k
    puts "\n ==> a.definition"
    p a.definition
    puts "\n ==> a.seq"
    p a.seq

    puts "\n ==> a.features.keys.sort "
    p a.features.keys.sort

    puts "\n ==> a.features['checking 63 PROSITE DNA binding motifs'] "
    puts a.features['checking 63 PROSITE DNA binding motifs']

    
  end

end





=begin



= Bio::PSORT::PSORT2

--- Bio::PSORT::SclNames
--- Bio::PSORT::Features
--- Bio::PSORT::FeaturesLong

= Bio::PSORT::PSORT2::Report

Parsed results of the PSORT2 report for default, ``-v'' and WWW version 
output format.

--- Bio::PSORT::PSORT2::Report.new
--- Bio::PSORT::PSORT2::Report#entry_id
--- Bio::PSORT::PSORT2::Report#scl
--- Bio::PSORT::PSORT2::Report#definition
--- Bio::PSORT::PSORT2::Report#seq
--- Bio::PSORT::PSORT2::Report#features
--- Bio::PSORT::PSORT2::Report#prob
--- Bio::PSORT::PSORT2::Report#pred
--- Bio::PSORT::PSORT2::Report#k

--- Bio::PSORT::PSORT2::Report.parser(report)

      Returns a PSORT report object (Bio::PSORT::PSORT2::Report). 
      Formats are auto detedted.

--- Bio::PSORT::PSORT2::Report::BOUNDARY

      Fields boundary in a PSORT report.

--- Bio::PSORT::PSORT2::Report::DELIMITER

      Entry boundary in PSORT reports.

=end
