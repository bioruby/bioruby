#
# bio/db/ddbj.rb - DDBJ database class
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
#  $Id: ddbj.rb,v 1.1 2001/08/21 12:48:32 katayama Exp $
#

require 'bio/db/genbank'

class DDBJ < GenBank
  # Nothing to do (DDBJ database format is completely same as GenBank)
end
