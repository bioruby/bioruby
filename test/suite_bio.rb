#
# suite_bio.rb - Unit test suite for the BioRuby classes
#
#   Copyright (C) 2004 Moses Hohman <mmhohman@northwestern.edu>
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
#  $Id: suite_bio.rb,v 1.1 2004/11/12 02:27:08 k Exp $
#

require 'pathname'
testpath = Pathname.new(File.join(File.dirname(__FILE__), "..")).cleanpath.to_s
$:.unshift(testpath) unless $:.include?(testpath)

require 'bio/test_alignment'
require 'bio/test_location'
require 'bio/test_pathway'
require 'bio/test_sequence'

