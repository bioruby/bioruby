# to be removed
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

#require 'bio/util/restriction_enzyme/analysis/shared_information'
#require 'bio'

module Bio; end
class Bio::RestrictionEnzyme
class Analysis

class Tags < Hash
end

end
end
