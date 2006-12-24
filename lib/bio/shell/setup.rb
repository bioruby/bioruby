#
# = bio/shell/setup.rb - setup initial environment for the BioRuby shell
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: setup.rb,v 1.1 2006/12/24 08:32:08 k Exp $
#

require 'getoptlong'

class Bio::Shell::Setup

  def initialize
    check_ruby_version

    # command line options
    getoptlong

    # setup working directory
    setup_workdir

    # load configuration and plugins
    Dir.chdir(@workdir)
    Bio::Shell.configure
    Bio::Shell.cache[:workdir] = @workdir

    # set default to irb mode
    @mode ||= :irb

    case @mode
    when :web
      # setup rails server
      Bio::Shell::Web.new
    when :irb
      # setup irb server
      Bio::Shell::Irb.new
    when :script
      # run bioruby shell script
      Bio::Shell::Script.new(@script)
    end
  end

  def check_ruby_version
    if RUBY_VERSION < "1.8.2"
      raise "BioRuby shell runs on Ruby version >= 1.8.2"
    end
  end

  # command line argument (working directory or bioruby shell script file)
  def getoptlong
    opts = GetoptLong.new
    opts.set_options(
      [ '--rails',   '-r',  GetoptLong::NO_ARGUMENT ],
      [ '--web',     '-w',  GetoptLong::NO_ARGUMENT ],
      [ '--console', '-c',  GetoptLong::NO_ARGUMENT ],
      [ '--irb',     '-i',  GetoptLong::NO_ARGUMENT ]
    )
    opts.each_option do |opt, arg|
      case opt
      when /--rails/, /--web/
        @mode = :web
      when /--console/, /--irb/
        @mode = :irb
      end
    end
  end

  def setup_workdir
    arg = ARGV.shift

    # Options after the '--' argument are not parsed by GetoptLong and
    # are passed to irb or rails.  This hack preserve the first option
    # when working directory of the project is not given.
    if arg and arg[/^-/]
      ARGV.unshift arg
      arg = nil
    end
    
    if arg.nil?
      # run in current directory
      @workdir = current_workdir
    elsif File.directory?(arg)
      # run in existing directory
      @workdir = arg
    elsif File.file?(arg)
      # run file as a bioruby shell script
      @workdir = File.join(File.dirname(arg), "..")
      @script = File.basename(arg)
      @mode = :script
    else
      # run in new directory
      @workdir = install_workdir(arg)
    end
  end

  def current_workdir
    unless File.exists?(Bio::Shell.datadir)
      message = "Are you sure to start new session in this directory? [y/n] "
      unless Bio::Shell.ask_yes_or_no(message)
        exit
      end
    end
    return '.'
  end

  def install_workdir(workdir)
    FileUtils.mkdir_p(workdir)
    return workdir
  end

end # Setup
