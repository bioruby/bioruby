#
# bio/appl/fasta/format10.rb - FASTA output (-m 10) parser
# 
#   Copyright (C) 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: format10.rb,v 1.6 2005/09/26 13:00:05 k Exp $
#

require 'bio/appl/fasta'

module Bio
  class Fasta

    class Report

      def initialize(data)
        # header lines - brief list of the hits
        if data.sub!(/.*\nThe best scores are/m, '')
          data.sub!(/(.*)\n\n>>>/m, '')
          @list = "The best scores are" + $1
        else
          data.sub!(/.*\n!!\s+/m, '')
          data.sub!(/.*/) { |x| @list = x; '' }
        end

        # body lines - fasta execution result
        program, *hits = data.split(/\n>>/)

        # trailing lines - log messages of the execution
        @log = hits.pop
        @log.sub!(/.*<\n/m, '')
        @log.strip!

        # parse results
        @program = Program.new(program)
        @hits = []

        hits.each do |x|
          @hits.push(Hit.new(x))
        end
      end
      attr_reader :list, :log, :program, :hits

      def each
        @hits.each do |x|
          yield x
        end
      end

      def threshold(evalue_max = 0.1)
        list = []
        @hits.each do |x|
          list.push(x) if x.evalue < evalue_max
        end
        return list
      end

      def lap_over(length_min = 0)
        list = []
        @hits.each do |x|
          list.push(x) if x.overlap > length_min
        end
        return list
      end


      class Program
        def initialize(data)
          @definition, *program = data.split(/\n/)
          @program = {}

          pat = /;\s+([^:]+):\s+(.*)/

          program.each do |x|
            if pat.match(x)
              @program[$1] = $2
            end
          end
        end
        attr_reader :definition, :program
      end


      class Hit
        def initialize(data)
          score, query, target = data.split(/\n>/)

          @definition, *score = score.split(/\n/)
          @score = {}

          pat = /;\s+([^:]+):\s+(.*)/

          score.each do |x|
            if pat.match(x)
              @score[$1] = $2
            end
          end

          @query = Query.new(query)
          @target = Target.new(target)
        end
        attr_reader :definition, :score, :query, :target

        def evalue
          if @score['fa_expect']
            @score['fa_expect'].to_f
          elsif @score['sw_expect']
            @score['sw_expect'].to_f
          elsif @score['fx_expect']
            @score['fx_expect'].to_f
          elsif @score['tx_expect']
            @score['tx_expect'].to_f
          end
        end

        def bit_score
          if @score['fa_bits']
            @score['fa_bits'].to_f
          elsif @score['sw_bits']
            @score['sw_bits'].to_f
          elsif @score['fx_bits']
            @score['fx_bits'].to_f
          elsif @score['tx_bits']
            @score['tx_bits'].to_f
          end
        end

        def direction
          @score['fa_frame'] || @score['sw_frame'] || @score['fx_frame'] || @score['tx_frame']
        end

        def sw
          @score['sw_score'].to_i
        end

        def identity
          @score['sw_ident'].to_f
        end

        def overlap
          @score['sw_overlap'].to_i
        end

        def query_id
          @query.entry_id
        end

        def target_id
          @target.entry_id
        end

        def query_def
          @query.definition
        end

        def target_def
          @target.definition
        end

        def query_len
          @query.length
        end

        def target_len
          @target.length
        end

        def query_seq
          @query.sequence
        end

        def target_seq
          @target.sequence
        end

        def query_type
          @query.moltype
        end

        def target_type
          @target.moltype
        end

        def query_start
          @query.start
        end

        def query_end
          @query.stop
        end

        def target_start
          @target.start
        end

        def target_end
          @target.stop
        end

        def lap_at
          [ query_start, query_end, target_start, target_end ]
        end


        class Query
          def initialize(data)
            @definition, *data = data.split(/\n/)
            @data = {}
            @sequence = ''

            pat = /;\s+([^:]+):\s+(.*)/

            data.each do |x|
              if pat.match(x)
                @data[$1] = $2
              else
                @sequence += x
              end
            end
          end
          attr_reader :definition, :data, :sequence

          def entry_id
            @definition[/\S+/]
          end

          def length
            @data['sq_len'].to_i
          end

          def moltype
            @data['sq_type']
          end

          def start
            @data['al_start'].to_i
          end

          def stop
            @data['al_stop'].to_i
          end

        end

        class Target < Query; end
      end

    end

  end
end


if __FILE__ == $0
  begin
    require 'pp'
    alias p pp
  rescue
  end

  rep = Bio::Fasta::Report.new(ARGF.read)
  p rep

end


=begin

= Bio::Fasta::Report

Summarized results of the fasta execution hits.

--- Bio::Fasta::Report.new(data)
--- Bio::Fasta::Report#each

      Iterates on each Bio::Fasta::Report::Hit object.

