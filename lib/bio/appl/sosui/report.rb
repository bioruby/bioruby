#
# bio/appl/sosui/report.rb - SOSUI report class
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
#  $Id: report.rb,v 1.4 2003/09/08 05:46:25 n Exp $
#


module Bio

  class SOSUI

    class Report

      DELIMITER = "\n>"

      def initialize(entry)
	entry       = entry.split(/\n/)

	@entry_id   = entry[0].strip.sub(/^>/,'')
	@prediction = entry[1].strip
	@tmh        = []
	@tmhs       = 0
	parse_tmh(entry) if /MEMBRANE/ =~ @prediction
      end

      attr_reader :entry_id, :prediction, :tmhs, :tmh


      private

      def parse_tmh(entry)
	entry.each do |line|
	  if /NUMBER OF TM HELIX = (\d+)/ =~ line
	    @tmhs = $1
	  elsif /TM (\d+) +(\d+)- *(\d+) (\w+) +(\w+)/ =~ line
	    tmp = {'TMH'   => $1.to_i, 
	           'range' => Range.new($2.to_i, $3.to_i), 
	           'grade' => $4, 
	           'seq'   => $5 }
	    @tmh.push(tmp)
	  end
	end
      end

    end # class Report

  end # class SOSUI

end # module Bio



if __FILE__ == $0

  begin
    require 'pp'
    alias :p :pp 
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

  def hoge(ent)
    puts '==='
    puts ent
    puts '==='
    sosui = Bio::SOSUI::Report.new(ent)
    p [:entry_id, sosui.entry_id]
    p [:prediction, sosui.prediction]
    p [:tmhs, sosui.tmhs]
    pp [:tmh, sosui.tmh]
  end

  sample.split(/#{Bio::SOSUI::Report::DELIMITER}/).each {|ent|
    hoge(ent)
  }

  exit if ARGV.size == 0

  while ent = $<.gets(Bio::SOSUI::Report::DELIMITER)
    hoge(ent)
  end

end



=begin

= Bio::SOSUI

    SOSUI class for
    ((<URL:http://sosui.proteome.bio.tuat.ac.jp/sosuiframe0.html>))

= Bio::SOSUI::Report

    A parser and contianer class

--- Bio::SOSUI::Report.new(str)
--- Bio::SOSUI::Report#entry_id
--- Bio::SOSUI::Report#prediction

      Returns the prediction result whether "MEMBRANE PROTEIN" or 
      "SOLUBLE PROTEIN".

--- Bio::SOSUI::Report#tmhs

      Returns the number of predicted TMHs.
    
--- Bio::SOSUI::Report#tmh

      Returns an Array of TMHs in Hash.

=end
