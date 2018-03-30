#
# = bio/appl/fasta/format10.rb - FASTA output (-m 10) parser
# 
# Copyright::  Copyright (C) 2002 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/appl/fasta'
require 'bio/io/flatfile/splitter'

module Bio
class Fasta

# Summarized results of the fasta execution results.
class Report

  # Splitter for Bio::FlatFile
  class FastaFormat10Splitter < Bio::FlatFile::Splitter::Template

    # creates a new splitter object
    def initialize(klass, bstream)
      super(klass, bstream)
      @delimiter = '>>>'
      @real_delimiter = /^\s*\d+\>\>\>\z/
    end

    # do nothing and returns nil
    def skip_leader
      nil
    end

    # gets an entry
    def get_entry
      p0 = stream_pos()
      pieces = []
      overrun = nil
      first = true
      while e = stream.gets(@delimiter)
        pieces.push e
        if @real_delimiter =~ e then
          if first then
            first = nil
          else
            overrun = $&
            break
          end
        end
      end

      ent = (pieces.empty? ? nil : pieces.join(''))
      if ent and overrun then
        ent[-overrun.length, overrun.length] = ''
        stream.ungets(overrun)
      end

      p1 = stream_pos()
      self.entry_start_pos = p0
      self.entry = ent
      self.entry_ended_pos = p1
      return ent
    end
  end #FastaFormat10Splitter

  # Splitter for Bio::FlatFile
  FLATFILE_SPLITTER = FastaFormat10Splitter

  def initialize(data)
    # Split outputs containing multiple query sequences' results
    chunks = data.split(/^(\s*\d+\>\>\>.*)/, 3)
    if chunks.size >= 3 then
      if chunks[0].strip.empty? then
        qdef_line = chunks[1]
        data = chunks[1..2].join('')
        overruns = chunks[3..-1]
      elsif /^\>\>\>/ =~ chunks[0] then
        qdef_line = nil
        data = chunks.shift
        overruns = chunks
      else
        qdef_line = chunks[1]
        data = chunks[0..2].join('')
        overruns = chunks[3..-1]
      end
      @entry_overrun = overruns.join('')
      if qdef_line and
          /^ *\d+\>\>\>([^ ]+) .+ \- +(\d+) +(nt|aa)\s*$/ =~ qdef_line then
        @query_def = $1
        @query_len = $2.to_i
      end
    end

    # header lines - brief list of the hits
    if list_start = data.index("\nThe best scores are") then
      data = data[(list_start + 1)..-1]
      data.sub!(/(.*?)\n\n>>>/m, '')
      @list = $1
      data.sub!(/>>><<<(.*)$/m, '')
    else
      if list_start = data.index(/\n!!\s+/) then
        data = data[list_start..-1]
        data.sub!(/\n!!\s+/, '')
        data.sub!(/.*/) { |x| @list = x; '' }
      else
        data = data.sub(/.*/) { |x| @list = x; '' }
      end
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

  # piece of next entry. Bio::FlatFile uses it.
  attr_reader :entry_overrun

  # Query definition. For older reports, the value may be nil.
  attr_reader :query_def

  # Query sequence length. For older reports, the value may be nil.
  attr_reader :query_len

  # Returns the 'The best scores are' lines as a String.
  attr_reader :list

  # Returns the trailing lines including library size, execution date,
  # fasta function used, and fasta versions as a String.
  attr_reader :log

  # Returns a Bio::Fasta::Report::Program object.
  attr_reader :program

  # Returns an Array of Bio::Fasta::Report::Hit objects.
  attr_reader :hits

  # Iterates on each Bio::Fasta::Report::Hit object.
  def each
    @hits.each do |x|
      yield x
    end
  end

  # Returns an Array of Bio::Fasta::Report::Hit objects having
  # better evalue than 'evalue_max'.
  def threshold(evalue_max = 0.1)
    list = []
    @hits.each do |x|
      list.push(x) if x.evalue < evalue_max
    end
    return list
  end

  # Returns an Array of Bio::Fasta::Report::Hit objects having
  # longer overlap length than 'length_min'.
  def lap_over(length_min = 0)
    list = []
    @hits.each do |x|
      list.push(x) if x.overlap > length_min
    end
    return list
  end

  # Log of the fasta execution environments.
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
    
    # Returns a String containing query and library filenames.
    attr_reader :definition

    # Accessor for a Hash containing 'mp_name', 'mp_ver', 'mp_argv',
    # 'pg_name', 'pg_ver, 'pg_matrix', 'pg_gap-pen', 'pg_ktup',
    # 'pg_optcut', 'pg_cgap', 'mp_extrap', 'mp_stats', and 'mp_KS' values.
    attr_reader :program
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

    # E-value score
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

    # Bit score
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

    # Smith-Waterman score
    def sw
      @score['sw_score'].to_i
    end

    # percent identity
    def identity
      @score['sw_ident'].to_f
    end

    # overlap length
    def overlap
      @score['sw_overlap'].to_i
    end

    # Shortcuts for the methods of Bio::Fasta::Report::Hit::Query

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

    # Shortcuts for the methods of Bio::Fasta::Report::Hit::Target

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

    # Information on matching region

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

      # Returns the definition of the entry as a String.
      # You can access this value by Report::Hit#query_def method.
      attr_reader :definition

      # Returns a Hash containing 'sq_len', 'sq_offset', 'sq_type',
      # 'al_start', 'al_stop', and 'al_display_start' values.
      # You can access most of these values by Report::Hit#query_* methods.
      attr_reader :data

      # Returns the sequence (with gaps) as a String.
      # You can access this value by the Report::Hit#query_seq method.
      attr_reader :sequence

      # Returns the first word in the definition as a String.
      # You can get this value by Report::Hit#query_id method.
      def entry_id
        @definition[/\S+/]
      end

      # Returns the sequence length.
      # You can access this value by the Report::Hit#query_len method.
      def length
        @data['sq_len'].to_i
      end

      # Returns 'p' for protein sequence, 'D' for nucleotide sequence.
      def moltype
        @data['sq_type']
      end

      # Returns alignment start position. You can also access this value
      # by Report::Hit#query_start method for shortcut.
      def start
        @data['al_start'].to_i
      end

      # Returns alignment end position. You can access this value
      # by Report::Hit#query_end method for shortcut.
      def stop
        @data['al_stop'].to_i
      end

    end

    # Same as Bio::Fasta::Report::Hit::Query but for Target.
    class Target < Query; end
  end

end # Report

end # Fasta
end # Bio

