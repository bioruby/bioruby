#
# = bio/db/genbank/refseq.rb - RefSeq database class
#
# Copyright::  Copyright (C) 2000-2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: refseq.rb,v 1.8 2007/04/05 23:35:40 trevor Exp $
#

require 'bio/db/genbank/genbank'

module Bio

class RefSeq < GenBank
  # Nothing to do (RefSeq database format is completely same as GenBank)
end

end # Bio
