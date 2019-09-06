#!/usr/bin/env ruby
#
# color_scheme_aa.rb - A Bio::ColorScheme demo script for Amino Acid sequences.
#
#  Usage:
#
#   % ruby color_scheme_aa.rb > cs-seq-faa.html
#
#   % cat seq.faa
#   >AA_sequence
#   MKRISTTITTTITITTGNGAG
#   % ruby color_scheme_aa.rb seq.faa > colored-seq-faa.html
#
#
# Copyright::  Copyright (C) 2005
#              Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#

require 'bio'


# returns folded sequence with <br>.
def br(i, width = 80)
  return "<br\n>"  if i % width == 0
  ""
end


# returns sequence html doc
def display(seq, cs)
  html = '<p style="font-family: monospace">'
  postfix = '</span>'
  i = 0
  seq.each_char do |c|
    color = cs[c]
    prefix = %Q(<span style="background:\##{color};">)
    html += prefix + c + postfix
    html += br(i += 1)
  end
  html + '</p>'
end


# returns scheme wise html doc
def display_scheme(scheme, aaseq)
  html = ''
  cs = Bio::ColorScheme.const_get(scheme.intern)
  [aaseq].each do |seq|
    html += display(seq, cs)
  end
  return  ['<div>', "<h3>#{cs}</h3>", html, '</div>']
end



if fna = ARGV.shift
  aaseq = Bio::FlatFile.open(fna) { |ff| ff.next_entry.aaseq }
else
  aaseq = Bio::Sequence::AA.new('ARNDCQEGHILKMFPSTWYV' * 20).randomize
end

title =  'Bio::ColorScheme for amino acid sequences'
doc = ['<html>',
       '<header>', '<title>', title, '</title>', '</header>',
       '<body>',  '<h1>', title, '</h1>']

doc << ['<div>', '<h2>', 'Simple colors', '</h2>']

['Zappo', 'Taylor' ].each do |scheme|
  doc << display_scheme(scheme, aaseq)
end
doc << ['</div>']


doc << ['<div>', '<h2>', 'Score colors', '</h2>']
['Buried', 'Helix', 'Hydropathy', 'Strand', 'Turn'].each do |score|
  doc << display_scheme(score, aaseq)
end
doc << ['</div>']

puts doc + ['</body>','</html>']
