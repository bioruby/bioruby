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
#  $Id: das.rb,v 1.1 2003/02/18 08:06:32 k Exp $
#

begin
  require 'rexml/document'
rescue LoadError
end
require 'net/http'

module Bio

  class DAS

    def initialize(url = "www.wormbase.org", dir = "db", port = 80)
      @h = Net::HTTP.new(url, port)
      @dir = dir
    end

    def get_dsn
      dsns = []
      result, = @h.get('/' + @dir + '/das/dsn', nil)
      @source = result.body
      doc = REXML::Document.new(@source)
      doc.elements.each("/descendant::DSN") do |elm|
        dsn = DSN.new
        elm.elements.each do |e|
          if e.name == "SOURCE"
            dsn.source = e.text
            dsn.source_id = e.attributes["id"]
            dsn.source_version = e.attributes["version"]
          elsif e.name == "MAPMASTER"
            dsn.mapmaster = e.name
          elsif e.name == "DESCRIPTION"
            dsn.description = e.text
            dsn.description_href = e.attributes["href"]
          end
        end
        dsns << dsn
      end
      dsns
    end

    def get_entry_points(dsn_src)
      ary = []
      hash = {}
      resp, src = @h.get('/' + @dir + '/das/' + dsn_src +
      '/entry_points' , nil)
      doc = REXML::Document.new(src)
      doc.elements.each("/descendant::SEGMENT") do |elm|
        ary << [elm.text]
        elm.attributes.each do |n, v|
	  hash[n] = v
	end
        ary << [elm.text, hash]
      end
      ary
    end

    def get_dna(dsn_source, reference, start, stop)
      dna = DNA.new
      result, = @h.get('/' + @dir + '/das/' + dsn_source + '/dna' +
      "?segment=" + reference + ':' + start.to_s + ',' + stop.to_s, nil)
      @source = result.body
      doc = REXML::Document.new(@source)
      doc.elements.each("/descendant::SEQUENCE") do |elm|
        hash = {}
        seq = ""
        length = 0
        elm.attributes.each do |n, v|
	  hash[n] = v
	end
        elm.elements.each do |e|
          if e.name == "DNA"
            length = e.attributes["length"].to_i
            e.text.each do |line|
              seq << line.chomp
            end
          end
        end
        dna.sequence << [hash, length, Bio::Sequence.new(seq)]
      end
      dna
    end

    def get_features(dsn_src, ref, start, stop)
      gff = GFF.new
      result = @h.get('/' + @dir + '/das/' + dsn_src + "/features?segment=" +
      ref + ':' + start.to_s + ',' + stop.to_s, nil)
      @source = result.body
      doc = REXML::Document.new(src)
      doc.elements.each("/descendant::GFF") do |e|
        gff.gff_version = e.attributes["version"]
        gff.gff_href = e.attributes["href"]
        e.elements.each("/descendant::SEGMENT") do |f|
          gff.segment[0] = f.attributes["id"]
          gff.segment[1] = f.attributes["start"]
          gff.segment[2] = f.attributes["stop"]
          gff.segment[3] = f.attributes["version"]
          gff.segment[4] = f.attributes["label"]
	  if f.has_elements? # FEATURE tag is optional
            gff.segment[5] = Array.new()
            f.elements.each("/descendant::FEATURE") do |g|
              feature_tmp = Array.new(11)
              g.elements.each do |h|
                if h.name == "TYPE"
                  feature_tmp[0] = [ h.text, 
                                     h.attributes["id"],
                                     h.attributes["category"],
                                     h.attributes["reference"] ]
                elsif h.name == "METHOD"
                  feature_tmp[1] = [ h.text,
                                     h.attributes["id"] ]
                elsif h.name == "START"
                  feature_tmp[2] = h.text
                elsif h.name == "END"
                  feature_tmp[3] = h.text
                elsif h.name == "SCORE"
                  feature_tmp[4] = h.text
                elsif h.name == "ORIENTATION"
                  feature_tmp[5] = h.text
                elsif h.name == "TARGET"
                  feature_tmp[6] = [ h.text,
                                     h.attributes["id"],
                                     h.attributes["start"],
                                     h.attributes["stop"] ]
                elsif h.name == "PHASE"
                  feature_tmp[7] = h.text
                elsif h.name == "NOTE"
                  feature_tmp[8] = h.text
                elsif h.name == "LINK"
                  feature_tmp[9] = [ h.text,
                                     h.attributes["href"] ]
                elsif h.name == "GROUP"
                  g_tmp = Array.new(6)
                  n_tmp = Array.new()
                  l_tmp = Array.new()
                  t_tmp = Array.new()
                  g_tmp[0] = h.attributes["id"]
                  g_tmp[1] = h.attributes["label"]
                  g_tmp[2] = h.attributes["type"]
                  h.elements.each do |i|
                    if i.name == "NOTE"
                      n_tmp << i.text
                    elsif i.name == "LINK"
                      l_tmp << [ i.text,
                                i.attributes["href"] ]
                    elsif i.name == "TARGET"
                      t_tmp << [ i.text, 
                                 i.attributes["id"],
                                 i.attributes["start"],
                                 i.attributes["stop"] ]
                    end
                  end
                  g_tmp[3] = n_tmp
                  g_tmp[4] = l_tmp
                  g_tmp[5] = t_tmp
                  if feature_tmp[10] == nil
                    feature_tmp[10] = [g_tmp]
                  else
                    feature_tmp[10] << g_tmp
                  end
                end
              end
              gff.segment[5] << feature_tmp
            end
	  end
	end
      end
      gff
    end

#    private

    class DSN

      def initialize()
        @source         = nil
        @source_id      = nil
        @source_version = nil
        @mapmaster      = nil
        @descriotion    = nil
        @descriotion_href    = nil
      end
      attr_accessor :source
      attr_accessor :source_id
      attr_accessor :source_version
      attr_accessor :mapmaster
      attr_accessor :description
      attr_accessor :description_href

    end

    class DNA

      def initialize()
        @sequence         = Array.new()
      end
      attr_accessor :sequence

    end

    class GFF

      def initialize()
        @gff_version        = nil
        @gff_href           = nil
        @segment            = Array.new(6)
      end
      attr_accessor :gff_version
      attr_accessor :gff_href
      attr_accessor :segment
    end
  end

end


if __FILE__ == $0

  begin
    require 'pp'
    alias :p :pp
  rescue LoadError
  end

  wormbase = Bio::DAS.new("www.wormbase.org", "db", 80)

  p wormbase.get_dsn
  p wormbase.get_dna("elegans", "I", 0, 1000)
  gff = wormbase.get_features("elegans", "I", 0, 1000)
  (0..4).each do |i|
    p gff.segment[i]
  end
  gff.segment[5].each do |i|
    puts "<----- feature ----->\n"
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
