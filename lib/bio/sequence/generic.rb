#
# = bio/sequence/generic.rb - generic sequence class to store an intact string
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: generic.rb,v 1.4 2006/03/26 02:27:59 k Exp $
#

require 'bio/sequence/common'

module Bio
class Sequence

class Generic < String #:nodoc:

  include Bio::Sequence::Common

end # Generic

end # Sequence
end # Bio

