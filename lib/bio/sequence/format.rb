#
# = bio/sequence/format.rb - various output format of the biological sequence
#
# Copyright::   Copyright (C) 2006-2008
#               Toshiaki Katayama <k@bioruby.org>,
#               Naohisa Goto <ng@bioruby.org>,
#               Ryan Raaum <ryan@raaum.org>,
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#
# = TODO
#
# porting from N. Goto's feature-output.rb on BioRuby list.
#
# $Id: format.rb,v 1.4.2.8 2008/06/17 15:50:05 ngoto Exp $
#

require 'erb'

module Bio

class Sequence

# = DESCRIPTION
# A Mixin[http://www.rubycentral.com/book/tut_modules.html]
# of methods used by Bio::Sequence#output to output sequences in 
# common bioinformatic formats.  These are not called in isolation.
#
# = USAGE
#   # Given a Bio::Sequence object,
#   puts s.output(:fasta)
#   puts s.output(:genbank)
#   puts s.output(:embl)
module Format

  # Repository of generic (or both nucleotide and protein) sequence
  # formatter classes
  module Formatter

    # Raw format generatar
    autoload :Raw, 'bio/sequence/format_raw'

    # Fasta format generater
    autoload :Fasta, 'bio/db/fasta/format_fasta'

    # NCBI-style Fasta format generatar
    # (resemble to EMBOSS "ncbi" format)
    autoload :Fasta_ncbi, 'bio/db/fasta/format_fasta'

  end #module Formatter

  # Repository of nucleotide sequence formatter classes
  module NucFormatter

    # GenBank format generater
    # Note that the name is 'Genbank' and NOT 'GenBank'
    autoload :Genbank, 'bio/db/genbank/format_genbank'

    # EMBL format generater
    # Note that the name is 'Embl' and NOT 'EMBL'
    autoload :Embl, 'bio/db/embl/format_embl'

  end #module NucFormatter

  # Repository of protein sequence formatter classes
  module AminoFormatter
    # currently no formats available
  end #module AminoFormatter

  # Formatter base class.
  # Any formatter class should inherit this class.
  class FormatterBase

    # Returns a formatterd string of the given sequence
    # ---
    # *Arguments*:
    # * (required) _sequence_: Bio::Sequence object
    # * (optional) _options_: a Hash object
    # *Returns*:: String object
    def self.output(sequence, options = {})
      self.new(sequence, options).output
    end

    # register new Erb template
    def self.erb_template(str)
      erb = ERB.new(str)
      erb.def_method(self, 'output')
      true
    end
    private_class_method :erb_template

    # generates output data
    # ---
    # *Returns*:: String object
    def output
      raise NotImplementedError, 'should be implemented in subclass'
    end

    # creates a new formatter object for output
    def initialize(sequence, options = {})
      @sequence = sequence
      @options = options
    end

    private

    # any unknown methods are delegated to the sequence object
    def method_missing(sym, *args, &block) #:nodoc:
      begin
        @sequence.__send__(sym, *args, &block)
      rescue NoMethodError => evar
        lineno = __LINE__ - 2
        file = __FILE__
        bt_here = [ "#{file}:#{lineno}:in \`__send__\'",
                    "#{file}:#{lineno}:in \`method_missing\'"
                  ]
        if bt_here == evar.backtrace[0, 2] then
          bt = evar.backtrace[2..-1]
          evar = evar.class.new("undefined method \`#{sym.to_s}\' for #{self.inspect}")
          evar.set_backtrace(bt)
        end
        raise(evar)
      end
    end
  end #class FormatterBase

  # Using Bio::Sequence::Format, return a String with the Bio::Sequence
  # object formatted in the given style.
  #
  # Formats currently implemented are: 'fasta', 'genbank', and 'embl'
  #
  #   s = Bio::Sequence.new('atgc')
  #   puts s.output(:fasta)                   #=> "> \natgc\n"
  #
  # The style argument is given as a Ruby 
  # Symbol(http://www.ruby-doc.org/core/classes/Symbol.html)
  # ---
  # *Arguments*: 
  # * (required) _format_: :fasta, :genbank, *or* :embl
  # *Returns*:: String object
  def output(format = :fasta, options = {})
    formatter_const = format.to_s.capitalize.intern

    formatter_class = nil
    get_formatter_repositories.each do |mod|
      begin
        formatter_class = mod.const_get(formatter_const)
      rescue NameError
      end
      break if formatter_class
    end
    unless formatter_class then
      raise "unknown format name #{format.inspect}"
    end

    formatter_class.output(self, options)
  end

  # Returns a list of available output formats for the sequence
  # ---
  # *Arguments*: 
  # *Returns*:: Array of Symbols
  def list_output_formats
    a = get_formatter_repositories.collect { |mod| mod.constants }
    a.flatten!
    a.collect! { |x| x.to_s.downcase.intern }
    a
  end

  private

  # returns formatter repository modules
  def get_formatter_repositories
    if self.moltype == Bio::Sequence::NA then
      [ NucFormatter, Formatter ]
    elsif self.moltype == Bio::Sequence::AA then
      [ AminoFormatter, Formatter ]
    else
      [ NucFormatter, AminoFormatter, Formatter ]
    end
  end

  #---

  # Not yet implemented :)
  # Remove the nodoc command after implementation!
  # ---
  # *Returns*:: String object
  #def format_gff #:nodoc:
  #  raise NotImplementedError
  #end

  #+++

