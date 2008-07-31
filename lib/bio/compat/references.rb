#
# = bio/compat/references.rb - Obsoleted References class
#
# Copyright::   Copyright (C) 2008
#               Toshiaki Katayama <k@bioruby.org>,
#               Ryan Raaum <ryan@raaum.org>,
#               Jan Aerts <jandot@bioruby.org>,
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#
# $Id: references.rb,v 1.1.2.1 2008/03/04 10:07:49 ngoto Exp $
#
# == Description
#
# The Bio::References class was obsoleted after BioRuby 1.2.1.
# To keep compatibility, some wrapper methods are provided in this file.
# As the compatibility methods (and Bio::References) will soon be removed,
# Please change your code not to use Bio::References.
#
# Note that Bio::Reference is different from Bio::References.
# Bio::Reference still exists for storing a reference information
# in sequence entries.

module Bio

  # = DESCRIPTION
  #
  # This class is OBSOLETED, and will soon be removed.
  # Instead of this class, an array is to be used.
  #
  # 
  # A container class for Bio::Reference objects.
  #
  # = USAGE
  #
  # This class should NOT be used.
  #
  #   refs = Bio::References.new
  #   refs.append(Bio::Reference.new(hash))
  #   refs.each do |reference|
  #     ...
  #   end
  #
  class References

    # module to keep backward compatibility with obsoleted Bio::References
    module BackwardCompatibility #:nodoc:

      # Backward compatibility with Bio::References#references.
      # Now, references are stored in an array, and
      # you should change your code not to use this method.
      def references
        warn 'Bio::References is obsoleted. Now, references are stored in an array.'
        self
      end

      # Backward compatibility with Bio::References#append.
      # Now, references are stored in an array, and
      # you should change your code not to use this method.
      def append(reference)
        warn 'Bio::References is obsoleted. Now, references are stored in an array.'
        self.push(reference) if reference.is_a? Reference
        self
      end
    end #module BackwardCompatibility

    # This method should not be used.
    # Only for backward compatibility of existing code.
    #
    # Since Bio::References is obsoleted,
    # Bio::References.new not returns Bio::References object,
    # but modifies given _ary_ and returns the _ary_.
    #
    # *Arguments*:
    # * (optional) __: Array of Bio::Reference objects
    # *Returns*:: the given array
    def self.new(ary = [])
      warn 'Bio::References is obsoleted. Some methods are added to given array to keep backward compatibility.'
      ary.extend(BackwardCompatibility)
      ary
    end

    # Array of Bio::Reference objects
    attr_accessor :references

    # Normally, users can not call this method.
    #
    # Create a new Bio::References object
    # 
    #   refs = Bio::References.new
    # ---
    # *Arguments*:
    # * (optional) __: Array of Bio::Reference objects
    # *Returns*:: Bio::References object
    def initialize(ary = [])
      @references = ary
    end


    # Add a Bio::Reference object to the container.
    #
    #   refs.append(reference)
    # ---
    # *Arguments*:
    # * (required) _reference_: Bio::Reference object
    # *Returns*:: current Bio::References object
    def append(reference)
      @references.push(reference) if reference.is_a? Reference
      return self
    end

    # Iterate through Bio::Reference objects.
    #
    #   refs.each do |reference|
    #     ...
    #   end
    # ---
    # *Block*:: yields each Bio::Reference object
    def each
      @references.each do |reference|
        yield reference
      end
    end

  end #class References
end #module Bio


