#
# bio/appl/targetp/report.rb - TargetP report class
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
#  $Id: report.rb,v 1.3 2003/02/26 01:54:03 k Exp $
#

module Bio

  class TargetP

    class Report

      DELIMITER = "\n \n"

      def initialize(str)
	@version                  = nil
	@query_sequences          = nil
	@cleavage_site_prediction = nil
	@networks                 = nil
	@prediction               = {}
	@cutoff                   = {}
	parse_entry(str)
      end

      attr_reader :version, :query_sequences, 
	:cleavage_site_prediction, :networks,
	:prediction, :cutoff

      alias :pred   :prediction

      def name
	@prediction['Name']
      end
      alias :entry_id :name 

      def query_len
	if @prediction['Len']
	  @prediction['Len']
	else
	  @prediction['Length']
	end
      end
      alias :length :query_len

      def loc
	if @prediction['Loc'] 
	  @prediction['Loc']   # version 1.0
	else
	  @prediction['Loc.']  # version 1.1
	end
      end

      def rc
	@prediction['RC']
      end
      
      private

      def parse_entry(str)
	labels = []
	cutoff = []
	values = []

	str.split("\n").each {|line|
	  case line
	  when /targetp v(\d+.\d+)/,/T A R G E T P\s+(\d+.\d+)/
	    @version = $1

	  when /Number of (query|input) sequences:\s+(\d+)/
	    @query_sequences = $1.to_i

	  when /Cleavage site predictions (\w.+)\./ 
	    @cleavage_site_prediction = $1

	  when /Using (\w+.+) networks/
	    @networks = $1
	  when /Name +Len/
	    labels = line.sub(/^\#\s*/,'').split(/\s+/)

	  when /cutoff/
	    cutoff = line.split(/\s+/)
	    cutoff.shift
	    labels[2, 4].each_with_index {|loc, i|
	      next if loc =~ /Loc/
	      @cutoff[loc] = cutoff[i].to_f
	    }
	  when /-----$/
	  when /^ +$/, ''
	  else
	    values = line.sub(/^\s*/,'').split(/\s+/)
	    values.each_with_index {|val, i|
	      label = labels[i]
	      case label
	      when 'RC', /Len/ 
		val = val.to_i
	      when 'SP','mTP','cTP','other'
		val = val.to_f
	      end
	      @prediction[label] = val
	    }
	  end
	}
      end

    end # class Report
    
  end # class TargetP

end # moudel Bio



if __FILE__ == $0

  begin
    require 'pp'
    alias :p :pp 
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


  def hoge(e)
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


  [plant, plant_c, non_plant_c].each {|e|
    hoge(e)
  }

  exit  if ARGV.size == 0

  while ent = $<.gets(Bio::TargetP::Report::DELIMITER)
    hoge(ent)
  end

end


=begin

= Bio::TargetP

    TargetP class for ((<URL:http://www.cbs.dtu.dk/services/TargetP/>))

= Bio::TargetP::Report

    A parser and container class for TargetP report.

--- Bio::TargetP::Report.new(str)

--- Bio::TargetP::Report#version

      This class is tested by version 1.0 and 1.1 reports.

--- Bio::TargetP::Report#query_sequences
--- Bio::TargetP::Report#cleavage_site_prediction

      Returns 'included' or 'not included'.
      If the value is 'included', Bio::TargetP::Report#prediction['TPlen']
      contains a valid value.

--- Bio::TargetP::Report#networks
 
      There are PLANT and NON-PLANT networks.

--- Bio::TargetP::Report#entry_id
--- Bio::TargetP::Report#name

      Returns the qeury entry_id.

--- Bio::TargetP::Report#query_len

      Returns query length.

--- Bio::TargetP::Report#prediction

      Returns a Hash of the prediction results.

      Valid keys: Name, Len, SP, mTP, other, Loc, RC
      Additional key in PLANT networks: cTP
      Additional key in Cleavage site: TPlen

      Use 'Length' and 'Loc.' instead of 'Len' and 'Loc' respectively
      for the version 1.0 report.

--- Bio::TargetP::Report#cutoff
      
      Returns a Hash of cutoff values.

--- Bio::TargetP::Report#loc

      Returns the predicted localization S, M, C, * or _.

--- Bio::TargetP::Report#rc


=end

