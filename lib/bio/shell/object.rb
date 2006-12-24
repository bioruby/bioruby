#
# = bio/shell/object.rb - Object extension for the BioRuby shell
#
# Copyright::   Copyright (C) 2006
#               Nobuya Tanaka <t@chemruby.org>,
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: object.rb,v 1.2 2006/12/24 08:40:00 k Exp $
#

require 'pp'
require 'cgi'
require 'yaml'

### Object extention

class Object
  # Couldn't work for Fixnum (Marshal)
  attr_accessor :memo

  def output(format = :yaml)
    case format
    when :yaml
      self.to_yaml
    when :html
      format_html
    when :inspect
      format_pp
    when :png
      # *TODO*
    when :svg
      # *TODO*
    when :graph
      # *TODO* (Gruff, RSRuby etc.)
    else
      #self.inspect.to_s.fold(80)
      self.to_s
    end
  end

  private

  def format_html
    "<pre>#{CGI.escapeHTML(format_pp)}</pre>"
  end

  def format_pp
    str = ""
    PP.pp(self, str)
    return str
  end

end

class Hash

  private

  def format_html
    html = ""
    html += "<table>"
    @data.each do |k, v|
      html += "<tr><td>#{k}</td><td>#{v}</td></tr>"
    end
    html += "</table>"
    return html
  end

end

