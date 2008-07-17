#
# = bio/sequence/adapter.rb - Bio::Sequence adapter helper module
#
# Copyright::   Copyright (C) 2008
#               Naohisa Goto <ng@bioruby.org>,
# License::     The Ruby License
#
# $Id:$
#

require 'bio/sequence'

# Internal use only. Normal users should not use this module.
#
# Helper methods for defining adapters used when converting data classes to
# Bio::Sequence class, with pseudo lazy evaluation and pseudo memoization.
#
# This module is used by using "extend", not "include".
# 
module Bio::Sequence::Adapter

  autoload :GenBank,     'bio/db/genbank/genbank_to_biosequence'
  autoload :EMBL,        'bio/db/embl/embl_to_biosequence'
  autoload :FastaFormat, 'bio/db/fasta/fasta_to_biosequence'
  autoload :BioSQL,      'bio/db/biosql/biosql_to_biosequence'

  private

  # Defines a reader attribute method with psudo lazy evaluation/memoization.
  #
  # It defines a method <i>name</i> like attr_reader, but at the first time
  # when the method <i>name</i> is called, it acts as follows:
  # When instance variable @<i>name</i> is not defined,
  # calls <tt>__get__<i>name</i>(@source_data)</tt> and stores the returned
  # value to @<i>name</i>, and changes its behavior to the same as
  # <tt>attr_reader </tt><i>:name</i>.
  # When instance variable @name is already defined,
  # its behavior is changed to the same as
  # <tt>attr_reader </tt><i>:name</i>.
  # When the object is frozen, storing to the instance variable and
  # changing methods behavior do not occur, and the value of
  # <tt>__get__<i>name</i>(@source_data)</tt> is returned.
  # 
  # Note that it assumes that the source data object is stored in
  # @source_data instance variable.
  def attr_reader_lazy(name)
    #$stderr.puts "attr_reader_lazy :#{name}"
    varname = "@#{name}".intern
    methodname = "__get__#{name}".intern

    # module to reset method's behavior to normal attr_reader
    reset = "Attr_#{name}".intern
    const_set(reset, Module.new { attr_reader name })
    reset_module_name = "#{self}::#{reset}"

    # define attr method
    module_eval <<__END_OF_DEF__
      def #{name}
        unless defined? #{varname} then
          #$stderr.puts "LAZY #{name}: calling #{methodname}"
          val = #{methodname}(@source_data)
          #{varname} = val unless frozen?
        else
          val = #{varname}
        end
        unless frozen? then
          #$stderr.puts "LAZY #{name}: finalize: attr_reader :#{name}"
          self.extend(#{reset_module_name})
        end
        val
      end
__END_OF_DEF__
  end

  # Defines a Bio::Sequence to Bio::* adapter method with
  # psudo lazy evaluation and psudo memoization.
  #
  # Without block, defines a private method <tt>__get__<i>name</i>(orig)</tt>
  # which calls <i>source_method</i> for @source_data.
  #
  # def__get__(name, source_method) is the same as:
  #   def __get__name(orig); orig.source_method; end
  #   attr_reader_lazy name
  #
  # If block is given, <tt>__get__<i>name</i>(orig)</tt> is defined
  # with the block. The @source_data is given as an argument of the block,
  # i.e. the block must get an argument.
  #
  def def_biosequence_adapter(name, source_method = name, &block)
    methodname = "__get__#{name}".intern

    if block then
      define_method(methodname, block)
    else
      module_eval <<__END_OF_DEF__
        def #{methodname}(orig)
          orig.#{source_method}
        end
__END_OF_DEF__
    end
    private methodname
    attr_reader_lazy name
    true
  end

end #module Bio::Sequence::Adapter


