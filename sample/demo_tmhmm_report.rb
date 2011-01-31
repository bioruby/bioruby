#
# = sample/demo_tmhmm_report.rb - demonstration of Bio::TMHMM::Report
# 
# Copyright::  Copyright (C) 2003 
#              Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::TMHMM::Report, TMHMM output parser.
#
# == Usage
#
# Specify files containing SOSUI reports.
#
#  $ ruby demo_tmhmm_report.rb files...
#
# Example usage using test data:
#
#  $ ruby -Ilib sample/demo_tmhmm_report.rb test/data/TMHMM/sample.report
#
# == References
#
# * http://www.cbs.dtu.dk/services/TMHMM/
#
# == Development information
#
# The code was moved from lib/bio/appl/tmhmm/report.rb.
#

require 'bio'

#if __FILE__ == $0

  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  Bio::TMHMM.reports(ARGF.read) do |ent|
    puts '==>'
    puts ent.to_s
    pp ent

    p [:entry_id, ent.entry_id]
    p [:query_len, ent.query_len]
    p [:predicted_tmhs, ent.predicted_tmhs]
    p [:tmhs_size, ent.tmhs.size]
    p [:exp_aas_in_tmhs, ent.exp_aas_in_tmhs]
    p [:exp_first_60aa, ent.exp_first_60aa]
    p [:total_prob_of_N_in, ent.total_prob_of_N_in]

    ent.tmhs.each do |t|
      p t
      p [:entry_id, t.entry_id]
      p [:version, t.version]
      p [:status, t.status]
      p [:range, t.range]
      p [:pos, t.pos]
    end

    p [:helix, ent.helix]
    p ent.tmhs.map {|t| t if t.status == 'TMhelix' }.compact
  end

#end
