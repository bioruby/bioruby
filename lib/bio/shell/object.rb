#
# = bio/shell/object.rb - Object extension for the BioRuby shell
#
# Copyright::   Copyright (C) 2006
#               Nobuya Tanaka <t@chemruby.org>,
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: object.rb,v 1.1 2006/02/27 09:16:13 k Exp $
#

require 'cgi'
require 'pp'

### Object extention

class Object
  # Couldn't work for Fixnum (Marshal)
  attr_accessor :memo

  # *TODO*
  def to_html
    if self.is_a?(String)
      "<pre>" + self + "</pre>"
    else
      str = ""
      PP.pp(self, str)
      "<pre>" + str + "</pre>"
      #"<pre>" + CGI.escapeHTML(str) + "</pre>"
      #self.inspect
      #"<pre>" + self.inspect + "</pre>"
      #"<pre>" + self.to_s + "</pre>"
    end
  end
end

=begin
module Bio
  class DB
    def to_html
      html = ""
      html += "<table>"
      @data.each do |k, v|
        html += "<tr><td>#{k}</td><td>#{v}</td></tr>"
      end
      html += "</table>"
    end
  end
end
=end

 
