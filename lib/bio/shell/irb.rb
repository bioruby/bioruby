#
# = bio/shell/irb.rb - CUI for the BioRuby shell
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: irb.rb,v 1.3 2007/04/05 23:35:41 trevor Exp $
#

module Bio::Shell

  class Irb

    def initialize
      require 'irb'
      begin
        require 'irb/completion'
        Bio::Shell.cache[:readline] = true
      rescue LoadError
        Bio::Shell.cache[:readline] = false
      end
      IRB.setup(nil)
      setup_irb
      start_irb
    end

    def start_irb
      Bio::Shell.cache[:irb] = IRB::Irb.new

      # needed for method completion
      IRB.conf[:MAIN_CONTEXT] = Bio::Shell.cache[:irb].context

      # store binding for evaluation
      Bio::Shell.cache[:binding] = IRB.conf[:MAIN_CONTEXT].workspace.binding

      # overwrite gets to store history with time stamp
      io = IRB.conf[:MAIN_CONTEXT].io
      io.class.class_eval do
        alias_method :irb_original_gets, :gets
      end

      def io.gets
        line = irb_original_gets
        if line
          Bio::Shell.store_history(line)
        end
        return line
      end

      if File.exists?("./config/boot.rb")
        require "./config/boot"
        require "./config/environment"
        #require 'commands/console'
      end
    end

    def setup_irb
      # set application name
      IRB.conf[:AP_NAME] = 'bioruby'

      # change prompt for bioruby
      $_ = Bio::Shell.colors
      IRB.conf[:PROMPT][:BIORUBY_COLOR] = {
        :PROMPT_I => "bio#{$_[:ruby]}ruby#{$_[:none]}> ",
        :PROMPT_S => "bio#{$_[:ruby]}ruby#{$_[:none]}%l ",
        :PROMPT_C => "bio#{$_[:ruby]}ruby#{$_[:none]}+ ",
        :RETURN   => "  ==> %s\n"
      }
      IRB.conf[:PROMPT][:BIORUBY] = {
        :PROMPT_I => "bioruby> ",
        :PROMPT_S => "bioruby%l ",
        :PROMPT_C => "bioruby+ ",
        :RETURN   => "  ==> %s\n"
      }
      if Bio::Shell.config[:color]
        IRB.conf[:PROMPT_MODE] = :BIORUBY_COLOR
      else
        IRB.conf[:PROMPT_MODE] = :BIORUBY
      end

      # echo mode (uncomment to off by default)
      #IRB.conf[:ECHO] = Bio::Shell.config[:echo] || false

      # irb/input-method.rb >= v1.5 (not in 1.8.2)
      #IRB.conf[:SAVE_HISTORY] = 100000

      # not nicely works
      #IRB.conf[:AUTO_INDENT] = true
    end

  end # Irb

end

