#
# = bio/shell/core.rb - internal methods for the BioRuby shell
#
# Copyright::   Copyright (C) 2005, 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: core.rb,v 1.21 2006/02/27 09:09:57 k Exp $
#


module Bio::Shell::Ghost

  SAVEDIR = "session/"
  CONFIG  = "config"
  OBJECT  = "object"
  HISTORY = "history"
  SCRIPT  = "script.rb"
  PLUGIN  = "plugin/"
  DATADIR = "data/"
  BIOFLAT = "bioflat/"

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

  def history
    SAVEDIR + HISTORY
  end

  def datadir
    DATADIR
  end

  def esc_seq
    ESC_SEQ
  end

  ### save/restore the environment

  def setup
    @config = {}
    @cache  = {}
    check_version
    check_marshal
    load_config
    load_plugin
  end
 
  # A hash to store persistent configurations
  attr_accessor :config

  # A hash to store temporal (per session) configurations
  attr_accessor :cache

  def load_session
    load_object
    load_history
    opening_splash
  end

  def save_session
    closing_splash
    if create_save_dir_ask
      #save_history	# changed to use our own...
      save_object
      save_config
    end
  end

  ### setup

  def check_version
    if RUBY_VERSION < "1.8.2"
      raise "BioRuby shell runs on Ruby version >= 1.8.2"
    end
  end

  def check_marshal
    if @config[:marshal] and @config[:marshal] != MARSHAL
      raise "Marshal version mismatch"
    end
  end

  def create_save_dir
    create_real_dir(SAVEDIR)
    create_real_dir(DATADIR)
    create_real_dir(PLUGIN)
  end

  def create_save_dir_ask
    if File.directory?(SAVEDIR)
      @cache[:save] = true
    end
    if @cache[:save].nil?
      if ask_yes_or_no("Save session in '#{SAVEDIR}' directory? [y/n] ")
        create_real_dir(SAVEDIR)
        create_real_dir(DATADIR)
        create_real_dir(PLUGIN)
