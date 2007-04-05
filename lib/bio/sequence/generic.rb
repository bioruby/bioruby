#
# = bio/sequence/generic.rb - generic sequence class to store an intact string
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: generic.rb,v 1.5 2007/04/05 23:35:41 trevor Exp $
#

require 'bio/sequence/common'

module Bio
class Sequence

class Generic < String #:nodoc:

  include Bio::Sequence::Common

end # Generic

end # Sequence
end # Bio

