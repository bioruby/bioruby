#
# = bio/shell/script.rb - script mode for the BioRuby shell
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: script.rb,v 1.2 2007/03/28 20:21:26 k Exp $
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