--- Bio::Fasta::Report#hits

      Returns an Array of Bio::Fasta::Report::Hit objects.

--- Bio::Fasta::Report#threshold(evalue_max = 0.1)

      Returns an Array of Bio::Fasta::Report::Hit objects having
      better evalue than 'evalue_max'.

--- Bio::Fasta::Report#lap_over(length_min = 0)

      Returns an Array of Bio::Fasta::Report::Hit objects having
      longer overlap length than 'length_min'.

--- Bio::Fasta::Report#program

      Returns a Bio::Fasta::Report::Program object.

--- Bio::Fasta::Report#list

      Returns the 'The best scores are' lines as a String.

--- Bio::Fasta::Report#log

      Returns the trailing lines including library size, execution date,
      fasta function used, and fasta versions as a String.


== Bio::Fasta::Report::Program

Log of the fasta execution environments.

--- Bio::Fasta::Report::Program#definition

      Returns a String containing query and library filenames.

--- Bio::Fasta::Report::Program#program

      Accessor for a Hash containing 'mp_name', 'mp_ver', 'mp_argv',
      'pg_name', 'pg_ver, 'pg_matrix', 'pg_gap-pen', 'pg_ktup',
      'pg_optcut', 'pg_cgap', 'mp_extrap', 'mp_stats', and 'mp_KS' values.


== Bio::Fasta::Report::Hit

--- Bio::Fasta::Report::Hit#definition
--- Bio::Fasta::Report::Hit#score
--- Bio::Fasta::Report::Hit#query
--- Bio::Fasta::Report::Hit#target

      Accessors for the internal structures.

--- Bio::Fasta::Report::Hit#evalue
--- Bio::Fasta::Report::Hit#bit_score
--- Bio::Fasta::Report::Hit#sw
--- Bio::Fasta::Report::Hit#identity

      Matching scores.

--- Bio::Fasta::Report::Hit#query_id
--- Bio::Fasta::Report::Hit#query_def
--- Bio::Fasta::Report::Hit#query_len
--- Bio::Fasta::Report::Hit#query_seq
--- Bio::Fasta::Report::Hit#query_type
--- Bio::Fasta::Report::Hit#target_id
--- Bio::Fasta::Report::Hit#target_def
--- Bio::Fasta::Report::Hit#target_len
--- Bio::Fasta::Report::Hit#target_seq
--- Bio::Fasta::Report::Hit#target_type

      Matching subjects.
      Shortcuts for the methods of Hit::Query and the Hit::Target.

--- Bio::Fasta::Report::Hit#query_start
--- Bio::Fasta::Report::Hit#query_end
--- Bio::Fasta::Report::Hit#target_start
--- Bio::Fasta::Report::Hit#target_end
--- Bio::Fasta::Report::Hit#overlap
--- Bio::Fasta::Report::Hit#lap_at
--- Bio::Fasta::Report::Hit#direction

      Matching regions.


== Bio::Fasta::Report::Hit::Query

--- Bio::Fasta::Report::Hit::Query#entry_id

      Returns the first word in the definition as a String.
      You can get this value by Report::Hit#query_id method.

--- Bio::Fasta::Report::Hit::Query#definition

      Returns the definition of the entry as a String.
      You can access this value by Report::Hit#query_def method.

--- Bio::Fasta::Report::Hit::Query#sequence

      Returns the sequence (with gaps) as a String.
      You can access this value by the Report::Hit#query_seq method.

--- Bio::Fasta::Report::Hit::Query#length

      Returns the sequence length.
      You can access this value by the Report::Hit#query_len method.

--- Bio::Fasta::Report::Hit::Query#moltype

      Returns 'p' for protein sequence, 'D' for nucleotide sequence.

--- Bio::Fasta::Report::Hit::Query#start
--- Bio::Fasta::Report::Hit::Query#stop

      Returns alignment start and stop position.
      You can access these values by Report::Hit#query_start and
      Report::Hit#query_end methods.

--- Bio::Fasta::Report::Hit::Query#data

      Returns a Hash containing 'sq_len', 'sq_offset', 'sq_type',
      'al_start', 'al_stop', and 'al_display_start' values.
      You can access most of these values by Report::Hit#query_* methods.


== Bio::Fasta::Report::Hit::Target

--- Bio::Fasta::Report::Hit::Target#entry_id
--- Bio::Fasta::Report::Hit::Target#definition
--- Bio::Fasta::Report::Hit::Target#data
--- Bio::Fasta::Report::Hit::Target#sequence
--- Bio::Fasta::Report::Hit::Target#length
--- Bio::Fasta::Report::Hit::Target#start
--- Bio::Fasta::Report::Hit::Target#stop

      Same as Bio::Fasta::Report::Hit::Query but for Target.

=end
