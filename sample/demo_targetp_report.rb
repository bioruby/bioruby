#
# = sample/demo_targetp_report.rb - demonstration of Bio::TargetP::Report
# 
# Copyright::  Copyright (C) 2003 
#              Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::TargetP::Report, TargetP output parser.
#
# == Usage
#
# Usage 1: Without arguments, runs demo using preset example data.
#
#  $ ruby demo_targetp_report.rb
#
# Usage 2: Specify files containing TargetP reports.
#
#  $ ruby demo_targetp_report.rb files...
#
# == References
#
# * http://www.cbs.dtu.dk/services/TargetP/
#
# == Development information
#
# The code was moved from lib/bio/appl/targetp/report.rb, and modified
# as below:
# * Disables internal sample data when arguments are specified.
# * Method name is changed.
#

require 'bio'


  begin
    require 'pp'
    alias p pp 
  rescue LoadError
  end


  plant = <<HOGE
 
### ### ###  T A R G E T P  1.0  prediction results  ### ### ### 
 
# Number of input sequences:  1
# Cleavage site predictions not included.
# Using PLANT networks.
 
#                        Name   Length	  cTP   mTP    SP other  Loc.  RC
#----------------------------------------------------------------------------------
                   MGI_2141503	  640	0.031 0.161 0.271 0.844   _     3
#----------------------------------------------------------------------------------
# cutoff                                 0.00  0.00  0.00  0.00


HOGE

plant_c = <<HOGE
 
### ### ###  T A R G E T P  1.0  prediction results  ### ### ### 
 
# Number of input sequences:  1
# Cleavage site predictions included.
# Using PLANT networks.
 
#                        Name   Length	  cTP   mTP    SP other  Loc.  RC     TPlen
#----------------------------------------------------------------------------------
                   MGI_2141503	  640	0.031 0.161 0.271 0.844   _     3	  -
#----------------------------------------------------------------------------------
# cutoff                                 0.00  0.00  0.00  0.00



HOGE

non_plant_c = <<HOGE
 
### ### ###  T A R G E T P  1.0  prediction results  ### ### ### 
 
# Number of input sequences:  1
# Cleavage site predictions included.
# Using NON-PLANT networks.
 
#                        Name   Length    mTP   SP  other  Loc.  RC   TPlen
#--------------------------------------------------------------------------
                     MGI_96083	 2187	0.292 0.053 0.746   _     3	  -
#--------------------------------------------------------------------------
# cutoff                                 0.00  0.00  0.00



HOGE


  def demo_targetp_report(e)
    puts e
    ent = Bio::TargetP::Report.new(e)
    pp ent

    p [:entry_id, ent.entry_id]
    p [:name, ent.name]
    p [:version, ent.version]
    p [:query_sequnces, ent.query_sequences]
    p [:cleavage_site_prediction, ent.cleavage_site_prediction]
    p [:networks, ent.networks]
    p [:query_len, ent.query_len]
    p [:prediction, ent.prediction]
    p [:pred_Name, ent.pred['Name']]
    p [:pred_SP, ent.pred['SP']]
    p [:pred_mTP, ent.pred['mTP']]
    p [:cutoff, ent.cutoff]
    p [:loc, ent.loc]
    p [:rc, ent.rc]

    puts '=='
  end

if ARGV.empty? then

  [plant, plant_c, non_plant_c].each {|e|
    demo_targetp_report(e)
  }

else

  while ent = $<.gets(Bio::TargetP::Report::DELIMITER)
    demo_targetp_report(ent)
  end

end

