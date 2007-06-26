#
# = bio/shell/web.rb - GUI for the BioRuby shell
#
# Copyright::   Copyright (C) 2006
#               Nobuya Tanaka <t@chemruby.org>,
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: web.rb,v 1.5 2007/06/26 08:38:38 k Exp $
#


module Bio::Shell

  class Web

    def initialize
      Bio::Shell.cache[:binding] = binding
      Bio::Shell.cache[:results] ||= Results.new
      install_rails
      setup_rails
      start_rails
    end

    private

    def setup_rails
      puts
      puts ">>>"
      puts ">>>  open http://localhost:3000/bioruby"
      puts ">>>"
      puts
      puts '(You can change the port number by adding "-- -p 4000" option)'
      puts
    end

    def install_rails
      savedir = Bio::Shell.cache[:savedir]
      path = File.join(savedir, "script", "generate")
      unless File.exist?(path)
        puts "Installing Rails application for BioRuby shell ... "
        system("rails #{savedir}")
        puts "done"
      end
      path = File.join(savedir, "app", "controllers", "bioruby_controller.rb")
      unless File.exist?(path)
        basedir = File.dirname(__FILE__)
        puts "Installing Rails plugin for BioRuby shell ... "
        FileUtils.cp_r("#{basedir}/rails/.", savedir)
        Dir.chdir(savedir) do 
          system("./script/generate bioruby shell")
        end
        puts "done"
      end
    end

    def start_rails
      begin
        Bio::Shell.cache[:rails] = Thread.new do
          Dir.chdir(Bio::Shell.cache[:savedir]) do
            require './config/boot'
            require 'commands/server'
          end
        end
      end
    end

    class Results
      attr_accessor :number, :script, :result, :output

      def initialize
        @number = 0
        @script = []
        @result = []
        @output = []
      end

      def store(script, result, output)
        @number += 1
        @script[@number] = script
        @result[@number] = result
        @output[@number] = output
        return @number
      end

      def restore(number)
        return @script[number], @result[number], @output[number]
      end
    end

  end

  private

  # *TODO* stop irb and start rails?
  #def web
  #end

end



