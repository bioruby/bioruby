#
# bio/io/das.rb - BioDAS access module
#
#   Copyright (C) 2003 KAWASHIMA Shuichi <s@bioruby.org>
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
#  $Id: das.rb,v 1.2 2003/02/21 03:36:49 k Exp $
#

begin
  require 'rexml/document'
rescue LoadError
end
require 'uri'
require 'net/http'

module Bio

  class DAS

    def initialize(url = 'http://www.wormbase.org:80/db/')
      schema, user, host, port, path, = URI.parse(url).to_a
      @server = Net::HTTP.new(host, port)
      @prefix = path ? path.chomp('/') : ''
    end

    def get_dsn
      ary = []
      result, = @server.get(@prefix + '/das/dsn')
      doc = REXML::Document.new(result.body)
      doc.elements.each('/descendant::DSN') do |e|
        dsn = DSN.new
        e.elements.each do |e|
	  case e.name
	  when 'SOURCE'
            dsn.source = e.text
            dsn.source_id = e.attributes['id']
            dsn.source_version = e.attributes['version']
          when 'MAPMASTER'
            dsn.mapmaster = e.name
          when 'DESCRIPTION'
            dsn.description = e.text
            dsn.description_href = e.attributes['href']
          end
        end
        ary << dsn
      end
      ary
    end

    def get_entry_point(dsn)
      entry_point = ENTRY_POINT.new
      dsn = dsn.source if dsn.instance_of?(Bio::DAS::DSN)
      result, = @server.get(@prefix + '/das/' + dsn + '/entry_points')
      doc = REXML::Document.new(result.body)
      doc.elements.each('/descendant::ENTRY_POINTS') do |e|
	entry_point.href = e.attributes['href']
	entry_point.version = e.attributes['version']
	e.elements.each('/descendant::SEGMENT') do |e|
	  segment = SEGMENT.new
	  segment.entry_id = e.attributes['id']
	  segment.start = e.attributes['start']
	  segment.stop = e.attributes['stop']
	  segment.stop = e.attributes['orientation']
	  segment.subparts = e.attributes['subparts']
	  segment.description = e.text
	  entry_point.segments << segment
	end
      end
      entry_point
    end

    def get_dna(dsn, segments)
      ary = []

      dsn = dsn.source if dsn.instance_of?(DSN)
      segments = [segments] if segments.instance_of?(SEGMENT)

      opts = []
      segments.each do |s|
	opts << "segment=#{s.entry_id}:#{s.start},#{s.stop}"
      end
      query = opts.join(';')

      result, = @server.get(@prefix + '/das/' + dsn + '/dna?' + query)
      doc = REXML::Document.new(result.body)
      doc.elements.each('/descendant::SEQUENCE') do |e|
	sequence = DNA.new
	sequence.entry_id = e.attributes['id']
	sequence.start = e.attributes['start']
	sequence.stop = e.attributes['stop']
	sequence.version = e.attributes['version']
	e.elements.each('/descendant::DNA') do |e|
	  sequence.sequence = Bio::Sequence::NA.new(e.text)
	  sequence.length = e.attributes['length'].to_i
	end
        ary << sequence
      end
      ary
    end

    def get_sequence(dsn, segments)
      ary = []

      dsn = dsn.source if dsn.instance_of?(DSN)
      segments = [segments] if segments.instance_of?(SEGMENT)

      opts = []
      segments.each do |s|
	opts << "segment=#{s.entry_id}:#{s.start},#{s.stop}"
      end
      query = opts.join(';')

      result, = @server.get(@prefix + '/das/' + dsn + '/sequence?' + query)
      doc = REXML::Document.new(result.body)
      doc.elements.each('/descendant::SEQUENCE') do |e|
	sequence = SEQUENCE.new
	sequence.entry_id = e.attributes['id']
	sequence.start = e.attributes['start']
	sequence.stop = e.attributes['stop']
	sequence.moltype = e.attributes['moltype']
	sequence.version = e.attributes['version']
	case sequence.moltype
	when /dna|rna/i		# 'DNA', 'ssRNA', 'dsRNA'
	  sequence.sequence = Bio::Sequence::NA.new(e.text)
	when /protein/i		# 'Protein
	  sequence.sequence = Bio::Sequence::AA.new(e.text)
	else
	  sequence.sequence = e.text
	end
        ary << sequence
      end
      ary
    end

    def get_types(dsn, segments = [])	# argument 'type' is deprecated
      types = TYPES.new

      dsn = dsn.source if dsn.instance_of?(DSN)
      segments = [segments] if segments.instance_of?(SEGMENT)

      opts = []
      segments.each do |s|
	opts << "segment=#{s.entry_id}:#{s.start},#{s.stop}"
      end
      query = opts.join(';')

      result, = @server.get(@prefix + '/das/' + dsn + '/types?' + query)
      doc = REXML::Document.new(result.body)
      doc.elements.each('/descendant::GFF') do |e|
	types.version = e.attributes['version']
	types.href = e.attributes['href']
	e.elements.each('/descendant::SEGMENT') do |e|
	  segment = SEGMENT.new
	  segment.entry_id = e.attributes['id']
	  segment.start = e.attributes['start']
	  segment.stop = e.attributes['stop']
	  segment.version = e.attributes['version']
	  segment.label = e.attributes['label']
	  e.elements.each('/descendant::TYPE') do |i|
	    t = TYPE.new
	    t.entry_id = i.attributes['id']
	    t.method = i.attributes['method']
	    t.category = i.attributes['category']
	    t.count = i.text.to_i
	    segment.types << t
	  end
	  types.segments << segment
	end
      end
      types
    end

    def get_features(dsn, segments = [], categorize = false, feature_ids = [], group_ids = [])
      # arguments 'type' and 'category' are deprecated
      gff = GFF.new

      dsn = dsn.source if dsn.instance_of?(DSN)
      segments = [segments] if segments.instance_of?(SEGMENT)

      opts = []
      segments.each do |s|
	opts << "segment=#{s.entry_id}:#{s.start},#{s.stop}"
      end
      if categorize
	opts << "categorize=yes"	# default is 'no'
      end
      feature_ids.each do |fid|
	opts << "feature_id=#{fid}"
      end
      group_ids.each do |gid|
	opts << "group_id=#{gid}"
      end
      query = opts.join(';')

      result, = @server.get(@prefix + '/das/' + dsn + '/features?' + query)
      doc = REXML::Document.new(result.body)
      doc.elements.each('/descendant::GFF') do |e|
        gff.version = e.attributes['version']
        gff.href = e.attributes['href']
        e.elements.each('/descendant::SEGMENT') do |e|
	  segment = SEGMENT.new
	  segment.entry_id = e.attributes['id']
	  segment.start = e.attributes['start']
	  segment.stop = e.attributes['stop']
	  segment.version = e.attributes['version']
	  segment.label = e.attributes['label']
	  e.elements.each('/descendant::FEATURE') do |e|
	    feature = FEATURE.new
	    feature.entry_id = e.attributes['id']
	    feature.label = e.attributes['label']
	    e.elements.each('/descendant::TYPE') do |e|
	      t = TYPE.new
	      t.entry_id = e.attributes['id']
	      t.category = e.attributes['category']
	      t.reference = e.attributes['referrence']
	      t.label = e.text
	      feature.type << t
	    end
	    e.elements.each('/descendant::METHOD') do |e|
	      feature.method_id = e.attributes['id']
	      feature.method = e.text
	    end
	    e.elements.each('/descendant::START') do |e|
	      feature.start = e.text
	    end
	    e.elements.each('/descendant::STOP') do |e|
	      feature.stop = e.text
	    end
	    e.elements.each('/descendant::SCORE') do |e|
	      feature.score = e.text
	    end
	    e.elements.each('/descendant::ORIENTATION') do |e|
	      feature.orientation = e.text
	    end
	    e.elements.each('/descendant::PHASE') do |e|
	      feature.phase = e.text
	    end
	    e.elements.each('/descendant::NOTE') do |e|
	      feature.notes << e.text
	    end
	    e.elements.each('/descendant::LINK') do |e|
	      link = LINK.new
	      link.href = e.attributes['href']
	      link.text = e.text
	      feature.links << link
	    end
	    e.elements.each('/descendant::TARGET') do |e|
	      target = TARGET.new
	      target.entry_id = e.attributes['id']
	      target.start = e.attributes['start']
	      target.stop = e.attributes['stop']
	      target.name = e.text
	      feature.targets << target
	    end
	    e.elements.each('/descendant::GROUP') do |e|
	      group = GROUP.new
	      group.entry_id = e.attributes['id']
	      group.label = e.attributes['label']
	      group.type = e.attributes['type']
	      e.elements.each('/descendant::NOTE') do |e|
		group.notes << e.text
	      end
	      e.elements.each('/descendant::LINK') do |e|
		link = LINK.new
		link.href = e.attributes['href']
		link.text = e.text
		group.linkss << link
	      end
	      e.elements.each('/descendant::TARGET') do |e|
		target = TARGET.new
		target.entry_id = e.attributes['id']
		target.start = e.attributes['start']
		target.stop = e.attributes['stop']
		target.text = e.text
		group.targets << target
	      end
	      feature.groups << group
	    end
	    segment.features << feature
	  end
	  gff.segments << segment
	end
      end
      gff
    end


    class DSN
      attr_accessor :source, :source_id, :source_version,
	:mapmaster, :description, :description_href
    end

    class ENTRY_POINT
      def initialize
	@segments = Array.new
      end
      attr_reader :segments
      attr_accessor :href, :version
    end

    class SEGMENT
      def initialize
	@features = Array.new		# for FEATURE
	@types = Array.new		# for TYPE
      end
      attr_accessor :entry_id, :start, :stop, :orientation, :description,
	:subparts,			# optional
	:features, :version, :label,	# for FEATURE
	:types				# for TYPE
    end

    class DNA
      attr_accessor :entry_id, :start, :stop, :version, :sequence, :length
    end

    class SEQUENCE
      attr_accessor :entry_id, :start, :stop, :moltype, :version, :sequence
    end

    class TYPES < ENTRY_POINT; end

    class TYPE
      attr_accessor :entry_id, :method, :category, :count,
	:reference, :label	# for FEATURE
    end

    class GFF
      def initialize
	@segments = Array.new
      end
      attr_reader :segments
      attr_accessor :version, :href
    end

    class FEATURE
      def initialize
	@notes = Array.new
	@links = Array.new
	@types = Array.new
	@targets = Array.new
	@groups = Array.new
      end
      attr_accessor :entry_id, :label,
	:method_id, :method, :start, :stop, :score, :orientation, :phase
      attr_reader :notes, :links, :types, :targets, :groups
    end

    class LINK
      attr_accessor :href, :text
    end

    class TARGET
      attr_accessor :entry_id, :start, :stop, :name
    end

    class GROUP
      def initialize
	@notes = Array.new
	@links = Array.new
	@targets = Array.new
      end
      attr_accessor :entry_id, :label, :type
      attr_reader :notes, :links, :targets
    end

  end
end


if __FILE__ == $0

  begin
    require 'pp'
    alias :p :pp
  rescue LoadError
  end

  wormbase = Bio::DAS.new('www.wormbase.org', 'db', 80)

  p wormbase.get_dsn
  p wormbase.get_dna('elegans', 'I', 0, 1000)
  gff = wormbase.get_features('elegans', 'I', 0, 1000)
  (0..4).each do |i|
    p gff.segment[i]
  end
  gff.segment[5].each do |i|
    puts '<----- feature ----->\n'
    i.each do |j|
      p j
    end
  end

end


=begin

= Bio::DAS

--- Bio::DAS.new

--- Bio::DAS.close

=end