# Formatting helper methods for INSD (NCBI, EMBL, DDBJ) feature table
module INSDFeatureHelper
  private

  # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD. (And in any
  # case, it would be difficult to successfully call this method outside
  # its expected context).
  #
  # Output the Genbank feature format string of the sequence.
  # Used in Bio::Sequence#output.
  # ---
  # *Returns*:: String object
  def format_features_genbank(features)
    prefix = ' ' * 5
    indent = prefix + ' ' * 16
    fwidth = 79 - indent.length
  
    format_features(features, prefix, indent, fwidth)
  end

  # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD. (And in any
  # case, it would be difficult to successfully call this method outside
  # its expected context).
  #
  # Output the EMBL feature format string of the sequence.
  # Used in Bio::Sequence#output.
  # ---
  # *Returns*:: String object
  def format_features_embl(features)
    prefix = 'FT   '
    indent = prefix + ' ' * 16
    fwidth = 80 - indent.length
  
    format_features(features, prefix, indent, fwidth)
  end

  # format INSD featurs
  def format_features(features, prefix, indent, width)
    result = []
    features.each do |feature|
      result.push format_feature(feature, prefix, indent, width)
    end
    return result.join('')
  end

  # format an INSD feature
  def format_feature(feature, prefix, indent, width)
    result = prefix + sprintf("%-16s", feature.feature)

    position = feature.position
    #position = feature.locations.to_s

    result << wrap_and_split_lines(position, width).join("\n" + indent)
    result << "\n"
    result << format_qualifiers(feature.qualifiers, indent, width)
    return result
  end

  # format qualifiers
  def format_qualifiers(qualifiers, indent, width)
    qualifiers.collect do |qualifier|
      q = qualifier.qualifier
      v = qualifier.value.to_s

      if v == true
        lines = wrap_with_newline('/' + q, width)
      elsif q == 'translation'
        lines = fold("/#{q}=\"#{v}\"", width)
      else
        if v[/\D/] or q == 'chromosome'
          #v.delete!("\x00-\x1f\x7f-\xff")
          v.gsub!(/"/, '""')
          v = '"' + v + '"'
        end
        lines = wrap_with_newline('/' + q + '=' + v, width)
      end

      lines.gsub!(/^/, indent)
      lines
    end.join
  end

  def fold(str, width)
    str.gsub(Regexp.new("(.{1,#{width}})"), "\\1\n")
  end

  def fold_and_split_lines(str, width)
    str.scan(Regexp.new(".{1,#{width}}"))
  end

  def wrap_and_split_lines(str, width)
    result = []
    lefts = str.chomp.split(/(?:\r\n|\r|\n)/)
    lefts.each do |left|
      left.rstrip!
      while left and left.length > width
        line = nil
        width.downto(1) do |i|
          if left[i..i] == ' ' or /[\,\;]/ =~ left[(i-1)..(i-1)]  then
            line = left[0..(i-1)].sub(/ +\z/, '')
            left = left[i..-1].sub(/\A +/, '')
            break
          end
        end
        if line.nil? then
          line = left[0..(width-1)]
          left = left[width..-1]
        end
        result << line
        left = nil if  left.to_s.empty?
      end
      result << left if left
    end
    return result
  end

  def wrap_with_newline(str, width)
    result = wrap_and_split_lines(str, width)
    result_string = result.join("\n")
    result_string << "\n" unless result_string.empty?
    return result_string
  end

  def wrap(str, width = 80, prefix = '')
    actual_width = width - prefix.length
    result = wrap_and_split_lines(str, actual_width)
    result_string = result.join("\n#{prefix}")
    result_string = prefix + result_string unless result_string.empty?
    return result_string
  end

  #--
  # internal use only
  MonthStr = [ nil, 
               'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
               'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
             ].collect { |x| x.freeze }.freeze
  #++

  # formats a date from Date, DateTime, or Time object, or String.
  def format_date(d)
    begin
      yy = d.year
      mm = d.month
      dd = d.day
    rescue NoMethodError, NameError, ArgumentError, TypeError
      return sprintf("%-11s", d)
    end
    sprintf("%02d-%-3s-%04d", dd, MonthStr[mm], yy)
  end

  # null date
  def null_date
    Date.new(0, 1, 1)
  end

end #module INSDFeatureHelper

end #module Format

end #class Sequence

end #module Bio

