#
# = bio/shell/plugin/midi.rb - Sequence to MIDI converter
#
# Copyright::   Copyright (C) 2003, 2005
#               Natsuhiro Ichinose <ichinose@genome.ist.i.kyoto-u.ac.jp>,
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: midi.rb,v 1.9 2007/04/05 23:35:41 trevor Exp $
#

#--
# *TODO*
#   - add "Ohno" style
#   - add a accessor to drum pattern
#   - add a new feature to select music style (pop, trans, ryukyu, ...)
#   - what is the base?
#++

class Bio::Sequence::NA

  class MidiTrack

    MidiProg = [
      "Acoustic Grand Piano",
      "Bright Acoustic Piano",
      "Electric grand Piano",
      "Honky Tonk Piano",
      "Eiectric Piano 1",
      "Electric Piano 2",
      "Harpsichord",
      "Clavinet",
      "Celesra",
      "Glockenspiel",
      "Music Box",
      "Vibraphone",
      "Marimba",
      "Xylophone",
      "Tubular bells",
      "Dulcimer",
      "Drawbar Organ",
      "Percussive Organ",
      "Rock Organ",
      "Church Organ",
      "Reed Organ",
      "Accordion",
      "Harmonica",
      "Tango Accordion",
      "Nylon Accustic Guitar",
      "Steel Acoustic Guitar",
      "Jazz Electric Guitar",
      "Ciean Electric Guitar",
      "Muted Electric Guitar",
      "Overdrive Guitar",
      "Distorted Guitar",
      "Guitar Harmonics",
      "Acoustic Bass",
      "Electric Fingered Bass",
      "Electric Picked Bass",
      "Fretless Bass",
      "Slap Bass 1",
      "Slap Bass 2",
      "Syn Bass 1",
      "Syn Bass 2",
      "Violin",
      "Viola",
      "Cello",
      "Contrabass",
      "Tremolo Strings",
      "Pizzicato Strings",
      "Orchestral Harp",
      "Timpani",
      "String Ensemble 1",
      "String Ensemble 2 (Slow)",
      "Syn Strings 1",
      "Syn Strings 2",
      "Choir Aahs",
      "Voice Oohs",
      "Syn Choir",
      "Orchestral Hit",
      "Trumpet",
      "Trombone",
      "Tuba",
      "Muted Trumpet",
      "French Horn",
      "Brass Section",
      "Syn Brass 1",
      "Syn Brass 2",
      "Soprano Sax",
      "Alto Sax",
      "Tenor Sax",
      "Baritone Sax",
      "Oboe",
      "English Horn",
      "Bassoon",
      "Clarinet",
      "Piccolo",
      "Flute",
      "Recorder",
      "Pan Flute",
      "Bottle Blow",
      "Shakuhachi",
      "Whistle",
      "Ocarina",
      "Syn Square Wave",
      "Syn Sawtooth Wave",
      "Syn Calliope",
      "Syn Chiff",
      "Syn Charang",
      "Syn Voice",
      "Syn Fifths Sawtooth Wave",
      "Syn Brass & Lead",
      "New Age Syn Pad",
      "Warm Syn Pad",
      "Polysynth Syn Pad",
      "Choir Syn Pad",
      "Bowed Syn Pad",
      "Metal Syn Pad",
      "Halo Syn Pad",
      "Sweep Syn Pad",
      "SFX Rain",
      "SFX Soundtrack",
      "SFX Crystal",
      "SFX Atmosphere",
      "SFX Brightness",
      "SFX Goblins",
      "SFX Echoes",
      "SFX Sci-fi",
      "Sitar",
      "Banjo",
      "Shamisen",
      "Koto",
      "Kalimba",
      "Bag Pipe",
      "Fiddle",
      "Shanai",
      "Tinkle Bell",
      "Agogo",
      "Steel Drums",
      "Woodblock",
      "Taiko Drum",
      "Melodic Tom",
      "Syn Drum",
      "Reverse Cymbal",
      "Guitar Fret Noise",
      "Breath Noise",
      "Seashore",
      "Bird Tweet",
      "Telephone Ring",
      "Helicopter",
      "Applause",
      "Gun Shot"
    ]

    Styles = {
  #    "Ohno" => {
  #      # http://home.hiroshima-u.ac.jp/cato/bunkakoryuron.html
  #    },
      "Ichinose" => {
        :tempo => 120,
        :scale => [0, 2, 4, 5, 7, 9, 11],
        :tones => [
          {:prog =>  9, :base => 60, :range => 2},
          {:prog => 13, :base => 48, :range => 2},
          {:prog => 41, :base => 48, :range => 2},
          {:prog => 44, :base => 36, :range => 2},
        ]
      },
      "Okinawan" => {
        :tempo => 180,
        :scale => [0,4,5,7,11],
        :tones => [
          {:prog => MidiProg.index("Harpsichord"),   :base => 60, :range => 2},
          {:prog => MidiProg.index("Dulcimer"),      :base => 48, :range => 2},
          {:prog => MidiProg.index("Fretless Base"), :base => 36, :range => 1},
        ]
      },
      "Major" => {
        :scale => [0,2,4,5,7,9,11],
      },
      "Minor" => {
        :scale => [0,2,3,5,7,9,10],
      },
      "Harmonic minor" => {
        :scale => [0,2,3,5,7,9,11],
      },
      "Whole tone" => {
        :scale => [0,2,4,6,8,10],
      },
      "Half tone" => {
        :scale => [0,1,2,3,4,5,6,7,8,9,10,11],
      },
      "Indian" => {
        :scale => [0,1,4,5,7,8,11],
      },
      "Arabic" => {
        :scale => [0,2,3,6,7,8,11],
      },
      "Spanish" => {
        :scale => [0,1,3,4,5,7,8,10],
      },
      "Japanese" => {
        :scale => [0,2,5,7,9],
      },
    }

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


  # style:
  #   Hash of :tempo, :scale, :tones
  # scale:
  #   C  C# D  D# E  F  F# G  G# A  A#  B
  #   0  1  2  3  4  5  6  7  8  9  10  11
  # tones:
  #   Hash of :prog, :base, :range -- tone, vol? or len?, octaves
  # drum:
  #   true (with rhythm part), false (without rhythm part)
  def to_midi(style = {}, drum = true)
    default = MidiTrack::Styles["Ichinose"]
    if style.is_a?(String)
      style = MidiTrack::Styles[style] || default
    end
    tempo = style[:tempo] || default[:tempo]
    scale = style[:scale] || default[:scale]
    tones = style[:tones] || default[:tones]

    track = []

    tones.each_with_index do |tone, i|
      ch = i
      ch += 1 if i >= 9         # skip rythm track
      track.push MidiTrack.new(ch, tone[:prog], tone[:base], tone[:range], scale)
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

  private

  def midifile(filename, seq, *args)
    begin
      print "Saving MIDI file (#{filename}) ... "
      File.open(filename, "w") do |file|
        file.puts seq.to_midi(*args)
      end
      puts "done"
    rescue
      warn "Error: Failed to save (#{filename}) : #{$!}"
    end
  end

end


if $0 == __FILE__

  # % for i in file*
  # do
  #   ruby -r bio bio/shell/plugin/midi.rb $i ${i}.mid
  # done

  include Bio::Shell

  seq_file = ARGV.shift
  mid_file = ARGV.shift

  Bio::FlatFile.auto(seq_file) do |ff|
    ff.each do |f|
      midifile(mid_file, f.naseq[0..1000])
    end
  end
end

