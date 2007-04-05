#
# = bio/appl/psort/report.rb - PSORT systems report classes
#
# Copyright::   Copyright (C) 2003 
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
#  $Id: report.rb,v 1.15 2007/04/05 23:35:40 trevor Exp $
#
# == A Report classes for PSORT Systems
# 

require 'bio/appl/psort'


module Bio

  autoload :Sequence, 'bio/sequence'

  class PSORT

    class PSORT1

      # = Bio::PSORT::PSORT1::Report
      # Parser class for PSORT1 output report.
      # 
      # == Example
      class Report

        # Returns aBio::PSORT::PSORT1::Report.
        def self.parser(output_report)
          self.default_parser(output_report)
        end

        # Returns aBio::PSORT::PSORT1::Report.
        def self.default_parser(output_report)
          rpt = self.new
          rpt.raw = output_report
          query_info = output_report.scan(/^Query Information\n\n(.+?)\n\n/m)[0][0].split(/\n/)
          result_info = output_report.scan(/^Result Information\n\n(.+?)\n\n\*/m)[0][0]
          step1 = output_report.scan(/^\*\*\* Reasoning Step: 1\n\n(.+?)\n\n/m)[0][0]
          step2 = output_report.scan(/^\*\*\* Reasoning Step: 2\n\n(.+?)\n\n/m)[0][0]
          final_result = output_report.scan(/\n\n----- Final Results -----\n\n(.+?)\n\n\n/m)[0][0]

          rpt.entry_id = query_info[2].scan(/^>(\S+) */).to_s
          rpt.origin   = query_info[0].scan(/ORIGIN (\w+)/).to_s
          rpt.sequence = Bio::Sequence::AA.new(query_info[3..query_info.size].to_s)
          # rpt.reasoning

          rpt.final_result = final_result.split(/\n/).map {|x|
            x = x.strip.split(/---/).map {|y| y.strip }
            { 'prediction' => x[0], 
              'certainty'  => x[1].scan(/Certainty= (\d\.\d{3})/).to_s,
              'comment'    => x[1].scan(/\((\w+)\)/).to_s
            }
          }
          return rpt
        end

        attr_accessor :entry_id
        attr_accessor :origin
        attr_accessor :title
        attr_accessor :sequence
        attr_accessor :result_info
        attr_accessor :reasoning
        attr_accessor :final_result
        attr_accessor :raw



        # Constructs aBio::PSORT::PSORT1::Report object.
        def initialize(entry_id = '', origin = '', title = '', sequence = '',
                       result_info = '', reasoning = {}, final_result = [])
          @entry_id = entry_id
          @origin = origin
          @title = title
          @sequence = sequence
          @result_info = result_info
          @reasoning = reasoning
          @final_result = final_result
          @raw = ''
        end


      end # class Report

    end # class PSORT1



    class PSORT2

      # Subcellular localization name codes used by PSORT2 
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
    
      # Feature name codes
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
      
      # Feature name codes (long version).
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

      # = Bio::PSORT::PSORT2::Report
      # Report parser classe for PSORT II(PSORT2).
      # == Example
      class Report

        # Report boundary string.
        BOUNDARY  = '-' * 75


        # Report delimiter.
        RS = DELIMITER = "\)\n\n#{BOUNDARY}"

        # entry_id of query sequence. 
        attr_accessor :entry_id 

        # Given subcellular localization (three letters code).
        attr_accessor :scl

        # Definition of query sequence.
        attr_accessor :definition
        
        # Sequence of query sequence.
        attr_accessor :seq

        # k parameter of k-nearest neighbors classifier.
        attr_accessor :k

        # Feature vector used the kNN prediction.
        attr_accessor :features

        # Probability vector of kNN prediction.
        attr_accessor :prob

        # Predicted subcellular localization (three letters code).
        attr_accessor :pred
        
        # Raw text of output report.
        attr_accessor :raw


        # Constructs aBio::PSORT::PSORT2::Report object.
        def initialize(raw = '', entry_id = nil, scl = nil, definition = nil, 
                       seq = nil, k = nil, features = {}, prob = {}, pred = nil)
          @entry_id   = entry_id
          @scl        = scl
          @definition = definition
          @seq        = seq
          @features   = features
          @prob       = prob
          @pred       = pred
          @k          = k
          @raw        = raw
        end

        
        # Parses output report with output format detection automatically.
        def self.parser(str, entry_id)
          case str
          when /^ psg:/   # default report
            self.default_parser(str, entry_id)
          when /^PSG:/    # -v report
            self.v_parser(str, entry_id)
          when /: too short length /
            self.too_short_parser(str, entry_id)
          when /PSORT II server/
            tmp = self.new(ent, entry_id)
          else
            raise ArgumentError, "invalid format\n[#{str}]"
          end
        end

        # Parser for ``too short length'' report.
        #
        #  $id: too short length ($leng), skipped\n";
        def self.too_short_parser(ent, entry_id = nil)
          report = self.new(ent)
          report.entry_id = entry_id
          if ent =~ /^(.+)?: too short length/
            report.entry_id = $1 unless report.entry_id
            report.scl = '---'
          end
          report
        end


        # Parser for the default report format.
        # ``psort report'' output.
        def self.default_parser(ent, entry_id = nil)
          report = self.new(ent, entry_id)
          ent = ent.split(/\n\n/).map {|e| e.chomp }

          report.set_header_line(ent[0])

          # feature matrix
          ent[1].gsub(/\n/,' ').strip.split(/  /).map {|fe|
            pair = fe.split(/: /)
            report.features[pair[0].strip] = pair[1].strip.to_f
          }

          report.prob = self.set_kNN_prob(ent[2])
          report.set_prediction(ent[3])         

          return report
        end

        # Returns header information.
        def set_header_line(str)
          str.sub!(/^-+\n/,'')
          tmp = str.split(/\t| /)
          @entry_id = tmp.shift.sub(/^-+/,'').strip unless @entry_id

          case tmp.join(' ').chomp
          when /\(\d+ aa\) (.+)$/
            @definition = $1
          else
            @definition = tmp.join(' ').chomp
          end
          scl = @definition.split(' ')[0]

          @scl = scl if SclNames.keys.index(scl)
        end

        # Returns @prob value.
        def self.set_kNN_prob(str)
          prob = Hash.new
          Bio::PSORT::PSORT2::SclNames.keys.each {|a| 
            prob.update( {a => 0.0} )
          }
          str.gsub(/\t/,'').split(/\n/).each {|a|
            val,scl = a.strip.split(/ %: /)
            key = Bio::PSORT::PSORT2::SclNames.index(scl)
            prob[key] = val.to_f
          }
          return prob
        end

        # Returns @prob and @k values.
        def set_prediction(str)
          case str
          when /prediction for (\S+?) is (\w{3}) \(k=(\d+)\)/
            @entry_id ||= $1 unless @entry_id
            @pred = $2
            @k    = $3
          else
            raise ArgumentError, 
              "Invalid format at(#{self.entry_id}):\n[#{str}]\n"
          end
        end


        # Parser for the verbose output report format.
        # ``psort -v report'' and WWW server output.
        def self.v_parser(ent, entry_id = nil)
          report = Bio::PSORT::PSORT2::Report.new(ent, entry_id)

          ent = ent.split(/\n\n/).map {|e| e.chomp }
          ent.each_with_index {|e, i|
            unless /^(\w|-|\>|\t)/ =~ e
              j = self.__send__(:search_j, i, ent)
              ent[i - j] += e
              ent[i] = nil
            end
            if /^none/ =~ e    # psort output bug
              j = self.__send__(:search_j, i, ent)
              ent[i - j] += e
              ent[i] = nil
            end
          }
          ent.compact!

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

          fent, pent = self.divent(ent)
          report.set_features(fent)          
          report.prob = self.set_kNN_prob(pent[0].strip)  
          report.set_prediction(pent[1].strip)

          return report
        end


        # 
        def self.search_j(i, ent)
          j = 1
          1.upto(ent.size) {|x|
            if ent[i - x]
              j = x
              break
            end
          }
          return j
        end
        private_class_method :search_j


        # Divides entry body
        def self.divent(entry)
          boundary = entry.index(BOUNDARY)
          return entry[0..(boundary - 1)], entry[(boundary + 2)..(entry.length)]
        end

        # Sets @features values.
        def set_features(features_ary)
          features_ary.each {|fent|
            key = fent.split(/\:( |\n)/)[0].strip
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

    a.features.keys.sort.each do |key|
      puts "\n ==> a.features['#{key}'] "
      puts a.features[key]
    end

    
  end

end
