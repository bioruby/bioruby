#
# = bio/io/hinv.rb - H-invDB web service (REST) client module
#
# Copyright::  Copyright (C) 2008 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: hinv.rb,v 1.2 2008/02/19 04:42:14 k Exp $
#

require 'bio/command'
require 'rexml/document'

module Bio

  # = Bio::Hinv
  #
  # Accessing the H-invDB web services.
  #
  # * http://www.h-invitational.jp/
  # * http://www.jbirc.aist.go.jp/hinv/hws/doc/index.html
  #
  class Hinv

    BASE_URI = "http://www.jbirc.aist.go.jp/hinv/hws/"

    module Common
      def query(options = nil)
        response, = Bio::Command.post_form(@url, options)
        @result = response.body
        @xml = REXML::Document.new(@result)
      end
    end


    # Bio::Hinv.acc2hit("BC053657")  # => "HIT000053961"
    def self.acc2hit(acc)
      serv = Acc2hit.new
      serv.query("acc" => acc)
      serv.result
    end

    # Bio::Hinv.hit2acc("HIT000022181")  # => "AK097327"
    def self.hit2acc(hit)
      serv = Hit2acc.new
      serv.query("hit" => hit)
      serv.result
    end

    # Bio::Hinv.hit_cnt  # => 187156
    def self.hit_cnt
      serv = HitCnt.new
      serv.query
      serv.result
    end

    # Bio::Hinv.hit_definition("HIT000000001")  # => "Rho guanine ..."
    def self.hit_definition(hit)
      serv = HitDefinition.new
      serv.query("hit" => hit)
      serv.result
    end

    # Bio::Hinv.hit_pubmedid("HIT000053961")  # => [7624364, 11279095, ... ]
    def self.hit_pubmedid(hit)
      serv = HitPubmedId.new
      serv.query("hit" => hit)
      serv.result
    end

    # Bio::Hinv.hit_xml("HIT000000001")  # => "<?xml version="1.0" ..."
    def self.hit_xml(hit)
      serv = Bio::Hinv::HitXML.new
      serv.query("hit" => hit)
      puts serv.result
    end

    # Bio::Hinv.hix2hit("HIX0000004")  # => ["HIT000012846", ... ]
    def self.hix2hit(hix)
      serv = Bio::Hinv::Hix2hit.new
      serv.query("hix" => hix)
      serv.result
    end

    # Bio::Hinv.hix_cnt  # => 36073
    def self.hix_cnt
      serv = HixCnt.new
      serv.query
      serv.result
    end

    # Bio::Hinv.hix_represent("HIX0000001")  # => "HIT000022181"
    def self.hix_represent(hix)
      serv = HixRepresent.new
      serv.query("hix" => hix)
      serv.result
    end

    # Bio::Hinv.id_search("HIT00002218*")  # => ["HIT000022181", ... ]
    def self.id_search(query)
      serv = IdSearch.new
      serv.query("query" => query)
      serv.result
    end

    # Bio::Hinv.keyword_search("HIT00002218*")  # => ["HIT000022181", ... ]
    def self.keyword_search(query)
      serv = KeywordSearch.new
      serv.query("query" => query)
      serv.result
    end


    # serv = Bio::Hinv::Acc2hit.new
    # serv.query("acc" => "BC053657")
    # puts serv.result
    class Acc2hit
      include Common

      def initialize
        @url = BASE_URI + "acc2hit.php"
      end

      # <?xml version='1.0' encoding='UTF-8'?>
      # <H-Inv>
      #  <H-INVITATIONAL-ID>HIT000053961</H-INVITATIONAL-ID>
      # </H-Inv>
      def result
        @xml.elements['//H-INVITATIONAL-ID'].text
      end
    end

    # serv = Bio::Hinv::Hit2acc.new
    # serv.query("hit" => "HIT000022181")
    # puts serv.result
    class Hit2acc
      include Common

      def initialize
        @url = BASE_URI + "hit2acc.php"
      end

      # <?xml version='1.0' encoding='UTF-8'?>
      # <H-Inv>
      #  <ACCESSION-NO>AK097327</ACCESSION-NO>
      # </H-Inv>
      def result
        @xml.elements['//ACCESSION-NO'].text
      end
    end

    # serv = Bio::Hinv::HitCnt.new
    # serv.query
    # puts serv.result
    class HitCnt
      include Common

      def initialize
        @url = BASE_URI + "hit_cnt.php"
      end

      # <?xml version='1.0' encoding='UTF-8'?>
      # <H-Inv>
      #  <TRANSCRIPT_CNT>187156</TRANSCRIPT_CNT>
      # </H-Inv>
      def result
        @xml.elements['//TRANSCRIPT_CNT'].text.to_i
      end
    end

    # serv = Bio::Hinv::HitDefinition.new
    # serv.query("hit" => "HIT000000001")
    # puts serv.result
    # puts serv.data_source_definition
    # puts serv.cdna_rep_h_invitational
    # puts serv.cdna_splicing_isoform_curation
    # puts serv.data_source_db_reference_protein_motif_id
    # puts serv.data_source_identity
    # puts serv.data_source_coverage
    # puts serv.data_source_homologous_species
    # puts serv.data_source_similarity_category
    class HitDefinition
      include Common

      def initialize
        @url = BASE_URI + "hit_definition.php"
      end

      # <?xml version='1.0' encoding='UTF-8'?>
      # <H-Inv>
      #  <HIT_FUNCTION>
      #   <H-INVITATIONAL-ID>HIT000000001</H-INVITATIONAL-ID>
      #   <DATA-SOURCE_DEFINITION>Rho guanine nucleotide exchange factor 10.</DATA-SOURCE_DEFINITION>
      #   <CDNA_REP-H-INVITATIONAL>Representative transcript</CDNA_REP-H-INVITATIONAL>
      #   <CDNA_SPLICING-ISOFORM_CURATION></CDNA_SPLICING-ISOFORM_CURATION>
      #   <DATA-SOURCE_DB-REFERENCE_PROTEIN-MOTIF-ID>NP_055444</DATA-SOURCE_DB-REFERENCE_PROTEIN-MOTIF-ID>
      #   <DATA-SOURCE_IDENTITY>100.0</DATA-SOURCE_IDENTITY>
      #   <DATA-SOURCE_COVERAGE>100.0</DATA-SOURCE_COVERAGE>
      #   <DATA-SOURCE_HOMOLOGOUS_SPECIES>Homo sapiens</DATA-SOURCE_HOMOLOGOUS_SPECIES>
      #   <DATA-SOURCE_SIMILARITY-CATEGORY>Identical to known human protein(Category I).</DATA-SOURCE_SIMILARITY-CATEGORY>
      #  </HIT_FUNCTION>
      # </H-Inv>
      def result
        @xml.elements['//DATA-SOURCE_DEFINITION'].text
      end
      alias :data_source_definition :result

      def cdna_rep_h_invitational
        @xml.elements['//CDNA_REP-H-INVITATIONAL'].text
      end
      def cdna_splicing_isoform_curation
        @xml.elements['//CDNA_SPLICING-ISOFORM_CURATION'].text
      end
      def data_source_db_reference_protein_motif_id
        @xml.elements['//DATA-SOURCE_DB-REFERENCE_PROTEIN-MOTIF-ID'].text
      end
      def data_source_identity
        @xml.elements['//DATA-SOURCE_IDENTITY'].text.to_f
      end
      def data_source_coverage
        @xml.elements['//DATA-SOURCE_COVERAGE'].text.to_f
      end
      def data_source_homologous_species
        @xml.elements['//DATA-SOURCE_HOMOLOGOUS_SPECIES'].text
      end
      def data_source_similarity_category
        @xml.elements['//DATA-SOURCE_SIMILARITY-CATEGORY'].text
      end
    end

    # serv = Bio::Hinv::HitPubmedId.new
    # serv.query("hit" => "HIT000053961")
    # puts serv.result
    class HitPubmedId
      include Common

      def initialize
        @url = BASE_URI + "hit_pubmedid.php"
      end

      # <?xml version='1.0' encoding='UTF-8'?>
      # <H-Inv>
      #  <CDNA_DB-REFERENCE_PUBMED>7624364</CDNA_DB-REFERENCE_PUBMED>
      #  <CDNA_DB-REFERENCE_PUBMED>11279095</CDNA_DB-REFERENCE_PUBMED>
      #  <CDNA_DB-REFERENCE_PUBMED>15489334</CDNA_DB-REFERENCE_PUBMED>
      # </H-Inv>
      def result
        list = []
        @xml.elements.each('//CDNA_DB-REFERENCE_PUBMED') do |e|
          list << e.text.to_i
        end
        return list
      end
    end

    # serv = Bio::Hinv::HitXML.new
    # serv.query("hit" => "HIT000000001")
    # puts serv.result
    class HitXML
      include Common

      def initialize
        @url = BASE_URI + "hit_xml.php"
      end

      # <?xml version="1.0" standalone="yes" ?>
      # <H-Inv>
      #  <cDNAXML>
      #  <CLUSTER-ID>HIX0021591</CLUSTER-ID>
      #  <CLUSTER-ID-VERSION>HIX0021591.11</CLUSTER-ID-VERSION>
      #  <H-INVITATIONAL-ID>HIT000000001</H-INVITATIONAL-ID>
      #    :
      #    </PROBE-MAPPING>
      #   </EXPRESSION>
      #  </cDNAXML>
      # </H-Inv>
      def result
        @result
      end
    end

    # serv = Bio::Hinv::Hix2hit.new
    # serv.query("hix" => "HIX0000004")
    # puts serv.result
    class Hix2hit
      include Common

      def initialize
        @url = BASE_URI + "hix2hit.php"
      end

      # <?xml version='1.0' encoding='UTF-8'?>
      # <H-Inv>
      #  <H-INVITATIONAL-ID>HIT000012846</H-INVITATIONAL-ID>
      #  <H-INVITATIONAL-ID>HIT000022124</H-INVITATIONAL-ID>
      #  <H-INVITATIONAL-ID>HIT000007722</H-INVITATIONAL-ID>
      #    :
      #  <H-INVITATIONAL-ID>HIT000262478</H-INVITATIONAL-ID>
      # </H-Inv>
      def result
        list = []
        @xml.elements.each('//H-INVITATIONAL-ID') do |e|
          list << e.text
        end
        return list
      end
    end

    # serv = Bio::Hinv::HixCnt.new
    # serv.query
    # puts serv.result
    class HixCnt
      include Common

      def initialize
        @url = BASE_URI + "hix_cnt.php"
      end

      # <?xml version='1.0' encoding='UTF-8'?>
      # <H-Inv>
      #  <LOCUS_CNT>36073</LOCUS_CNT>
      # </H-Inv>
      def result
        @xml.elements['//LOCUS_CNT'].text.to_i
      end
    end

    # serv = Bio::Hinv::HixRepresent.new
    # serv.query("hix" => "HIX0000001")
    # puts serv.result
    # puts serv.rep_h_invitational_id
    # puts serv.rep_accession_no
    class HixRepresent
      include Common

      def initialize
        @url = BASE_URI + "hix_represent.php"
      end

      # <?xml version='1.0' encoding='UTF-8'?>
      # <H-Inv>
      #  <LOCUS>
      #   <CLUSTER-ID>HIX0000001</CLUSTER-ID>
      #   <REP-H-INVITATIONAL-ID>HIT000022181</REP-H-INVITATIONAL-ID>
      #   <REP-ACCESSION-NO>AK097327</REP-ACCESSION-NO>
      #  </LOCUS>
      # </H-Inv>
      def result
        @xml.elements['//REP-H-INVITATIONAL-ID'].text
      end
      alias :rep_h_invitational_id :result

      def rep_accession_no
        @xml.elements['//REP-ACCESSION-NO'].text
      end
    end

    # example at "http://www.jbirc.aist.go.jp/hinv/hws/doc/index_jp.html"
    # is for hit_xml.php (not for hix_xml.php)
    class HixXML
    end

    # serv = Bio::Hinv::KeywordSearch.new
    # serv.query("query" => "HIT00002218*", "start" => 1, "end" => 100)
    # puts serv.result
    # puts serv.size
    # puts serv.start
    # puts serv.end
    class KeywordSearch
      include Common

      def initialize
        @url = BASE_URI + "keyword_search.php"
      end

      def query(hash = {})
        default = {
          "start" => 1,
          "end" => 100
        }
        options = default.update(hash)
        super(options)
      end

      # <?xml version='1.0' encoding='UTF-8'?>
      # <HINVDB_SEARCH>
      #  <QUERY>HIT00002218*</QUERY>
      #  <SIZE>8</SIZE>
      #  <START>1</START>
      #  <END>8</END>
      #  <H-INVITATIONAL-ID>HIT000022180</H-INVITATIONAL-ID>
      #  <H-INVITATIONAL-ID>HIT000022181</H-INVITATIONAL-ID>
      #  <H-INVITATIONAL-ID>HIT000022183</H-INVITATIONAL-ID>
      #  <H-INVITATIONAL-ID>HIT000022184</H-INVITATIONAL-ID>
      #  <H-INVITATIONAL-ID>HIT000022185</H-INVITATIONAL-ID>
      #  <H-INVITATIONAL-ID>HIT000022186</H-INVITATIONAL-ID>
      #  <H-INVITATIONAL-ID>HIT000022188</H-INVITATIONAL-ID>
      #  <H-INVITATIONAL-ID>HIT000022189</H-INVITATIONAL-ID>
      # </HINVDB_SEARCH>
      def result
        list = []
        @xml.elements.each('//H-INVITATIONAL-ID') do |e|
          list << e.text
        end
        return list
      end

      def size
        @xml.elements['//SIZE'].text.to_i
      end
      def start
        @xml.elements['//START'].text.to_i
      end
      def end
        @xml.elements['//END'].text.to_i
      end
    end

    # serv = Bio::Hinv::IdSearch.new
    # serv.query("query" => "HIT00002218*", "id_type" => "H-INVITATIONAL-ID", "start" => 1, "end" => 100)
    # puts serv.result
    # puts serv.size
    # puts serv.start
    # puts serv.end
    class IdSearch < KeywordSearch
      def initialize
        @url = BASE_URI + "id_search.php"
      end

      def query(hash = {})
        default = {
          "id_type" => "H-INVITATIONAL-ID",
          "start" => 1,
          "end" => 100
        }
        options = default.update(hash)
        super(options)
      end
    end

  end
end

