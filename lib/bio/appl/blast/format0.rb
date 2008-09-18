#
# = bio/appl/blast/format0.rb - BLAST default output (-m 0) parser
# 
# Copyright::  Copyright (C) 2003-2006 GOTO Naohisa <ng@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#
# == Description
#
# NCBI BLAST default (-m 0 option) output parser.
#
# == References
#
# * Altschul, Stephen F., Thomas L. Madden, Alejandro A. Schaffer,
#   Jinghui Zhang, Zheng Zhang, Webb Miller, and David J. Lipman (1997),
#   "Gapped BLAST and PSI-BLAST: a new generation of protein database search
#   programs", Nucleic Acids Res. 25:3389-3402.
# * http://www.ncbi.nlm.nih.gov/blast/ 
#

begin
  require 'strscan'
rescue LoadError
end
require 'singleton'

#--
#require 'bio/db'
#++
require 'bio/io/flatfile'

module Bio
  class Blast
    module Default #:nodoc:

      # Bio::Blast::Default::Report parses NCBI BLAST default output
      # and stores information in the data.
      # It may store some Bio::Blast::Default::Report::Iteration objects.
      class Report #< DB
        # Delimiter of each entry. Bio::FlatFile uses it.
        DELIMITER = RS = "\nBLAST"

        # (Integer) excess read size included in DELIMITER.
        DELIMITER_OVERRUN = 5 # "BLAST"

        # Opens file by using Bio::FlatFile.open.
        def self.open(filename, *mode)
          Bio::FlatFile.open(self, filename, *mode)
        end

        # Creates a new Report object from BLAST result text.
        def initialize(str)
          str = str.sub(/\A\s+/, '')
          str.sub!(/\n(T?BLAST.*)/m, "\n") # remove trailing entries for sure
          @entry_overrun = $1
          @entry = str
          data = str.split(/(?:^[ \t]*\n)+/)

          format0_split_headers(data)
          @iterations = format0_split_search(data)
          format0_split_stat_params(data)
        end
        # piece of next entry. Bio::FlatFile uses it.
        attr_reader :entry_overrun

        # (PSI-BLAST)
        # Returns iterations.
        # It returns an array of Bio::Blast::Default::Report::Iteration class.
        # Note that normal blastall result usually contains one iteration.
        attr_reader :iterations

        # Returns whole entry as a string.
        def to_s; @entry; end

        #:stopdoc:
        # prevent using StringScanner_R (in old version of strscan)
        if !defined?(StringScanner) then
          def initialize(*arg)
            raise 'couldn\'t load strscan.so'
          end #def
        elsif StringScanner.name == 'StringScanner_R' then
          def initialize(*arg)
            raise 'cannot use StringScanner_R'
          end #def
        end
        #:startdoc:

        # Defines attributes which delegate to @f0dbstat objects.
        def self.delegate_to_f0dbstat(*names)
          names.each do |x|
            module_eval("def #{x}; @f0dbstat.#{x}; end")
          end
        end
        private_class_method :delegate_to_f0dbstat

        # number of sequences in database
        attr_reader          :db_num if false #dummy
        delegate_to_f0dbstat :db_num

        # number of letters in database
        attr_reader          :db_len if false #dummy
        delegate_to_f0dbstat :db_len

        # posted date of the database
        attr_reader          :posted_date if false #dummy
        delegate_to_f0dbstat :posted_date

        # effective length of the database
        attr_reader          :eff_space if false #dummy
        delegate_to_f0dbstat :eff_space

        # name of the matrix
        attr_reader          :matrix if false #dummy
        delegate_to_f0dbstat :matrix

        # match score of the matrix
        attr_reader          :sc_match if false #dummy
        delegate_to_f0dbstat :sc_match

        # mismatch score of the matrix
        attr_reader          :sc_mismatch if false #dummy
        delegate_to_f0dbstat :sc_mismatch

        # gap open penalty
        attr_reader          :gap_open if false #dummy
        delegate_to_f0dbstat :gap_open

        # gap extend penalty
        attr_reader          :gap_extend if false #dummy
        delegate_to_f0dbstat :gap_extend

        # e-value threshold specified when BLAST was executed
        attr_reader          :expect if false #dummy
        delegate_to_f0dbstat :expect

        # number of hits. Note that this may differ from <tt>hits.size</tt>.
        attr_reader          :num_hits if false #dummy
        delegate_to_f0dbstat :num_hits

        # Same as <tt>iterations.last.kappa</tt>.
        def kappa;          @iterations.last.kappa;          end
        # Same as <tt>iterations.last.lambda</tt>.
        def lambda;         @iterations.last.lambda;         end
        # Same as <tt>iterations.last.entropy</tt>.
        def entropy;        @iterations.last.entropy;        end

        # Same as <tt>iterations.last.gapped_kappa</tt>.
        def gapped_kappa;   @iterations.last.gapped_kappa;   end
        # Same as <tt>iterations.last.gapped_lambda</tt>.
        def gapped_lambda;  @iterations.last.gapped_lambda;  end
        # Same as <tt>iterations.last.gapped_entropy</tt>.
        def gapped_entropy; @iterations.last.gapped_entropy; end

        # Returns program name.
        def program;        format0_parse_header; @program;        end
        # Returns version of the program.
        def version;        format0_parse_header; @version;        end
        # Returns version number string of the program.
        def version_number; format0_parse_header; @version_number; end
        # Returns released date of the program.
        def version_date;   format0_parse_header; @version_date;   end

        # Returns length of the query.
        def query_len; format0_parse_query; @query_len; end

        # Returns definition of the query.
        def query_def; format0_parse_query; @query_def; end

        # (PHI-BLAST)
        # Same as <tt>iterations.first.pattern</tt>.
        # Note that it returns the FIRST iteration's value.
        def pattern; @iterations.first.pattern; end

        # (PHI-BLAST)
        # Same as <tt>iterations.first.pattern_positions</tt>.
        # Note that it returns the FIRST iteration's value.
        def pattern_positions
          @iterations.first.pattern_positions
        end

        # (PSI-BLAST)
        # Iterates over each iteration.
        # Same as <tt>iterations.each</tt>.
        # Yields a Bio::Blast::Default::Report::Iteration object.
        def each_iteration
          @iterations.each do |x|
            yield x
          end
        end

        # Iterates over each hit of the last iteration.
        # Same as <tt>iterations.last.each_hit</tt>.
        # Yields a Bio::Blast::Default::Report::Hit object.
        # This is very useful in most cases, e.g. for blastall results.
        def each_hit
          @iterations.last.each do |x|
            yield x
          end
        end
        alias each each_hit

        # Same as <tt>iterations.last.hits</tt>.
        # Returns the last iteration's hits.
        # Returns an array of Bio::Blast::Default::Report::Hit object.
        # This is very useful in most cases, e.g. for blastall results.
        def hits
          @iterations.last.hits
        end

        # (PSI-BLAST)
        # Same as <tt>iterations.last.message</tt>.
        def message
          @iterations.last.message
        end

        # (PSI-BLAST)
        # Same as <tt>iterations.last.converged?</tt>.
        # Returns true if the last iteration is converged,
        # otherwise, returns false.
        def converged?
          @iterations.last.converged?
        end

        # Returns the bibliography reference of the BLAST software. 
        # Note that this method shows only the first reference.
        # When you want to get additional references,
        # you can use <tt>references</tt> method.
        def reference
          references[0]
        end

        # Returns the bibliography references of the BLAST software. 
        # Returns an array of strings.
        def references
          unless defined?(@references)
            @references = @f0references.collect do |x|
              x.to_s.gsub(/\s+/, ' ').strip
            end
          end #unless
          @references
        end

        # Returns the name (filename or title) of the database.
        def db
          unless defined?(@db)
            if /Database *\: *(.*)/m =~ @f0database then
              a = $1.split(/^/)
              a.pop if a.size > 1
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
              end until !sc.rest or r = sc.skip(/ *\( *([\,\d]+) *letters *\)\s*\z/)
              @query_len = sc[1].delete(',').to_i if r
              @query_def = q.join(' ')
            end
          end
        end

        # Parses the first line of the BLAST result.
        def format0_parse_header
          unless defined?(@program)
            if /([\-\w]+) +([\w\-\.\d]+) *\[ *([\-\.\w]+) *\] *(\[.+\])?/ =~ @f0header.to_s
              @program = $1
              @version = "#{$1} #{$2} [#{$3}]"
              @version_number = $2
              @version_date = $3
            end
          end
        end

        # Splits headers into the first line, reference, query line and
        # database line.
        def format0_split_headers(data)
          @f0header = data.shift
          @f0references = []
          while data[0] and /\AQuery\=/ !~ data[0]
            @f0references.push data.shift
          end
          @f0query = data.shift
          @f0database = data.shift
          # In special case, a void line is inserted after database name.
          if /\A +[\d\,]+ +sequences\; +[\d\,]+ total +letters\s*\z/ =~ data[0] then
            @f0database.concat "\n"
            @f0database.concat data.shift
          end
        end

        # Splits the statistical parameters.
        def format0_split_stat_params(data)
          dbs = []
          while r = data.first and /^ *Database\:/ =~ r
            dbs << data.shift
          end
          @f0dbstat = self.class::F0dbstat.new(dbs)
          i = -1
          while r = data[0] and /^Lambda/ =~ r
            #i -= 1 unless /^Gapped/ =~ r
            if itr = @iterations[i] then
              x = data.shift; itr.instance_eval { @f0stat << x }
              x = @f0dbstat; itr.instance_eval { @f0dbstat = x }
            end
          end
          @f0dbstat.f0params = data
        end

        # Splits the search results.
        def format0_split_search(data)
          iterations = []
          while r = data[0] and /^Searching/ =~ r
            iterations << Iteration.new(data)
          end
          iterations
        end

        # Stores format0 database statistics.
        # Internal use only. Users must not use the class.
        class F0dbstat #:nodoc:
          # Creates new F0dbstat class.
          # Internal use only.
          def initialize(ary)
            @f0dbstat = ary
            @hash = {}
          end
          attr_reader :f0dbstat
          attr_accessor :f0params

          # Parses colon-separeted lines (in +ary+) and stores to +hash+.
          def parse_colon_separated_params(hash, ary)
            ary.each do |str|
              sc = StringScanner.new(str)
              sc.skip(/\s*/)
              while sc.rest?
                if sc.match?(/Number of sequences better than +([e\+\-\.\d]+) *\: *(.+)/) then
                  ev = sc[1]
                  ev = '1' + ev if ev[0] == ?e
                  @expect = ev.to_f
                  @num_hits = sc[2].tr(',', '').to_i
                end
                if sc.skip(/([\-\,\.\'\(\)\#\w ]+)\: *(.*)/) then
                  hash[sc[1]] = sc[2]
                else
                  #p sc.peek(20)
                  raise ScanError
                end
                sc.skip(/\s*/)
              end #while
            end #each
          end #def
          private :parse_colon_separated_params

          # Parses parameters.
          def parse_params
            unless defined?(@parse_params)
              parse_colon_separated_params(@hash, @f0params)
              #p @hash
              if val = @hash['Matrix'] then
                if /blastn *matrix *\: *([e\+\-\.\d]+) +([e\+\-\.\d]+)/ =~ val then
                  @matrix = 'blastn'
                  @sc_match    = $1.to_i
                  @sc_mismatch = $2.to_i 
                else
                  @matrix = val
                end
              end
              if val = @hash['Gap Penalties'] then
                if /Existence\: *([e\+\-\.\d]+)/ =~ val then
                  @gap_open = $1.to_i
                end
                if /Extension\: *([e\+\-\.\d]+)/ =~ val then
                  @gap_extend = $1.to_i
                end
              end
              #@db_num = @hash['Number of Sequences'] unless defined?(@db_num)
              #@db_len = @hash['length of database']  unless defined?(@db_len)
              if val = @hash['effective search space'] then
                @eff_space = val.tr(',', '').to_i
              end
              @parse_params = true
            end #unless
          end
          private :parse_params

          # Returns name of the matrix.
          def matrix;      parse_params; @matrix;      end
          # Returns the match score of the matrix.
          def sc_match;    parse_params; @sc_match;    end
          # Returns the mismatch score of the matrix.
          def sc_mismatch; parse_params; @sc_mismatch; end

          # Returns gap open penalty value.
          def gap_open;    parse_params; @gap_open;    end
          # Returns gap extend penalty value.
          def gap_extend;  parse_params; @gap_extend;  end

          # Returns effective length of the database.
          def eff_space;   parse_params; @eff_space;   end

          # Returns e-value threshold specified when BLAST was executed.
          def expect;      parse_params; @expect;      end

          # Returns number of hits.
          def num_hits;    parse_params; @num_hits;    end

          # Parses database statistics lines.
          def parse_dbstat
            a = @f0dbstat[0].to_s.split(/^/)
            d = []
            i = 3
            while i > 0 and line = a.pop
              case line
              when /^\s+Posted date\:\s*(.*)$/
                unless defined?(@posted_date)
                  @posted_date = $1.strip
                  i -= 1; d.clear
                end
              when /^\s+Number of letters in database\:\s*(.*)$/
                unless defined?(@db_len)
                  @db_len =  $1.tr(',', '').to_i
                  i -= 1; d.clear
                end
              when /^\s+Number of sequences in database\:\s*(.*)$/
                unless defined?(@db_num)
                  @db_num = $1.tr(',', '').to_i
                  i -= 1; d.clear
                end
              else
                d.unshift(line)
              end
            end #while
            a.concat(d)
            while line = a.shift
              if /^\s+Database\:\s*(.*)$/ =~ line
                a.unshift($1)
                a.each { |x| x.strip! }
                @database = a.join(' ')
                break #while
              end
            end
          end #def
          private :parse_dbstat

          # Returns name (title or filename) of the database.
          def database
            unless defined?(@database);    parse_dbstat; end; @database
          end

          # Returns posted date of the database.
          def posted_date
            unless defined?(@posted_date); parse_dbstat; end; @posted_date
          end

          # Returns number of letters in database.
          def db_len
            unless defined?(@db_len);      parse_dbstat; end; @db_len
          end

          # Returns number of sequences in database.
          def db_num
            unless defined?(@db_num);      parse_dbstat; end; @db_num
          end
        end #class F0dbstat

        # Provides a singleton object of which any methods always return nil.
        # Internal use only. Users must not use the class.
        class AlwaysNil #:nodoc:
          include Singleton
          def method_missing(*arg)
            nil
          end
        end #class AlwaysNil

        # Bio::Blast::Default::Report::Iteration stores information about
        # a iteration.
        # It may contain some Bio::Blast::Default::Report::Hit objects.
        # Note that a PSI-BLAST (blastpgp command) result usually contain
        # multiple iterations in it, and a normal BLAST (blastall command)
        # result usually contain one iteration in it.
        class Iteration
          # Creates a new Iteration object.
          # It is designed to be called only internally from
          # the Bio::Blast::Default::Report class.
          # Users shall not use the method directly.
          def initialize(data)
            @f0stat = []
            @f0dbstat = AlwaysNil.instance
            @f0hitlist = []
            @hits = []
            @num = 1
            r = data.shift
            @f0message = [ r ]
            r.gsub!(/^Results from round (\d+).*\z/) { |x|
              @num = $1.to_i
              @f0message << x
              ''
            }
            r = data.shift
            while /^Number of occurrences of pattern in the database is +(\d+)/ =~ r
              # PHI-BLAST
              @pattern_in_database = $1.to_i
              @f0message << r
              r = data.shift
            end
            if /^Results from round (\d+)/ =~ r then
              @num = $1.to_i
              @f0message << r
              r = data.shift
            end
            if r and !(/\*{5} No hits found \*{5}/ =~ r) then
              @f0hitlist << r
              begin
                @f0hitlist << data.shift
              end until r = data[0] and /^\>/ =~ r
              if r and /^CONVERGED\!/ =~ r then
                r.sub!(/(.*\n)*^CONVERGED\!.*\n/) { |x| @f0hitlist << x; '' }
              end
              if defined?(@pattern_in_database) and r = data.first then
                #PHI-BLAST
                while /^\>/ =~ r
                  @hits << Hit.new(data)
                  r = data.first
                  break unless r
                  while /^Significant alignments for pattern/ =~ r
                    data.shift
                    r = data.first
                  end
                end
              else
                #not PHI-BLAST
                while r = data[0] and /^\>/ =~ r
                  @hits << Hit.new(data)
                end
              end
            end
            if /^CONVERGED\!\s*$/ =~ @f0hitlist[-1].to_s then
              @message = 'CONVERGED!'
              @flag_converged = true
            end
          end

          # (PSI-BLAST) Iteration round number.
          attr_reader :num
          # (PSI-BLAST) Messages of the iteration.
          attr_reader :message
          # (PHI-BLAST) Number of occurrences of pattern in the database.
          attr_reader :pattern_in_database

          # Returns the hits of the iteration.
          # It returns an array of Bio::Blast::Default::Report::Hit objects.
          def hits
            parse_hitlist
            @hits
          end

          # Iterates over each hit of the iteration.
          # Yields a Bio::Blast::Default::Report::Hit object.
          def each
            hits.each do |x|
              yield x
            end
          end

          # (PSI-BLAST) Returns true if the iteration is converged.
          # Otherwise, returns false.
          def converged?
            @flag_converged
          end

          # (PHI-BLAST) Returns pattern string.
          # Returns nil if it is not a PHI-BLAST result.
          def pattern
            #PHI-BLAST
            if !defined?(@pattern) and defined?(@pattern_in_database) then
              @pattern = nil
              @pattern_positions = []
              @f0message.each do |r|
                sc = StringScanner.new(r)
                if sc.skip_until(/^ *pattern +([^\s]+)/) then
                  @pattern = sc[1] unless @pattern
                  sc.skip_until(/(?:^ *| +)at position +(\d+) +of +query +sequence/)
                  @pattern_positions << sc[1].to_i
                end
              end
            end
            @pattern
          end

          # (PHI-BLAST) Returns pattern positions.
          # Returns nil if it is not a PHI-BLAST result.
          def pattern_positions
            #PHI-BLAST
            pattern
            @pattern_positions
          end

          # (PSI-BLAST)
          # Returns hits which have been found again in the iteration.
          # It returns an array of Bio::Blast::Default::Report::Hit objects.
          def hits_found_again
            parse_hitlist
            @hits_found_again
          end

          # (PSI-BLAST)
          # Returns hits which have been newly found in the iteration.
          # It returns an array of Bio::Blast::Default::Report::Hit objects.
          def hits_newly_found
            parse_hitlist
            @hits_newly_found
          end

          # (PHI-BLAST) Returns hits for pattern. ????
          def hits_for_pattern
            parse_hitlist
            @hits_for_pattern
          end

          # Parses list of hits.
          def parse_hitlist
            unless defined?(@parse_hitlist)
              @hits_found_again = []
              @hits_newly_found = []
              @hits_unknown_state = []
              i = 0
              a = @hits_newly_found
              flag = true
              @f0hitlist.each do |x|
                sc = StringScanner.new(x)
                if flag then
                  if sc.skip_until(/^Sequences used in model and found again\:\s*$/)
                    a = @hits_found_again
                  end
                  flag = nil
                  next
                end
                next if sc.skip(/^CONVERGED\!$/)
                if sc.skip(/^Sequences not found previously or not previously below threshold\:\s*$/) then
                  a = @hits_newly_found
                  next
                elsif sc.skip(/^Sequences.+\:\s*$/) then
                  #possibly a bug or unknown format?
                  a = @hits_unknown_state
                  next
                elsif sc.skip(/^Significant (matches|alignments) for pattern/) then
                  # PHI-BLAST
                  # do nothing when 'alignments'
                  if sc[1] == 'matches' then
                    unless defined?(@hits_for_pattern)
                      @hits_for_pattern = []
                    end
                    a = []
                    @hits_for_pattern << a
                  end
                  next
                end
                b = x.split(/^/)
                b.collect! { |y| y.empty? ? nil : y }
                b.compact!
                if i + b.size > @hits.size then
                  ((@hits.size - i)...(b.size)).each do |j|
                    y = b[j]; y.strip!
                    y.reverse!
                    z = y.split(/\s+/, 3)
                    z.each { |y| y.reverse! }
                    h = Hit.new([ z.pop.to_s.sub(/\.+\z/, '') ])
                    bs = z.pop.to_s
                    bs = '1' + bs if bs[0] == ?e
                    bs = (bs.empty? ? nil : bs.to_f)
                    ev = z.pop.to_s
                    ev = '1' + ev if ev[0] == ?e
                    ev = (ev.empty? ? (1.0/0.0) : ev.to_f)
                    h.instance_eval { @bit_score = bs; @evalue = ev }
                    @hits << h
                  end
                end
                a.concat(@hits[i, b.size])
                i += b.size
              end #each
              @hits_found_again.each do |x|
                x.instance_eval { @again = true }
              end
              @parse_hitlist = true
            end #unless
          end
          private :parse_hitlist

          # Parses statistics for the iteration.
          def parse_stat
            unless defined?(@parse_stat)
              @f0stat.each do |x|
                gapped = nil
                sc = StringScanner.new(x)
                sc.skip(/\s*/)
                if sc.skip(/Gapped\s*/) then
                  gapped = true
                end
                s0 = []
                h = {}
                while r = sc.scan(/\w+/)
                  #p r
                  s0 << r
                  sc.skip(/ */)
                end
                sc.skip(/\s*/)
                while r = sc.scan(/[e\+\-\.\d]+/)
                  #p r
                  h[s0.shift] = r
                  sc.skip(/ */)
                end
                if gapped then
                  @gapped_lambda = (v = h['Lambda']) ? v.to_f : nil
                  @gapped_kappa = (v = h['K']) ? v.to_f : nil
                  @gapped_entropy = (v = h['H']) ? v.to_f : nil
                else
                  @lambda = (v = h['Lambda']) ? v.to_f : nil
                  @kappa = (v = h['K']) ? v.to_f : nil
                  @entropy = (v = h['H']) ? v.to_f : nil
                end
              end #each
              @parse_stat = true
            end #unless
          end #def
          private :parse_stat

          # Defines attributes which call +parse_stat+ before accessing.
          def self.method_after_parse_stat(*names)
            names.each do |x|
              module_eval("def #{x}; parse_stat; @#{x}; end")
            end
          end
          private_class_method :method_after_parse_stat

          # lambda of the database
          attr_reader             :lambda  if false #dummy
          method_after_parse_stat :lambda
          # kappa of the database
          attr_reader             :kappa   if false #dummy
          method_after_parse_stat :kappa
          # entropy of the database
          attr_reader             :entropy if false #dummy
          method_after_parse_stat :entropy

          # gapped lambda of the database
          attr_reader             :gapped_lambda  if false #dummy
          method_after_parse_stat :gapped_lambda
          # gapped kappa of the database
          attr_reader             :gapped_kappa   if false #dummy
          method_after_parse_stat :gapped_kappa
          # gapped entropy of the database
          attr_reader             :gapped_entropy if false #dummy
          method_after_parse_stat :gapped_entropy

          # Defines attributes which delegate to @f0dbstat objects.
          def self.delegate_to_f0dbstat(*names)
            names.each do |x|
              module_eval("def #{x}; @f0dbstat.#{x}; end")
            end
          end
          private_class_method :delegate_to_f0dbstat

          # name (title or filename) of the database
          attr_reader          :database if false #dummy
          delegate_to_f0dbstat :database
          # posted date of the database
          attr_reader          :posted_date if false #dummy
          delegate_to_f0dbstat :posted_date

          # number of letters in database
          attr_reader          :db_num if false #dummy
          delegate_to_f0dbstat :db_num
          # number of sequences in database
          attr_reader          :db_len if false #dummy
          delegate_to_f0dbstat :db_len
          # effective length of the database
          attr_reader          :eff_space if false #dummy
          delegate_to_f0dbstat :eff_space

          # e-value threshold specified when BLAST was executed
          attr_reader          :expect if false #dummy
          delegate_to_f0dbstat :expect

        end #class Iteration

        # Bio::Blast::Default::Report::Hit contains information about a hit.
        # It may contain some Bio::Blast::Default::Report::HSP objects.
        class Hit
          # Creates a new Hit object.
          # It is designed to be called only internally from the
          # Bio::Blast::Default::Report::Iteration class.
          # Users should not call the method directly.
          def initialize(data)
            @f0hitname = data.shift
            @hsps = []
            while r = data[0] and /\A\s+Score/ =~ r
              @hsps << HSP.new(data)
            end
            @again = false
          end

          # Hsp(high-scoring segment pair)s of the hit.
          # Returns an array of Bio::Blast::Default::Report::HSP objects.
          attr_reader :hsps

          # Iterates over each hsp(high-scoring segment pair) of the hit.
          # Yields a Bio::Blast::Default::Report::HSP object.
          def each
            @hsps.each { |x| yield x }
          end

          # (PSI-BLAST)
          # Returns true if the hit is found again in the iteration.
          # Otherwise, returns false or nil.
          def found_again?
            @again
          end

          # Returns first hsp's score.
          def score
            (h = @hsps.first) ? h.score : nil
          end

          # Returns first hsp's bit score.
          # (shown in hit list of BLAST result)
          def bit_score
            unless defined?(@bit_score)
              if h = @hsps.first then
                @bit_score = h.bit_score
              end
            end
            @bit_score
          end

          # Returns first hsp's e-value.
          # (shown in hit list of BLAST result)
          def evalue
            unless defined?(@evalue)
              if h = @hsps.first then
                @evalue = h.evalue
              end
            end
            @evalue
          end

          # Parses name of the hit.
          def parse_hitname
            unless defined?(@parse_hitname)
              sc = StringScanner.new(@f0hitname)
              sc.skip(/\s*/)
              sc.skip(/\>/)
              d = []
              begin
                d << sc.scan(/.*/)
                sc.skip(/\s*/)
              end until !sc.rest? or r = sc.skip(/ *Length *\= *([\,\d]+)\s*\z/)
              @len = (r ? sc[1].to_i : nil)
              @definition = d.join(" ")
              @parse_hitname = true
            end
          end
          private :parse_hitname

          # Returns length of the hit.
          def len;        parse_hitname; @len;        end

          # Returns definition of the hit.
          def definition; parse_hitname; @definition; end

          def target_id; definition[/^\s*(\S+)/, 1]; end

          #--
          # Aliases to keep compatibility with Bio::Fasta::Report::Hit.
          alias target_def definition
          alias target_len len
          #++

          # Sends given method to the first hsp or returns nil if
          # there are no hsps.
          def hsp_first(m)
            (h = hsps.first) ? h.send(m) : nil
          end
          private :hsp_first

          #--
          # Shortcut methods for the best Hsp
          # (Compatibility method with FASTA)
          #++

          # Same as hsps.first.identity.
          # Returns nil if there are no hsp in the hit.
          # (Compatibility method with FASTA)
          def identity;      hsp_first :identity;     end

          # Same as hsps.first.align_len.
          # Returns nil if there are no hsp in the hit.
          # (Compatibility method with FASTA)
          def overlap;       hsp_first :align_len;    end

          # Same as hsps.first.qseq.
          # Returns nil if there are no hsp in the hit.
          # (Compatibility method with FASTA)
          def query_seq;     hsp_first :qseq;         end

          # Same as hsps.first.hseq.
          # Returns nil if there are no hsp in the hit.
          # (Compatibility method with FASTA)
          def target_seq;    hsp_first :hseq;         end

          # Same as hsps.first.midline.
          # Returns nil if there are no hsp in the hit.
          # (Compatibility method with FASTA)
          def midline;       hsp_first :midline;      end

          # Same as hsps.first.query_from.
          # Returns nil if there are no hsp in the hit.
          # (Compatibility method with FASTA)
          def query_start;   hsp_first :query_from;   end

          # Same as hsps.first.query_to.
          # Returns nil if there are no hsp in the hit.
          # (Compatibility method with FASTA)
          def query_end;     hsp_first :query_to;     end

          # Same as hsps.first.hit_from.
          # Returns nil if there are no hsp in the hit.
          # (Compatibility method with FASTA)
          def target_start;  hsp_first :hit_from;     end

          # Same as hsps.first.hit_to.
          # Returns nil if there are no hsp in the hit.
          # (Compatibility method with FASTA)
          def target_end;    hsp_first :hit_to;       end

          # Returns an array which contains
          # [ query_start, query_end, target_start, target_end ].
          # (Compatibility method with FASTA)
          def lap_at
            [ query_start, query_end, target_start, target_end ]
          end
        end #class Hit

        # Bio::Blast::Default::Report::HSP holds information about the hsp
        # (high-scoring segment pair).
        class HSP
          # Creates new HSP object.
          # It is designed to be called only internally from the
          # Bio::Blast::Default::Report::Hit class.
          # Users should not call the method directly.
          def initialize(data)
            @f0score = data.shift
            @f0alignment = []
            while r = data[0] and /^(Query|Sbjct)\:/ =~ r
              @f0alignment << data.shift
            end
          end

          # Parses scores, identities, positives, gaps, and so on.
          def parse_score
            unless defined?(@parse_score)
              sc = StringScanner.new(@f0score)
              while sc.rest?
                sc.skip(/\s*/)
                if sc.skip(/Expect(?:\(\d+\))? *\= *([e\+\-\.\d]+)/) then
                  ev = sc[1].to_s
                  ev = '1' + ev if ev[0] == ?e
                  @evalue = ev.to_f
                elsif sc.skip(/Score *\= *([e\+\-\.\d]+) *bits *\( *([e\+\-\.\d]+) *\)/) then
                  bs = sc[1]
                  bs = '1' + bs if bs[0] == ?e
                  @bit_score = bs.to_f
                  @score = sc[2].to_i
                elsif sc.skip(/(Identities|Positives|Gaps) *\= (\d+) *\/ *(\d+) *\(([\.\d]+) *\% *\)/) then
                  alen = sc[3].to_i
                  @align_len = alen unless defined?(@align_len)
                  raise ScanError if alen != @align_len
                  case sc[1]
                  when 'Identities'
                    @identity = sc[2].to_i
                    @percent_identity = sc[4].to_i
                  when 'Positives'
                    @positive = sc[2].to_i
                    @percent_positive = sc[4].to_i
                  when 'Gaps'
                    @gaps = sc[2].to_i
                    @percent_gaps = sc[4].to_i
                  else
                    raise ScanError
                  end
                elsif sc.skip(/Strand *\= *(Plus|Minus) *\/ *(Plus|Minus)/) then
                  @query_strand = sc[1]
                  @hit_strand = sc[2]
                  if sc[1] == sc[2] then
                    @query_frame = 1
                    @hit_frame = 1
                  elsif sc[1] == 'Plus' then # Plus/Minus
                    # complement sequence against xml(-m 7)
                    # In xml(-m 8), -1=>Plus, 1=>Minus ???
                    #@query_frame = -1
                    #@hit_frame = 1
                    @query_frame = 1
                    @hit_frame = -1
                  else # Minus/Plus
                    @query_frame = -1
                    @hit_frame = 1
                  end
                elsif sc.skip(/Frame *\= *([\-\+]\d+)( *\/ *([\-\+]\d+))?/) then
                  @query_frame = sc[1].to_i
                  if sc[2] then
                    @hit_frame = sc[3].to_i
                  end
                elsif sc.skip(/Score *\= *([e\+\-\.\d]+) +\(([e\+\-\.\d]+) *bits *\)/) then
                  #WU-BLAST
                  @score = sc[1].to_i
                  bs = sc[2]
                  bs = '1' + bs if bs[0] == ?e
                  @bit_score = bs.to_f
                elsif sc.skip(/P *\= * ([e\+\-\.\d]+)/) then
                  #WU-BLAST
                  @p_sum_n = nil
                  pv = sc[1]
                  pv = '1' + pv if pv[0] == ?e
                  @pvalue = pv.to_f
                elsif sc.skip(/Sum +P *\( *(\d+) *\) *\= *([e\+\-\.\d]+)/) then
                  #WU-BLAST
                  @p_sum_n = sc[1].to_i
                  pv = sc[2]
                  pv = '1' + pv if pv[0] == ?e
                  @pvalue = pv.to_f
                elsif sc.skip(/Method\:\s*(.+)/) then
                  # signature of composition-based statistics method
                  # for example, "Method: Composition-based stats."
                  @stat_method = sc[1]
                else
                  raise ScanError
                end
                sc.skip(/\s*\,?\s*/)
              end
              @parse_score = true
            end
          end
          private :parse_score

          # Defines attributes which call parse_score before accessing.
          def self.method_after_parse_score(*names)
            names.each do |x|
              module_eval("def #{x}; parse_score; @#{x}; end")
            end
          end
          private_class_method :method_after_parse_score

          # bit score
          attr_reader              :bit_score if false #dummy
          method_after_parse_score :bit_score
          # score
          attr_reader              :score if false #dummy
          method_after_parse_score :score

          # e-value
          attr_reader              :evalue if false #dummy
          method_after_parse_score :evalue

          # frame of the query
          attr_reader              :query_frame if false #dummy
          method_after_parse_score :query_frame
          # frame of the hit
          attr_reader              :hit_frame if false #dummy
          method_after_parse_score :hit_frame

          # Identity (number of identical nucleotides or amino acids)
          attr_reader              :identity if false #dummy
          method_after_parse_score :identity
          # percent of identical nucleotides or amino acids
          attr_reader              :percent_identity if false #dummy
          method_after_parse_score :percent_identity

          # Positives (number of positive hit amino acids or nucleotides)
          attr_reader              :positive if false #dummy
          method_after_parse_score :positive
          # percent of positive hit amino acids or nucleotides
          attr_reader              :percent_positive if false #dummy
          method_after_parse_score :percent_positive

          # Gaps (number of gaps)
          attr_reader              :gaps if false #dummy
          method_after_parse_score :gaps
          # percent of gaps
          attr_reader              :percent_gaps if false #dummy
          method_after_parse_score :percent_gaps

          # aligned length
          attr_reader              :align_len if false #dummy
          method_after_parse_score :align_len

          # strand of the query ("Plus" or "Minus" or nil)
          attr_reader              :query_strand if false #dummy
          method_after_parse_score :query_strand

          # strand of the hit ("Plus" or "Minus" or nil)
          attr_reader              :hit_strand if false #dummy
          method_after_parse_score :hit_strand

          # statistical method for calculating evalue and/or score
          # (nil or a string)
          # (note that composition-based statistics for blastp or tblastn
          # were enabled by default after NCBI BLAST 2.2.17)
          attr_reader              :stat_method if false #dummy
          method_after_parse_score :stat_method

          # Parses alignments.
          def parse_alignment
            unless defined?(@parse_alignment)
              qpos1 = nil
              qpos2 = nil
              spos1 = nil
              spos2 = nil
              qseq = []
              sseq = []
              mseq = []
              pos_st = nil
              len_seq = 0
              nextline = :q
              @f0alignment.each do |x|
                sc = StringScanner.new(x)
                while sc.rest?
                  #p pos_st, len_seq
                  #p nextline.to_s
                  if r = sc.skip(/(Query|Sbjct)\: *(\d+) */) then
                    pos_st = r
                    qs = sc[1]
                    pos1 = sc[2]
                    len_seq = sc.skip(/[^ ]*/)
                    seq = sc[0]
                    sc.skip(/ *(\d+) *\n/)
                    pos2 = sc[1]
                    if qs == 'Query' then
                      raise ScanError unless nextline == :q
                      qpos1 = pos1.to_i unless qpos1
                      qpos2 = pos2.to_i
                      qseq << seq
                      nextline = :m
                    elsif qs == 'Sbjct' then
                      if nextline == :m then
                        mseq << (' ' * len_seq)
                      end
                      spos1 = pos1.to_i unless spos1
                      spos2 = pos2.to_i
                      sseq << seq
                      nextline = :q
                    else
                      raise ScanError
                    end
                  elsif r = sc.scan(/ {6}.+/) then
                    raise ScanError unless nextline == :m
                    mseq << r[pos_st, len_seq]
                    sc.skip(/\n/)
                    nextline = :s
                  elsif r = sc.skip(/pattern +\d+.+/) then
                    # PHI-BLAST
                    # do nothing
                    sc.skip(/\n/)
                  else
                    raise ScanError
                  end
                end #while
              end #each
              #p qseq, sseq, mseq
              @qseq = qseq.join('')
              @hseq = sseq.join('')
              @midline = mseq.join('')
              @query_from = qpos1
              @query_to   = qpos2
              @hit_from = spos1
              @hit_to   = spos2
              @parse_alignment = true
            end #unless
          end #def
          private :parse_alignment

          # Defines attributes which call parse_alignment before accessing.
          def self.method_after_parse_alignment(*names)
            names.each do |x|
              module_eval("def #{x}; parse_alignment; @#{x}; end")
            end
          end
          private_class_method :method_after_parse_alignment

          # query sequence (with gaps) of the alignment of the hsp
          attr_reader                  :qseq if false #dummy
          method_after_parse_alignment :qseq
          # hit sequence (with gaps) of the alignment of the hsp
          attr_reader                  :hseq if false #dummy
          method_after_parse_alignment :hseq

          # middle line of the alignment of the hsp
          attr_reader                  :midline if false #dummy
          method_after_parse_alignment :midline

          # start position of the query (the first position is 1)
          attr_reader                  :query_from if false #dummy
          method_after_parse_alignment :query_from

          # end position of the query (including its position)
          attr_reader                  :query_to
          method_after_parse_alignment :query_to

          # start position of the hit (the first position is 1)
          attr_reader                  :hit_from if false #dummy
          method_after_parse_alignment :hit_from

          # end position of the hit (including its position)
          attr_reader                  :hit_to if false #dummy
          method_after_parse_alignment :hit_to

        end #class HSP

      end #class Report

      # NCBI BLAST default (-m 0 option) output parser for TBLAST.
      # All methods are equal to Bio::Blast::Default::Report.
      # Only DELIMITER (and RS) is different.
      class Report_TBlast < Report
        # Delimter of each entry for TBLAST. Bio::FlatFile uses it.
        DELIMITER = RS = "\nTBLAST"

        # (Integer) excess read size included in DELIMITER.
        DELIMITER_OVERRUN = 6 # "TBLAST"
      end #class Report_TBlast

    end #module Default
  end #class Blast
end #module Bio

######################################################################

if __FILE__ == $0

  Bio::FlatFile.open(Bio::Blast::Default::Report, ARGF) do |ff|
  ff.each do |rep|

  print "# === Bio::Blast::Default::Report\n"
  puts
  print "  rep.program           #=> "; p rep.program
  print "  rep.version           #=> "; p rep.version
  print "  rep.reference         #=> "; p rep.reference
  print "  rep.db                #=> "; p rep.db
  #print "  rep.query_id          #=> "; p rep.query_id
  print "  rep.query_def         #=> "; p rep.query_def
  print "  rep.query_len         #=> "; p rep.query_len
  #puts
  print "  rep.version_number    #=> "; p rep.version_number
  print "  rep.version_date      #=> "; p rep.version_date
  puts

  print "# === Parameters\n"
  #puts
  #print "  rep.parameters        #=> "; p rep.parameters
  puts
  print "  rep.matrix            #=> "; p rep.matrix
  print "  rep.expect            #=> "; p rep.expect
  #print "  rep.inclusion         #=> "; p rep.inclusion
  print "  rep.sc_match          #=> "; p rep.sc_match
  print "  rep.sc_mismatch       #=> "; p rep.sc_mismatch
  print "  rep.gap_open          #=> "; p rep.gap_open
  print "  rep.gap_extend        #=> "; p rep.gap_extend
  #print "  rep.filter            #=> "; p rep.filter
  print "  rep.pattern           #=> "; p rep.pattern
  #print "  rep.entrez_query      #=> "; p rep.entrez_query
  #puts
  print "  rep.pattern_positions  #=> "; p rep.pattern_positions
  puts

  print "# === Statistics (last iteration's)\n"
  #puts
  #print "  rep.statistics        #=> "; p rep.statistics
  puts
  print "  rep.db_num            #=> "; p rep.db_num
  print "  rep.db_len            #=> "; p rep.db_len
  #print "  rep.hsp_len           #=> "; p rep.hsp_len
  print "  rep.eff_space         #=> "; p rep.eff_space
  print "  rep.kappa             #=> "; p rep.kappa
  print "  rep.lambda            #=> "; p rep.lambda
  print "  rep.entropy           #=> "; p rep.entropy
  puts
  print "  rep.num_hits          #=> "; p rep.num_hits
  print "  rep.gapped_kappa      #=> "; p rep.gapped_kappa
  print "  rep.gapped_lambda     #=> "; p rep.gapped_lambda
  print "  rep.gapped_entropy    #=> "; p rep.gapped_entropy
  print "  rep.posted_date       #=> "; p rep.posted_date
  puts

  print "# === Message (last iteration's)\n"
  puts
  print "  rep.message           #=> "; p rep.message
  #puts
  print "  rep.converged?        #=> "; p rep.converged?
  puts

  print "# === Iterations\n"
  puts
  print "  rep.itrerations.each do |itr|\n"
  puts

  rep.iterations.each do |itr|
      
  print "# --- Bio::Blast::Default::Report::Iteration\n"
  puts

  print "    itr.num             #=> "; p itr.num
  #print "    itr.statistics      #=> "; p itr.statistics
  print "    itr.message         #=> "; p itr.message
  print "    itr.hits.size       #=> "; p itr.hits.size
  #puts
  print "    itr.hits_newly_found.size    #=> "; p itr.hits_newly_found.size;
  print "    itr.hits_found_again.size    #=> "; p itr.hits_found_again.size;
  if itr.hits_for_pattern then
  itr.hits_for_pattern.each_with_index do |hp, hpi|
  print "    itr.hits_for_pattern[#{hpi}].size #=> "; p hp.size;
  end
  end
  print "    itr.converged?      #=> "; p itr.converged?
  puts

  print "    itr.hits.each do |hit|\n"
  puts

  itr.hits.each_with_index do |hit, i|

  print "# --- Bio::Blast::Default::Report::Hit"
  print " ([#{i}])\n"
  puts

  #print "      hit.num           #=> "; p hit.num
  #print "      hit.hit_id        #=> "; p hit.hit_id
  print "      hit.len           #=> "; p hit.len
  print "      hit.definition    #=> "; p hit.definition
  #print "      hit.accession     #=> "; p hit.accession
  #puts
  print "      hit.found_again?  #=> "; p hit.found_again?

  print "        --- compatible/shortcut ---\n"
  #print "      hit.query_id      #=> "; p hit.query_id
  #print "      hit.query_def     #=> "; p hit.query_def
  #print "      hit.query_len     #=> "; p hit.query_len
  #print "      hit.target_id     #=> "; p hit.target_id
  print "      hit.target_def    #=> "; p hit.target_def
  print "      hit.target_len    #=> "; p hit.target_len

  print "            --- first HSP's values (shortcut) ---\n"
  print "      hit.evalue        #=> "; p hit.evalue
  print "      hit.bit_score     #=> "; p hit.bit_score
  print "      hit.identity      #=> "; p hit.identity
  #print "      hit.overlap       #=> "; p hit.overlap

  print "      hit.query_seq     #=> "; p hit.query_seq
  print "      hit.midline       #=> "; p hit.midline
  print "      hit.target_seq    #=> "; p hit.target_seq

  print "      hit.query_start   #=> "; p hit.query_start
  print "      hit.query_end     #=> "; p hit.query_end
  print "      hit.target_start  #=> "; p hit.target_start
  print "      hit.target_end    #=> "; p hit.target_end
  print "      hit.lap_at        #=> "; p hit.lap_at
  print "            --- first HSP's vaules (shortcut) ---\n"
  print "        --- compatible/shortcut ---\n"

  puts
  print "      hit.hsps.size     #=> "; p hit.hsps.size
  if hit.hsps.size == 0 then
  puts  "          (HSP not found: please see blastall's -b and -v options)"
  puts
  else

  puts
  print "      hit.hsps.each do |hsp|\n"
  puts

  hit.hsps.each_with_index do |hsp, j|

  print "# --- Bio::Blast::Default::Report::Hsp"
  print " ([#{j}])\n"
  puts
  #print "        hsp.num         #=> "; p hsp.num
  print "        hsp.bit_score   #=> "; p hsp.bit_score 
  print "        hsp.score       #=> "; p hsp.score
  print "        hsp.evalue      #=> "; p hsp.evalue
  print "        hsp.identity    #=> "; p hsp.identity
  print "        hsp.gaps        #=> "; p hsp.gaps
  print "        hsp.positive    #=> "; p hsp.positive
  print "        hsp.align_len   #=> "; p hsp.align_len
  #print "        hsp.density     #=> "; p hsp.density

  print "        hsp.query_frame #=> "; p hsp.query_frame
  print "        hsp.query_from  #=> "; p hsp.query_from
  print "        hsp.query_to    #=> "; p hsp.query_to

  print "        hsp.hit_frame   #=> "; p hsp.hit_frame
  print "        hsp.hit_from    #=> "; p hsp.hit_from
  print "        hsp.hit_to      #=> "; p hsp.hit_to

  #print "        hsp.pattern_from#=> "; p hsp.pattern_from
  #print "        hsp.pattern_to  #=> "; p hsp.pattern_to

  print "        hsp.qseq        #=> "; p hsp.qseq
  print "        hsp.midline     #=> "; p hsp.midline
  print "        hsp.hseq        #=> "; p hsp.hseq
  puts
  print "        hsp.percent_identity  #=> "; p hsp.percent_identity
  #print "        hsp.mismatch_count    #=> "; p hsp.mismatch_count
  #
  print "        hsp.query_strand      #=> "; p hsp.query_strand
  print "        hsp.hit_strand        #=> "; p hsp.hit_strand
  print "        hsp.percent_positive  #=> "; p hsp.percent_positive
  print "        hsp.percent_gaps      #=> "; p hsp.percent_gaps
  puts

  end #each
  end #if hit.hsps.size == 0
  end
  end
  end #ff.each
  end #FlatFile.open

end #if __FILE__ == $0

######################################################################
