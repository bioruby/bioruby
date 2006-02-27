#
# = bio/shell/web.rb - GUI for the BioRuby shell
#
# Copyright::   Copyright (C) 2006
#               Nobuya Tanaka <t@chemruby.org>,
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: web.rb,v 1.1 2006/02/27 09:22:42 k Exp $
#


module Bio::Shell

  private

  def rails_directory_setup
    server = "script/server"
    unless File.exists?(server)
      require 'fileutils'
      basedir = File.dirname(__FILE__)
      print "Copying web server files ... "
      FileUtils.cp_r("#{basedir}/rails/.", ".")
      puts "done"
    end
  end

  def rails_server_setup
    require 'open3'
    $web_server = Open3.popen3(server)

    $web_error_log = File.open("log/web-error.log", "a")
    $web_server[2].reopen($web_error_log)

    while line = $web_server[1].gets
      if line[/druby:\/\/localhost/]
        uri = line.chomp
        puts uri if $DEBUG
        break
      end
    end

    $web_access_log = File.open("log/web-access.log", "a")
    $web_server[1].reopen($web_access_log)

    return uri
  end

  def web
    return if $web_server

    require 'drb/drb'
    # $SAFE = 1   # disable eval() and friends

    rails_directory_setup
    #uri = rails_server_setup
    uri = 'druby://localhost:81064' # baioroji-

    $drb_server = DRbObject.new_with_uri(uri)
    $drb_server.puts_remote("Connected")

    puts "Connected to server #{uri}"
    puts "Open http://localhost:3000/shell/"

    io = IRB.conf[:MAIN_CONTEXT].io

    io.class.class_eval do
      alias_method :shell_original_gets, :gets
    end

    def io.gets
      bind = IRB.conf[:MAIN_CONTEXT].workspace.binding
      vars = eval("local_variables", bind)
      vars.each do |var|
        next if var == "_"
        if val = eval("#{var}", bind)
          $drb_server[var] = val
        else
          $drb_server.delete(var)
        end
      end
      line = shell_original_gets
      line
    end
  end
  
end



