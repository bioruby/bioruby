#!/usr/bin/env ruby
#
# fastq2html.rb - HTML visualization of FASTQ sequences
#
#  Usage:
#
#   % ruby fastq2html.rb seq00.fastq > seq00.html
#
#
# Copyright::  Copyright (C) 2019 BioRuby Project
#              Copyright (C) 2005 Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
#

require 'bio'

# thickness to color
def thickness2color(t)
  c = "%02X" % ((t * 255.0).to_i)
  c * 3
end

# Creates 
def create_score2color_hashes
  h_bg = {}
  h_char = {}
  cutoff_low = 0
  cutoff_high = 50
  range = cutoff_high - cutoff_low
  sc_min = -5
  sc_max = 100
  (sc_min..sc_max).each do |i|
    t = if i <= cutoff_low then
          0.0
        elsif i >= cutoff_high then
          1.0
        else
          (i - cutoff_low).to_f / range
        end
    h_bg[i] = thickness2color(t)
    h_char[i] = thickness2color((t > 0.3) ? 0.0 : 0.55)
  end
  h_bg.default = h_bg[cutoff_low]
  h_char.default = h_char[cutoff_low]
  [h_bg, h_char]
end

# Color code from quality score
SCORE2COLOR_BG, SCORE2COLOR_CHAR = create_score2color_hashes

# returns folded sequence with <br>.
def br(i, width = 80)
  return "<br\n>"  if i % width == 0
  ""
end

# returns sequence html doc
def display(naseq, scores)
  html = '<p style="font-family: monospace">'
  postfix = '</span>'
  i = 0
  naseq.each_char.with_index do |c, i|
    sc = scores[i]
    bgcol = SCORE2COLOR_BG[sc]
    col = SCORE2COLOR_CHAR[sc]
    prefix = %Q(<span style="color:\##{col}; background:\##{bgcol};">)
    html += prefix + c + postfix
    html += br(i += 1)
  end
  html + '</p>'
end

# returns colorized html doc
def fastq2html(definition, naseq, scores)
  html = display(naseq, scores)
  return  ['<div>', "<div>&gt;#{CGI.escapeHTML(definition)}</div>", html, '</div>']
end

title =  'Sequences with quality scores'
puts ['<html>',
       '<header>', '<title>', title, '</title>', '</header>',
       '<body>',  '<h1>', title, '</h1>']

#main loop
ARGV.each do |filename|
  Bio::FlatFile.open(filename) do |ff|
    ff.each do |e|
      puts fastq2html(e.definition, e.naseq, e.quality_scores)
    end
  end
end

puts ['</body>','</html>']
