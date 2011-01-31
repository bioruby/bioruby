#
# = sample/demo_sosui_report.rb - demonstration of Bio::SOSUI::Report
# 
# Copyright::   Copyright (C) 2003 
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
#
# == Description
#
# Demonstration of Bio::SOSUI::Report, SOSUI output parser.
#
# SOSUI performs classification and secondary structures prediction
# of membrane proteins.
#
# == Usage
#
# Usage 1: Without arguments, runs demo using preset example data.
#
#  $ ruby demo_sosui_report.rb
#
# Usage 2: Specify files containing SOSUI reports.
#
#  $ ruby demo_sosui_report.rb files...
#
# Example usage using test data:
#
#  $ ruby -Ilib sample/demo_sosui_report.rb test/data/SOSUI/sample.report
#
# == References
#
# * http://bp.nuap.nagoya-u.ac.jp/sosui/
#
# == Development information
#
# The code was moved from lib/bio/appl/sosui/report.rb, and modified as below:
# * Disables internal sample data when arguments are specified.
# * Method name is changed.
# * Bug fix about tmhs demo.

require 'bio'

  begin
    require 'pp'
    alias p pp 
  rescue LoadError
  end


  sample = <<HOGE
>HOGE1
 MEMBRANE PROTEIN
 NUMBER OF TM HELIX = 6
 TM 1   12-  34 SECONDARY   LLVPILLPEKCYDQLFVQWDLLH
 TM 2   36-  58 PRIMARY     PCLKILLSKGLGLGIVAGSLLVK
 TM 3  102- 124 SECONDARY   SWGEALFLMLQTITICFLVMHYR
 TM 4  126- 148 PRIMARY     QTVKGVAFLACYGLVLLVLLSPL
 TM 5  152- 174 SECONDARY   TVVTLLQASNVPAVVVGRLLQAA
 TM 6  214- 236 SECONDARY   AGTFVVSSLCNGLIAAQLLFYWN

>HOGE2
 SOLUBLE PROTEIN

HOGE

  def demo_sosui_report(ent)
    puts '==='
    puts ent
    puts '==='
    sosui = Bio::SOSUI::Report.new(ent)
    p [:entry_id, sosui.entry_id]
    p [:prediction, sosui.prediction]
    p [:tmhs, sosui.tmhs]
  end

if ARGV.empty? then

  sample.split(/#{Bio::SOSUI::Report::DELIMITER}/).each {|ent|
    demo_sosui_report(ent)
  }

else 

  while ent = $<.gets(Bio::SOSUI::Report::DELIMITER)
    demo_sosui_report(ent)
  end

end

