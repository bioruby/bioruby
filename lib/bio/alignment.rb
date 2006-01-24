#
# = bio/alignment.rb - multiple alignment of sequences
#
# Copyright:: Copyright (C) 2003, 2005
#             GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
#
# License:: LGPL
#
#  $Id: alignment.rb,v 1.15 2006/01/24 14:16:59 ngoto Exp $
#
#--
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
#++
#
# = About Bio::Alignment
#
# Please refer document of Bio::Alignment module.
#
# = References
#
# * Bio::Align::AlignI class of the BioPerl.
# http://doc.bioperl.org/releases/bioperl-1.4/Bio/Align/AlignI.html
# 
# * Bio::SimpleAlign class of the BioPerl.
# http://doc.bioperl.org/releases/bioperl-1.4/Bio/SimpleAlign.html
#

require 'bio/sequence'

module Bio

=begin rdoc

= About Bio::Alignment

Bio::Alignment is a namespace of classes/modules for multiple sequence
alignment.

= Multiple alignment container classes

== Bio::Alignment::OriginalAlignment

== Bio::Alignment::SequenceArray

== Bio::Alignment::SequenceHash

= Bio::Alignment::Site

= Modules

== Bio::Alignment::EnumerableExtension

Mix-in for classes included Enumerable.

== Bio::Alignment::ArrayExtension

Mix-in for Array or Array-like classes.

== Bio::Alignment::HashExtension

Mix-in for Hash or Hash-like classes.

== Bio::Alignment::SiteMethods

== Bio::Alignment::PropertyMethods

= Bio::Alignment::GAP

= Compatibility from older BioRuby

