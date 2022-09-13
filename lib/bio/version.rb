#
# = bio/version.rb - BioRuby version information
#
# Copyright::	Copyright (C) 2001-2012
#		Toshiaki Katayama <k@bioruby.org>,
#               Naohisa Goto <ng@bioruby.org>
# License::	The Ruby License
#

module Bio

  # BioRuby version (Array containing Integer)
  BIORUBY_VERSION = [2, 0, 4].extend(Comparable).freeze

  # Extra version specifier (String or nil).
  # Existance of the value indicates development version.
  #
  # nil             :: Release version.
  # ".pre           :: Pre-release version.
  #
  # References: https://guides.rubygems.org/patterns/#prerelease-gems
  BIORUBY_EXTRA_VERSION = nil
    #".pre"

  # Version identifier, including extra version string (String)
  # Unlike BIORUBY_VERSION, it is not comparable.
  BIORUBY_VERSION_ID =
    (BIORUBY_VERSION.join('.') + BIORUBY_EXTRA_VERSION.to_s).freeze

end #module Bio

