#
# = bio/db/genbank/ddbj.rb - DDBJ database class
#
# Copyright::  Copyright (C) 2000-2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: ddbj.rb,v 1.9 2007/04/05 23:35:40 trevor Exp $
#

require 'bio/db/genbank/genbank'

module Bio

class DDBJ < GenBank

  autoload :XML,          'bio/io/ddbjxml'

  # Nothing to do (DDBJ database format is completely same as GenBank)

end # DDBJ

end # Bio
