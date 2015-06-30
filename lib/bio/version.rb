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
  BIORUBY_VERSION = [1, 5, 0].extend(Comparable).freeze

  # Extra version specifier (String or nil).
  # Existance of the value indicates development version.
  #
  # nil                 :: Release version.
  # "-dev"              :: Development version (with YYYYMMDD digits).
  # ".20150630"         :: Development version (specify the date digits).
  #
  # By default, if the third digit (teeny) of BIORUBY_VERSION is 0,
  # the version is regarded as a development version.
  BIORUBY_EXTRA_VERSION =
    nil #(BIORUBY_VERSION[2] == 0) ? "-dev" : nil

  # Version identifier, including extra version string (String)
  # Unlike BIORUBY_VERSION, it is not comparable.
  BIORUBY_VERSION_ID =
    (BIORUBY_VERSION.join('.') + BIORUBY_EXTRA_VERSION.to_s).freeze

end #module Bio

