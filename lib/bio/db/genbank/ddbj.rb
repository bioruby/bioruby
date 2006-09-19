#
# = bio/db/genbank/ddbj.rb - DDBJ database class
#
# Copyright::  Copyright (C) 2000-2004 Toshiaki Katayama <k@bioruby.org>
# License::    Ruby's
#
# $Id: ddbj.rb,v 1.8 2006/09/19 05:57:54 k Exp $
#

require 'bio/db/genbank/genbank'

module Bio

class DDBJ < GenBank

  autoload :XML,          'bio/io/ddbjxml'

  # Nothing to do (DDBJ database format is completely same as GenBank)

end # DDBJ

end # Bio
