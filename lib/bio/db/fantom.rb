#
# bio/db/fantom.rb - RIKEN FANTOM2 database classes
#
#   Copyright (C) 2003 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
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
#  $Id: fantom.rb,v 1.2 2003/04/24 15:25:13 ng Exp $
#

begin
  require 'rexml/document'
  rescue LoadError
end

require 'bio/db'
require 'bio/sequence'

module Bio

  module FANTOM

    class MaXML < DB
      # DTD of MaXML(Mouse annotation XML)
      # http://fantom.gsc.riken.go.jp/maxml/maxml.dtd

      DELIMITER = RS = "\n--EOF--\n"
      # This class is for {allseq|repseq|allclust}.sep.xml,
      # not for {allseq|repseq|allclust}.xml.

      Data_XPath = ''

      def initialize(x)
	if x.is_a?(REXML::Element) then
	  @elem = x
	else
	  if x.is_a?(String) then
	    x = x.sub(/#{Regexp.escape(DELIMITER)}\z/om, "\n")
	  end
	  doc = REXML::Document.new(x)
	  @elem = doc.elements[self.class::Data_XPath]
	  raise 'element is null' unless @elem
	end
      end

      attr_reader :elem

      def gsub_entities(str)
	# workaround for bug?
	if str then
	  str.gsub(/\&\#(\d{1,3})\;/) { sprintf("%c", $1.to_i) }
	else
	  str
	end
      end

      def entry_id
	unless defined?(@entry_id)
	  @entry_id = @elem.attributes['id']
	end
	@entry_id
      end
      def self.define_element_text_method(array)
	array.each do |tagstr|
	  module_eval ("
	    def #{tagstr}
	      unless defined?(@#{tagstr})
		@#{tagstr} = gsub_entities(@elem.text('#{tagstr}'))
	      end
	      @#{tagstr}
	    end
	  ")
	end
      end
      private_class_method :define_element_text_method

      class Cluster < MaXML
	# (MaXML cluster)
	# ftp://fantom2.gsc.riken.go.jp/fantom/2.1/allclust.sep.xml.gz

	Data_XPath = 'maxml-clusters/cluster'

	def representative_seqid
	  unless defined?(@representative_seqid)
	    @representative_seqid =
	      gsub_entities(@elem.text('representative-seqid'))
	  end
	  @representative_seqid
	end

	def sequences
	  unless defined?(@sequences)
	    @sequences = MaXML::Sequences.new(@elem)
	  end
	  @sequences
	end

	def sequence(idstr)
	  sequences[idstr]
	end

	define_element_text_method(%w(fantomid))
      end #class MaXML::Cluster

      class Sequences < MaXML
	Data_XPath = 'maxml-sequences'

	include Enumerable
	def each
	  to_a.each { |x| yield x }
	end

	def to_a
	  unless defined?(@sequences)
	    @sequences = @elem.get_elements('sequence')
	    @sequences.collect! { |e| MaXML::Sequence.new(e) }
	  end
	  @sequences
	end

	def get(idstr)
	  unless defined?(@hash)
	    @hash = {}
	  end
	  unless @hash.member?(idstr) then
	    @hash[idstr] = self.find do |x|
	      x.altid.values.index(idstr)
	    end
	  end
	  @hash[idstr]
	end

	def [](*arg)
	  if arg[0].is_a?(String) and arg.size == 1 then
	    get(arg[0])
	  else
	    to_a[*arg]
	  end
	end
      end #class MaXML::Sequences

      class Sequence < MaXML
	# (MaXML sequence)
	# ftp://fantom2.gsc.riken.go.jp/fantom/2.1/allseq.sep.xml.gz
	# ftp://fantom2.gsc.riken.go.jp/fantom/2.1/repseq.sep.xml.gz
	
	Data_XPath = 'maxml-sequences/sequence'

	def altid(t = nil)
	  unless defined?(@altid)
	    @altid = {}
	    @elem.each_element('altid') do |e|
	      @altid[e.attributes['type']] = gsub_entities(e.text)
	    end
	  end
	  if t then
	    @altid[t]
	  else
	    @altid
	  end
	end

	def annotations
	  unless defined?(@annotations)
	    @annotations = @elem.get_elements('annotations/annotation')
	    @annotations.collect! { |e| Annotation.new(e) }
	  end
	  @annotations
	end

	define_element_text_method(%w(seqid fantomid cloneid rearrayid accession annotator version modified_time comment))
      end #class MaXML::Sequence

      class Annotation < MaXML
	def entry_id
	  nil
	end

	class DataSrc < String
	  def initialize(text, href)
	    super(text)
	    @href = href
	  end
	  attr_reader :href
	end

	def datasrc
	  unless defined?(@datasrc)
	    @datasrc = []
	    @elem.each_element('datasrc') do |e|
	      text = e.text
	      href = e.attributes['href']
	      @datasrc << DataSrc.new(gsub_entities(text), gsub_entities(href))
	    end
	  end
	  @datasrc
	end

	define_element_text_method(%w(qualifier srckey anntext evidence))

      end #class MaXML::Annotation

    end #class MaXML

  end #module FANTOM

end #module Bio

=begin

 Bio::FANTOM are database classes treating RIKEN FANTOM2 data.
 FANTOM2 is available at ((<URL:http://fantom2.gsc.riken.go.jp/>)).

= Bio::FANTOM::MaXML::Cluster

 This class is for 'allclust.sep.xml' found at
 ((<URL:ftp://fantom2.gsc.riken.go.jp/fantom/2.1/allclust.sep.xml.gz>)).
 Not that this class is not suitable for 'allclust.xml'.

--- Bio::FANTOM::MaXML::Cluster.new(str)

= Bio::FANTOM::MaXML::Sequences

 The instances of this class are automatically created
 by Bio::FANTOM::MaXML::Cluster class.

 This class can also be used for 'allseq.sep.xml' and 'repseq.sep.xml',
 but you'd better using Bio::FANTOM::MaXML::Sequence class.

 In addition, this class can be used for 'allseq.xml' and 'repseq.xml',
 but you'd better not to use them, becase of the speed is very slow.

= Bio::FANTOM::MaXML::Sequence

 This class is for 'allseq.sep.xml' and 'repseq.sep.xml' found at
 ((<URL:ftp://fantom2.gsc.riken.go.jp/fantom/2.1/allseq.sep.xml.gz>)) and
 ((<URL:ftp://fantom2.gsc.riken.go.jp/fantom/2.1/repseq.sep.xml.gz>)).
 Not that this class is not suitable for 'allseq.xml' and 'repseq.xml'.

 In addition, the instances of this class are automatically created
 by Bio::FANTOM::MaXML::Sequences class.

= Bio::FANTOM::MaXML::Annotation

 The instances of this class are automatically created
 by Bio::FANTOM::MaXML::Sequence class.

= Bio::FANTOM::MaXML::Annotation::DataSrc < String

 The instances of this class are automatically created
 by Bio::FANTOM::MaXML::Annotation class.

= References

* ((<URL:http://fantom2.gsc.riken.go.jp/>))

=end
