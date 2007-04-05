#!/usr/bin/env ruby
#
# psortplot_html.rb - A KEGG API demo script. Generates a HTML file of 
#                     genes marked by PSORT II predictions onto a 
#                     KEGG/PATHWAY map.
#
#  Usage:
#
#   % ruby psortplot_html.rb
#   % cat sce00010_psort2.html
#   % ruby psortplot_html.rb path:eco00010
#   % cat eco00010_psort2.html
#
# Copyright::  Copyright (C) 2005
#              Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: psortplot_html.rb,v 1.3 2007/04/05 23:35:42 trevor Exp $
#

require 'bio'

class KEGG
  DBGET_BASEURI = 'http://kegg.com/dbget-bin'
  WWW_BGET_BASEURI = DBGET_BASEURI + '/www_bget'
  WWW_PATHWAY_BASEURI = DBGET_BASEURI + '/get_pathway'

  # path := path:sce00010
  def self.link_pathway(path0)
    path, path = path0.split(':')
    org_name = path.scan(/(^\w{3})/).to_s
    mapno = path.sub(org_name, '')
    str = "<a href='#{WWW_PATHWAY_BASEURI}?org_name=#{org_name}&mapno=#{mapno}'>#{path0}</a>"
  end
  
  # ec_num := ec:1.2.3.4
  def self.link_ec(ec_num)
    ec = ec_num.sub(/^ec:/, '')
    str = "<a href='#{WWW_BGET_BASEURI}?enzyme+#{ec}'>#{ec_num}</a>"
    return str
  end

  # gene := eco:b0002
  def self.link_genes(gene)
    org_name, gene_name = gene.split(':')
    str = "<a href='#{WWW_BGET_BASEURI}?#{org_name}+#{gene_name}'>#{gene}</a>"
    return str
  end
end


class PSORT
  COLOR_Palette = {
    'csk' => "#FF0000",   # 'cytoskeletal'
    'cyt' => "#FF8000",   # 'cytoplasmic'
    'nuc' => "#FFFF00",   # 'nuclear'
    'mit' => "#80FF00",   # 'mitochondrial'
    'ves' => "#00FF00",	# 'vesicles of secretory system'
    'end' => "#00FF80",	# 'endoplasmic reticulum'
    'gol' => "#00FFFF",	# 'Golgi'
    'vac' => "#0080FF",	# 'vacuolar'
    'pla' => "#0000FF",	# 'plasma membrane'
    'pox' => "#8000FF",	# 'peroxisomal'
    'exc' => "#FF00FF",	# 'extracellular, including cell wall'
    '---' => "#FF0080"	# 'other'
  }
end




keggapi = Bio::KEGG::API.new
psort2serv = Bio::PSORT::PSORT2.imsut

# Obtains a list of genes on specified pathway
pathway = ARGV.shift || "path:sce00010"
genes = keggapi.get_genes_by_pathway(pathway)

scl = Hash.new # protein subcelluler localizations
ec = Hash.new  # EC numbers

serial = 0
sync_default = $stdout.sync
$stdout.sync = true
genes.each do |gene|
  print "#{(serial += 1).to_s.rjust(genes.size.to_s.size)}\t#{gene}\t"
  # Obtains amino acid sequence from KEGG GENES entry
  aaseq = keggapi.get_aaseqs([gene])

  # Predicts protein subcellualr localization
  result = psort2serv.exec(aaseq)
  scl[gene] = result.pred
  print "#{scl[gene]}\t"

  # Obtains the EC number from KEGG GENES entry
  ec[gene] = keggapi.get_enzymes_by_gene(gene)
  puts "#{ec[gene].inspect}"
end
$stdout.sync = sync_default




fg_list = Array.new
bg_list = Array.new

genes.each do |gene|
  fg_list << "#FF0000"
  bg_list << PSORT::COLOR_Palette[scl[gene]]
end

# coloring KEGG pathway according to gene's localization
url = keggapi.color_pathway_by_objects(pathway, genes, fg_list, bg_list)
puts "#{url} downloaded."

# remove "path:" prefix from pathway_id
path_code = pathway.sub(/^path:/, '')

# save the result image
image_file = "#{path_code}_psort2.gif"
begin
  keggapi.save_image(url, image_file)
end


# create html with a color palette
html = <<END
<html>
<head>
<title>PSORT II prediction protein subcellular localization map of KEGG/PATHWAY (#{pathway})</title>
<style>
table { border-collapse: collapse; }
td { border: 1px solid black; padding: 5px; }
td.outer { border: none; vertical-align: top; }
</style>
</head>
<body>
<h1><li><a href="http://psort.ims.u-tokyo.ac.jp/helpwww2.html">PSORT II</a> prediction protein subcellular localization map of <a href="http://kegg.com/kegg/pathway.html">KEGG/PATHWAY</a> (<a href="">#{KEGG.link_pathway(pathway)})</h1>

<table>
<tr>
  <td class=outer>
    <table>
    <tr>
      <th></th>
      <th>EC</th>
      <th>Gene</th>
      <th>Localization</th>
    </tr>
END


# generate gene table with localization
names = Bio::PSORT::PSORT2::SclNames
multi_genes = Hash.new(0)

ec.values.flatten.sort.uniq.each do |ec_num|
  ec.find_all {|x| x[1].include?(ec_num) }.each do |gene|
    gene = gene[0]
    loc = scl[gene]
    color = PSORT::COLOR_Palette[loc]
    name = names[loc]
    multi_genes[gene] += 1

    html += <<END
    <tr>
      <td>#{multi_genes[gene]}</td>
      <td>#{KEGG.link_ec(ec_num)}</td>
      <td>#{KEGG.link_genes(gene)}</td>
      <td bgcolor="#{color}">#{name}</td>
    </tr>
END
  end
end

html += <<END
    </table>
  </td>
  <td class=outer>
    <table>
    <tr>
      <th>Code</th>
      <th>Color</th>
    </tr>
END

# generate color code table also
PSORT::COLOR_Palette.sort.each do |code, color|
  html += <<END
    <tr>
      <td>#{code}</td>
      <td bgcolor="#{color}">#{names[code]}</td>
    </tr>
END
end

html += <<END
    </table>
  </td>
</tr>
</table>
<br>
<img src="#{image_file}">
</body>
</html>
END

# save generated HTML file
html_file = "#{path_code}_psort2.html" 
File.open(html_file, "w+") do |file|
  file.puts html
end

puts "Open #{html_file}"
