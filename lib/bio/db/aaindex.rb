#
# = bio/db/aaindex.rb - AAindex database class
#
# Copyright::  Copyright (C) 2001 
#              KAWASHIMA Shuichi <s@bioruby.org>
# Copyright::  Copyright (C) 2006
#              Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
# $Id: aaindex.rb,v 1.20 2007/04/05 23:35:40 trevor Exp $
#
# == Description
#
# Classes for Amino Acid Index Database (AAindex and AAindex2).
# * AAindex Manual: http://www.genome.jp/dbget-bin/show_man?aaindex
#
# == Examples
#
#  aax1 = Bio::AAindex.auto("PRAM900102.aaindex1")
#  aax2 = Bio::AAindex.auto("DAYM780301.aaindex2")
#
#  aax1 = Bio::AAindex1.new("PRAM900102.aaindex1")
#  aax1.entry_id
#  aax1.index
#
#  aax2 = Bio::AAindex2.new("DAYM780301.aaindex2")
#  aax2.entry_id
#  aax2.matrix
#  aax2.matrix[2,2]
#  aax2.matrix('R', 'A')
#  aax2['R', 'A']
#
# == References
#
# * http://www.genome.jp/aaindex/
#

require "bio/db"
require "matrix"

module Bio

  # Super class for AAindex1 and AAindex2
  class AAindex < KEGGDB

    # Delimiter
    DELIMITER ="\n//\n"

    # Delimiter
    RS = DELIMITER

    # Bio::DB API
    TAGSIZE = 2

    # Auto detecter for two AAindex formats.
    # returns a Bio::AAindex1 object or a Bio::AAindex2 object.
    def self.auto(str)
      case str
      when /^I /m 
        Bio::AAindex1.new(str)
      when /^M /m
        Bio::AAindex2.new(str)
      else
        raise
      end        
    end

    # 
    def initialize(entry)
      super(entry, TAGSIZE)
    end

    # Returns entry_id in the H line.
    def entry_id
      if @data['entry_id']
        @data['entry_id']
      else
        @data['entry_id'] = field_fetch('H')
      end
    end

    # Returns definition in the D line.
    def definition
      if @data['definition']
        @data['definition']
      else
        @data['definition'] = field_fetch('D')
      end
    end

    # Returns database links in the R line.
    # cf.) ['LIT:123456', 'PMID:12345678']
    def dblinks
      if @data['ref']
        @data['ref']
      else
        @data['ref'] = field_fetch('R').split(' ')
      end
    end

    # Returns authors in the A line.
    def author
      if @data['author']
        @data['author']
      else
        @data['author'] = field_fetch('A')
      end
    end

    # Returns title in the T line.
    def title
      if @data['title']
        @data['title']
      else
        @data['title'] = field_fetch('T')
      end
    end

    # Returns journal name in the J line.
    def journal
      if @data['journal']
        @data['journal']
      else
        @data['journal'] = field_fetch('J')
      end
    end

    # Returns comment (if any).
    def comment
      if @data['comment']
        @data['comment']
      else
        @data['comment'] = field_fetch('*')
      end
    end
  end


  # Class for AAindex1 format.
  class AAindex1 < AAindex

    def initialize(entry)
      super(entry)
    end

    # Returns correlation_coefficient (Hash) in the C line.
    #
    # cf.) {'ABCD12010203' => 0.999, 'CDEF123456' => 0.543, ...}
    def correlation_coefficient
      if @data['correlation_coefficient']
        @data['correlation_coefficient']
      else
        hash = {}
        ary = field_fetch('C').split(' ')
        ary.each do |x|
          next unless x =~ /^[A-Z]/
          hash[x] = ary[ary.index(x) + 1].to_f
        end
        @data['correlation_coefficient'] = hash
      end
    end

    # Returns the index (Array) in the I line.
    #
    # an argument: :string, :float, :zscore or :integer
    def index(type = :float)
      aa = %w( A R N D C Q E G H I L K M F P S T W Y V )
      values = field_fetch('I', 1).split(' ')

      if values.size != 20
        raise "Invalid format in #{entry_id} : #{values.inspect}"
      end

      if type == :zscore and values.size > 0
        sum = 0.0
        values.each do |a|
          sum += a.to_f
        end
        mean = sum / values.size # / 20
        var = 0.0
        values.each do |a|
          var += (a.to_f - mean) ** 2
        end
        sd = Math.sqrt(var)
      end

      if type == :integer
        figure = 0
        values.each do |a|
          figure = [ figure, a[/\..*/].length - 1 ].max
        end
      end

      hash = {}

      aa.each_with_index do |a, i|
        case type
        when :string
          hash[a] = values[i]
        when :float
          hash[a] = values[i].to_f
        when :zscore
          hash[a] = (values[i].to_f - mean) / sd
        when :integer
          hash[a] = (values[i].to_f * 10 ** figure).to_i
        end
      end
      return hash
    end

  end


  # Class for AAindex2 format.
  class AAindex2 < AAindex

    def initialize(entry)
      super(entry)
    end

    # Returns row labels.
    def rows
      if @data['rows']
        @data['rows']
      else 
        label_data
        @rows
      end
    end

    # Returns col labels.
    def cols
      if @data['cols']
        @data['cols']
      else 
        label_data
        @cols
      end
    end

    # Returns the value of amino acids substitution (aa1 -> aa2).
    def [](aa1 = nil, aa2 = nil)
      matrix[cols.index(aa1), rows.index(aa2)]
    end

    # Returns amino acids matrix in Matrix.
    def matrix(aa1 = nil, aa2 = nil)
      return self[aa1, aa2] if aa1 and aa2

      if @data['matrix'] 
        @data['matrix'] 
      else
        ma = []
        label_data.each_line do |line|
          ma << line.strip.split(/\s+/).map {|x| x.to_f }
        end
        @data['matrix'] = Matrix[*ma]
      end
    end

    # Returns amino acids matrix in Matrix  for the old format (<= ver 5.0).
    def old_matrix # for AAindex <= ver 5.0
      return @data['matrix'] if @data['matrix']

      @aa = {} 
      # used to determine row/column of the aa
      attr_reader :aa
      alias_method :aa, :rows
      alias_method :aa, :cols

      field = field_fetch('I')

      case field
      when / (ARNDCQEGHILKMFPSTWYV)\s+(.*)/ # 20x19/2 matrix
        aalist = $1
        values = $2.split(/\s+/)

        0.upto(aalist.length - 1) do |i|
          @aa[aalist[i].chr] = i
        end

        ma = Array.new
        20.times do
          ma.push(Array.new(20)) # 2D array of 20x(20)
        end

        for i in 0 .. 19 do
          for j in i .. 19 do
            ma[i][j] = values[i + j*(j+1)/2].to_f
            ma[j][i] = ma[i][j]
          end
        end
        @data['matrix'] = Matrix[*ma]
      when / -ARNDCQEGHILKMFPSTWYV / # 21x20/2 matrix (with gap)
        raise NotImplementedError
      when / ACDEFGHIKLMNPQRSTVWYJ- / # 21x21 matrix (with gap)
        raise NotImplementedError
      end
    end

    private

    def label_data
      if @data['data'] 
        @data['data'] 
      else
        label, data = get('M').split("\n", 2)
        if /M rows = (\S+), cols = (\S+)/.match(label)
          rows, cols = $1, $2
          @rows = rows.split('')
          @cols = cols.split('')
        end
        @data['data'] = data
      end
    end

  end # class AAindex2

end # module Bio


if __FILE__ == $0
  require 'bio/io/fetch'

  puts "### AAindex1 (PRAM900102)"
  aax1 = Bio::AAindex1.new(Bio::Fetch.query('aaindex', 'PRAM900102', 'raw'))
  p aax1.entry_id
  p aax1.definition
  p aax1.dblinks
  p aax1.author
  p aax1.title
  p aax1.journal
  p aax1.comment
  p aax1.correlation_coefficient
  p aax1.index
  p aax1
  puts "### AAindex2 (DAYM780301)"
  aax2 = Bio::AAindex2.new(Bio::Fetch.query('aaindex', 'DAYM780301', 'raw'))
  p aax2.entry_id
  p aax2.definition
  p aax2.dblinks
  p aax2.author
  p aax2.title
  p aax2.journal
  p aax1.comment
  p aax2.rows
  p aax2.cols
  p aax2.matrix
  p aax2.matrix[2,2]
  p aax2.matrix[2,3]
  p aax2.matrix[4,3]
  p aax2.matrix.determinant
  p aax2.matrix.rank
  p aax2.matrix.transpose
  p aax2
end