#       create_real_dir(BIOFLAT)
        @cache[:save] = true
      else
        @cache[:save] = false
      end
    end
    return @cache[:save]
  end

  def ask_yes_or_no(message)
    loop do
      print "#{message}"
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

  def create_real_dir(dir)
    unless File.directory?(dir)
      begin
        print "Creating directory (#{dir}) ... "
        Dir.mkdir(dir)
        puts "done"
      rescue
        warn "Error: Failed to create directory (#{dir}) : #{$!}"
      end
    end
  end

  ### bioflat

  def create_flat_dir(dbname)
    dir = BIOFLAT + dbname.to_s.strip
    unless File.directory?(BIOFLAT)
      Dir.mkdir(BIOFLAT)
    end
    unless File.directory?(dir)
      Dir.mkdir(dir)
    end
    return dir
  end

  def find_flat_dir(dbname)
    dir = BIOFLAT + dbname.to_s.strip
    if File.exists?(dir)
      return dir
    else
      return nil
    end
  end

  ### config

  def load_config
    load_config_file(SAVEDIR + CONFIG)
  end

  def load_config_file(file)
    if File.exists?(file)
      print "Loading config (#{file}) ... "
      if hash = YAML.load(File.read(file))
        @config.update(hash)
      end
      puts "done"
    end
  end

  def save_config
    save_config_file(SAVEDIR + CONFIG)
  end

  def save_config_file(file)
    begin
      print "Saving config (#{file}) ... "
      File.open(file, "w") do |f|
        f.puts @config.to_yaml
      end
      puts "done"
    rescue
      warn "Error: Failed to save (#{file}) : #{$!}"
    end
  end

  def config_show
    @config.each do |k, v|
      puts "#{k}\t= #{v.inspect}"
    end
  end

  def config_echo
    bind = IRB.conf[:MAIN_CONTEXT].workspace.binding
    flag = ! @config[:echo]
    @config[:echo] = IRB.conf[:ECHO] = flag
    eval("conf.echo = #{flag}", bind)
    puts "Echo #{flag ? 'on' : 'off'}"
  end

  def config_color
    bind = IRB.conf[:MAIN_CONTEXT].workspace.binding
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
    puts "Splash #{flag ? 'on' : 'off'}"
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
    if File.directory?(dir)
      Dir.glob("#{dir}/*.rb").sort.each do |file|
        print "Loading plugin (#{file}) ... "
        load file
        puts "done"
      end
    end
  end

  ### object

  def load_object
    load_object_file(SAVEDIR + OBJECT)
  end

  def load_object_file(file)
    if File.exists?(file)
      print "Loading object (#{file}) ... "
      begin
        bind = IRB.conf[:MAIN_CONTEXT].workspace.binding
        hash = Marshal.load(File.read(file))
        hash.each do |k, v|
          begin
            Thread.current[:restore_value] = v
            eval("#{k} = Thread.current[:restore_value]", bind)
          rescue
            puts "Warning: object '#{k}' couldn't be loaded : #{$!}"
          end
        end
      rescue
        warn "Error: Failed to load (#{file}) : #{$!}"
      end
      puts "done"
    end
  end
  
  def save_object
    save_object_file(SAVEDIR + OBJECT)
  end

  def save_object_file(file)
    begin
      print "Saving object (#{file}) ... "
      File.open(file, "w") do |f|
        begin
          bind = IRB.conf[:MAIN_CONTEXT].workspace.binding
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
        rescue
          warn "Error: Failed to dump (#{file}) : #{$!}"
        end
      end
      puts "done"
    rescue
      warn "Error: Failed to save (#{file}) : #{$!}"
    end
  end

  ### history

  def load_history
    if @cache[:readline]
      load_history_file(SAVEDIR + HISTORY)
    end
  end

  def load_history_file(file)
    if File.exists?(file)
      print "Loading history (#{file}) ... "
      File.open(file).each do |line|
        #Readline::HISTORY.push line.chomp
	date, hist = line.chomp.split("\t")
        Readline::HISTORY.push hist if hist
      end
      puts "done"
    end
  end
  
  def save_history
    if @cache[:readline]
      save_history_file(SAVEDIR + HISTORY)
    end
  end

  def save_history_file(file)
    begin
      print "Saving history (#{file}) ... "
      File.open(file, "w") do |f|
        f.puts Readline::HISTORY.to_a
      end
      puts "done"
    rescue
      warn "Error: Failed to save (#{file}) : #{$!}"
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
    puts "-- 8< -- 8< -- 8< --  Script  -- 8< -- 8< -- 8< --"
    @script_begin = Readline::HISTORY.size
  end

  def script_end
    puts "-- >8 -- >8 -- >8 --  Script  -- >8 -- >8 -- >8 --"
    @script_end = Readline::HISTORY.size - 2
  end

  def save_script
    if @script_begin and @script_end and @script_begin <= @script_end
      if File.exists?(SCRIPT)
        message = "Overwrite script file (#{SCRIPT})? [y/n] "
      else
        message = "Save script file (#{SCRIPT})? [y/n] "
      end
      if ask_yes_or_no(message)
        save_script_file(SCRIPT)
      else
        puts " ... save aborted."
      end 
    elsif @script_begin and @script_end and @script_begin - @script_end == 1
      puts " ... script aborted."
    else
      puts "Error: Script range #{@script_begin}..#{@script_end} is invalid"
    end
  end

  def save_script_file(file)
    begin
      print "Saving script (#{file}) ... "
        File.open(file, "w") do |f|
        f.puts "#!/usr/bin/env bioruby"
        f.puts
        f.puts Readline::HISTORY.to_a[@script_begin..@script_end]
        f.puts
      end
      puts "done"
    rescue
      @script_begin = nil
      warn "Error: Failed to save (#{file}) : #{$!}"
    end
  end

  ### splash

  def splash_message
    @config[:message] ||= MESSAGE
    @config[:message].to_s.split(//).join(" ")
  end

  def splash_message_color
    str = splash_message
    ruby = ESC_SEQ[:ruby]
    none = ESC_SEQ[:none]
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
    c = ESC_SEQ
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
    puts
    if @config[:splash]
      if @config[:color]
        splash_message_action_color
      else
        splash_message_action
      end
    end
    if @config[:color]
      print splash_message_color
    else
      print splash_message
    end
    puts
    puts
    print "  Version : BioRuby #{Bio::BIORUBY_VERSION.join(".")}"
    print " / Ruby #{RUBY_VERSION}"
    puts
    puts
  end

  def closing_splash
    puts
    puts
    if @config[:color]
      print splash_message_color
    else
      print splash_message
    end
    puts
    puts
  end

end

