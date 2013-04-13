#
# = bio/shell.rb - Loading all BioRuby shell features
#
# Copyright::   Copyright (C) 2005, 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id:$
#

require 'bio'
require 'yaml'
require 'open-uri'
require 'fileutils'
require 'pp'

module Bio::Shell

  require 'bio/shell/setup'
  require 'bio/shell/irb'
  require 'bio/shell/web'
  require 'bio/shell/script'
  require 'bio/shell/core'
  require 'bio/shell/interface'
  require 'bio/shell/object'
  require 'bio/shell/demo'
  require 'bio/shell/plugin/entry'
  require 'bio/shell/plugin/seq'
  require 'bio/shell/plugin/midi'
  require 'bio/shell/plugin/codon'
  require 'bio/shell/plugin/flatfile'
  require 'bio/shell/plugin/obda'
  require 'bio/shell/plugin/das'
  require 'bio/shell/plugin/soap'
  require 'bio/shell/plugin/emboss'
  require 'bio/shell/plugin/blast'
  require 'bio/shell/plugin/psort'
  require 'bio/shell/plugin/ncbirest'
  require 'bio/shell/plugin/togows'

  extend Ghost

end