=end
  module Alignment

    # Bio::Alignment::PropertyMethods is a set of methods to treat
    # the gap character and so on.
    module PropertyMethods
      # regular expression for detecting gaps.
      GAP_REGEXP   = /[^a-zA-Z]/
      # gap character
      GAP_CHAR     = '-'.freeze
      # missing character
      MISSING_CHAR = '?'.freeze

      # If given character is a gap, returns true.
      # Otherwise, return false.
      # Note that <em>s</em> must be a String which contain a single character.
      def is_gap?(s)
        (gap_regexp =~ s) ? true : false
      end

      # Returns regular expression for checking gap.
      def gap_regexp
        @gap_regexp or GAP_REGEXP
      end
      # regular expression for checking gap
      attr_writer :gap_regexp

      # Gap character.
      def gap_char
        @gap_char or GAP_CHAR
      end
      # gap character
      attr_writer :gap_char

      # Character if the site is missing or unknown.
      def missing_char
        @missing_char or MISSING_CHAR
      end
      # Character if the site is missing or unknown.
      attr_writer :missing_char

      # Returns class of the sequence.
      # If instance variable @seqclass (which can be
      # set by 'seqclass=' method) is set, simply returns the value.
      # Otherwise, returns the first sequence's class.
      # If no sequences are found, returns nil.
      def seqclass
        @seqclass or String
      end

      # The class of the sequence.
      # The value must be String or its derivatives.
      attr_writer :seqclass

      # Returns properties defined in the object as an hash.
      def get_all_property
        ret = {}
        if defined? @gap_regexp
          ret[:gap_regexp] = @gap_regexp
        end
        if defined? @gap_char
          ret[:gap_char] = @gap_char
        end
        if defined? @missing_char
          ret[:missing_char] = @missing_char
        end
        if defined? @seqclass
          ret[:seqclass] = @seqclass
        end
        ret
      end

      # Sets properties from given hash.
      # <em>hash</em> would be a return value of <tt>get_character</tt> method.
      def set_all_property(hash)
        @gap_regexp   = hash[:gap_regexp]   if hash.has_key?(:gap_regexp)
        @gap_char     = hash[:gap_char]     if hash.has_key?(:gap_char)
        @missing_char = hash[:missing_char] if hash.has_key?(:missing_char)
        @seqclass     = hash[:seqclass]     if hash.has_key?(:seqclass)
        self
      end
    end #module PropertyMethods

    # Bio::Alignment::SiteMethods is a set of methods for
    # Bio::Alignment::Site.
    # It can also be used for extending an array of single-letter strings.
    module SiteMethods
      include PropertyMethods

      # If there are gaps, returns true. Otherwise, returns false.
      def has_gap?
        (find { |x| is_gap?(x) }) ? true : false
      end

      # Removes gaps in the site. (destructive method)
      def remove_gaps!
        flag = nil
        self.collect! do |x|
          if is_gap?(x) then flag = self; nil; else x; end
        end
        self.compact!
        flag
      end

      # Returns consensus character of the site.
      # If consensus is found, eturns a single-letter string.
      # If not, returns nil.
      def consensus_string(threshold = 1.0)
        return nil if self.size <= 0
        return self[0] if self.sort.uniq.size == 1
        h = Hash.new(0)
        self.each { |x| h[x] += 1 }
        total = self.size
        b = h.to_a.sort do |x,y|
          z = (y[1] <=> x[1])
          z = (self.index(x[0]) <=> self.index(y[0])) if z == 0
          z
        end
        if total * threshold <= b[0][1] then
          b[0][0]
        else
          nil
        end
      end

      # IUPAC nucleotide groups. Internal use only.
      IUPAC_NUC = [
        %w( t           u ),
        %w( m   a c       ),
        %w( r   a   g     ),
        %w( w   a     t u ),
        %w( s     c g     ),
        %w( y     c   t u ),
        %w( k       g t u ),
        %w( v   a c g     m r   s     ),
        %w( h   a c   t u m   w   y   ),
        %w( d   a   g t u   r w     k ),
        %w( b     c g t u       s y k ),
        %w( n   a c g t u m r w s y k v h d b )
      ]

      # Returns an IUPAC consensus base for the site.
      # If consensus is found, eturns a single-letter string.
      # If not, returns nil.
      def consensus_iupac
        a = self.collect { |x| x.downcase }.sort.uniq
        if a.size == 1 then
          case a[0]
          when 'a', 'c', 'g', 't'
            a[0]
          when 'u'
            't'
          else
            IUPAC_NUC.find { |x| a[0] == x[0] } ? a[0] : nil
          end
        elsif r = IUPAC_NUC.find { |x| (a - x).size <= 0 } then
          r[0]
        else
          nil
        end
      end

      # Table of strongly conserved amino-acid groups.
      #
      # The value of the tables are taken from BioPerl
      # (Bio/SimpleAlign.pm in BioPerl 1.0),
      # and the BioPerl's document says that
      # it is taken from Clustalw documentation and
      #   These are all the positively scoring groups that occur in the 
      #   Gonnet Pam250 matrix. The strong and weak groups are 
      #   defined as strong score >0.5 and weak score =<0.5 respectively.
      #
      StrongConservationGroups = %w(STA NEQK NHQK NDEQ QHRK MILV MILF
            HY FYW).collect { |x| x.split('').sort }

      # Table of weakly conserved amino-acid groups.
      #
      # Please refer StrongConservationGroups document
      # for the origin of the table.
      WeakConservationGroups = %w(CSA ATV SAG STNK STPA SGND SNDEQK
            NDEQHK NEQHRK FVLIM HFY).collect { |x| x.split('').sort }

      # Returns the match-line character for the site.
      # This is amino-acid version.
      def match_line_amino(opt = {})
        # opt[:match_line_char]   ==> 100% equal    default: '*'
        # opt[:strong_match_char] ==> strong match  default: ':'
        # opt[:weak_match_char]   ==> weak match    default: '.'
        # opt[:mismatch_char]     ==> mismatch      default: ' '
        mlc = (opt[:match_line_char]   or '*')
        smc = (opt[:strong_match_char] or ':')
        wmc = (opt[:weak_match_char]   or '.')
        mmc = (opt[:mismatch_char]     or ' ')
        a = self.collect { |c| c.upcase }.sort.uniq
        a.extend(SiteMethods)
        if a.has_gap? then
          mmc
        elsif a.size == 1 then
          mlc
        elsif StrongConservationGroups.find { |x| (a - x).empty? } then
          smc
        elsif WeakConservationGroups.find { |x| (a - x).empty? } then
          wmc
        else
          mmc
        end
      end

      # Returns the match-line character for the site.
      # This is nucleic-acid version.
      def match_line_nuc(opt = {})
        # opt[:match_line_char]   ==> 100% equal    default: '*'
        # opt[:mismatch_char]     ==> mismatch      default: ' '
        mlc = (opt[:match_line_char]   or '*')
        mmc = (opt[:mismatch_char]     or ' ')
        a = self.collect { |c| c.upcase }.sort.uniq
        a.extend(SiteMethods)
        if a.has_gap? then
          mmc
        elsif a.size == 1 then
          mlc
        else
          mmc
        end
      end
    end #module SiteMethods

    # Bio::Alignment::Site stores bases or amino-acids in a 
    # site of the alignment.
    # It would store multiple String objects of length 1.
    # Please refer to the document of Array and SiteMethods for methods.
    class Site < Array
      include SiteMethods
    end #module Site

    # The module Bio::Alignment::EnumerableExtension is a set of useful
    # methods for multiple sequence alignment.
    # It can be included by any classes or can be extended to any objects.
    # The classes or objects must have methods defined in Enumerable,
    # and must have the <tt>each</tt> method 
    # which iterates over each sequence (or string) and yields
    # a sequence (or string) object.
    # 
    # Optionally, if <tt>each_seq</tt> method is defined,
    # which iterates over each sequence (or string) and yields
    # each sequence (or string) object, it is used instead of <tt>each</tt>.
    #
    # Note that the <tt>each</tt> or <tt>each_seq</tt> method would be
    # called multiple times.
    # This means that the module is not suitable for IO objects.
    # In addition, <tt>break</tt> would be used in the given block and
    # destructive methods would be used to the sequences.
    #
    # For Array or Hash objects, you'd better using
    # ArrayExtension or HashExtension modules, respectively.
    # They would have built-in <tt>each_seq</tt> method and/or
    # some methods would be redefined.
    #
    module EnumerableExtension
      include PropertyMethods

      # Iterates over each sequences.
      # Yields a sequence.
      # It acts the same as Enumerable#each.
      #
      # You would redefine the method suitable for the class/object.
      def each_seq(&block) #:yields: seq
        each(&block)
      end

      # Returns class of the sequence.
      # If instance variable @seqclass (which can be
      # set by 'seqclass=' method) is set, simply returns the value.
      # Otherwise, returns the first sequence's class.
      # If no sequences are found, returns nil.
      def seqclass
        if @seqclass then
          @seqclass
        else
          klass = nil
          each_seq do |s|
            if s then
              klass = s.class
              break if klass
            end
          end
          (klass or String)
        end
      end

      # Returns the alignment length.
      # Returns the longest length of the sequence in the alignment.
      def alignment_length
        maxlen = 0
        each_seq do |s|
          x = s.length
          maxlen = x if x > maxlen
        end
        maxlen
      end
      alias seq_length alignment_length

      # Gets a site of the position.
      # Returns a Bio::Alignment::Site object.
      # 
      # If the position is out of range, it returns the site
      # of which all are gaps.
      #
      # It is a private method.
      # Only difference from public alignment_site method is
      # it does not do <tt>set_all_property(get_all_property)</tt>.
      def _alignment_site(position)
        site = Site.new
        each_seq do |s|
          c = s[position, 1]
          if c.to_s.empty?
            c = seqclass.new(gap_char)
          end
          site << c
        end
        site
      end
      private :_alignment_site

      # Gets a site of the position.
      # Returns a Bio::Alignment::Site object.
      # 
      # If the position is out of range, it returns the site
      # of which all are gaps.
      def alignment_site(position)
        site = _alignment_site(position)
        site.set_all_property(get_all_property)
        site
      end

      # Iterates over each site of the alignment.
      # It yields a Bio::Alignment::Site object (which inherits Array).
      # It returns self.
      def each_site
        cp = get_all_property
        (0...alignment_length).each do |i|
          site = _alignment_site(i)
          site.set_all_property(cp)
          yield(site)
        end
        self
      end

      # Iterates over each site of the alignment, with specifying
      # start, stop positions and step.
      # It yields Bio::Alignment::Site object (which inherits Array).
      # It returns self.
      # It is same as
      # <tt>start.step(stop, step) { |i| yield alignment_site(i) }</tt>.
      def each_site_step(start, stop, step = 1)
        cp = get_all_property
        start.step(stop, step) do |i|
          site = _alignment_site(i)
          site.set_all_property(cp)
          yield(site)
        end
        self
      end

      # Iterates over each sequence and results running blocks
      # are collected and returns a new alignment as a
      # Bio::Alignment::SequenceArray object.
      #
      # Note that it would be redefined if you want to change
      # return value's class.
      #
      def alignment_collect
        a = SequenceArray.new
        a.set_all_property(get_all_property)
        each_seq do |str|
          a << yield(str)
        end
        a
      end

      # Returns specified range of the alignment.
      # For each sequence, the '[]' method (it may be String#[])
      # is executed, and returns a new alignment
      # as a Bio::Alignment::SequenceArray object.
      #
      # Unlike alignment_slice method, the result alignment are
      # guaranteed to contain String object if the range specified
      # is out of range.
      #
      # If you want to change return value's class, you should redefine
      # alignment_collect method.
      #
      def alignment_window(*arg)
        alignment_collect do |s|
          s[*arg] or seqclass.new('')
        end
      end
      alias window alignment_window

      # Iterates over each sliding window of the alignment.
      # window_size is the size of sliding window.
      # step is the step of each sliding.
      # It yields a Bio::Alignment::SequenceArray object which contains
      # each sliding window.
      # It returns a Bio::Alignment::SequenceArray object which contains
      # remainder alignment at the terminal end.
      # If window_size is smaller than 0, it returns nil.
      def each_window(window_size, step_size = 1)
        return nil if window_size < 0
        if step_size >= 0 then
          i = nil
          0.step(alignment_length - window_size, step_size) do |i|
            yield alignment_window(i, window_size)
          end
          alignment_window((i+window_size)..-1)
        else
          i = alignment_length - window_size
          while i >= 0
            yield alignment_window(i, window_size)
            i += step_size
          end
          alignment_window(0...(i-step_size))
        end
      end

      # Iterates over each site of the alignment and results running the
      # block are collected and returns an array.
      # It yields a Bio::Alignment::Site object.
      def collect_each_site
        ary = []
        each_site do |site|
          ary << yield(site)
        end
        ary
      end

      # Helper method for calculating consensus sequence.
      # It iterates over each site of the alignment.
      # In each site, gaps will be removed if specified with opt.
      # It yields a Bio::Alignment::Site object.
      # Results running the block (String objects are expected)
      # are joined to a string and it returns the string.
      #
      #  opt[:gap_mode] ==> 0 -- gaps are regarded as normal characters
      #                     1 -- a site within gaps is regarded as a gap
      #                    -1 -- gaps are eliminated from consensus calculation
      #      default: 0
      #
      def consensus_each_site(opt = {})
        mchar = (opt[:missing_char] or self.missing_char)
        gap_mode = opt[:gap_mode]
        case gap_mode
        when 0, nil
          collect_each_site do |a|
            yield(a) or mchar
          end.join('')
        when 1
          collect_each_site do |a|
            a.has_gap? ? gap_char : (yield(a) or mchar)
          end.join('')
        when -1
          collect_each_site do |a|
            a.remove_gaps!
            a.empty? ? gap_char : (yield(a) or mchar)
          end.join('')
        else
          raise ':gap_mode must be 0, 1 or -1'
        end
      end

      # Returns the consensus string of the alignment.
      # 0.0 <= threshold <= 1.0 is expected.
      #
      # It resembles the BioPerl's AlignI::consensus_string method.
      #
      # Please refer to the consensus_each_site method for opt.
      #
      def consensus_string(threshold = 1.0, opt = {})
        consensus_each_site(opt) do |a|
          a.consensus_string(threshold)
        end
      end

      # Returns the IUPAC consensus string of the alignment
      # of nucleic-acid sequences.
      #
      # It resembles the BioPerl's AlignI::consensus_iupac method.
      #
      # Please refer to the consensus_each_site method for opt.
      #
      def consensus_iupac(opt = {})
        consensus_each_site(opt) do |a|
          a.consensus_iupac
        end
      end

      # Returns the match line stirng of the alignment
      # of amino-acid sequences.
      # 
      # It resembles the BioPerl's AlignI::match_line method.
      #
      #   opt[:match_line_char]   ==> 100% equal    default: '*'
      #   opt[:strong_match_char] ==> strong match  default: ':'
      #   opt[:weak_match_char]   ==> weak match    default: '.'
      #   opt[:mismatch_char]     ==> mismatch      default: ' '
      #
      # More opt can be accepted.
      # Please refer to the consensus_each_site method for opt.
      #
      def match_line_amino(opt = {})
        collect_each_site do |a|
          a.match_line_amino(opt)
        end.join('')
      end

      # Returns the match line stirng of the alignment
      # of nucleic-acid sequences.
      # 
      # It resembles the BioPerl's AlignI::match_line method.
      #
      #   opt[:match_line_char]   ==> 100% equal    default: '*'
      #   opt[:mismatch_char]     ==> mismatch      default: ' '
      #
      # More opt can be accepted.
      # Please refer to the consensus_each_site method for opt.
      #
      def match_line_nuc(opt = {})
        collect_each_site do |a|
          a.match_line_nuc(opt)
        end.join('')
      end

      # Returns the match line stirng of the alignment
      # of nucleic- or amino-acid sequences.
      # The type of the sequence is automatically determined
      # or you can specify with opt[:type].
      #
      # It resembles the BioPerl's AlignI::match_line method.
      #
      #   opt[:type] ==> :na or :aa (or determined by sequence class)
      #   opt[:match_line_char]   ==> 100% equal    default: '*'
      #   opt[:strong_match_char] ==> strong match  default: ':'
      #   opt[:weak_match_char]   ==> weak match    default: '.'
      #   opt[:mismatch_char]     ==> mismatch      default: ' '
      #     :strong_ and :weak_match_char are used only in amino mode (:aa)
      # 
      # More opt can be accepted.
      # Please refer to the consensus_each_site method for opt.
      #
      def match_line(opt = {})
        case opt[:type]
        when :aa
          amino = true
        when :na, :dna, :rna
          amino = false
        else
          if seqclass == Bio::Sequence::AA then
            amino = true
          elsif seqclass == Bio::Sequence::NA then
            amino = false
          elsif self.find { |x| /[EFILPQ]/i =~ x } then
            amino = true
          else
            amino = nil
          end
        end
        if amino then
          match_line_amino(opt)
        else
          match_line_nuc(opt)
        end
      end

      # This is the BioPerl's AlignI::match like method.
      #
      # Changes second to last sequences' sites to match_char(default: '.')
      # when a site is equeal to the first sequence's corresponding site.
      #
      # Note that it is a destructive method.
      #
      # For Hash, please use it carefully because
      # the order of the sequences is inconstant.
      #
      def convert_match(match_char = '.')
        #(BioPerl) AlignI::match like method
        len = alignment_length
        firstseq = nil
        each_seq do |s|
          unless firstseq then
            firstseq = s
          else
            (0...len).each do |i|
              if s[i] and firstseq[i] == s[i] and !is_gap?(firstseq[i..i])
                s[i..i] = match_char
              end
            end
          end
        end
        self
      end

      # This is the BioPerl's AlignI::unmatch like method.
      #
      # Changes second to last sequences' sites match_char(default: '.')
      # to original sites' characters.
      #
      # Note that it is a destructive method.
      #
      # For Hash, please use it carefully because
      # the order of the sequences is inconstant.
      #
      def convert_unmatch(match_char = '.')
        #(BioPerl) AlignI::unmatch like method
        len = alignment_length
        firstseq = nil
        each_seq do |s|
          unless firstseq then
            firstseq = s
          else
            (0...len).each do |i|
              if s[i..i] == match_char then
                s[i..i] = (firstseq[i..i] or match_char)
              end
            end
          end
        end
        self
      end

      # Fills gaps to the tail of each sequence if the length of
      # the sequence is shorter than the alignment length.
      #
      # Note that it is a destructive method.
      def alignment_normalize!
        #(original)
        len = alignment_length
        each_seq do |s|
          s << (gap_char * (len - s.length)) if s.length < len
        end
        self
      end
      alias normalize! alignment_normalize!

      # Removes excess gaps in the tail of the sequences.
      # If removes nothing, returns nil.
      # Otherwise, returns self.
      #
      # Note that it is a destructive method.
      def alignment_rstrip!
        #(String-like)
        len = alignment_length
        newlen = len
        each_site_step(len - 1, 0, -1) do |a|
          a.remove_gaps!
          if a.empty? then
            newlen -= 1
          else
            break
          end
        end
        return nil if newlen >= len
        each_seq do |s|
          s[newlen..-1] = '' if s.length > newlen
        end
        self
      end
      alias rstrip! alignment_rstrip!

      # Removes excess gaps in the head of the sequences.
      # If removes nothing, returns nil.
      # Otherwise, returns self.
      #
      # Note that it is a destructive method.
      def alignment_lstrip!
        #(String-like)
        pos = 0
        each_site do |a|
          a.remove_gaps!
          if a.empty?
            pos += 1
          else
            break
          end
        end
        return nil if pos <= 0
        each_seq { |s| s[0, pos] = '' }
        self
      end
      alias lstrip! alignment_lstrip!

      # Removes excess gaps in the sequences.
      # If removes nothing, returns nil.
      # Otherwise, returns self.
      #
      # Note that it is a destructive method.
      def alignment_strip!
        #(String-like)
        r = alignment_rstrip!
        l = alignment_lstrip!
        (r or l)
      end
      alias strip! alignment_strip!

      # Completely removes ALL gaps in the sequences.
      # If removes nothing, returns nil.
      # Otherwise, returns self.
      #
      # Note that it is a destructive method.
      def remove_all_gaps!
        ret = nil
        each_seq do |s|
          x = s.gsub!(gap_regexp, '')
          ret ||= x
        end
        ret ? self : nil
      end

      # Returns the specified range of the alignment.
      # For each sequence, the 'slice' method (it may be String#slice,
      # which is the same as String#[]) is executed, and
      # returns a new alignment as a Bio::Alignment::SequenceArray object.
      #
      # Unlike alignment_window method, the result alignment
      # might contain nil.
      #
      # If you want to change return value's class, you should redefine
      # alignment_collect method.
      #
      def alignment_slice(*arg)
        #(String-like)
        #(BioPerl) AlignI::slice like method
        alignment_collect do |s|
          s.slice(*arg)
        end
      end
      alias slice alignment_slice

      # For each sequence, the 'subseq' method (Bio::Seqeunce::Common#subseq is
      # expected) is executed, and returns a new alignment as
      # a Bio::Alignment::SequenceArray object.
      #
      # All sequences in the alignment are expected to be kind of
      # Bio::Sequence::NA or Bio::Sequence::AA objects.
      #
      # Unlike alignment_window method, the result alignment
      # might contain nil.
      #
      # If you want to change return value's class, you should redefine
      # alignment_collect method.
      #
      def alignment_subseq(*arg)
        #(original)
        alignment_collect do |s|
          s.subseq(*arg)
        end
      end
      alias subseq alignment_subseq

      # Concatenates the given alignment.
      # <em>align</em> must have <tt>each_seq</tt>
      # or <tt>each</tt> method.
      # 
      # Returns self.
      #
      # Note that it is a destructive method.
      #
      # For Hash, please use it carefully because
      # the order of the sequences is inconstant and
      # key information is completely ignored.
      #
      def alignment_concat(align)
        flag = nil
        a = []
        each_seq { |s| a << s }
        i = 0
        begin
          align.each_seq do |seq|
            flag = true
            a[i].concat(seq) if a[i] and seq
            i += 1
          end
          return self
        rescue NoMethodError, ArgumentError => evar
          raise evar if flag
        end
        align.each do |seq|
          a[i].concat(seq) if a[i] and seq
          i += 1
        end
        self
      end
    end #module EnumerableExtension

    # ClustalWFormatter is a module to create ClustalW-formatted text
    # from an alignment object.
    #
    # It will be obsoleted and the methods will be frequently changed.
    module ClustalWFormatter
      # Check whether there are same names.
      #
      # array:: names of the sequences (array of string)
      # len::   length to check (default:30)
      def have_same_name?(array, len = 30)
        na30 = array.collect do |k|
          k.to_s.split(/[\x00\s]/)[0].to_s[0, len].gsub(/\:\;\,\(\)/, '_').to_s
        end
        #p na30
        na30idx = (0...(na30.size)).to_a
        na30idx.sort! do |x,y|
          na30[x] <=> na30[y]
        end
        #p na30idx
        y = nil
        dupidx = []
        na30idx.each do |x|
          if y and na30[y] == na30[x] then
            dupidx << y
            dupidx << x
          end
          y = x
        end
        if dupidx.size > 0 then
          dupidx.sort!
          dupidx.uniq!
          dupidx
        else
          false
        end
      end
      private :have_same_name?

      # Changes sequence names if there are conflicted names.
      #
      # array:: names of the sequences (array of string)
      # len::   length to check (default:30)
      def avoid_same_name(array, len = 30)
        na = array.collect { |k| k.to_s.gsub(/[\r\n\x00]/, ' ') }
        if dupidx = have_same_name?(na, len)
          procs = [
            Proc.new { |s, i|
              s[0, len].to_s.gsub(/\s/, '_') + s[len..-1].to_s
            },
            # Proc.new { |s, i|
            #   "#{i}_#{s}"
            # },
          ]
          procs.each do |pr|
            dupidx.each do |i|
              s = array[i]
              na[i] = pr.call(s.to_s, i)
            end
            dupidx = have_same_name?(na, len)
            break unless dupidx
          end
          if dupidx then
            na.each_with_index do |s, i|
              na[i] = "#{i}_#{s}"
            end
          end
        end
        na
      end
      private :avoid_same_name

      # Generates ClustalW-formatted text
      # seqs:: sequences (must be an alignment object)
      # names:: names of the sequences
      # options:: options
      def clustalw_formatter(seqs, names, options = {})
        #(original)
        aln = [ "CLUSTAL   (0.00) multiple sequence alignment\n\n" ]
        len = seqs.seq_length
        sn = names.collect { |x| x.to_s.gsub(/[\r\n\x00]/, ' ') }
        if options[:replace_space]
          sn.collect! { |x| x.gsub(/\s/, '_') }
        end
        if !options.has_key?(:escape) or options[:escape]
          sn.collect! { |x| x.gsub(/[\:\;\,\(\)]/, '_') }
        end
        if !options.has_key?(:split) or options[:split]
          sn.collect! { |x| x.split(/\s/)[0].to_s }
        end
        if !options.has_key?(:avoid_same_name) or options[:avoid_same_name]
          sn = avoid_same_name(sn)
        end
        
        if sn.find { |x| x.length > 10 } then
          seqwidth = 50
          namewidth = 30
          sep = ' ' * 6
        else
          seqwidth = 60
          namewidth = 10
          sep = ' ' * 6
        end
        seqregexp = Regexp.new("(.{1,#{seqwidth}})")
        gchar = (options[:gap_char] or '-')

        case options[:type].to_s
        when /protein/i, /aa/i
          mopt = { :type => :aa }
        when /na/i
          mopt = { :type => :na }
        else
          mopt = {}
        end
        mline = (options[:match_line] or seqs.match_line(mopt))
        
        aseqs = seqs.collect do |s|
          s.to_s.gsub(seqs.gap_regexp, gchar)
        end
        case options[:case].to_s
        when /lower/i
          aseqs.each { |s| s.downcase! }
        when /upper/i
          aseqs.each { |s| s.upcase! }
        end
        
        aseqs << mline
        aseqs.collect! do |s|
          snx = sn.shift
          head = sprintf("%*s", -namewidth, snx.to_s)[0, namewidth] + sep
          s << (gchar * (len - s.length))
          s.gsub!(seqregexp, "\\1\n")
          a = s.split(/^/)
          if options[:seqnos] and snx then
            i = 0
            a.each do |x|
              x.chomp!
              l = x.tr(gchar, '').length
              i += l
              x.concat(l > 0 ? " #{i}\n" : "\n")
            end
          end
          a.collect { |x| head + x }
        end
        lines = (len + seqwidth - 1).div(seqwidth)
        lines.times do
          aln << "\n"
          aseqs.each { |a| aln << a.shift }
        end
        aln.join('')
      end
      private :clustalw_formatter
    end #module ClustalWFormatter


    # Bio::Alignment::ArrayExtension is a set of useful methods for
    # multiple sequence alignment.
    # It is designed to be extended to array objects or
    # included in your own classes which inherit Array.
    # (It can also be included in Array, though not recommended.)
    #
    # It possesses all methods defined in EnumerableExtension.
    # For usage of methods, please refer to EnumerableExtension.
    module ArrayExtension
      include EnumerableExtension

      # Iterates over each sequences.
      # Yields a sequence.
      #
      # It works the same as Array#each.
      def each_seq(&block) #:yields: seq
        each(&block)
      end

      include ClustalWFormatter
      # Returns a string of Clustal W formatted text of the alignment.
      def to_clustal(options = {})
        clustalw_formatter(self, (0...(self.size)).to_a, options)
      end
    end #module ArrayExtension

    # Bio::Alignment::HashExtension is a set of useful methods for
    # multiple sequence alignment.
    # It is designed to be extended to hash objects or
    # included in your own classes which inherit Hash.
    # (It can also be included in Hash, though not recommended.)
    #
    # It possesses all methods defined in EnumerableExtension.
    # For usage of methods, please refer to EnumerableExtension.
    #
    # Because SequenceHash#alignment_collect is redefined,
    # some methods' return value's class are changed to
    # SequenceHash instead of SequenceArray.
    #
    # Because the order of the objects in a hash is inconstant,
    # some methods strictly affected with the order of objects
    # might not work correctly,
    # e.g. EnumerableExtension#convert_match and #convert_unmatch.
    module HashExtension
      include EnumerableExtension

      # Iterates over each sequences.
      # Yields a sequence.
      #
      # It works the same as Hash#each_value.
      def each_seq(&block) #:yields: seq
        each_value(&block)
      end

      # Iterates over each sequence and each results running block
      # are collected and returns a new alignment as a
      # Bio::Alignment::SequenceHash object.
      #
      # Note that it would be redefined if you want to change
      # return value's class.
      #
      def alignment_collect
        a = SequenceHash.new
        a.set_all_property(get_all_property)
        each_pair do |key, str|
          a.store(key, yield(str))
        end
        a
      end

      # Concatenates the given alignment.
      # If <em>align</em> is a Hash (or SequenceHash),
      # sequences of same keys are concatenated.
      # Otherwise, <em>align</em> must have <tt>each_seq</tt>
      # or <tt>each</tt> method and
      # works same as EnumerableExtension#alignment_concat.
      # 
      # Returns self.
      #
      # Note that it is a destructive method.
      #
      def alignment_concat(align)
        flag = nil
        begin
          align.each_pair do |key, seq|
            flag = true
            if origseq = self[key]
              origseq.concat(seq)
            end
          end
          return self
        rescue NoMethodError, ArgumentError =>evar
          raise evar if flag
        end
        a = values
        i = 0
        begin
          align.each_seq do |seq|
            flag = true
            a[i].concat(seq) if a[i] and seq
            i += 1
          end
          return self
        rescue NoMethodError, ArgumentError => evar
          raise evar if flag
        end
        align.each do |seq|
          a[i].concat(seq) if a[i] and seq
          i += 1
        end
        self
      end

      include ClustalWFormatter
      # Returns a string of Clustal W formatted text of the alignment.
      def to_clustal(options = {})
        seqs = SequenceArray.new
        names = self.keys
        names.each do |k|
          seqs << self[k]
        end
        clustalw_formatter(seqs, names, options)
      end
    end #module HashExtension

    # Bio::Alignment::SequenceArray is a container class of
    # multiple sequence alignment.
    # Since it inherits Array, it acts completely same as Array.
    # In addition, methods defined in ArrayExtension and EnumerableExtension
    # can be used.
    class SequenceArray < Array
      include ArrayExtension
    end #class SequenceArray

    # Bio::Alignment::SequenceHash is a container class of
    # multiple sequence alignment.
    # Since it inherits Hash, it acts completely same as Hash.
    # In addition, methods defined in HashExtension and EnumerableExtension
    # can be used.
    class SequenceHash < Hash
      include HashExtension
    end #class SequenceHash

    # Bio::Alignment::OriginalPrivate is a set of private methods
    # for Bio::Alignment::OriginalAlignment.
    module OriginalPrivate

      # Gets the sequence from given object.
      def extract_seq(obj)
        seq = nil
        if obj.is_a?(Bio::Sequence::NA) or obj.is_a?(Bio::Sequence::AA) then
          seq = obj
        else
          for m in [ :seq, :naseq, :aaseq ]
            begin
              seq = obj.send(m)
            rescue NameError, ArgumentError
              seq = nil
            end
            break if seq
          end
          seq = obj unless seq
        end
        seq
      end
      module_function :extract_seq

      # Gets the name or the definition of the sequence from given object.
      def extract_key(obj)
        sn = nil
        for m in [ :definition, :entry_id ]
          begin
            sn = obj.send(m)
          rescue NameError, ArgumentError
            sn = nil
          end
          break if sn
        end
        sn
      end
      module_function :extract_key
    end #module OriginalPrivate

    # Bio::Alignment::OriginalAlignment is
    # the BioRuby original multiple sequence alignment container class.
    # It includes HashExtension.
    #
    # It is recommended only to use methods defined in EnumerableExtension
    # (and the each_seq method).
    # The method only defined in this class might be obsoleted in the future.
    #
    class OriginalAlignment

      include Enumerable
      include HashExtension
      include OriginalPrivate

      # Read files and creates a new alignment object.
      #
      # It will be obsoleted.
      def self.readfiles(*files)
        require 'bio/io/flatfile'
        aln = self.new
        files.each do |fn|
          Bio::FlatFile.open(nil, fn) do |ff|
            aln.add_sequences(ff)
          end
        end
        aln
      end
      
      # Creates a new alignment object from given arguments.
      #
      # It will be obsoleted.
      def self.new2(*arg)
        self.new(arg)
      end

      # Creates a new alignment object.
      # <em>seqs</em> may be one of follows:
      # an array of sequences (or strings),
      # an array of sequence database objects,
      # an alignment object.
      def initialize(seqs = [])
        @seqs = {}
        @keys = []
        self.add_sequences(seqs)
      end

      # If <em>x</em> is the same value, returns true.
      # Otherwise, returns false.
      def ==(x)
        #(original)
        if x.is_a?(self.class)
          self.to_hash == x.to_hash
        else
          false
        end
      end
      
      # convert to hash
      def to_hash
        #(Hash-like)
        @seqs
      end

      # Adds sequences to the alignment. 
      # <em>seqs</em> may be one of follows:
      # an array of sequences (or strings),
      # an array of sequence database objects,
      # an alignment object.
      def add_sequences(seqs)
        if block_given? then
          seqs.each do |x|
            s, key = yield x
            self.store(key, s)
          end
        else
          if seqs.is_a?(self.class) then
            seqs.each_pair do |k, s|
              self.store(k, s)
            end
          elsif seqs.respond_to?(:each_pair)
            seqs.each_pair do |k, x|
              s = extract_seq(x)
              self.store(k, s)
            end
          else
            seqs.each do |x|
              s = extract_seq(x)
              k = extract_key(x)
              self.store(k, s)
            end
          end
        end
        self
      end

      # identifiers (or definitions or names) of the sequences
      attr_reader :keys

      # stores a sequences with the name
      # key:: name of the sequence
      # seq:: sequence
      def __store__(key, seq)
        #(Hash-like)
        h = { key => seq }
        @keys << h.keys[0]
        @seqs.update(h)
        seq
      end

      # stores a sequence with <em>key</em>
      # (name or definition of the sequence).
      # Unlike <tt>__store__</tt> method, the method doesn't allow
      # same keys.
      # If the key is already used, returns nil.
      # When succeeded, returns key.
      def store(key, seq)
        #(Hash-like) returns key instead of seq
        if @seqs.has_key?(key) then
          # don't allow same key
          # New key is discarded, while existing key is preserved.
          key = nil
        end
        unless key then
          unless defined?(@serial)
            @serial = 0
          end
          @serial = @seqs.size if @seqs.size > @serial
          while @seqs.has_key?(@serial)
            @serial += 1
          end
          key = @serial
        end
        self.__store__(key, seq)
        key
      end

      # Reconstructs internal data structure.
      # (Like Hash#rehash)
      def rehash
        @seqs.rehash
        oldkeys = @keys
        tmpkeys = @seqs.keys
        @keys.collect! do |k|
          tmpkeys.delete(k)
        end
        @keys.compact!
        @keys.concat(tmpkeys)
        self
      end

      # Prepends seq (with key) to the front of the alignment.
      # (Like Array#unshift)
      def unshift(key, seq)
        #(Array-like)
        self.store(key, seq)
        k = @keys.pop
        @keys.unshift(k)
        k
      end

      # Removes the first sequence in the alignment and
      # returns [ key, seq ].
      def shift
        k = @keys.shift
        if k then
          s = @seqs.delete(k)
          [ k, s ]
        else
          nil
        end
      end

      # Gets the <em>n</em>-th sequence.
      # If not found, returns nil.
      def order(n)
        #(original)
        @seqs[@keys[n]]
      end

      # Removes the sequence whose key is <em>key</em>.
      # Returns the removed sequence.
      # If not found, returns nil.
      def delete(key)
        #(Hash-like)
        @keys.delete(key)
        @seqs.delete(key)
      end

      # Returns sequences. (Like Hash#values)
      def values
        #(Hash-like)
        @keys.collect { |k| @seqs[k] }
      end

      # Adds a sequence without key.
      # The key is automatically determined.
      def <<(seq)
        #(Array-like)
        self.store(nil, seq)
        self
      end

      # Gets a sequence. (Like Hash#[])
      def [](*arg)
        #(Hash-like)
        @seqs[*arg]
      end

      # Number of sequences in the alignment.
      def size
        #(Hash&Array-like)
        @seqs.size
      end

      # If the key exists, returns true. Otherwise, returns false.
      # (Like Hash#has_key?)
      def has_key?(key)
        #(Hash-like)
        @seqs.has_key?(key)
      end

      # Iterates over each sequence.
      # (Like Array#each)
      def each
        #(Array-like)
        @keys.each do |k|
          yield @seqs[k]
        end
      end
      alias each_seq each

      # Iterates over each key and sequence.
      # (Like Hash#each_pair)
      def each_pair
        #(Hash-like)
        @keys.each do |k|
          yield k, @seqs[k]
        end
      end

      # Iterates over each sequence, replacing the sequence with the
      # value returned by the block.
      def collect!
        #(Array-like)
        @keys.each do |k|
          @seqs[k] = yield @seqs[k]
        end
      end

      ###--
      ### note that 'collect' and 'to_a' is defined in Enumerable
      ###
      ### instance-variable-related methods
      ###++

      # Creates new alignment. Internal use only.
      def new(*arg)
        na = self.class.new(*arg)
        na.set_all_property(get_all_property)
        na
      end
      protected :new

      # Duplicates the alignment
      def dup
        #(Hash-like)
        self.new(self)
      end

      #--
      # methods below should not access instance variables
      #++

      # Merges given alignment and returns a new alignment.
      def merge(*other)
        #(Hash-like)
        na = self.new(self)
        na.merge!(*other)
        na
      end

      # Merge given alignment.
      # Note that it is destructive method.
      def merge!(*other)
        #(Hash-like)
        if block_given? then
          other.each do |aln|
            aln.each_pair do |k, s|
              if self.has_key?(k) then
                s = yield k, self[k], s
                self.to_hash.store(k, s)
              else
                self.store(k, s)
              end
            end
          end
        else
          other.each do |aln|
            aln.each_pair do |k, s|
              self.delete(k) if self.has_key?(k)
              self.store(k, s)
            end
          end
        end
        self
      end

      # Returns the key for a given sequence. If not found, returns nil.
      def index(seq)
        #(Hash-like)
        k = nil
        self.each_pair do |k, s|
          if s.class == seq.class then
            r = (s == seq)
          else
            r = (s.to_s == seq.to_s)
          end
          break if r
        end
        k
      end

      # Sequences in the alignment are duplicated.
      # If keys are given to the argument, sequences of given keys are
      # duplicated.
      #
      # It will be obsoleted.
      def isolate(*arg)
        #(original)
        if arg.size == 0 then
          self.collect! do |s|
            seqclass.new(s)
          end
        else
          arg.each do |k|
            if self.has_key?(k) then
              s = self.delete(key)
              self.store(k, seqclass.new(s))
            end
          end
        end
        self
      end

      # Iterates over each sequence and each results running block
      # are collected and returns a new alignment.
      #
      # The method name 'collect_align' will be obsoleted.
      # Please use 'alignment_collect' instead.
      def alignment_collect
        #(original)
        na = self.class.new
        na.set_all_property(get_all_property)
        self.each_pair do |k, s|
          na.store(k, yield(s))
        end
        na
      end
      alias collect_align alignment_collect

      # Removes empty sequences or nil in the alignment.
      # (Like Array#compact!)
      def compact!
        #(Array-like)
        d = []
        self.each_pair do |k, s|
          if !s or s.empty?
            d << k
          end
        end
        d.each do |k|
          self.delete(k)
        end
        d.empty? ? nil : d
      end

      # Removes empty sequences or nil and returns new alignment.
      # (Like Array#compact)
      def compact
        #(Array-like)
        na = self.dup
        na.compact!
        na
      end

      # Adds a sequence to the alignment.
      # Returns key if succeeded.
      # Returns nil (and not added to the alignment) if key is already used.
      #
      # It resembles BioPerl's AlignI::add_seq method.
      def add_seq(seq, key = nil)
        #(BioPerl) AlignI::add_seq like method
        unless seq.is_a?(Bio::Sequence::NA) or seq.is_a?(Bio::Sequence::AA)
          s =   extract_seq(seq)
          key = extract_key(seq) unless key
          seq = s
        end
        self.store(key, seq)
      end

      # Removes given sequence from the alignment.
      # Returns removed sequence. If nothing removed, returns nil.
      #
      # It resembles BioPerl's AlignI::remove_seq.
      def remove_seq(seq)
        #(BioPerl) AlignI::remove_seq like method
        if k = self.index(seq) then
          self.delete(k)
        else
          nil
        end
      end

      # Removes sequences from the alignment by given keys.
      # Returns an alignment object consists of removed sequences.
      #
      # It resembles BioPerl's AlignI::purge method.
      def purge(*arg)
        #(BioPerl) AlignI::purge like method
        purged = self.new
        arg.each do |k|
          if self[k] then
            purged.store(k, self.delete(k))
          end
        end
        purged
      end

      # If block is given, it acts like Array#select (Enumerable#select). 
      # Returns a new alignment containing all sequences of the alignment
      # for which return value of given block is not false nor nil.
      #
      # If no block is given, it acts like the BioPerl's AlignI::select.
      # Returns a new alignment containing sequences of given keys.
      #
      # The BioPerl's AlignI::select-like action will be obsoleted.
      def select(*arg)
        #(original)
        na = self.new
        if block_given? then
          # 'arg' is ignored
          # nearly same action as Array#select (Enumerable#select)
          self.each_pair.each do |k, s|
            na.store(k, s) if yield(s)
          end
        else
          # BioPerl's AlignI::select like function
          arg.each do |k|
            if s = self[k] then
              na.store(k, s)
            end
          end
        end
        na
      end

      # The method name <tt>slice</tt> will be obsoleted.
      # Please use <tt>alignment_slice</tt> instead.
      alias slice  alignment_slice

      # The method name <tt>subseq</tt> will be obsoleted.
      # Please use <tt>alignment_subseq</tt> instead.
      alias subseq alignment_subseq

      # Not-destructive version of alignment_normalize!.
      # Returns a new alignment.
      def normalize
        #(original)
        na = self.dup
        na.alignment_normalize!
        na
      end

      # Not-destructive version of alignment_rstrip!.
      # Returns a new alignment.
      def rstrip
        #(String-like)
        na = self.dup
        na.isolate
        na.alignment_rstrip!
        na
      end

      # Not-destructive version of alignment_lstrip!.
      # Returns a new alignment.
      def lstrip
        #(String-like)
        na = self.dup
        na.isolate
        na.alignment_lstrip!
        na
      end

      # Not-destructive version of alignment_strip!.
      # Returns a new alignment.
      def strip
        #(String-like)
        na = self.dup
        na.isolate
        na.alignment_strip!
        na
      end

      # Not-destructive version of remove_gaps!.
      # Returns a new alignment.
      #
      # The method name 'remove_gap' will be obsoleted.
      # Please use 'remove_all_gaps' instead.
      def remove_all_gaps
        #(original)
        na = self.dup
        na.isolate
        na.remove_all_gaps!
        na
      end

      # Concatenates a string or an alignment.
      # Returns self.
      #
      # Note that the method will be obsoleted.
      # Please use <tt>each_seq { |s| s << str }</tt> for concatenating
      # a string and
      # <tt>alignment_concat(aln)</tt> for concatenating an alignment.
      def concat(aln)
        #(String-like)
        if aln.respond_to?(:to_str) then #aln.is_a?(String)
          self.each do |s|
            s << aln
          end
          self
        else
          alignment_concat(aln)
        end
      end

      # Replace the specified region of the alignment to aln.
      # aln:: String or Bio::Alignment object
      # arg:: same format as String#slice
      #
      # It will be obsoleted.
      def replace_slice(aln, *arg)
        #(original)
        if aln.respond_to?(:to_str) then #aln.is_a?(String)
          self.each do |s|
            s[*arg] = aln
          end
        elsif aln.is_a?(self.class) then
          aln.each_pair do |k, s|
            self[k][*arg] = s
          end
        else
          i = 0
          aln.each do |s|
            self.order(i)[*arg] = s
            i += 1
          end
        end
        self
      end

      # Performs multiple alignment by using external program.
      def do_align(factory)
        a0 = self.class.new
        (0...self.size).each { |i| a0.store(i, self.order(i)) }
        r = factory.query(a0)
        a1 = r.alignment
        a0.keys.each do |k|
          unless a1[k.to_s] then
            raise 'alignment result is inconsistent with input data'
          end
        end
        a2 = self.new
        a0.keys.each do |k|
          a2.store(self.keys[k], a1[k.to_s])
        end
        a2
      end

      # Convert to fasta format and returns an array of strings.
      #
      # It will be obsoleted.
      def to_fasta_array(*arg)
        #(original)
        width = nil
        if arg[0].is_a?(Integer) then
          width = arg.shift
        end
        options = (arg.shift or {})
        width = options[:width] unless width
        if options[:avoid_same_name] then
          na = avoid_same_name(self.keys, 30)
        else
          na = self.keys.collect { |k| k.to_s.gsub(/[\r\n\x00]/, ' ') }
        end
        a = self.collect do |s|
          ">#{na.shift}\n" +
            if width then
              s.to_s.gsub(Regexp.new(".{1,#{width}}"), "\\0\n")
            else
              s.to_s + "\n"
            end
        end
        a
      end

      # Convets to fasta format and returns an array of FastaFormat objects.
      #
      # It will be obsoleted.
      def to_fastaformat_array(*arg)
        #(original)
        require 'bio/db/fasta'
        a = self.to_fasta_array(*arg)
        a.collect! do |x|
          Bio::FastaFormat.new(x)
        end
        a
      end

      # Converts to fasta format and returns a string.
      #
      # The specification of the argument will be changed.
      def to_fasta(*arg)
        #(original)
        self.to_fasta_array(*arg).join('')
      end

      include ClustalWFormatter
      # Returns a string of Clustal W formatted text of the alignment.
      def to_clustal(options = {})
        clustalw_formatter(self, self.keys, options)
      end

      # The method name <tt>consensus</tt> will be obsoleted.
      # Please use <tt>consensus_string</tt> instead.
      alias consensus consensus_string
    end #class OriginalAlignment

    # Bio::Alignment::GAP is a set of class methods for
    # gap-related position translation.
    module GAP
      # position with gaps are translated into the position without gaps.
      #<em>seq</em>:: sequence
      #<em>pos</em>:: position with gaps
      #<em>gap_regexp</em>:: regular expression to specify gaps
      def ungapped_pos(seq, pos, gap_regexp)
        p = seq[0..pos].gsub(gap_regexp, '').length
        p -= 1 if p > 0
        p
      end
      module_function :ungapped_pos

      # position without gaps are translated into the position with gaps.
      #<em>seq</em>:: sequence
      #<em>pos</em>:: position with gaps
      #<em>gap_regexp</em>:: regular expression to specify gaps
      def gapped_pos(seq, pos, gap_regexp)
        olen = seq.gsub(gap_regexp, '').length
        pos = olen if pos >= olen
        pos = olen + pos if pos < 0
        
        i = 0
        l = pos + 1
        while l > 0 and i < seq.length
          x = seq[i, l].gsub(gap_regexp, '').length
          i += l
          l -= x
        end
        i -= 1 if i > 0
        i
      end
      module_function :gapped_pos
    end # module GAP

    # creates a new Bio::Alignment::OriginalAlignment object.
    # Please refer document of OriginalAlignment.new.
    def self.new(*arg)
      OriginalAlignment.new(*arg)
    end

    # creates a new Bio::Alignment::OriginalAlignment object.
    # Please refer document of OriginalAlignment.new2.
    def self.new2(*arg)
      OriginalAlignment.new2(*arg)
    end

    # creates a new Bio::Alignment::OriginalAlignment object.
    # Please refer document of OriginalAlignment.readfiles.
    def self.readfiles(*files)
      OriginalAlignment.readfiles(*files)
    end
  end #module Alignment

end #module Bio

