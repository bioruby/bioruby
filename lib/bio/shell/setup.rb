#
# = bio/shell/setup.rb - setup initial environment for the BioRuby shell
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: setup.rb,v 1.7 2007/06/26 08:38:38 k Exp $
#

require 'getoptlong'

class Bio::Shell::Setup

  def initialize
    check_ruby_version

    # command line options
    getoptlong

    # setup working directory
    workdir = setup_workdir

    # load configuration and plugins
    #Dir.chdir(workdir) if workdir # changed not chdir
    Bio::Shell.configure(workdir)

    # set default to irb mode
    Bio::Shell.cache[:mode] = @mode || :irb

    case Bio::Shell.cache[:mode]
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
      # run in the current directory
      workdir = File.join(ENV['HOME'].to_s, ".bioruby")
      install_workdir(workdir)
    elsif File.directory?(arg)
      # run in the existing directory
      workdir = File.join(Dir.pwd, arg)
    elsif File.file?(arg)
      # run file as a bioruby shell script (slightly tricky)
      workdir = File.join(File.dirname(arg), "..")
      @script = arg
      @mode = :script
    else
      # run in new directory
      workdir = File.join(Dir.pwd, arg)
      install_workdir(workdir)
    end

    return workdir
  end

  def install_workdir(workdir)
    FileUtils.mkdir_p(workdir)
  end

end # Setup
