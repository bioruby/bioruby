#
# bio/appl/blast/format0.rb - BLAST default output (-m 0) parser
# 
#   Copyright (C) 2003 GOTO Naohisa <ng@bioruby.org>
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
#  $Id: format0.rb,v 1.9 2005/08/07 16:42:28 ngoto Exp $
#

begin
  require 'strscan'
rescue LoadError
end

require 'bio/db'
require 'bio/io/flatfile'

module Bio
  class Blast
    module Default

      class Report #< DB
	DELIMITER = RS = "\nBLAST"

	def self.open(filename, *mode)
	  Bio::FlatFile.open(self, filename, *mode)
	end

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
	attr_reader :entry_overrun

	attr_reader :f0header, :f0reference, :f0query, :f0database, :f0dbstat
	attr_reader :iterations

	def to_s; @entry; end

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
	
	def db_num;      @f0dbstat.db_num;       end
	def db_len;      @f0dbstat.db_len;       end
	def posted_date; @f0dbstat.posted_date;  end
	def eff_space;   @f0dbstat.eff_space;    end
	def sc_match;    @f0dbstat.sc_match;     end
	def sc_mismatch; @f0dbstat.sc_mismatch;  end
	def gap_open;    @f0dbstat.gap_open;     end
	def gap_extend;  @f0dbstat.gap_extend;   end
	def matrix;      @f0dbstat.matrix;       end
	def expect;      @f0dbstat.expect;       end
	def num_hits;    @f0dbstat.num_hits;     end

	def kappa;          @iterations.last.kappa;          end
	def lambda;         @iterations.last.lambda;         end
	def entropy;        @iterations.last.entropy;        end
	def gapped_kappa;   @iterations.last.gapped_kappa;   end
	def gapped_lambda;  @iterations.last.gapped_lambda;  end
	def gapped_entropy; @iterations.last.gapped_entropy; end

	def program;        format0_parse_header; @program;        end
	def version;        format0_parse_header; @version;        end
	def version_number; format0_parse_header; @version_number; end
	def version_date;   format0_parse_header; @version_date;   end

	def query_len; format0_parse_query; @query_len; end
	def query_def; format0_parse_query; @query_def; end

	def pattern; @iterations.first.pattern; end
	def pattern_positions
	  @iterations.first.pattern_positions
	end

	# <for blastpgp>
	def each_iteration
	  @iterations.each do |x|
	    yield x
	  end
	end

	# <for blastall> shortcut for the last iteration's hits
	def each_hit
	  @iterations.last.each do |x|
	    yield x
	  end
	end
	alias :each :each_hit

	# shortcut for the last iteration's hits
	def hits
	  @iterations.last.hits
	end

	# shortcut for the last iteration's message (for checking 'CONVERGED')
	def message
	  @iterations.last.message
	end
	def converged?
	  @iterations.last.converged?
	end

	def reference
	  unless defined?(@reference)
	    @reference = @f0reference.to_s.gsub(/\s+/, ' ').strip
	  end #unless
	  @reference
	end

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
	def format0_parse_query
	  unless defined?(@query_def)
	    sc = StringScanner.new(@f0query)
	    sc.skip(/\s*/)
	    if sc.skip_until(/Query\= */) then
	      q = []
	      begin
		q << sc.scan(/.*/)
		sc.skip(/\s*^ ?/)
	      end until !sc.rest or r = sc.skip(/ *\( *(\d+) *letters *\)\s*\z/)
	      @query_len = sc[1].to_i if r
	      @query_def = q.join(' ')
	    end
	  end
	end

	def format0_parse_header
	  unless defined?(@program)
	    if /(\w+) +([\w\-\.\d]+) *\[ *([\-\.\w]+) *\] *(\[.+\])?/ =~ @f0header.to_s
	      @program = $1
	      @version = "#{$1} #{$2} [#{$3}]"
	      @version_number = $2
	      @version_date = $3
	    end
	  end
	end

	def format0_split_headers(data)
	  @f0header = data.shift
	  @f0reference = data.shift
	  @f0query = data.shift
	  @f0database = data.shift
	end

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
	      itr.f0stat << data.shift
	      itr.f0dbstat = @f0dbstat
	    end
	  end
	  @f0dbstat.f0params = data
	end

	def format0_split_search(data)
	  iterations = []
	  while r = data[0] and /^Searching/ =~ r
	    iterations << Iteration.new(data)
	  end
	  iterations
	end

	class F0dbstat
	  def initialize(ary)
	    @f0dbstat = ary
	    @hash = {}
	  end
	  attr_reader :f0dbstat
	  attr_accessor :f0params

	  def parse_colon_separated_params(hash, ary)
	    ary.each do |str|
	      sc = StringScanner.new(str)
	      sc.skip(/\s*/)
	      while sc.rest?
		if sc.match?(/Number of sequences better than +([e\-\.\d]+) *\: *(.+)/) then
		  @expect = sc[1]
		  @num_hits = sc[2].tr(',', '').to_i
		end
		if sc.skip(/([\-\,\.\'\(\)\w ]+)\: *(.+)/) then
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

	  def parse_params
	    unless defined?(@parse_params)
	      parse_colon_separated_params(@hash, @f0params)
	      #p @hash
	      if val = @hash['Matrix'] then
		if /blastn *matrix *\: *([e\-\.\d]+) +([e\-\.\d]+)/ =~ val then
		  @matrix = 'blastn'
		  @sc_match    = $1.to_i
		  @sc_mismatch = $2.to_i 
		else
		  @matrix = val
		end
	      end
	      if val = @hash['Gap Penalties'] then
		if /Existence\: *([e\-\.\d]+)/ =~ val then
		  @gap_open = $1.to_i
		end
		if /Extension\: *([e\-\.\d]+)/ =~ val then
		  @gap_extend = $1.to_i
		end
	      end
	      #@db_num = @hash['Number of Sequences'] unless defined?(@db_num)
	      #@db_len = @hash['length of database']  unless defined?(@db_len)
	      if val = @hash['effective length of database'] then
		@eff_space = val.tr(',', '').to_i
	      end
	      @parse_params = true
	    end #unless
	  end
	  private :parse_params
	  def self.method_after_parse_params(*names)
	    names.each do |x|
	      module_eval("def #{x}; parse_params; @#{x}; end")
	    end
	  end
	  private_class_method :method_after_parse_params
	  method_after_parse_params :matrix, :gap_open, :gap_extend,
	    :eff_space, :expect, :sc_match, :sc_mismatch,
	    :num_hits

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
	  def self.method_after_parse_dbstat(*names)
	    names.each do |x|
	      module_eval("def #{x}; unless defined?(@#{x}); parse_dbstat; end; @#{x}; end")
	    end
	  end
	  private_class_method :method_after_parse_dbstat
	  method_after_parse_dbstat :database, :posted_date, :db_len, :db_num
	end #class F0dbstat

	class Iteration
	  def initialize(data)
	    @f0stat = []
	    @f0dbstat = nil
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
		  if /^Significant alignments for pattern/ =~ r
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
	  attr_reader :num
	  attr_reader :message
	  attr_reader :pattern_in_database
	  attr_reader :f0message, :f0hitlist
	  attr_accessor :f0stat, :f0dbstat

	  def hits
	    parse_hitlist
	    @hits
	  end

	  def each
	    hits.each do |x|
	      yield x
	    end
	  end

	  def converged?
	    @flag_converged
	  end

	  def pattern
	    #PHI-BLAST
	    if !defined?(@pattern) and defined?(@pattern_in_database) then
	      @pattern = nil
	      @pattern_positions = []
	      @f0message.each do |r|
		sc = StringScanner.new(r)
		if sc.skip_until(/^ *pattern +(.+)$/) then
		  @pattern = sc[1] unless @pattern
		  sc.skip_until(/^ at position +(\d+)/)
		  @pattern_positions << sc[1].to_i
		end
	      end
	    end
	    @pattern
	  end

	  def pattern_positions
	    #PHI-BLAST
	    pattern
	    @pattern_positions
	  end

	  def hits_found_again
	    parse_hitlist
	    @hits_found_again
	  end

	  def hits_newly_found
	    parse_hitlist
	    @hits_newly_found
	  end

	  def hits_for_pattern
	    parse_hitlist
	    @hits_for_pattern
	  end

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
		    ev = z.pop.to_s
		    #ev = '1' + ev if ev[0] == ?e
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

	  def parse_stat
	    unless defined?(@parse_stat)
	      f0stat.each do |x|
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
		while r = sc.scan(/[e\.\-\d]+/)
		  #p r
		  h[s0.shift] = r
		  sc.skip(/ */)
		end
		if gapped then
		  @gapped_lambda = h['Lambda']
		  @gapped_kappa = h['K']
		  @gapped_entropy = h['H']
		else
		  @lambda = h['Lambda']
		  @kappa = h['K']
		  @entropy = h['H']
		end
	      end #each
	      @parse_stat = true
	    end #unless
	  end #def
	  private :parse_stat

	  def self.method_after_parse_stat(*names)
	    names.each do |x|
	      module_eval("def #{x}; parse_stat; @#{x}; end")
	    end
	  end
	  private_class_method :method_after_parse_stat
	  method_after_parse_stat :lambda, :kappa, :entropy,
	    :gapped_lambda, :gapped_kappa, :gapped_entropy

	  def self.method_delegate_f0dbstat(*names)
	    names.each do |x|
	      module_eval("def #{x}; if @f0dbstat then @f0dbstat.#{x}; else nil; end; end")
	    end
	  end
	  private_class_method :method_delegate_f0dbstat
	  method_delegate_f0dbstat :database, :posted_date, :db_num, :db_len,
	    :eff_space, :expect

	end #class Iteration

	class Hit
	  def initialize(data)
	    @f0hitname = data.shift
	    @hsps = []
	    while r = data[0] and /^\s+Score/ =~ r
	      @hsps << HSP.new(data)
	    end
	    @again = false
	  end
	  attr_reader :f0hitname, :hsps

	  def each
	    @hsps.each { |x| yield x }
	  end

	  def found_again?
	    @again
	  end

	  def score
	    (h = @hsps.first) ? h.score : nil
	  end

	  def bit_score
	    unless defined?(@bit_score)
	      if h = @hsps.first then
		@bit_score = h.bit_score
	      end
	    end
	    @bit_score
	  end
	  def evalue
	    unless defined?(@evalue)
	      if h = @hsps.first then
		@evalue = h.evalue
	      end
	    end
	    @evalue
	  end

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

	  def len;        parse_hitname; @len;        end
	  def definition; parse_hitname; @definition; end

	  # Compatible with Bio::Fasta::Report::Hit
	  #alias :target_id :accession
	  alias :target_def :definition
	  alias :target_len :len

	  # Shortcut methods for the best Hsp
	  def hsp_first(m)
	    (h = hsps.first) ? h.send(m) : nil
	  end
	  private :hsp_first

	  def identity;      hsp_first :identity;     end
	  def overlap;       hsp_first :align_len;    end
	  
	  def query_seq;     hsp_first :qseq;         end
	  def target_seq;    hsp_first :hseq;         end
	  def midline;       hsp_first :midline;      end

	  def query_start;   hsp_first :query_from;   end
	  def query_end;     hsp_first :query_to;     end
	  def target_start;  hsp_first :hit_from;     end
	  def target_end;    hsp_first :hit_to;       end
	  def lap_at
	    [ query_start, query_end, target_start, target_end ]
	  end
	end #class Hit

	class HSP
	  def initialize(data)
	    @f0score = data.shift
	    @f0alignment = []
	    while r = data[0] and /^(Query|Sbjct)\:/ =~ r
	      @f0alignment << data.shift
	    end
	  end
	  attr_reader :f0score, :f0alignment

	  def parse_score
	    unless defined?(@parse_score)
	      sc = StringScanner.new(@f0score)
	      while sc.rest?
		sc.skip(/\s*/)
		if sc.skip(/Expect(?:\(\d\))? *\= *([e\-\.\d]+)/) then
		  @evalue = sc[1]
		  #@evalue = '1' + @evalue if @evalue[0] == ?e
		elsif sc.skip(/Score *\= *([e\-\.\d]+) *bits *\( *([e\-\.\d]+) *\)/) then
		  @bit_score = sc[1]
		  @score = sc[2]
		elsif sc.skip(/(Identities|Positives|Gaps) *\= (\d+) *\/ *(\d+) *\(([\.\d]+) *\% *\)/) then
		  alen = sc[3].to_i
		  @align_len = alen unless defined?(@align_len)
		  raise ScanError if alen != @align_len
		  case sc[1]
		  when 'Identities'
		    @identity = sc[2].to_i
		    @percent_identity = sc[4]
		  when 'Positives'
		    @positive = sc[2].to_i
		    @percent_positive = sc[4]
		  when 'Gaps'
		    @gaps = sc[2].to_i
		    @percent_gaps = sc[4]
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
		elsif sc.skip(/Score *\= *([e\-\.\d]+) +\(([e\-\.\d]+) *bits *\)/) then
		  #WU-BLAST
		  @score = sc[1]
		  @bit_score = sc[2]
		elsif sc.skip(/P *\= * ([e\-\.\d]+)/) then
		  #WU-BLAST
		  @p_sum_n = nil
		  @pvalue = sc[1]
		elsif sc.skip(/Sum +P *\( *(\d+) *\) *\= *([e\-\.\d]+)/) then
		  #WU-BLAST
		  @p_sum_n = sc[1].to_i
		  @pvalue = sc[2]
		else
		  raise ScanError
		end
		sc.skip(/\s*\,?\s*/)
	      end
	      @parse_score = true
	    end
	  end
	  private :parse_score

	  def self.method_after_parse_score(*names)
	    names.each do |x|
	      module_eval("def #{x}; parse_score; @#{x}; end")
	    end
	  end
	  private_class_method :method_after_parse_score
	  method_after_parse_score :bit_score, :score,
	    :evalue, :query_frame, :hit_frame,
	    :identity, :positive, :gaps, :align_len,
	    :percent_identity, :percent_positive, :percent_gaps,
	    :query_strand, :hit_strand

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

	  def self.method_after_parse_alignment(*names)
	    names.each do |x|
	      module_eval("def #{x}; parse_alignment; @#{x}; end")
	    end
	  end
	  private_class_method :method_after_parse_alignment
	  method_after_parse_alignment :qseq, :hseq, :midline,
	    :query_from, :query_to, :hit_from, :hit_to
	end #class HSP

      end #class Report

      class Report_TBlast < Report
	DELIMITER = RS = "\nTBLAST"
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

=begin

= Bio::Blast::Default::Report

    NCBI BLAST default (-m 0 option) output parser

= Bio::Blast::Default::Report_TBlast

    NCBI BLAST default (-m 0 option) output parser for TBLAST.
    All methods are equal to Bio::Blast::Default::Report.
    Only DELIMITER (and RS) is different.

=end
