#
# = bio/shell/core.rb - internal methods for the BioRuby shell
#
# Copyright::   Copyright (C) 2005, 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: core.rb,v 1.25 2007/06/26 01:41:33 k Exp $
#

module Bio::Shell::Core

  # chdir
  # change to File.join for / ended dirs
  SAVEDIR = "shell/session/"
  CONFIG  = "config"
  OBJECT  = "object"
  HISTORY = "history"
  SCRIPT  = "shell/script.rb"
  PLUGIN  = "shell/plugin/"
  DATADIR = "data/"
  BIOFLAT = "data/bioflat/"

  MARSHAL = [ Marshal::MAJOR_VERSION, Marshal::MINOR_VERSION ]

  MESSAGE = "...BioRuby in the shell..."

  ESC_SEQ = {
    :k => "\e[30m",  :black   => "\e[30m",
    :r => "\e[31m",  :red     => "\e[31m",  :ruby  => "\e[31m",
    :g => "\e[32m",  :green   => "\e[32m",
    :y => "\e[33m",  :yellow  => "\e[33m",
    :b => "\e[34m",  :blue    => "\e[34m",
    :m => "\e[35m",  :magenta => "\e[35m",
    :c => "\e[36m",  :cyan    => "\e[36m",
    :w => "\e[37m",  :white   => "\e[37m",
    :n => "\e[00m",  :none    => "\e[00m",  :reset => "\e[00m",
  }

  def colors
    ESC_SEQ
  end

  def datadir
    File.join(@cache[:workdir], DATADIR)
  end

  def script_dir
    File.dirname(SCRIPT)
  end

  def object_file
    File.join(@cache[:workdir], SAVEDIR, OBJECT)
  end

  def history_file
    File.join(@cache[:workdir], SAVEDIR, HISTORY)
  end

  def ask_yes_or_no(message)
    loop do
      STDERR.print "#{message}"
      answer = gets
      if answer.nil?
        # readline support might be broken
        return false
      elsif /^\s*[Nn]/.match(answer)
        return false
      elsif /^\s*[Yy]/.match(answer)
        return true
      else
        # loop
      end
    end
  end

end


