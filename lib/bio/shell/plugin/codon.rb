#
# = bio/shell/plugin/codon.rb - plugin for the codon table
#
# Copyright::	Copyright (C) 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	LGPL
#
# $Id: codon.rb,v 1.4 2005/11/24 19:30:08 k Exp $
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

    def initialize(number, color = true)
      @aacode = Bio::AminoAcid.names
      @table  = Bio::CodonTable[number]
      @number = number
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
          aa = ''
        else
          code = @aacode[aa]
        end
        eval("@#{codon} = ' #{code} #{aa} '")
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
          color_aa = ""
        else
          color_code = "#{@@colors[property]}#{@aacode[aa]}"
          if @table.start_codon?(codon)
            color_aa = "#{@@colors[:start]}#{aa}"
          else
            color_aa = "#{@@colors[:aa]}#{aa}"
          end
        end
        eval("@#{codon} = ' #{color_code} #{color_aa}#{@@colors[:text]} '")
      end

      @hydrophilic = [
        "#{@@colors[:basic]}basic#{@@colors[:text]},",
        "#{@@colors[:polar]}polar#{@@colors[:text]},",
        "#{@@colors[:acidic]}acidic#{@@colors[:text]}"
      ].join(" ")
      @hydrophobic = "#{@@colors[:nonpolar]}nonpolar"
    end

    def output
      text = <<-END
        #
        # = Codon table #{@number} : #{@table.definition}
        #
        #   hydrophilic: #{@hydrophilic}
        #   hydrophobic: #{@hydrophobic}
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
      text.gsub(/^\s+#/, @@colors[:text])
    end

  end

  private

  def codontable(num = 1)
    cct = ColoredCodonTable.new(num, Bio::Shell.config(:color))
    display cct.output
    return cct.table
  end

  def codontables
    Bio::CodonTable::Definitions.sort.each do |i, definition|
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
    [
      [ 'A', 'Adenine'  ],
      [ 'T', 'Thymine'  ],
      [ 'G', 'Guanine'  ],
      [ 'C', 'Cytosine' ],
      [ 'U', 'Uracil'   ],
      [ 'r', '[ag]', 'puRine' ],
      [ 'y', '[tc]', 'pYrimidine' ],
      [ 'w', '[at]', 'Weak' ],
      [ 's', '[gc]', 'Strong' ],
      [ 'k', '[tg]', 'Keto' ],
      [ 'm', '[ac]', 'aroMatic' ],
      [ 'b', '[tgc]', 'not A' ],
      [ 'v', '[agc]', 'not T' ],
      [ 'h', '[atc]', 'not G' ],
      [ 'd', '[atg]', 'not C' ],
      [ 'n', '[atgc]', 'any' ],
    ].each do |list|
      puts list.join("\t")
    end
    return Bio::NucleicAcid.names
  end

end

