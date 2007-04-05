#
# = bio/shell/script.rb - script mode for the BioRuby shell
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: script.rb,v 1.3 2007/04/05 23:35:41 trevor Exp $
#

module Bio::Shell

  class Script

    def initialize(script)
      Bio::Shell.cache[:binding] = TOPLEVEL_BINDING
      Bio::Shell.load_session
      eval(File.read(script), TOPLEVEL_BINDING)
      exit
    end

  end # Script

end

