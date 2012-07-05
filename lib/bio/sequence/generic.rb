#
# = bio/sequence/generic.rb - generic sequence class to store an intact string
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#

module Bio

require 'bio/sequence' unless const_defined?(:Sequence)

class Sequence

class Generic < String #:nodoc:

  include Bio::Sequence::Common

end # Generic

end # Sequence
end # Bio

