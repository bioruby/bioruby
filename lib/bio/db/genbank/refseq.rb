#
# bio/db/refseq.rb - RefSeq database class
#
#   Copyright (C) 2000, 2001 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  $Id: refseq.rb,v 1.1 2001/09/01 07:27:02 katayama Exp $
#

require 'bio/db/genbank'

class RefSeq < GenBank
  # Nothing to do (RefSeq database format is completely same as GenBank)
end
