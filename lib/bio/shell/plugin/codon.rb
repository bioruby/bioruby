#
# = bio/shell/plugin/codon.rb - plugin for the codon table
#
# Copyright::	Copyright (C) 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	LGPL
#
# $Id: codon.rb,v 1.6 2005/11/27 15:01:17 k Exp $
#
#--
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
#++
#

require 'bio/data/codontable'
require 'bio/data/aa'
require 'bio/data/na'

module Bio::Shell

  class ColoredCodonTable

    Color = Bio::Shell::Core::ESC_SEQ

    @@colors = {
      :text		=> Color[:none],
      :aa		=> Color[:green],
      :start		=> Color[:red],
      :stop		=> Color[:red],
      :basic		=> Color[:cyan],
      :polar		=> Color[:blue],
      :acidic		=> Color[:magenta],
      :nonpolar		=> Color[:yellow],
    }

    @@properties = {
      :basic => %w( H K R ),
      :polar => %w( S T Y Q N S ),
      :acidic => %w( D E ),
      :nonpolar => %w( F L I M V P A C W G ),
      :stop => %w( * ),
    }

    def initialize(number, color = true, cuhash = nil)
      @aacode = Bio::AminoAcid.names
      @table  = Bio::CodonTable[number]
      @number = number
      @cuhash = cuhash
      if color
        generate_colored_text
      else
        generate_mono_text
      end
    end
    attr_reader :table

    def generate_mono_text
      @table.each do |codon, aa|
        if aa == '*'
          code = "STOP"
          aa = '' unless @cuhash
        else
          code = @aacode[aa]
        end
        if @cuhash
          percent = @cuhash[codon].to_s.rjust(6)
          eval("@#{codon} = '#{aa}#{percent}'")
        else
          eval("@#{codon} = ' #{code} #{aa} '")
        end
      end

      @hydrophilic = [
        @@properties[:basic].join(" "), "(basic),",
        @@properties[:polar].join(" "), "(polar),",
        @@properties[:acidic].join(" "), "(acidic)",
      ].join(" ")
      @hydrophobic = @@properties[:nonpolar].join(" ") + " (nonpolar)"
    end

    def generate_colored_text
      @table.each do |codon, aa|
        property, = @@properties.detect {|key, list| list.include?(aa)}

        if aa == '*'
          color_code = "#{@@colors[:stop]}STOP"
          if @cuhash
            color_aa = "#{@@colors[:stop]}#{aa}"
          else
            color_aa = ''
          end
        else
          color_code = "#{@@colors[property]}#{@aacode[aa]}"
          if @table.start_codon?(codon)
            if @cuhash
              color_aa = "#{@@colors[:aa]}#{aa}"
            else
              color_aa = "#{@@colors[:start]}#{aa}"
            end
          else
            if @cuhash
              color_aa = "#{@@colors[property]}#{aa}"
            else
              color_aa = "#{@@colors[:aa]}#{aa}"
            end
          end
        end

        if @cuhash
          percent = @cuhash[codon].to_s.rjust(6)
          eval("@#{codon} = '#{color_aa}#{@@colors[:text]}#{percent}'")
        else
          eval("@#{codon} = ' #{color_code} #{color_aa}#{@@colors[:text]} '")
        end
      end

      @hydrophilic = [
        "#{@@colors[:basic]}basic#{@@colors[:text]},",
        "#{@@colors[:polar]}polar#{@@colors[:text]},",
        "#{@@colors[:acidic]}acidic#{@@colors[:text]}"
      ].join(" ")
      @hydrophobic = "#{@@colors[:nonpolar]}nonpolar"
    end

    def output
      header = <<-END
        #
        # = Codon table #{@number} : #{@table.definition}
        #
        #   hydrophilic: #{@hydrophilic}
        #   hydrophobic: #{@hydrophobic}
      END
      table = <<-END
        #
        # *---------------------------------------------*
        # |       |              2nd              |     |
        # |  1st  |-------------------------------| 3rd |
        # |       |  U    |  C    |  A    |  G    |     |
        # |-------+-------+-------+-------+-------+-----|
        # | U   U |#{@ttt}|#{@tct}|#{@tat}|#{@tgt}|  u  |
        # | U   U |#{@ttc}|#{@tcc}|#{@tac}|#{@tgc}|  c  |
        # | U   U |#{@tta}|#{@tca}|#{@taa}|#{@tga}|  a  |
        # |  UUU  |#{@ttg}|#{@tcg}|#{@tag}|#{@tgg}|  g  |
        # |-------+-------+-------+-------+-------+-----|
        # |  CCCC |#{@ctt}|#{@cct}|#{@cat}|#{@cgt}|  u  |
        # | C     |#{@ctc}|#{@ccc}|#{@cac}|#{@cgc}|  c  |
        # | C     |#{@cta}|#{@cca}|#{@caa}|#{@cga}|  a  |
        # |  CCCC |#{@ctg}|#{@ccg}|#{@cag}|#{@cgg}|  g  |
        # |-------+-------+-------+-------+-------+-----|
        # |   A   |#{@att}|#{@act}|#{@aat}|#{@agt}|  u  |
        # |  A A  |#{@atc}|#{@acc}|#{@aac}|#{@agc}|  c  |
        # | AAAAA |#{@ata}|#{@aca}|#{@aaa}|#{@aga}|  a  |
        # | A   A |#{@atg}|#{@acg}|#{@aag}|#{@agg}|  g  |
        # |-------+-------+-------+-------+-------+-----|
        # |  GGGG |#{@gtt}|#{@gct}|#{@gat}|#{@ggt}|  u  |
        # | G     |#{@gtc}|#{@gcc}|#{@gac}|#{@ggc}|  c  |
        # | G GGG |#{@gta}|#{@gca}|#{@gaa}|#{@gga}|  a  |
        # |  GG G |#{@gtg}|#{@gcg}|#{@gag}|#{@ggg}|  g  |
        # *---------------------------------------------*
        #
      END
      if @cuhash
        text = table
      else
        text = header + table
      end
      text.gsub(/^\s+#/, @@colors[:text])
    end

  end

  private

  def codon_usage_table(num = 1, codon_usage = nil)
    ColoredCodonTable.new(num, Bio::Shell.config(:color), codon_usage)
  end    

  def codontable(num = 1)
    cct = codon_usage_table(num)
    display cct.output
    return cct.table
  end

  def codontables
    Bio::CodonTable::DEFINITIONS.sort.each do |i, definition|
      puts "#{i}\t#{definition}"
    end
  end

  def aminoacids
    names = Bio::AminoAcid.names
    names.sort.each do |aa, code|
      if aa.length == 1
        puts "#{aa}\t#{code}\t#{names[code]}"
      end
    end
    return names
  end

  def nucleicacids
    names = Bio::NucleicAcid.names
    %w(a t g c u r y w s k m b v h d n).each do |base|
      puts "#{base}\t#{names[base]}\t#{names[base.upcase]}"
    end
    return names
  end

end

