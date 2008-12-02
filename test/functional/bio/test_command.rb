#
# test/unit/bio/test_command.rb - Functional test for external command execution methods in Bio::Command
#
# Copyright::	Copyright (C) 2008
# 		Naohisa Goto <ng@bioruby.org>
# License::	The Ruby License
#
#  $Id:$
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)


require 'test/unit'
require 'tempfile'
require 'bio/command'

module Bio
  class FuncTestCommandCall < Test::Unit::TestCase

    def setup
      case RUBY_PLATFORM
      when /mswin32|bccwin32/
        bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3)).cleanpath.to_s
        cmd = File.expand_path(File.join(bioruby_root, 'test', 'data', 'command', 'echoarg2.bat'))
        @arg = [ cmd, 'test "argument 1"', '"test" argument 2', 'arg3' ]
        @expected = '"""test"" argument 2"'
      else
        cmd = "/bin/echo"
        @arg = [ cmd, "test (echo) command" ]
        @expected = "test (echo) command"
        unless FileTest.executable?(cmd) then
          raise "Unsupported environment: /bin/echo not found"
        end
      end
    end

    def test_call_command
      ret = Bio::Command.call_command(@arg) do |io|
        io.close_write
        io.read
      end
      assert_equal(@expected, ret.to_s.strip)
    end

    def test_call_command_popen
      ret = Bio::Command.call_command_popen(@arg) do |io|
        io.close_write
        io.read
      end
      assert_equal(@expected, ret.to_s.strip)
    end

    def test_call_command_fork
      begin
        ret = Bio::Command.call_command_fork(@arg) do |io|
          io.close_write
          io.read
        end
      rescue Errno::ENOENT, NotImplementedError
        # fork() not supported
        return
      end
      assert_equal(@expected, ret.to_s.strip)
    end

    def test_call_command_open3
      begin
        ret = Bio::Command.call_command_open3(@arg) do |pin, pout, perr| 
          t = Thread.start { perr.read }
          begin
            pin.close
            output = pout.read
          ensure
            t.join
          end
          output
        end
      rescue NotImplementedError
        # fork() not supported
        return
      end
      assert_equal(@expected, ret.to_s.strip)
    end

  end #class FuncTestCommandCall

  class FuncTestCommandQuery < Test::Unit::TestCase

    def setup
      @data = [ "987", "123", "567", "456", "345" ]
      @sorted = @data.sort
      case RUBY_PLATFORM
      when /mswin32|bccwin32/
        @sort = "sort"
        @data = @data.join("\r\n") + "\r\n"
      else
        @sort = "/usr/bin/sort"
        unless FileTest.executable?(@sort) then
          raise "Unsupported environment: /usr/bin/sort not found"
        end
        @data = @data.join("\n") + "\n"
      end
    end

    def test_query_command
      ary = [ @sort ]
      assert_equal('', Bio::Command.query_command(ary).to_s.strip)
      str = Bio::Command.query_command(ary, @data).to_s
      assert_equal(@sorted, str.strip.split(/\s+/))
    end

    def test_query_command_popen
      ary = [ @sort ]
      assert_equal('', Bio::Command.query_command_popen(ary).to_s.strip)
      str = Bio::Command.query_command_popen(ary, @data).to_s
      assert_equal(@sorted, str.strip.split(/\s+/))
    end

    def test_query_command_fork
      ary = [ @sort ]
      begin
        str = Bio::Command.query_command_fork(ary).to_s
      rescue Errno::ENOENT, NotImplementedError
        # fork() not supported
        return
      end
      assert_equal('', str.strip)
      str = Bio::Command.query_command_fork(ary, @data).to_s
      assert_equal(@sorted, str.strip.split(/\s+/))
    end

    def test_query_command_open3
      ary = [ @sort ]
      begin
        str, err = Bio::Command.query_command_open3(ary)
      rescue NotImplementedError
        # fork() not supported
        return
      end
      assert_equal('', str.to_s.strip)
      str, err = Bio::Command.query_command_open3(ary, @data)
      assert_equal(@sorted, str.to_s.strip.split(/\s+/))
    end
  end #class FuncTestCommandQuery

  class FuncTestCommandChdir < Test::Unit::TestCase
    def setup
      case RUBY_PLATFORM
      when /mswin32|bccwin32/
        @arg = [ 'dir', '/B', '/-P' ]
      else
        cmd = '/bin/ls'
        @arg = [ cmd ]
        unless FileTest.executable?(cmd) then
          raise "Unsupported environment: #{cmd} not found"
        end
      end
      @tempfile = Tempfile.new('chdir')
      @tempfile.close(false)
      @filename = File.basename(@tempfile.path)
      @dirname = File.dirname(@tempfile.path)
    end

    def teardown
      @tempfile.close(true)
    end

    def test_call_command_chdir
      str = nil
      Bio::Command.call_command(@arg, { :chdir => @dirname }) do |io|
        io.close_write
        str = io.read
      end
      assert(str.index(@filename))
    end

    def test_call_command_popen_chdir
      str = nil
      Bio::Command.call_command_popen(@arg,
                                      { :chdir => @dirname }) do |io|
        io.close_write
        str = io.read
      end
      assert(str.index(@filename))
    end

    def test_call_command_fork_chdir
      str = nil
      begin
        Bio::Command.call_command_fork(@arg, 
                                       { :chdir => @dirname }) do |io|
          io.close_write
          str = io.read
        end
      rescue Errno::ENOENT, NotImplementedError
        # fork() not supported
        return
      end
      assert(str.index(@filename))
    end

    def test_query_command_chdir
      str = Bio::Command.query_command(@arg, nil,
                                       { :chdir => @dirname }).to_s
      assert(str.index(@filename))
    end

    def test_query_command_popen_chdir
      str = Bio::Command.query_command_popen(@arg, nil,
                                             { :chdir => @dirname }).to_s
      assert(str.index(@filename))
    end

    def test_query_command_fork_chdir
      begin
        str = Bio::Command.query_command_fork(@arg, nil,
                                              { :chdir => @dirname }).to_s
      rescue Errno::ENOENT, NotImplementedError
        # fork() not supported
        return
      end
      assert(str.index(@filename))
    end
  end #class FuncTestCommandChdir

  class FuncTestCommandBackports < Test::Unit::TestCase
    def setup
      if RUBY_VERSION < "1.8.3"
        @notest = true
      else
        @notest = false
      end
    end

    def test_remove_entry_secure
      return if @notest
      begin
        tempfile = Tempfile.new('removed')
        tempfile.close(false)
        assert(File.exist?(tempfile.path))
        Bio::Command.remove_entry_secure(tempfile.path)
        assert_equal(false, File.exist?(tempfile.path))
      ensure
        tempfile.close(true) if tempfile
      end
    end

    def test_mktmpdir_with_block
      return if @notest
      tmpdirpath = nil
      Bio::Command.mktmpdir('bioruby') do |path|
        tmpdirpath = path
        assert(File.directory?(path))
        assert_nothing_raised {
          File.open(File.join(path, 'test'), 'w') do |w|
            w.print "This is test."
          end
        }
      end
      assert_equal(false, File.directory?(tmpdirpath))
    end

    def test_mktmpdir_without_block
      return if @notest
      path = nil
      begin
        assert_nothing_raised {
          path = Bio::Command.mktmpdir('bioruby')
        }
        assert(File.directory?(path))
        assert_nothing_raised {
          File.open(File.join(path, 'test'), 'w') do |w|
            w.print "This is test."
          end
        }
      ensure
        Bio::Command.remove_entry_secure(path) if path
      end
    end
  end #class FuncTestCommandBackports

  class FuncTestCommandNet < Test::Unit::TestCase
    def test_read_uri
      assert_nothing_raised {
        Bio::Command.read_uri("http://bioruby.open-bio.org/")
      }
    end

    def test_start_http
    end

    def test_new_http
    end

    def test_post_form
    end
  end #class FuncTestCommandNet
end #module Bio
