#
# bio/db/fantom.rb - RIKEN FANTOM2 database classes
#
# Copyright:: Copyright (C) 2003 GOTO Naohisa <ng@bioruby.org> 
# License::   The Ruby License
#
#  $Id: fantom.rb,v 1.14 2007/04/05 23:35:40 trevor Exp $
#

begin
  require 'rexml/document'
  rescue LoadError
end
require 'uri'
require 'net/http'

require 'bio/db'
require 'bio/command'
#require 'bio/sequence'

module Bio

  module FANTOM

    def query(idstr, http_proxy = nil)
      xml = get_by_id(idstr, http_proxy)
      seqs = MaXML::Sequences.new(xml.to_s)
      seqs[0]
    end
    module_function :query

    def get_by_id(idstr, http_proxy = nil)
      addr = 'fantom.gsc.riken.go.jp'
      port = 80
      path = "/db/maxml/maxmlseq.cgi?masterid=#{URI.escape(idstr.to_s)}&style=xml"
      xml = ''
      if http_proxy then
        proxy = URI.parse(http_proxy.to_s)
        Net::HTTP.start(addr, port, proxy.host, proxy.port) do |http|
          response, = http.get(path)
          xml = response.body
        end
      else
        Bio::Command.start_http(addr, port) do |http|
          response, = http.get(path)
          xml = response.body
        end
      end
      xml
    end
    module_function :get_by_id


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
          #raise 'element is null' unless @elem
          @elem = REXML::Document.new('') unless @elem
        end
      end
      attr_reader :elem

      def to_s
        @elem.to_s
      end

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
          module_eval("
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

        def sequence(idstr = nil)
          idstr ? sequences[idstr] : representative_sequence
        end

        def representative_sequence
          unless defined?(@representative_sequence)
            rid = representative_seqid
 	    @representative_sequence =
              rid ? sequences[representative_seqid] : nil
          end
          @representative_sequence
        end
        alias representative_clone representative_sequence

        def representative_annotations
          e = representative_sequence
          e ? e.annotations : nil
        end

        def representative_cloneid
          e = representative_sequence
          e ? e.cloneid : nil
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

        def cloneids
          unless defined?(@cloneids)
            @cloneids = to_a.collect { |x| x.cloneid }
          end
          @cloneids
        end

        def id_strings
          unless defined?(@id_strings)
            @id_strings = to_a.collect { |x| x.id_strings }
            @id_strings.flatten!
            @id_strings.sort!
            @id_strings.uniq!
          end
          @id_strings
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

        def id_strings
          altid.values.sort.uniq
        end

        def library_id
          entry_id[0,2]
        end

        def annotations
          unless defined?(@annotations)
            @annotations =
              MaXML::Annotations.new(@elem.elements['annotations'])
          end
          @annotations
        end

        define_element_text_method(%w(annotator version modified_time comment))

        def self.define_id_method(array)
          array.each do |tagstr|
            module_eval("
              def #{tagstr}
                unless defined?(@#{tagstr})
                  @#{tagstr} = gsub_entities(@elem.text('#{tagstr}'))
                  @#{tagstr} = altid('#{tagstr}') unless @#{tagstr}
                end
                @#{tagstr}
              end
            ")
          end
        end
        private_class_method :define_id_method

        define_id_method(%w(seqid fantomid cloneid rearrayid accession))
      end #class MaXML::Sequence

      class Annotations < MaXML
        Data_XPath = nil

        include Enumerable
        def each
          to_a.each { |x| yield x }
        end

        def to_a
          unless defined?(@a)
            @a = @elem.get_elements('annotation')
            @a.collect! { |e| MaXML::Annotation.new(e) }
          end
          @a
        end

        def get_all_by_qualifier(qstr)
          unless defined?(@hash)
            @hash = {}
          end
          unless @hash.member?(qstr) then
            @hash[qstr] = self.find_all do |x|
              x.qualifier == qstr
            end
          end
          @hash[qstr]
        end

        def get_by_qualifier(qstr)
          a = get_all_by_qualifier(qstr)
          a ? a[0] : nil
        end

        def [](*arg)
          if arg[0].is_a?(String) and arg.size == 1 then
            get_by_qualifier(arg[0])
          else
            to_a[*arg]
          end
        end

        def cds_start
          unless defined?(@cds_start)
            e = get_by_qualifier('cds_start')
            @cds_start = e ? e.anntext.to_i : nil
          end
          @cds_start
        end

        def cds_stop
          unless defined?(@cds_stop)
            e = get_by_qualifier('cds_stop')
            @cds_stop = e ? e.anntext.to_i : nil
          end
          @cds_stop
        end

        def gene_name
          unless defined?(@gene_name)
            e = get_by_qualifier('gene_name')
            @gene_name = e ? e.anntext : nil
          end
          @gene_name
        end

        def data_source
          unless defined?(@data_source)
            e = get_by_qualifier('gene_name')
            @data_source = e ? e.datasrc[0] : nil
          end
          @data_source
        end

        def evidence
          unless defined?(@evidence)
            e = get_by_qualifier('gene_name')
            @evidence = e ? e.evidence : nil
          end
          @evidence
        end
      end #class MaXML::Annotations

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

 Bio::FANTOM are database classes (and modules) treating RIKEN FANTOM2 data.
 FANTOM2 is available at ((<URL:http://fantom2.gsc.riken.go.jp/>)).

= Bio::FANTOM

 This module contains useful methods to access databases.

--- Bio::FANTOM.query(idstr, http_proxy=nil)

 Get MaXML sequence data corresponding to given ID through the internet
 from ((<URL:http://fantom.gsc.riken.go.jp/db/maxml/)).
 Returns Bio::FANTOM::MaXML::Sequence object.

--- Bio::FANTOM.get_by_id(idstr, http_proxy=nil)

 Same as FANTOM.query, but returns XML document as a string.
 (Reference: bio/io/registry.rb)


= Bio::FANTOM::MaXML::Cluster

 This class is for 'allclust.sep.xml' found at
 ((<URL:ftp://fantom2.gsc.riken.go.jp/fantom/2.1/allclust.sep.xml.gz>)).
 Not that this class is not suitable for 'allclust.xml'.

--- Bio::FANTOM::MaXML::Cluster.new(str)

--- Bio::FANTOM::MaXML::Cluster#entry_id

--- Bio::FANTOM::MaXML::Cluster#fantomid

--- Bio::FANTOM::MaXML::Cluster#representative_seqid

--- Bio::FANTOM::MaXML::Cluster#sequences

 Lists sequences in this cluster.
 Returns Bio::FANTOM::MaXML::Sequences object.

--- Bio::FANTOM::MaXML::Cluster#sequence(id_str)

 Shows a sequence information of given id.
 Returns Bio::FANTOM::MaXML::Sequence object or nil.

--- Bio::FANTOM::MaXML::Cluster#representataive_sequence
--- Bio::FANTOM::MaXML::Cluster#representataive_clone

 Shows a sequence of repesentative_seqid.
 Returns Bio::FANTOM::MaXML::Sequence object (or nil).

-- Bio::FANTOM::MaXML::Cluster#representative_annotations

 Shows annotations of repesentative sequence.
 Returns Bio::FANTOM::MaXML::Annotations object (or nil).

-- Bio::FANTOM::MaXML::Cluster#representative_cloneid

 Shows cloneid of repesentative sequence.
 Returns String (or nil).


= Bio::FANTOM::MaXML::Sequences

 The instances of this class are automatically created
 by Bio::FANTOM::MaXML::Cluster class.

 This class can also be used for 'allseq.sep.xml' and 'repseq.sep.xml',
 but you'd better using Bio::FANTOM::MaXML::Sequence class.

 In addition, this class can be used for 'allseq.xml' and 'repseq.xml',
 but you'd better not to use them, becase of the speed is very slow.

--- Bio::FANTOM::MaXML::Sequences#to_a

 Returns an Array of Bio::FANTOM::MaXML::Sequence objects.

--- Bio::FANTOM::MaXML::Sequences#each

--- Bio::FANTOM::MaXML::Sequences#[](x)

 Same as to_a[x] when x is a integer.
 Same as get[x] when x is a string.

--- Bio::FANTOM::MaXML::Sequences#get(id_str)

 Shows a sequence information of given id.
 Returns Bio::FANTOM::MaXML::Sequence object or nil.

--- Bio::FANTOM::MaXML::Sequences#cloneids

 Shows clone ID list.
 Returns an array of strings.

--- Bio::FANTOM::MaXML::Sequences#id_strings

 Shows ID list.
 Returns an array of strings.


= Bio::FANTOM::MaXML::Sequence

 This class is for 'allseq.sep.xml' and 'repseq.sep.xml' found at
 ((<URL:ftp://fantom2.gsc.riken.go.jp/fantom/2.1/allseq.sep.xml.gz>)) and
 ((<URL:ftp://fantom2.gsc.riken.go.jp/fantom/2.1/repseq.sep.xml.gz>)).
 Not that this class is not suitable for 'allseq.xml' and 'repseq.xml'.

 In addition, the instances of this class are automatically created
 by Bio::FANTOM::MaXML::Sequences class.

--- Bio::FANTOM::MaXML::Sequence.new(str)

--- Bio::FANTOM::MaXML::Sequence#entry_id

--- Bio::FANTOM::MaXML::Sequence#altid(type_str = nil)

 Returns hash of altid if no arguments are given.
 Returns ID as a string if a type of ID (string) is given.

--- Bio::FANTOM::MaXML::Sequence#annotations

 Gets lists of annotation data.
 Returns a Bio::FANTOM::MaXML::Annotations object.

--- Bio::FANTOM::MaXML::Sequence#id_strings

 Gets lists of ID. (same as altid.values)
 Returns an array of strings.

--- Bio::FANTOM::MaXML::Sequence#library_id

 Shows library ID. (same as cloneid[0,2])
 Library IDs are listed at:
   ((<URL:http://fantom2.gsc.riken.go.jp/fantom2/SI/sup01_est_3r_libraryinfo.pdf))
   ((<URL:http://fantom2.gsc.riken.go.jp/fantom2/SI/sup01_est_5f_libraryinfo.pdf))

--- Bio::FANTOM::MaXML::Sequence#seqid

--- Bio::FANTOM::MaXML::Sequence#fantomid

--- Bio::FANTOM::MaXML::Sequence#cloneid

--- Bio::FANTOM::MaXML::Sequence#rearrayid

--- Bio::FANTOM::MaXML::Sequence#accession

--- Bio::FANTOM::MaXML::Sequence#annotator

--- Bio::FANTOM::MaXML::Sequence#version

--- Bio::FANTOM::MaXML::Sequence#modified_time

--- Bio::FANTOM::MaXML::Sequence#comment


= Bio::FANTOM::MaXML::Annotations

 The instances of this class are automatically created
 by Bio::FANTOM::MaXML::Sequence class.

--- Bio::FANTOM::MaXML::Annotations#to_a

 Returns an Array of Bio::FANTOM::MaXML::Annotations objects.

--- Bio::FANTOM::MaXML::Annotations#each

--- Bio::FANTOM::MaXML::Annotations#get_all_by_qualifier(qstr)

--- Bio::FANTOM::MaXML::Annotations#get_by_qualifier(qstr)

--- Bio::FANTOM::MaXML::Annotations#[](x)

 Same as to_a[x] when x is a integer.
 Same as get_by_qualifier[x] when x is a string.

--- Bio::FANTOM::MaXML::Annotations#cds_start
--- Bio::FANTOM::MaXML::Annotations#cds_stop
--- Bio::FANTOM::MaXML::Annotations#gene_name
--- Bio::FANTOM::MaXML::Annotations#data_source
--- Bio::FANTOM::MaXML::Annotations#evidence


= Bio::FANTOM::MaXML::Annotation

 The instances of this class are automatically created
 by Bio::FANTOM::MaXML::Annotations class.

--- Bio::FANTOM::MaXML::Annotation#datasrc

 Returns an Array of Bio::FANTOM::MaXML::Annotation::DataSrc objects.

--- Bio::FANTOM::MaXML::Annotation#qualifier

--- Bio::FANTOM::MaXML::Annotation#srckey

--- Bio::FANTOM::MaXML::Annotation#anntext

--- Bio::FANTOM::MaXML::Annotation#evidence

= Bio::FANTOM::MaXML::Annotation::DataSrc < String

 The instances of this class are automatically created
 by Bio::FANTOM::MaXML::Annotation class.

---- Bio::FANTOM::MaXML::Annotation::DataSrc#href

 Shows a link URL to database web page as an String.

= References

* ((<URL:http://fantom2.gsc.riken.go.jp/>))

=end
