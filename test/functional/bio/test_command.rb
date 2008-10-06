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
require 'bio/command'

module Bio
  class FuncTestCommandCall < Test::Unit::TestCase

    def setup
      case RUBY_PLATFORM
      when /mswin32|bccwin32/
        @echo = "echo"
      else
        @echo = "/bin/echo"
        unless FileTest.executable?(@echo) then
          raise "Unsupported environment: /bin/echo not found"
        end
      end
    end

    def test_call_command
      ary = [ @echo, "test (echo) command" ]
      ret = Bio::Command.call_command(ary) do |io|
        io.close_write
        io.read
      end
      assert_equal("test (echo) command", ret.to_s.strip)
    end

    def test_call_command_popen
      ary = [ @echo, "test (echo) command" ]
      ret = Bio::Command.call_command_popen(ary) do |io|
        io.close_write
        io.read
      end
      assert_equal("test (echo) command", ret.to_s.strip)
    end

    def test_call_command_fork
      ary = [ @echo, "test (echo) command" ]
      begin
        ret = Bio::Command.call_command_fork(ary) do |io|
          io.close_write
          io.read
        end
      rescue Errno::ENOENT, NotImplementedError
        # fork() not supported
        return
      end
      assert_equal("test (echo) command", ret.to_s.strip)
    end

    def test_call_command_open3
      ary = [ @echo, "test (echo) command" ]
      begin
        ret = Bio::Command.call_command_open3(ary) do |pin, pout, perr| 
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
      assert_equal("test (echo) command", ret.to_s.strip)
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
        str = Bio::Command.query_command_open3(ary).to_s
      rescue NotImplementedError
        # fork() not supported
        return
      end
      assert_equal('', str.strip)
      str = Bio::Command.query_command_open3(ary, @data).to_s
      assert_equal(@sorted, str.strip.split(/\s+/))
    end
  end #class FuncTestCommandQuery

  class FuncTestCommandNet < Test::Unit::TestCase
    def test_read_uri
      assert_nothing_raised {
        Bio::Command.read_uri("http://bioruby.org/")
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
