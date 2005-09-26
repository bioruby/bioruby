= Incompatible and important changes since the BioRuby 0.6.4 release

A lot of changes have been made to the BioRuby after the version 0.6.4
is released.

--- Ruby 1.6 series are no longer supported.

We use autoload functionality and many other libraries bundled in
Ruby 1.8.2 (such as SOAP, open-uri, pp etc.) by default.

--- BioRuby will be loaded about 30 times faster than before.

As we changed to use autoload instead of require, time required
to start up the BioRuby library made surprisingly faster.

Other changes (including exciting BioRuby shell etc.) made in this release
is described in this file.

== New features

--- BioRuby shell

Command line user interface for the BioRuby is included.
You can invoke the shell by

  % bioruby

--- UnitTest

Test::Unit now covers wide range of the BioRuby library.
You can run them by

  % ruby test/runner.rb

or

  % ruby install.rb config
  % ruby install.rb setup
  % ruby install.rb test

during the installation procedure.

--- Documents

README, README.DEV, doc/Tutorial.rd, doc/Tutorial.rd.ja etc. are updated
or newly added.

== Incompatible changes

--- Bio::Sequence

* Bio::Sequence::NA#gc_percent returns integer instead of float
* Bio::Sequence::NA#gc (was aliased to gc_percent) is removed

In BioRuby, GC% is rounded to one decimal place.  However, how many digits
should be left when rounding the value is not clear and as the GC% is an
rough measure by its nature, we have changed to return integer part only.
If you need a precise value, you can calculate it by values from the
'composition' method by your own criteria.

The 'gc' method is removed as the method name doesn't represent its value
is ambiguous.

