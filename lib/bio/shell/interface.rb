#
# = bio/shell/session.rb - core user interface of the BioRuby shell
#
# Copyright::	Copyright (C) 2005
#		Toshiaki Katayama <k@bioruby.org>
# Lisence::	LGPL
#
# $Id: interface.rb,v 1.4 2005/11/06 18:28:48 k Exp $
#
#--
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#++
#

module Bio::Shell

  private

  ### work space

  def ls
    list = eval("local_variables", conf.workspace.binding).reject { |x|
      eval(x, conf.workspace.binding).nil?
    }
    display list.inspect
  end

  def rm(name)                  # name = :hoge
    begin
      eval("#{name} = nil", conf.workspace.binding)
    rescue
      puts "Usage: rm :var (rm var is not valid)"
    end
  end

  ### config

  def config(mode = :show, *opts)
    Bio::Shell.config(mode, *opts)
  end

  ### script

  def script(mode = nil)
    Bio::Shell.script(mode)
  end

  ### plugin

  def reload_plugin
    Bio::Shell.load_plugin
  end

  ### pager

  #--
  # mysql> pager less
  #++
  def display(*obj)
    # The original idea is from http://sheepman.parfait.ne.jp/20050215.html
    if $bioruby_config[:PAGER]
      pg = IO.popen($bioruby_config[:PAGER], "w")
      begin
        stdout_save = STDOUT.clone
        STDOUT.reopen(pg)
        puts(*obj)
      ensure
        STDOUT.reopen(stdout_save)
        stdout_save.close
        pg.close
      end
    else
      puts(*obj)
    end
  end

  ### file system

  def cd(dir = ENV['HOME'])
    if dir
      Dir.chdir(dir)
    end
    display Dir.pwd.inspect
  end

  def pwd
    display Dir.pwd.inspect
  end

  def dir(file = nil)
    if file
      if File.directory?(file)
        files = Dir.glob("#{file}/*")
      else
        files = Dir.glob(file)
      end
    else
      files = Dir.glob("*")
    end
    if files
      str  = "   UGO  Date                                 Byte  File\n"
      str << "------  ----------------------------  -----------  ------------\n"
      files.sort.each { |f|
        stat = File.lstat(f)
        mode = format("%6o", stat.mode)
        date = stat.mtime
        byte = stat.size
        name = f.inspect
        str << format("%s  %s%13d  %s\n", mode, date, byte, name)
      }
      display str
    end
  end

  def head(file, num = 10)
    str = ""
    File.open(file) do |f|
      num.times do
        if line = f.gets
          str << line
        end
      end
    end
    display str
  end

end


