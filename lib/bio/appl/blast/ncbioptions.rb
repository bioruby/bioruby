#
# = bio/appl/blast/ncbioptions.rb - NCBI Tools-style options parser
#
# Copyright::  Copyright (C) 2008 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#
# == Description
#
# Bio::Blast::NCBIOptions is a class to parse and store NCBI Tools-style
# command-line options.
# It is internally used in Bio::Blast and some other classes.
#

require 'bio/appl/blast'
require 'shellwords'

class Bio::Blast

  # A class to parse and store NCBI-tools style command-line options.
  # It is internally used in Bio::Blast and some other classes.
  #
  class NCBIOptions

    # creates a new object from an array
    def initialize(options = [])
      #@option_pairs = []
      @option_pairs = _parse_options(options)
    end

    # (protected) option pairs. internal use only.
    attr_reader :option_pairs
    protected :option_pairs

    # (private) parse options from given array
    def _parse_options(options)
      i = 0
      pairs = []
      while i < options.size
        opt = options[i].to_s
        if m = /\A(\-.)/.match(opt) then
          key = m[1]
          if m.post_match.empty? then
            i += 1
            val = options.fetch(i) rescue ''
          else
            val = m.post_match
          end
          pairs.push([ key, val ])
        elsif '-' == opt then
          pairs.push [ opt ]
        else
          #warn "Arguments must start with \'-\'" if $VERBOSE
          pairs.push [ opt ]
        end
        i += 1
      end
      pairs
    end
    private :_parse_options

    # Normalize options.
    # For two or more same options (e.g. '-p blastn -p blastp'),
    # only the last option is used. (e.g. '-p blastp' for above example).
    # 
    # Note that completely illegal options are left untouched.
    #
    # ---
    # *Returns*:: self
    def normalize!
      hash = {}
      newpairs = []
      @option_pairs.reverse_each do |pair|
        if pair.size == 2 then
          key = pair[0]
          unless hash[key] then
            newpairs.push pair
            hash[key] = pair
          end
        else
          newpairs.push pair
        end
      end
      newpairs.reverse!
      @option_pairs = newpairs
      self
    end

    # current options as an array of strings
    def options
      @option_pairs.flatten
    end

    # parses a string and returns a new object
    def self.parse(str)
      options = Shellwords.shellwords(str)
      self.new(options)
    end

    # (private) key string to regexp
    def _key_to_regexp(key)
      key = key.sub(/\A\-/, '')
      Regexp.new('\A\-' + Regexp.escape(key) + '\z')
    end
    private :_key_to_regexp

    # Return the option.
    # ---
    # *Arguments*:
    # * _key_: option name as a string, e.g. 'm', 'p', or '-m', '-p'.
    # *Returns*:: String or nil
    def get(key)
      re = _key_to_regexp(key)

      # Note: the last option is used when two or more same option exist.
      value = nil
      @option_pairs.reverse_each do |pair|
        if re =~ pair[0] then
          value = pair[1]
          break
        end
      end
      return value
    end

    # Delete the given option.
    # ---
    # *Arguments*:
    # * _key_: option name as a string, e.g. 'm', 'p', or '-m', '-p'.
    # *Returns*:: String or nil
    def delete(key)
      re = _key_to_regexp(key)

      # Note: the last option is used for return value
      # when two or more same option exist.
      oldvalue = nil
      @option_pairs = @option_pairs.delete_if do |pair|
        if re =~ pair[0] then
          oldvalue = pair[1]
          true
        else
          false
        end
      end
      return oldvalue
    end

    # Sets the option to given value.
    #
    # For example, if you want to set '-p blastall' option,
    #   obj.set('p', 'blastall')
    # or
    #   obj.set('-p', 'blastall')
    # (above two are equivalent).
    #
    # ---
    # *Arguments*:
    # * _key_: option name as a string, e.g. 'm', 'p'.
    # * _value_: value as a string, e.g. '7', 'blastp'.
    # *Returns*:: previous value; String or nil
    def set(key, value)
      re = _key_to_regexp(key)
      oldvalue = nil
      flag = false
      # Note: only the last options is modified for multiple same options.
      @option_pairs.reverse_each do |pair|
        if re =~ pair[0] then
          oldvalue = pair[1]
          pair[1] = value
          flag = true
          break
        end
      end
      unless flag then
        key = "-#{key}" unless key[0, 1] == '-'
        @option_pairs.push([ key, value ])
      end
      oldvalue
    end

    # Adds options from given array.
    # Note that existing options will also be normalized.
    # ---
    # *Arguments*:
    # * _options_: options as an Array of String objects.
    # *Returns*:: self
    def add_options(options)
      @option_pairs.concat _parse_options(options)
      self.normalize!
      self
    end

    # If self == other, returns true. Otherwise, returns false.
    def ==(other)
      return true if super(other)
      begin
        oopts = other.options
      rescue
        return false
      end
      return self.options == oopts 
    end

    # Returns an array for command-line options.
    # prior_options are preferred to be used.
    def make_command_line_options(prior_options = [])
      newopts = self.class.new(self.options)
      #newopts.normalize!
      prior_pairs = _parse_options(prior_options)
      prior_pairs.each do |pair|
        newopts.delete(pair[0])
      end
      newopts.option_pairs[0, 0] = prior_pairs
      newopts.options
    end

  end #class NCBIOptions

end #class Bio::Blast
