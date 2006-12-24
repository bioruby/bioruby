#
# = bio/shell/script.rb - script mode for the BioRuby shell
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: script.rb,v 1.1 2006/12/24 08:32:08 k Exp $
#

module Bio::Shell

  class Script

    def initialize(script)
      Bio::Shell.cache[:binding] = TOPLEVEL_BINDING
      Bio::Shell.load_session
      eval(File.read(File.join(Bio::Shell.script_dir, script)), TOPLEVEL_BINDING)
      exit
    end

  end # Script

end

