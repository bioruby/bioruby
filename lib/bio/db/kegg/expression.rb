#
# = bio/db/kegg/expression.rb - KEGG EXPRESSION database class
#
# Copyright::	Copyright (C) 2001-2003, 2005
#		Shuichi Kawashima <shuichi@hgc.jp>,
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
# $Id: expression.rb,v 1.11 2007/04/05 23:35:41 trevor Exp $
#

require "bio/db"

module Bio
class KEGG

class EXPRESSION

  def initialize(entry)
    @orf2val   = Hash.new('')
    @orf2rgb   = Hash.new('')
    @orf2ratio = Hash.new('')
    @max_intensity = 10000
    entry.split("\n").each do |line|
      unless /^#/ =~ line
        ary = line.split("\t")
        orf = ary.shift
        val = ary[2, 4].collect {|x| x.to_f}
        @orf2val[orf] = val 
      end
    end
  end
  attr_reader :orf2val
  attr_reader :orf2rgb
  attr_reader :orf2ratio
  attr_reader :max_intensity

  def control_avg
    sum = 0.0
    @orf2val.values.each do |v|
      sum += v[0] - v[1]
    end
    sum/orf2val.size
  end

  def target_avg
    sum = 0.0
    @orf2val.values.each do |v|
      sum += v[2] - v[3]
    end
    sum/orf2val.size
  end

  def control_var
    sum = 0.0
    avg = self.control_avg
    @orf2val.values.each do |v|
      tmp = v[0] - v[1]
      sum += (tmp - avg)*(tmp - avg)
    end
    sum/orf2val.size
  end

  def target_var
    sum = 0.0
    avg = self.target_avg
    @orf2val.values.each do |v|
      tmp = v[2] - v[3]
      sum += (tmp - avg)*(tmp - avg)
    end
    sum/orf2val.size
  end

  def control_sd
    var = self.control_var
    Math.sqrt(var)
  end

  def target_sd
    var = self.target_var
    Math.sqrt(var)
  end

  def up_regulated(num=20, threshold=nil)
    logy_minus_logx
    ary = @orf2ratio.to_a.sort{|a, b| b[1] <=> a[1]}
    if threshold != nil
      i = 0
      while ary[i][1] > threshold
        i += 1
      end
      return ary[0..i]
    else
      return ary[0..num-1]
    end
  end

  def down_regulated(num=20, threshold=nil)
    logy_minus_logx
    ary = @orf2ratio.to_a.sort{|a, b| a[1] <=> b[1]}
    if threshold != nil
      i = 0
      while ary[i][1] < threshold
        i += 1
      end
      return ary[0..i]
    else
      return ary[0..num-1]
    end
  end

  def regulated(num=20, threshold=nil)
    logy_minus_logx
    ary = @orf2ratio.to_a.sort{|a, b| b[1].abs <=> a[1].abs}
    if threshold != nil
      i = 0
      while ary[i][1].abs > threshold
        i += 1
      end
      return ary[0..i]
    else
      return ary[0..num-1]
    end
  end

  def logy_minus_logx
    @orf2val.each do |k, v|
      @orf2ratio[k] = (1.0/Math.log10(2))*(Math.log10(v[2]-v[3]) - Math.log10(v[0]-v[1]))
    end
  end

  def val2rgb
    col_unit = @max_intensity/255
    @orf2val.each do |k, v|
      tmp_val = ((v[0] - v[1])/col_unit).to_i
      if tmp_val > 255
        g = "ff" 
      else
        g = format("%02x", tmp_val)
      end
      tmp_val = ((v[2] - v[3])/col_unit).to_i
      if tmp_val > 255
        r = "ff" 
      else
        r = format("%02x", tmp_val)
      end
      @orf2rgb[k] = r + g + "00"
    end
  
  end

end # class EXPRESSION

end # class KEGG
end # module Bio