module Bio::Shell::Ghost

  include Bio::Shell::Core

  # A hash to store persistent configurations
  attr_accessor :config

  # A hash to store temporal (per session) configurations
  attr_accessor :cache

  ### save/restore the environment

  def configure(workdir)
    savedir = File.join(Dir.pwd, workdir)
    @config = {}
    @cache  = {
      :workdir => workdir,
      :savedir => savedir,
    }
    create_save_dir
    load_config
    load_plugin
  end
 
  def load_session
    load_object
    unless @cache[:mode] == :script
      load_history
      opening_splash
      open_history
    end
  end

  def save_session
    unless @cache[:mode] == :script
      close_history
      closing_splash
    end
    if create_save_dir_ask
      #save_history	# changed to use our own...
      save_object
      save_config
    end
    #STDERR.puts "Leaving directory '#{@cache[:workdir]}'"
    STDERR.puts "History is saved in '#{@cache[:workdir]}/#{SAVEDIR + HISTORY}'"
  end

  ### directories

  def create_save_dir
    create_real_dir(SAVEDIR)
    create_real_dir(DATADIR)
    create_real_dir(PLUGIN)
  end

  def create_save_dir_ask
    Dir.chdir(@cache[:workdir]) do |path|
      if File.directory?(SAVEDIR)
        @cache[:save] = true
      end
    end
    unless @cache[:save]
      if ask_yes_or_no("Save session in '#{@cache[:workdir]}/#{SAVEDIR}' directory? [y/n] ")
        create_real_dir(SAVEDIR)
        create_real_dir(PLUGIN)
        create_real_dir(DATADIR)
        create_real_dir(BIOFLAT)
        @cache[:save] = true
      else
        @cache[:save] = false
      end
    end
    return @cache[:save]
  end

  def create_real_dir(dir)
    Dir.chdir(@cache[:workdir]) do |path|
      unless File.directory?(dir)
        begin
          STDERR.print "Creating directory (#{path}/#{dir}) ... "
          FileUtils.mkdir_p(dir)
          STDERR.puts "done"
        rescue
          warn "Error: Failed to create directory (#{path}/#{dir}) : #{$!}"
        end
      end
    end
  end

  ### bioflat

  def create_flat_dir(dbname)
    flatdb = ""
    Dir.chdir(@cache[:workdir]) do |path|
      dir = BIOFLAT + dbname.to_s.strip
      unless File.directory?(dir)
        FileUtils.mkdir_p(dir)
      end
      flatdb = "#{path}/#{dir}"
    end
    return flatdb
  end

  def find_flat_dir(dbname)
    flatdb = ""
    Dir.chdir(@cache[:workdir]) do |path|
      dir = BIOFLAT + dbname.to_s.strip
      if File.exists?(dir)
        flatdb = "#{path}/#{dir}"
      else
        flatdb = nil
      end
    end
    return flatdb
  end

  ### config

  def load_config
    load_config_file(SAVEDIR + CONFIG)
  end

  def load_config_file(file)
    Dir.chdir(@cache[:workdir]) do |path|
      if File.exists?(file)
        STDERR.print "Loading config (#{path}/#{file}) ... "
        if hash = YAML.load(File.read(file))
          @config.update(hash)
        end
        STDERR.puts "done"
      end
    end
  end

  def save_config
    save_config_file(SAVEDIR + CONFIG)
  end

  def save_config_file(file)
    Dir.chdir(@cache[:workdir]) do |path|
      begin
        STDERR.print "Saving config (#{path}/#{file}) ... "
        File.open(file, "w") do |f|
          f.puts @config.to_yaml
        end
        STDERR.puts "done"
      rescue
        warn "Error: Failed to save (#{path}/#{file}) : #{$!}"
      end
    end
  end

  def config_show
    @config.each do |k, v|
      STDERR.puts "#{k}\t= #{v.inspect}"
    end
  end

  def config_echo
    bind = Bio::Shell.cache[:binding]
    flag = ! @config[:echo]
    @config[:echo] = IRB.conf[:ECHO] = flag
    eval("conf.echo = #{flag}", bind)
    STDERR.puts "Echo #{flag ? 'on' : 'off'}"
  end

  def config_color
    bind = Bio::Shell.cache[:binding]
    flag = ! @config[:color]
    @config[:color] = flag
    if flag
      IRB.conf[:PROMPT_MODE] = :BIORUBY_COLOR
      eval("conf.prompt_mode = :BIORUBY_COLOR", bind)
    else
      IRB.conf[:PROMPT_MODE] = :BIORUBY
      eval("conf.prompt_mode = :BIORUBY", bind)
    end
  end

  def config_pager(cmd = nil)
    @config[:pager] = cmd
  end

  def config_splash
    flag = ! @config[:splash]
    @config[:splash] = flag
    STDERR.puts "Splash #{flag ? 'on' : 'off'}"
    opening_splash
  end

  def config_message(str = nil)
    str ||= MESSAGE
    @config[:message] = str
    opening_splash
  end

  ### plugin

  def load_plugin
    load_plugin_dir(PLUGIN)
  end

  def load_plugin_dir(dir)
    Dir.chdir(@cache[:workdir]) do |path|
      if File.directory?(dir)
        Dir.glob("#{dir}/*.rb").sort.each do |file|
          STDERR.print "Loading plugin (#{path}/#{file}) ... "
          load file
          STDERR.puts "done"
        end
      end
    end
  end

  ### object

  def check_marshal
    if @config[:marshal] and @config[:marshal] != MARSHAL
      raise "Marshal version mismatch"
    end
  end

  def load_object
    begin
      check_marshal
      load_object_file(SAVEDIR + OBJECT)
    rescue
      warn "Error: Load aborted : #{$!}"
    end
  end

  def load_object_file(file)
    Dir.chdir(@cache[:workdir]) do |path|
      if File.exists?(file)
        STDERR.print "Loading object (#{path}/#{file}) ... "
        begin
          bind = Bio::Shell.cache[:binding]
          hash = Marshal.load(File.read(file))
          hash.each do |k, v|
            begin
              Thread.current[:restore_value] = v
              eval("#{k} = Thread.current[:restore_value]", bind)
            rescue
              STDERR.puts "Warning: object '#{k}' couldn't be loaded : #{$!}"
            end
          end
        rescue
          warn "Error: Failed to load (#{path}/#{file}) : #{$!}"
        end
        STDERR.puts "done"
      end
    end
  end

  def save_object
    save_object_file(SAVEDIR + OBJECT)
  end

  def save_object_file(file)
    Dir.chdir(@cache[:workdir]) do |path|
      begin
        STDERR.print "Saving object (#{path}/#{file}) ... "
        File.rename(file, "#{file}.old") if File.exist?(file)
        File.open(file, "w") do |f|
          bind = Bio::Shell.cache[:binding]
          list = eval("local_variables", bind)
          list -= ["_"]
          hash = {}
          list.each do |elem|
            value = eval(elem, bind)
            if value
              begin
                Marshal.dump(value)
                hash[elem] = value
              rescue
                # value could not be dumped.
              end
            end
          end
          Marshal.dump(hash, f)
          @config[:marshal] = MARSHAL
        end
        STDERR.puts "done"
      rescue
        File.rename("#{file}.old", file) if File.exist?("#{file}.old")
        warn "Error: Failed to save (#{file}) : #{$!}"
      end
    end
  end

  ### history

  def open_history
    Dir.chdir(@cache[:workdir]) do |path|
      @cache[:histfile] = File.open(SAVEDIR + HISTORY, "a")
    end
    @cache[:histfile].sync = true
  end

  def store_history(line)
    Bio::Shell.cache[:histfile].puts "# #{Time.now}"
    Bio::Shell.cache[:histfile].puts line
  end

  def close_history
    @cache[:histfile].close if @cache[:histfile]
  end

  def load_history
    if @cache[:readline]
      load_history_file(SAVEDIR + HISTORY)
    end
  end

  def load_history_file(file)
    Dir.chdir(@cache[:workdir]) do |path|
      if File.exists?(file)
        STDERR.print "Loading history (#{path}/#{file}) ... "
        File.open(file).each do |line|
          unless line[/^# /]
            Readline::HISTORY.push line.chomp
          end
        end
      end
      STDERR.puts "done"
    end
  end
  
  # not used (use open_history/close_history instead)
  def save_history
    if @cache[:readline]
      save_history_file(SAVEDIR + HISTORY)
    end
  end

  def save_history_file(file)
    Dir.chdir(@cache[:workdir]) do |path|
      begin
        STDERR.print "Saving history (#{path}/#{file}) ... "
        File.open(file, "w") do |f|
          f.puts Readline::HISTORY.to_a
        end
        STDERR.puts "done"
      rescue
        warn "Error: Failed to save (#{path}/#{file}) : #{$!}"
      end
    end
  end

  ### script

  def script(mode = nil)
    case mode
    when :begin, "begin", :start, "start"
      @cache[:script] = true
      script_begin
    when :end, "end", :stop, "stop"
      @cache[:script] = false
      script_end
      save_script
    else
      if @cache[:script]
        @cache[:script] = false
        script_end
        save_script
      else
        @cache[:script] = true
        script_begin
      end
    end
  end

  def script_begin
    STDERR.puts "-- 8< -- 8< -- 8< --  Script  -- 8< -- 8< -- 8< --"
    @script_begin = Readline::HISTORY.size
  end

  def script_end
    STDERR.puts "-- >8 -- >8 -- >8 --  Script  -- >8 -- >8 -- >8 --"
    @script_end = Readline::HISTORY.size - 2
  end

  def save_script
    if @script_begin and @script_end and @script_begin <= @script_end
      Dir.chdir(@cache[:workdir]) do |path|
        if File.exists?(SCRIPT)
          message = "Overwrite script file (#{path}/#{SCRIPT})? [y/n] "
        else
          message = "Save script file (#{path}/#{SCRIPT})? [y/n] "
        end
        if ask_yes_or_no(message)
          save_script_file(SCRIPT)
        else
          STDERR.puts " ... save aborted."
        end 
      end
    elsif @script_begin and @script_end and @script_begin - @script_end == 1
      STDERR.puts " ... script aborted."
    else
      STDERR.puts "Error: Script range #{@script_begin}..#{@script_end} is invalid"
    end
  end

  def save_script_file(file)
    Dir.chdir(@cache[:workdir]) do |path|
      begin
        STDERR.print "Saving script (#{path}/#{file}) ... "
        File.open(file, "w") do |f|
          f.puts "#!/usr/bin/env bioruby"
          f.puts
          f.puts Readline::HISTORY.to_a[@script_begin..@script_end]
          f.puts
        end
        STDERR.puts "done"
      rescue
        @script_begin = nil
        warn "Error: Failed to save (#{path}/#{file}) : #{$!}"
      end
    end
  end

  ### splash

  def splash_message
    @config[:message] ||= MESSAGE
    @config[:message].to_s.split(//).join(" ")
  end

  def splash_message_color
    str = splash_message
    ruby = colors[:ruby]
    none = colors[:none]
    return str.sub(/R u b y/) { "#{ruby}R u b y#{none}" }
  end

  def splash_message_action(message = nil)
    s = message || splash_message
    l = s.length
    x = " "
    0.step(l,2) do |i|
      l1 = l-i;  l2 = l1/2;  l4 = l2/2
      STDERR.print "#{s[0,i]}#{x*l1}#{s[i,1]}\r"
      sleep(0.001)
      STDERR.print "#{s[0,i]}#{x*l2}#{s[i,1]}#{x*(l1-l2)}\r"
      sleep(0.002)
      STDERR.print "#{s[0,i]}#{x*l4}#{s[i,1]}#{x*(l2-l4)}\r"
      sleep(0.004)
      STDERR.print "#{s[0,i+1]}#{x*l4}\r"
      sleep(0.008)
    end
  end

  def splash_message_action_color(message = nil)
    s = message || splash_message
    l = s.length
    c = colors
    x = " "
    0.step(l,2) do |i|
      l1 = l-i;  l2 = l1/2;  l4 = l2/2
      STDERR.print "#{c[:n]}#{s[0,i]}#{x*l1}#{c[:y]}#{s[i,1]}\r"
      sleep(0.001)
      STDERR.print "#{c[:n]}#{s[0,i]}#{x*l2}#{c[:g]}#{s[i,1]}#{x*(l1-l2)}\r"
      sleep(0.002)
      STDERR.print "#{c[:n]}#{s[0,i]}#{x*l4}#{c[:r]}#{s[i,1]}#{x*(l2-l4)}\r"
      sleep(0.004)
      STDERR.print "#{c[:n]}#{s[0,i+1]}#{x*l4}\r"
      sleep(0.008)
    end
  end

  def opening_splash
    STDERR.puts
    if @config[:splash]
      if @config[:color]
        splash_message_action_color
      else
        splash_message_action
      end
    end
    if @config[:color]
      STDERR.print splash_message_color
    else
      STDERR.print splash_message
    end
    STDERR.puts
    STDERR.puts
    STDERR.print "  Version : BioRuby #{Bio::BIORUBY_VERSION.join(".")}"
    STDERR.print " / Ruby #{RUBY_VERSION}"
    STDERR.puts
    STDERR.puts
  end

  def closing_splash
    STDERR.puts
    STDERR.puts
    if @config[:color]
      STDERR.print splash_message_color
    else
      STDERR.print splash_message
    end
    STDERR.puts
    STDERR.puts
  end

end

