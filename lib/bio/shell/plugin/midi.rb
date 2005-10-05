#
#  bio/shell/plugin/midi.rb - Sequence to MIDI converter
#
#   Copyright (C) 2003 Natsuhiro Ichinose <ichinose@genome.ist.i.kyoto-u.ac.jp>
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
#  $Id: midi.rb,v 1.2 2005/10/05 08:58:33 k Exp $
#

class Bio::Sequence::NA

  class MidiTrack

    def initialize(channel = 0, program = nil, base = nil, range = nil, scale = nil)
      @channel = channel & 0xff
      @program = program || 0
      @base    = base    || 60
      @range   = range   || 2
      @scale   = scale   || [0, 2, 4, 5, 7, 9, 11]

      @tunes   = []
      @tune    = 0
      @code    = []
      @time    = 0

      @range.times do |i|
        @scale.each do |c|
          @tunes.push c + i * 12
        end
      end

      @ttype = {
        'aa' =>  1, 'at' =>  0, 'ac' => 3, 'ag' => -1,
        'ta' =>  0, 'tt' => -1, 'tc' => 1, 'tg' => -2,
        'ca' =>  2, 'ct' =>  1, 'cc' => 2, 'cg' =>  6,
        'ga' => -1, 'gt' => -3, 'gc' => 0, 'gg' => -2,
      }
      @dtype = [
        { 'aa' => 2, 'at' => 4, 'ac' => 4, 'ag' => 2,
          'ta' => 2, 'tt' => 4, 'tc' => 4, 'tg' => 2,
          'ca' => 2, 'ct' => 3, 'cc' => 1, 'cg' => 2,
          'ga' => 1, 'gt' => 2, 'gc' => 2, 'gg' => 3,
        },
        { 'aa' => 3, 'at' => 3, 'ac' => 2, 'ag' => 3,
          'ta' => 3, 'tt' => 3, 'tc' => 2, 'tg' => 2,
          'ca' => 3, 'ct' => 2, 'cc' => 1, 'cg' => 1,
          'ga' => 1, 'gt' => 1, 'gc' => 1, 'gg' => 1,
        },
        { 'aa' => 2, 'at' => 2, 'ac' => 2, 'ag' => 2,
          'ta' => 1, 'tt' => 1, 'tc' => 2, 'tg' => 2,
          'ca' => 2, 'ct' => 2, 'cc' => 2, 'cg' => 3,
          'ga' => 2, 'gt' => 2, 'gc' => 3, 'gg' => 1,
        },
        { 'aa' => 1, 'at' => 1, 'ac' => 1, 'ag' => 1,
          'ta' => 1, 'tt' => 1, 'tc' => 1, 'tg' => 1,
          'ca' => 1, 'ct' => 1, 'cc' => 1, 'cg' => 3,
          'ga' => 1, 'gt' => 1, 'gc' => 1, 'gg' => 1,
        },
      ]

      @code.concat [0x00, 0xc0 | (@channel & 0xff)]
      @code.concat icode(@program & 0xff, 1)
    end

    def icode(num, n)
      code = []
      n.times do |i|
        code.push num & 0xff
        num >>= 8
      end
      code.reverse
    end

    def rcode(num)
      code = []
      code.push num & 0x7f
      while num > 0x7f
        num >>= 7
        code.push num & 0x7f | 0x80
      end
      code.reverse
    end

    def c2s(code)
      ans = ""
      code.each do |c|
        ans += c.chr
      end
      ans
    end

    def push(s)
      tt = @time % 4
      t = @ttype[s[0, 2]]
      d = @dtype[tt][s[2, 2]]
      if !t.nil? && !d.nil?
        @tune += t
        @tune %= @tunes.length
        if tt == 0
          vel = 90
        elsif tt == 1 && d > 1
          vel = 100
        elsif tt == 2
          vel = 60
        else
          vel = 50
        end
        @code.concat rcode(1)
        @code.concat [0x90 | @channel, @tunes[@tune] + @base, vel]
        @code.concat rcode(240 * d)
        @code.concat [0x80 | @channel, @tunes[@tune] + @base, 0]
        @time += d
      end
    end

    def push_silent(d)
      @code.concat rcode(1)
      @code.concat [0x90 | @channel, 0, 0]
      @code.concat rcode(240 * d)
      @code.concat [0x80 | @channel, 0, 0]
      @time += d;
    end

    def get_time
      @time
    end

    def encode
      ans ="MTrk"
      ans += c2s(icode(@code.length + 4, 4))
      ans += c2s(@code)
      ans += c2s([0x00, 0xff, 0x2f, 0x00])
      ans
    end

    def header(num, tempo = 120)
      ans = "MThd"
      ans += c2s(icode(6, 4))
      ans += c2s(icode(1, 2))
      ans += c2s(icode(num + 1, 2))
      ans += c2s(icode(480, 2))
      ans += "MTrk"
      ans += c2s(icode(11, 4))
      ans += c2s([0x00, 0xff, 0x51, 0x03])
      ans += c2s(icode(60000000 / tempo, 3))
      ans += c2s([0x00, 0xff, 0x2f, 0x00])
      ans
    end

  end # MidiTrack



  # drum:
  #   true (with rhythm part), false (without rhythm part)
  # scale:
  #   C  C# D  D# E  F  F# G  G# A  A#  B
  #   0  1  2  3  4  5  6  7  8  9  10  11
  def to_midi(tempo = 120, drum = true, scale = nil, track_info = nil)
    scale      ||= [0, 2, 4, 5, 7, 9, 11]
    track_info ||= [[9, 60, 2], [13, 48, 2], [41, 48, 2], [44, 36, 2]]

    track = []

    track_info.each_with_index do |i, j|
      k = j
      k += 1 if j >= 9
      track.push MidiTrack.new(k, i[0], i[1], i[2], scale)
    end

    if drum
      rhythm = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      track.push(MidiTrack.new(9, 0, 35, 2, rhythm))
    end

    cur = 0
    window_search(4) do |s|
      track[cur % track.length].push(s)
      cur += 1
    end

    track.each do |t|
      t.push_silent(12)
    end

    ans = track[0].header(track.length, tempo)
    track.each do |t|
      ans += t.encode
    end
    return ans
  end

end


module Bio::Shell

  def midi(seq, filename, *args)
    begin
      print "Saving MIDI file (#{filename}) ... "
      File.open(filename, "w") do |file|
        file.puts seq.to_midi(*args)
      end
      puts "done"
    rescue
      raise "Failed to save (#{filename}) : #{$!}"
    end
  end

end


if $0 == __FILE__
  include Bio::Shell

  seq_file = ARGV.shift
  mid_file = ARGV.shift

  ff = Bio::FlatFile.auto(seq_file)
  ff.each do |f|
    midi(f.naseq[1..1000], save_file)
  end
end
