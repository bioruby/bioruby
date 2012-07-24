#
# = bio/io/das.rb - BioDAS access module
#
# Copyright::	Copyright (C) 2003, 2004, 2007
#		Shuichi Kawashima <shuichi@hgc.jp>,
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
# $Id:$
#
#--
# == TODO
#
#  link, stylesheet
#
#++
#

begin
  require 'rexml/document'
rescue LoadError
end
require 'bio/command'
require 'bio/sequence'


module Bio

class DAS

  # Specify DAS server to connect
  def initialize(url = 'http://www.wormbase.org:80/db/')
    @server = url.chomp('/')
  end

  def dna(dsn, entry_point, start, stop)
    seg = Bio::DAS::SEGMENT.region(entry_point, start, stop)
    self.get_dna(dsn, seg).first.sequence
  end

  def features(dsn, entry_point, start, stop)
    seg = Bio::DAS::SEGMENT.region(entry_point, start, stop)
    self.get_features(dsn, seg)
  end


  # Returns an Array of Bio::DAS::DSN
  def get_dsn
    ary = []
    result = Bio::Command.post_form("#{@server}/das/dsn")
    doc = REXML::Document.new(result.body)
    doc.elements.each('/descendant::DSN') do |e|
      dsn = DSN.new
      e.elements.each do |e2|
        case e2.name
        when 'SOURCE'
          dsn.source = e2.text
          dsn.source_id = e2.attributes['id']
          dsn.source_version = e2.attributes['version']
        when 'MAPMASTER'
          dsn.mapmaster = e2.text
        when 'DESCRIPTION'
          dsn.description = e2.text
          dsn.description_href = e2.attributes['href']
        end
      end
      ary << dsn
    end
    ary
  end

  # Returns Bio::DAS::ENTRY_POINT.
  # The 'dsn' can be a String or a Bio::DAS::DSN object.
  def get_entry_points(dsn)
    entry_point = ENTRY_POINT.new
    if dsn.instance_of?(Bio::DAS::DSN)
      src = dsn.source 
    else
      src = dsn
    end
    result = Bio::Command.post_form("#{@server}/das/#{src}/entry_points")
    doc = REXML::Document.new(result.body)
    doc.elements.each('/descendant::ENTRY_POINTS') do |e|
      entry_point.href = e.attributes['href']
      entry_point.version = e.attributes['version']
      e.elements.each do |e2|
        segment = SEGMENT.new
        segment.entry_id = e2.attributes['id']
        segment.start = e2.attributes['start']
        segment.stop = e2.attributes['stop'] || e2.attributes['size']
        segment.orientation = e2.attributes['orientation']
        segment.subparts = e2.attributes['subparts']
        segment.description = e2.text
        entry_point.segments << segment
      end
    end
    entry_point
  end

  # Returns an Array of Bio::DAS::DNA.
  # The 'dsn' can be a String or a Bio::DAS::DSN object.
  # The 'segments' can be a Bio::DAS::SEGMENT object or an Array of
  # Bio::DAS::SEGMENT
  def get_dna(dsn, segments)
    ary = []

    dsn = dsn.source if dsn.instance_of?(DSN)
    segments = [segments] if segments.instance_of?(SEGMENT)

    opts = []
    segments.each do |s|
      opts << "segment=#{s.entry_id}:#{s.start},#{s.stop}"
    end

    result = Bio::Command.post_form("#{@server}/das/#{dsn}/dna", opts)
    doc = REXML::Document.new(result.body)
    doc.elements.each('/descendant::SEQUENCE') do |e|
      sequence = DNA.new
      sequence.entry_id = e.attributes['id']
      sequence.start = e.attributes['start']
      sequence.stop = e.attributes['stop']
      sequence.version = e.attributes['version']
      e.elements.each do |e2|
        sequence.sequence = Bio::Sequence::NA.new(e2.text)
        sequence.length = e2.attributes['length'].to_i
      end
      ary << sequence
    end
    ary
  end

  # Returns an Array of Bio::DAS::SEQUENCE.
  # The 'dsn' can be a String or a Bio::DAS::DSN object.
  # The 'segments' can be a Bio::DAS::SEGMENT object or an Array of
  # Bio::DAS::SEGMENT
  def get_sequence(dsn, segments)
    ary = []

    dsn = dsn.source if dsn.instance_of?(DSN)
    segments = [segments] if segments.instance_of?(SEGMENT)

    opts = []
    segments.each do |s|
      opts << "segment=#{s.entry_id}:#{s.start},#{s.stop}"
    end

    result = Bio::Command.post_form("#{@server}/das/#{dsn}/sequence", opts)
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

  # Returns a Bio::DAS::TYPES object.
  # The 'dsn' can be a String or a Bio::DAS::DSN object.
  # The 'segments' is optional and can be a Bio::DAS::SEGMENT object or
  # an Array of Bio::DAS::SEGMENT
  def get_types(dsn, segments = [])	# argument 'type' is deprecated
    types = TYPES.new

    dsn = dsn.source if dsn.instance_of?(DSN)
    segments = [segments] if segments.instance_of?(SEGMENT)

    opts = []
    segments.each do |s|
      opts << "segment=#{s.entry_id}:#{s.start},#{s.stop}"
    end

    result = Bio::Command.post_form("#{@server}/das/#{dsn}/types", opts)
    doc = REXML::Document.new(result.body)
    doc.elements.each('/descendant::GFF') do |e|
      types.version = e.attributes['version']
      types.href = e.attributes['href']
      e.elements.each do |e2|
        segment = SEGMENT.new
        segment.entry_id = e2.attributes['id']
        segment.start = e2.attributes['start']
        segment.stop = e2.attributes['stop']
        segment.version = e2.attributes['version']
        segment.label = e2.attributes['label']
        e2.elements.each do |e3|
          t = TYPE.new
          t.entry_id = e3.attributes['id']
          t.method = e3.attributes['method']
          t.category = e3.attributes['category']
          t.count = e3.text.to_i
          segment.types << t
        end
        types.segments << segment
      end
    end
    types
  end

  # Returns a Bio::DAS::GFF object.
  # The 'dsn' can be a String or a Bio::DAS::DSN object.
  # The 'segments' is optional and can be a Bio::DAS::SEGMENT object or
  # an Array of Bio::DAS::SEGMENT
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

    result = Bio::Command.post_form("#{@server}/das/#{dsn}/features", opts)
    doc = REXML::Document.new(result.body)
    doc.elements.each('/descendant::GFF') do |e|
      gff.version = e.attributes['version']
      gff.href = e.attributes['href']
      e.elements.each('SEGMENT') do |e2|
        segment = SEGMENT.new
        segment.entry_id = e2.attributes['id']
        segment.start = e2.attributes['start']
        segment.stop = e2.attributes['stop']
        segment.version = e2.attributes['version']
        segment.label = e2.attributes['label']
        e2.elements.each do |e3|
          feature = FEATURE.new
          feature.entry_id = e3.attributes['id']
          feature.label = e3.attributes['label']
          e3.elements.each do |e4|
            case e4.name
            when 'TYPE'
              type = TYPE.new
              type.entry_id = e4.attributes['id']
              type.category = e4.attributes['category']
              type.reference = e4.attributes['referrence']
              type.label = e4.text
              feature.types << type
            when 'METHOD'
              feature.method_id = e4.attributes['id']
              feature.method = e4.text
            when 'START'
              feature.start = e4.text
            when 'STOP', 'END'
              feature.stop = e4.text
            when 'SCORE'
              feature.score = e4.text
            when 'ORIENTATION'
              feature.orientation = e4.text
            when 'PHASE'
              feature.phase = e4.text
            when 'NOTE'
              feature.notes << e4.text
            when 'LINK'
              link = LINK.new
              link.href = e4.attributes['href']
              link.text = e4.text
              feature.links << link
            when 'TARGET'
              target = TARGET.new
              target.entry_id = e4.attributes['id']
              target.start = e4.attributes['start']
              target.stop = e4.attributes['stop']
              target.name = e4.text
              feature.targets << target
            when 'GROUP'
              group = GROUP.new
              group.entry_id = e4.attributes['id']
              group.label = e4.attributes['label']
              group.type = e4.attributes['type']
              e4.elements.each do |e5|
                case e5.name
                when 'NOTE'		# in GROUP
                  group.notes << e5.text
                when 'LINK'		# in GROUP
                  link = LINK.new
                  link.href = e5.attributes['href']
                  link.text = e5.text
                  group.links << link
                when 'TARGET'		# in GROUP
                  target = TARGET.new
                  target.entry_id = e5.attributes['id']
                  target.start = e5.attributes['start']
                  target.stop = e5.attributes['stop']
                  target.name = e5.text
                  group.targets << target
                end
              end
              feature.groups << group
            end
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

    def each
      @segments.each do |x|
        yield x
      end
    end
  end

  class SEGMENT
    def self.region(entry_id, start, stop)
      segment = self.new
      segment.entry_id = entry_id
      segment.start = start
      segment.stop = stop
      return segment
    end

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

end # module Bio

