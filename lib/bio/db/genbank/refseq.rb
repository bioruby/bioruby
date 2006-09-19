#
# = bio/db/genbank/refseq.rb - RefSeq database class
#
# Copyright::  Copyright (C) 2000-2004 Toshiaki Katayama <k@bioruby.org>
# License::    Ruby's
#
# $Id: refseq.rb,v 1.7 2006/09/19 06:00:06 k Exp $
#

require 'bio/db/genbank/genbank'

module Bio

class RefSeq < GenBank
  # Nothing to do (RefSeq database format is completely same as GenBank)
end

end # Bio
