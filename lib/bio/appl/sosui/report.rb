#
# = bio/appl/sosui/report.rb - SOSUI report class
# 
# Copyright::   Copyright (C) 2003 
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
#  $Id:$
#
# == Example
#
# == References
#
# * http://bp.nuap.nagoya-u.ac.jp/sosui/
# * http://bp.nuap.nagoya-u.ac.jp/sosui/sosui_submit.html
#


module Bio

  class SOSUI

    # = SOSUI output report parsing class
    #
    # == References
    # * http://bp.nuap.nagoya-u.ac.jp/sosui/
    # * http://bp.nuap.nagoya-u.ac.jp/sosui/sosui_submit.html
    class Report

      # Delimiter
      DELIMITER = "\n>"
      RS = DELIMITER

      # Query entry_id
      attr_reader :entry_id

      # Returns the prediction result whether "MEMBRANE PROTEIN" or 
      # "SOLUBLE PROTEIN".
      attr_reader :prediction

      # Transmembrane helixes ary
      attr_reader :tmhs

      # Parser for SOSUI output report.
      def initialize(output_report)
        entry       = output_report.split(/\n/)

        @entry_id   = entry[0].strip.sub(/^>/,'')
        @prediction = entry[1].strip
        @tms        = 0
        @tmhs       = []
        parse_tmh(entry) if /MEMBRANE/ =~ @prediction
      end

      private

      # Parser for TMH lines.
      def parse_tmh(entry)
        entry.each do |line|
          if /NUMBER OF TM HELIX = (\d+)/ =~ line
            @tms = $1
          elsif /TM (\d+) +(\d+)- *(\d+) (\w+) +(\w+)/ =~ line
            tmh  = $1.to_i
            range = Range.new($2.to_i, $3.to_i)
            grade = $4
            seq   = $5
            @tmhs.push(TMH.new(range, grade, seq))
          end
        end
      end


      # = Bio::SOSUI::Report::TMH
      # Container class for transmembrane helix information.
      #  
      #  TM 1   31-  53 SECONDARY   HIRMTFLRKVYSILSLQVLLTTV
      class TMH

        # Returns aRng of transmembrane helix
        attr_reader :range
        
        # Retruns ``PRIMARY'' or ``SECONDARY'' of helix.
        attr_reader :grade

        # Returns the sequence. of transmembrane helix. 
        attr_reader :sequence

        # Sets values.
        def initialize(range, grade, sequence)
          @range = range
          @grade = grade
          @sequence = sequence
        end
      end

    end # class Report

  end # class SOSUI

end # module Bio


