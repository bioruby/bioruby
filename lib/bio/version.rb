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
  BIORUBY_VERSION = [1, 4, 3].extend(Comparable).freeze

  # Extra version specifier (String or nil).
  # Existance of the value indicates pre-release version or modified version.
  #
  # nil                 :: Release version.
  # ".0000"..".4999"    :: Release version with patches.
  # ".5000"             :: Development unstable version.
  # ".5001"..".8999"    :: Pre-alpha version.
  # "-alphaN" (N=0..99) :: Alpha version.
  # "-preN"   (N=0..99) :: Pre-release test version.
  # "-rcN"    (N=0..99) :: Release candidate version.
  #
  BIORUBY_EXTRA_VERSION = ".0001"

  # Version identifier, including extra version string (String)
  # Unlike BIORUBY_VERSION, it is not comparable.
  BIORUBY_VERSION_ID =
    (BIORUBY_VERSION.join('.') + BIORUBY_EXTRA_VERSION.to_s).freeze

end #module Bio

