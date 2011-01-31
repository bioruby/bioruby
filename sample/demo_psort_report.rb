#
# = sample/demo_psort_report.rb - demonstration of Bio::PSORT::PSORT2::Report
#
# Copyright::   Copyright (C) 2003 
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
#
# == IMPORTANT NOTE
#
# The sample may not work because it has not been tested for a long time.
#
# == Description
#
# Demonstration of Bio::PSORT::PSORT2::Report, parser class for the PSORT
# systems output.
#
# == Usage
#
# Specify a file containing PSORT2 output.
#
#  $ ruby demo_psort_report.rb
#
# == Development information
#
# The code was moved from lib/bio/appl/psort/report.rb.
#

require 'bio'

# testing code

#if __FILE__ == $0


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

#end
