#
# = bio/shell/plugin/codon.rb - plugin for the codon table
#
# Copyright::   Copyright (C) 2005
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: codon.rb,v 1.16 2007/04/05 23:35:41 trevor Exp $
#

module Bio::Shell

  class ColoredCodonTable

    @@properties = {
      :basic => %w( H K R ),
      :polar => %w( S T Y Q N S ),
      :acidic => %w( D E ),
      :nonpolar => %w( F L I M V P A C W G ),
      :stop => %w( * ),
    }

    def initialize(number, cuhash = nil)
      @aacode = Bio::AminoAcid.names
      @table  = Bio::CodonTable[number]
      @number = number
      @cuhash = cuhash
      setup_colors
      if Bio::Shell.config[:color]
        generate_colored_text
      else
        generate_mono_text
      end
    end
    attr_reader :table

    def setup_colors
      c = Bio::Shell.colors

      @colors = {
        :text		=> c[:none],
        :aa		=> c[:green],
        :start		=> c[:red],
        :stop		=> c[:red],
        :basic		=> c[:cyan],
        :polar		=> c[:blue],
        :acidic		=> c[:magenta],
        :nonpolar	=> c[:yellow],
      }
    end

    def generate_mono_text
      @table.each do |codon, aa|
        if aa == '*'
          code = 'STOP'
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
          if @cuhash
            color_code = "#{@colors[:stop]}STOP"
            color_aa = "#{@colors[:stop]}#{aa}"
          else
            color_code = "#{@colors[:stop]}STP"
            case codon
            when 'tga'
              color_aa = "#{@colors[:text]}U"
            when 'tag'
              color_aa = "#{@colors[:text]}O"
            else
              color_aa = "#{@colors[:text]}*"
            end
          end
        else
          color_code = "#{@colors[property]}#{@aacode[aa]}"
          if @table.start_codon?(codon)
            if @cuhash
              color_aa = "#{@colors[:aa]}#{aa}"
            else
              color_aa = "#{@colors[:start]}#{aa}"
            end
          else
            if @cuhash
              color_aa = "#{@colors[property]}#{aa}"
            else
              color_aa = "#{@colors[:aa]}#{aa}"
            end
          end
        end

        if @cuhash
          percent = @cuhash[codon].to_s.rjust(6)
          eval("@#{codon} = '#{color_aa}#{@colors[:text]}#{percent}'")
        else
          eval("@#{codon} = ' #{color_code} #{color_aa}#{@colors[:text]} '")
        end
      end

      @hydrophilic = [
        "#{@colors[:basic]}basic#{@colors[:text]},",
        "#{@colors[:polar]}polar#{@colors[:text]},",
        "#{@colors[:acidic]}acidic#{@colors[:text]}"
      ].join(" ")
      @hydrophobic = "#{@colors[:nonpolar]}nonpolar"
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
      if Bio::Shell.config[:color]
        text.gsub(/^\s+#/, @colors[:text])
      else
        text.gsub(/^\s+#/, '')
      end
    end

  end

  private

  def codontable(num = 1, codon_usage = nil)
    cct = ColoredCodonTable.new(num, codon_usage)
    if codon_usage
      return cct
    else
      puts cct.output
      return cct.table
    end
  end

  def codontables
    tables = Bio::CodonTable::DEFINITIONS
    tables.sort.each do |i, definition|
      puts "#{i}\t#{definition}"
    end
    return tables
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

