#
#  bio/shell.rb - Loading all BioRuby shell features
#
#   Copyright (C) 2005 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: shell.rb,v 1.2 2005/09/24 12:33:07 k Exp $
#

require 'bio'
require 'yaml'
require 'pp'

$bioruby_config = {}
$bioruby_cache  = {}

module Bio::Shell

  require 'bio/shell/core'
  require 'bio/shell/session'
  require 'bio/shell/plugin/seq'
  require 'bio/shell/plugin/flatfile'
  require 'bio/shell/plugin/obda'

  extend Core

end


