#
# = bio/appl/tmhmm/report.rb - TMHMM report class
# 
# Copyright::  Copyright (C) 2003 
#              Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: report.rb,v 1.8 2007/04/05 23:35:40 trevor Exp $
#
# == Description
#
#
# == Example
# == References
#

module Bio

  # = TMHMM class for http://www.cbs.dtu.dk/services/TMHMM/
  class TMHMM

    # Splits multiple reports into a report entry.
    def TMHMM.reports(data)
      entry     = []
      ent_state = ''
      data.each_line do |line|
        if /^\#/ =~ line
          if ent_state == 'next'
            ent_state = 'entry'
          elsif ent_state == 'tmh'
            ent_state = 'next'
          end
        else
          ent_state = 'tmh'
        end

        if ent_state != 'next'
          entry << line
        else
          if block_given?
            yield Bio::TMHMM::Report.new(entry)
          else
            Bio::TMHMM::Report.new(entry)
          end
          entry = [line]
        end
      end

      if block_given?
        yield Bio::TMHMM::Report.new(entry)
      else
        Bio::TMHMM::Report.new(entry)
      end
    end

    # = TMHMM report parser class.
    class Report

      # Returns an Array of Bio::TMHMM::TMH.
      attr_reader :tmhs

      # Returns
      attr_reader :entry_id

      # Returns
      attr_reader :query_len

      # Returns
      attr_reader :predicted_tmhs

      # Returns
      attr_reader :exp_aas_in_tmhs

      # Returns
      attr_reader :exp_first_60aa

      # Returns
      attr_reader :total_prob_of_N_in

      alias length query_len

      #
      def initialize(entry = nil)
        parse_header(entry)
        @tmhs = parse_tmhs(entry)
      end

      # Returns an Array of Bio::TMHMM::TMH including only "TMhelix".
      def helix
        @tmhs.map {|t| t if t.status == 'TMhelix' }.compact
      end

      #
      def to_s
        [
          [
            ["Length:",                    @query_len],
            ["Number of predicted TMHs:",  @predicted_tmhs],
            ["Exp number of AAs in THMs:", @exp_aas_in_tmhs],
            ["Exp number, first 60 AAs:",  @exp_first_60aa],
            ["Total prob of N-in:",        @total_prob_of_N_in]
          ].map {|e| "\# " + [@entry_id, e].flatten.join("\t") },
          tmhs.map {|ent| ent.to_s }
        ].flatten.join("\n")
      end


      private

      #
      def parse_header(raw)
        raw.each do |line|
          next unless /^#/.match(line)

          case line
          when / (\S.+) Length: +(\d+)/
            @entry_id  = $1.strip
            @query_len = $2.to_i
          when /Number of predicted TMHs: +(\d+)/
            @predicted_tmhs  = $1.to_i
          when /Exp number of AAs in TMHs: +([\d\.]+)/
            @exp_aas_in_tmhs = $1.to_f
          when /Exp number, first 60 AAs: +([\d\.]+)/
            @exp_first_60aa  = $1.to_f
          when /Total prob of N-in: +([\d\.]+)/
            @total_prob_of_N_in = $1.to_f
          end
        end
      end

      #
      def parse_tmhs(raw)
        tmhs = []
        raw.each do |line|
          case line
          when /^[^\#]/
            eid,version,status,r0,r1 = line.split(/\s+/)
            tmhs << Bio::TMHMM::TMH.new(eid.strip,
                                        version.strip, 
                                        status.strip, 
                                        Range.new(r0.to_i, r1.to_i))
          end
        end
        tmhs
      end

    end # class Report


    # = Container class of the trainsmembrane helix(TMH) and the other
    #   segments.
    class TMH

      # Returns
      attr_accessor :entry_id

      # Returns
      attr_accessor :version

      # Returns the status of the TMH. ("outside", "TMhelix" or "inside").
      attr_accessor :status

      # Returns an Range of TMH position.
      attr_accessor :range

      alias pos range

      #
      def initialize(entry_id = nil, version = nil, status = nil, range = nil)
        @entry_id = entry_id
        @version  = version
        @status   = status
        @range    = range
      end

      #
      def to_s
        [@entry_id, @version, @status, @range.first, @range.last].join("\t")
      end

    end # class TMH

  end # class TMHMM

end # module Bio


if __FILE__ == $0

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

end
