#
# = bio/db/genbank/ddbj.rb - DDBJ database class
#
# Copyright::  Copyright (C) 2000-2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#

require 'bio/db/genbank/genbank'

module Bio

class DDBJ < GenBank

  autoload :XML,          'bio/io/ddbjxml'
  autoload :REST,         'bio/io/ddbjrest'

  # Nothing to do (DDBJ database format is completely same as GenBank)

end # DDBJ

end # Bio
