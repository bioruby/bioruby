#
# = bio/appl/blast/wublast.rb - WU-BLAST default output parser
# 
# Copyright::  Copyright (C) 2003, 2008 Naohisa GOTO <ng@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# WU-BLAST default output parser.
#
# The parser is still incomplete and may contain many bugs,
# because I didn't have WU-BLAST license.
# It was tested under web-based WU-BLAST results and
# obsolete version downloaded from http://blast.wustl.edu/ .
#
# == References
#
# * http://blast.wustl.edu/
# * http://www.ebi.ac.uk/blast2/
#

module Bio

  require 'bio/appl/blast' unless const_defined?(:Blast)

  class Blast
    module WU #:nodoc:

      # Bio::Blast::WU::Report parses WU-BLAST default output
      # and stores information in the data.
      # It may contain a Bio::Blast::WU::Report::Iteration object.
      # Because it inherits Bio::Blast::Default::Report,
      # please also refer Bio::Blast::Default::Report.
      class Report < Default::Report

        # Returns parameters (???)
        def parameters
          parse_parameters
          @parameters
        end

        # Returns parameter matrix (???)
        def parameter_matrix
          parse_parameters
          @parameter_matrix
        end

        # Returns e-value threshold specified when BLAST was executed.
        def expect; parse_parameters; @parameters['E']; end

        # Returns warning messages.
        def warnings
          unless defined?(@warnings)
            @warnings = @f0warnings
            iterations.each { |x| @warnings.concat(x.warnings) }
          end
          @warnings
        end

        # Returns notice messages.
        def notice
          unless defined?(@notice)
            @notice = @f0notice.to_s.gsub(/\s+/, ' ').strip
          end #unless
          @notice
        end

        # (WU-BLAST) Returns record number of the query.
        # It may only be available for reports with multiple queries.
        # Returns an Integer or nil.
        def query_record_number
          format0_parse_query
          @query_record_number
        end

        # (WU-BLAST) Returns exit code for the execution.
        # Returns an Integer or nil.
        def exit_code
          if defined? @exit_code then
            @exit_code
          else
            nil
          end
        end

        # (WU-BLAST) Returns the message bundled with the exit code output.
        # The message will be shown when WU-BLAST ignores a fatal error
        # due to the command line option "-nonnegok", "-novalidctxok",
        # or "-shortqueryok".
        # 
        # Returns a String or nil.
        def exit_code_message
          if defined? @exit_code_message then
            @exit_code_message
          else
            nil
          end
        end

        # (WU-BLAST) Returns "NOTE:" information.
        # Returns nil or an array containing String.
        def notes
          if defined? @notes then
            @notes
          else
            nil
          end
        end

        # (WU-BLAST) Returns fatal error information.
        # Returns nil or an array containing String.
        def fatal_errors
          if defined? @fatal_errors then
            @fatal_errors
          else
            nil
          end
        end

        # Returns the name (filename or title) of the database.
        def db
          unless defined?(@db)
            if /Database *\: *(.*)/m =~ @f0database then
              a = $1.split(/^/)
              if a.size > 1 and /\ASearching\..+ done\s*\z/ =~ a[-1] then
                a.pop
              end
              if a.size > 1 and /\A +[\d\,]+ +sequences\; +[\d\,]+ total +letters\.?\s*\z/ =~ a[-1] then
                a.pop
              end
              @db = a.collect { |x| x.sub(/\s+\z/, '') }.join(' ')
            end
          end #unless
          @db
        end

        private
        # Parses the query lines (begins with "Query = ").
        def format0_parse_query
          unless defined?(@query_def)
            sc = StringScanner.new(@f0query)
            sc.skip(/\s*/)
            if sc.skip_until(/Query\= */) then
              q = []
              begin
                q << sc.scan(/.*/)
                sc.skip(/\s*^ ?/)
              end until !sc.rest or r = sc.skip(/ *\( *([\,\d]+) *letters *(\; *record *([\,\d]+) *)?\)\s*\z/)
              @query_len = sc[1].delete(',').to_i if r
              @query_record_number = sc[3].delete(',').to_i if r and sc[2]
              @query_def = q.join(' ')
            end
          end
        end

        # Splits headers.
        def format0_split_headers(data)
          @f0header = data.shift
          @f0references = []
          while r = data.first
            case r
            when /^Reference\: /
              @f0references.push data.shift
            when /^Copyright /
              @f0copyright = data.shift
            when /^Notice\: /
              @f0notice = data.shift
            when /^Query\= /
              break
            else
              break
            end
          end
          @f0query = data.shift
          @f0warnings ||= []
          while r = data.first
            case r
            when /^WARNING\: /
              @f0warnings << data.shift
            when /^NOTE\: /
              @notes ||= []
              @notes << data.shift
            else
              break #from the above "while"
            end
          end
          return if r = data.first and /\A(Parameters\:|EXIT CODE *\d+)/ =~ r
          if r = data.first and !(/^Database\: / =~ r)
            @f0translate_info = data.shift
          end
          @f0database = data.shift
        end

        # Splits search data.
        def format0_split_search(data)
          @f0warnings ||= []
          while r = data.first and r =~ /^WARNING\: /
            @f0warnings << data.shift
          end
          [ Iteration.new(data) ]
        end

        # Splits statistics parameters.
        def format0_split_stat_params(data)
          @f0warnings ||= []
          while r = data.first and r =~ /^WARNING\: /
            @f0warnings << data.shift
          end
          @f0wu_params = []
          @f0wu_stats = []
          ary = @f0wu_params
          while r = data.shift 
            case r
            when /\AStatistics\:/
              ary = @f0wu_stats
            when /\AEXIT CODE *(\d+)\s*(.*)$/
              @exit_code = $1.to_i
              if $2 and !$2.empty? then
                @exit_code_message = r.sub(/\AEXIT CODE *(\d+)\s*/, '')
              end
              r = nil
            when /\AFATAL\: /
              @fatal_errors ||= []
              @fatal_errors.push r
              r = nil
            when /\AWARNING\: /
              @f0warnings ||= []
              @f0warnings << r
              r = nil
            end
            ary << r if r
          end
          @f0dbstat = F0dbstat.new(@f0wu_stats)
          itr = @iterations[0]
          x = @f0dbstat
          itr.instance_eval { @f0dbstat = x } if itr
        end

        # Splits parameters.
        def parse_parameters
          unless defined?(@parse_parameters)
            @parameters = {}
            @parameter_matrix = []
            @f0wu_params.each do |x|
              if /^  Query/ =~ x then
                @parameter_matrix << x
              else
                x.split(/^/).each do |y|
                  if /\A\s*(.+)\s*\=\s*(.*)\s*/ =~ y then
                    @parameters[$1] = $2
                  elsif /\AParameters\:/ =~ y then
                    ; #ignore this
                  elsif /\A\s*(.+)\s*$/ =~ y then
                    @parameters[$1] = true
                  end
                end
              end
            end
            if ev = @parameters['E'] then
              ev = '1' + ev if ev[0] == ?e
              @parameters['E'] = ev.to_f
            end
            @parse_parameters = true
          end
        end

        # Stores database statistics.
        # Internal use only. Users must not use the class.
        class F0dbstat < Default::Report::F0dbstat #:nodoc:
          def initialize(ary)
            @f0stat = ary
            @hash = {}
          end

          #--
          #undef :f0params
          #undef :matrix, :gap_open, :gap_extend,
          #  :eff_space, :expect, :sc_match, :sc_mismatch,
          #  :num_hits
          #++

          # Parses database statistics.
          def parse_dbstat
            unless defined?(@parse_dbstat)
              parse_colon_separated_params(@hash, @f0stat)
              @database = @hash['Database']
              @posted_date = @hash['Posted']
              if val = @hash['# of letters in database'] then
                @db_len =  val.tr(',', '').to_i
              end
              if val = @hash['# of sequences in database'] then
                @db_num = val.tr(',', '').to_i
              end
              @parse_dbstat = true
            end #unless
          end #def
          private :parse_dbstat

        end #class F0dbstat

        #--
        #class Frame
        #end #class FrameParams
        #++

        # Iteration class for WU-BLAST report.
        # Though WU-BLAST does not iterate like PSI-BLAST,
        # Bio::Blast::WU::Report::Iteration aims to keep compatibility
        # with Bio::Blast::Default::Report::* classes.
        # It may contain some Bio::Blast::WU::Report::Hit objects.
        # Because it inherits Bio::Blast::Default::Report::Iteration,
        # please also refer Bio::Blast::Default::Report::Iteration.
        class Iteration < Default::Report::Iteration
          # Creates a new Iteration object.
          # It is designed to be called only internally from
          # the Bio::Blast::WU::Report class.
          # Users shall not use the method directly.
          def initialize(data)
            @f0stat = []
            @f0dbstat = Default::Report::AlwaysNil.instance
            @f0hitlist = []
            @hits = []
            @num = 1
            @f0message = []
            @f0warnings = []
            return unless r = data.first
            return if /\AParameters\:$/ =~ r
            return if /\AEXIT CODE *\d+/ =~ r
            @f0hitlist << data.shift
            return unless r = data.shift
            unless /\*{3} +NONE +\*{3}/ =~ r then
              @f0hitlist << r
              while r = data.first and /^WARNING\: / =~ r
                @f0warnings << data.shift
              end
              while r = data.first and /^\>/ =~ r
                @hits << Hit.new(data)
              end
            end #unless
          end

          # Returns warning messages.
          def warnings
            @f0warnings
          end

          private
          # Parses hit list.
          def parse_hitlist
            unless defined?(@parse_hitlist)
              r = @f0hitlist.shift.to_s
              if /Reading/ =~ r and /Frame/ =~ r then
                flag_tblast = true 
                spnum = 5
              else
                flag_tblast = nil
                spnum = 4
              end
              i = 0
              @f0hitlist.each do |x|
                b = x.split(/^/)
                b.collect! { |y| y.empty? ? nil : y }
                b.compact!
                b.each do |y|
                  y.strip!
                  y.reverse!
                  z = y.split(/\s+/, spnum)
                  z.each { |y| y.reverse! }
                  dfl  = z.pop
                  h = @hits[i] 
                  unless h then
                    h = Hit.new([ dfl.to_s.sub(/\.+\z/, '') ])
                    @hits[i] = h
                  end
                  z.pop if flag_tblast #ignore Reading Frame
                  scr = z.pop
                  scr = (scr ? scr.to_i : nil)
                  pval = z.pop.to_s
                  pval = '1' + pval if pval[0] == ?e
                  pval = (pval.empty? ? (1.0/0.0) : pval.to_f)
                  nnum = z.pop.to_i
                  h.instance_eval {
                    @score = scr
                    @pvalue = pval
                    @n_number = nnum
                  }
                  i += 1
                end
              end #each
              @parse_hitlist = true
            end #unless
          end
        end #class Iteration

        # Bio::Blast::WU::Report::Hit contains information about a hit.
        # It may contain some Bio::Blast::WU::Report::HSP objects.
        #
        # Because it inherits Bio::Blast::Default::Report::Hit,
        # please also refer Bio::Blast::Default::Report::Hit.
        class Hit < Default::Report::Hit
          # Creates a new Hit object.
          # It is designed to be called only internally from the
          # Bio::Blast::WU::Report::Iteration class.
          # Users should not call the method directly.
          def initialize(data)
            @f0hitname = data.shift
            @hsps = []
            while r = data.first
              if r =~ /^\s*(?:Plus|Minus) +Strand +HSPs\:/ then
                data.shift
                r = data.first
              end
              if /\A\s+Score/ =~ r then
                @hsps << HSP.new(data)
              else
                break
              end
            end
            @again = false
          end

          # Returns score.
          def score
            @score
          end
          # p-value
          attr_reader :pvalue
          # n-number (???)
          attr_reader :n_number
        end #class Hit

        # Bio::Blast::WU::Report::HSP holds information about the hsp
        # (high-scoring segment pair).
        #
        # Because it inherits Bio::Blast::Default::Report::HSP,
        # please also refer Bio::Blast::Default::Report::HSP.
        class HSP < Default::Report::HSP
          # p-value
          attr_reader :pvalue if false #dummy
          method_after_parse_score :pvalue
          # p_sum_n (???)
          attr_reader :p_sum_n if false #dummy
          method_after_parse_score :p_sum_n
        end #class HSP

      end #class Report

      # WU-BLAST default output parser for TBLAST.
      # All methods are equal to Bio::Blast::WU::Report.
      # Only DELIMITER (and RS) is different.
      class Report_TBlast < Report
        # Delimter of each entry for TBLAST. Bio::FlatFile uses it.
        DELIMITER = RS = "\nTBLAST"

        # (Integer) excess read size included in DELIMITER.
        DELIMITER_OVERRUN = 6 # "TBLAST"
      end #class Report_TBlast

    end #module WU
  end #class Blast
end #module Bio

