require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/codeml/report'

BIORUBY_ROOT  = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
TEST_DATA = Pathname.new(File.join(BIORUBY_ROOT, 'test', 'data', 'codeml')).cleanpath.to_s

class TestCodemlReport < Test::Unit::TestCase

  EXAMPLE_REPORT = Bio::CodeML::Report.new(File.open(TEST_DATA + '/output.txt').read)

  def test_tree_log_likelihood
    assert_equal(EXAMPLE_REPORT.tree_log_likelihood,-1817.465211)
  end

  def test_tree_length
    assert_equal(EXAMPLE_REPORT.tree_length,0.77902)
  end

  def test_alpha
    assert_equal(EXAMPLE_REPORT.alpha,0.58871)
  end

end
