#
# = bio/version.rb - BioRuby version information
#
# Copyright::	Copyright (C) 2001-2009
#		Toshiaki Katayama <k@bioruby.org>,
#               Naohisa Goto <ng@bioruby.org>
# License::	The Ruby License
#

module Bio

  # BioRuby version (Array containing Integer)
  BIORUBY_VERSION = [1, 4, 2].extend(Comparable).freeze

  # Extra version specifier (String or nil).
  # Existance of the value indicates pre-release version or modified version.
  BIORUBY_EXTRA_VERSION = ".5000"

  # Version identifier, including extra version string (String)
  # Unlike BIORUBY_VERSION, it is not comparable.
  BIORUBY_VERSION_ID =
    (BIORUBY_VERSION.join('.') + BIORUBY_EXTRA_VERSION.to_s).freeze

end #module Bio

