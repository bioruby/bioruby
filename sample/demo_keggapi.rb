#
# = sample/demo_keggapi.rb - demonstration of Bio::KEGG::API web service client
#
# Copyright::  Copyright (C) 2003, 2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::KEGG::API, the KEGG API web service client via
# SOAP/WSDL.
#
# == Requirements
#
# Internet connection is needed.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_keggapi.rb
#
# == Notes
#
# * It may take long time to run this script.
# * It can not be run with Ruby 1.9 because SOAP4R (SOAP support for Ruby)
#   currently does not support Ruby 1.9.
#
# == Development information
#
# The code was moved from lib/bio/io/keggapi.rb, and modified as below:
#
# * Commented out deprecated methods: get_neighbors_by_gene,
#   get_similarity_between_genes, get_ko_members, get_oc_members_by_gene,
#   get_pc_members_by_gene.
# * Commented out some methods internally using the deprecated methods:
#   get_all_neighbors_by_gene, get_all_oc_members_by_gene,
#   get_all_pc_members_by_gene.
#

require 'bio'

#if __FILE__ == $0

  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  puts ">>> KEGG API"
  serv = Bio::KEGG::API.new
# serv.log = STDERR

  puts "# * parameters"
  puts "        wsdl : #{serv.wsdl}"
  puts "         log : #{serv.log}"
  puts "       start : #{serv.start}"
  puts " max_results : #{serv.max_results}"

  puts "=== META"

  puts "### list_databases"
  list = serv.list_databases
  list.each do |db|
    print db.entry_id, "\t", db.definition, "\n"
  end

  puts "### list_organisms"
  list = serv.list_organisms
  list.each do |org|
    print org.entry_id, "\t", org.definition, "\n"
  end

  puts "### list_pathways('map') : reference pathway"
  list = serv.list_pathways("map")
  list.each do |path|
    print path.entry_id, "\t", path.definition, "\n"
  end

  puts "### list_pathways('eco') : E. coli pathway"
  list = serv.list_pathways("eco")
  list.each do |path|
    print path.entry_id, "\t", path.definition, "\n"
  end

  puts "=== DBGET"

  puts "### binfo('all')"
  puts serv.binfo("all")

  puts "### binfo('genbank')"
  puts serv.binfo("genbank")

  puts "### bfind('genbank kinase cell cycle human')"
  puts serv.bfind("genbank kinase cell cycle human")

  puts "### bget('gb:AJ617376')"
  puts serv.bget("gb:AJ617376")

  puts "### bget('eco:b0002 eco:b0003')"
  puts serv.bget("eco:b0002 eco:b0003")

  puts "### btit('eco:b0002 eco:b0003')"
  puts serv.btit("eco:b0002 eco:b0003")

  puts "# * get_entries(['eco:b0002', 'eco:b0003'])"
  puts serv.get_entries(["eco:b0002", "eco:b0003"])

  puts "# * get_aaseqs(['eco:b0002', 'eco:b0003'])"
  puts serv.get_aaseqs(["eco:b0002", "eco:b0003"])

  puts "# * get_naseqs(['eco:b0002', 'eco:b0003'])"
  puts serv.get_naseqs(["eco:b0002", "eco:b0003"])

  puts "# * get_definitions(['eco:b0002', 'eco:b0003'])"
  puts serv.get_definitions(["eco:b0002", "eco:b0003"])

  puts "# * get_definitions(('eco:b0001'..'eco:b0200').to_a)"
  puts serv.get_definitions(("eco:b0001".."eco:b0200").to_a)

  puts "=== LinkDB"

  puts "### get_linkdb_by_entry('eco:b0002', 'pathway', 1, 5)"
  list = serv.get_linkdb_by_entry("eco:b0002", "pathway", 1, 5)
  list.each do |link|
    puts [ link.entry_id1, link.entry_id2, link.type, link.path ].join("\t")
  end

  puts "# * get_all_linkdb_by_entry('eco:b0002', 'pathway')"
  list = serv.get_all_linkdb_by_entry("eco:b0002", "pathway")
  list.each do |link|
    puts [ link.entry_id1, link.entry_id2, link.type, link.path ].join("\t")
  end

  puts "=== SSDB"

  # The method "get_neighbors_by_gene" is deprecated in 2005-02-20.
  #
  #puts "### get_neighbors_by_gene('eco:b0002', 'all', 1, 5)"
  #list = serv.get_neighbors_by_gene("eco:b0002", "all", 1, 5)
  #list.each do |hit|
  #  puts [ hit.genes_id1, hit.genes_id2, hit.sw_score ].join("\t")
  #end

  # The method "get_all_neighbors_by_gene" can not be used because
  # it internally uses the deprecated "get_neighbors_by_gene" method.
  #
  #puts "# * get_all_neighbors_by_gene('eco:b0002', 'bsu')"
  #list = serv.get_all_neighbors_by_gene("eco:b0002", "bsu")
  #list.each do |hit|
  #  puts [ hit.genes_id1, hit.genes_id2, hit.sw_score ].join("\t")
  #end

  puts "### get_best_best_neighbors_by_gene('eco:b0002', 1, 5)"
  list = serv.get_best_best_neighbors_by_gene("eco:b0002", 1, 5)
  list.each do |hit|
    puts [ hit.genes_id1, hit.genes_id2, hit.sw_score ].join("\t")
  end

  puts "# * get_all_best_best_neighbors_by_gene('eco:b0002')"
  list = serv.get_all_best_best_neighbors_by_gene("eco:b0002")
  list.each do |hit|
    puts [ hit.genes_id1, hit.genes_id2, hit.sw_score ].join("\t")
  end

  puts "### get_best_neighbors_by_gene('eco:b0002', 1, 5)"
  list = serv.get_best_neighbors_by_gene("eco:b0002", 1, 5)
  list.each do |hit|
    puts [ hit.genes_id1, hit.genes_id2, hit.sw_score ].join("\t")
  end

  puts "# * get_all_best_neighbors_by_gene('eco:b0002')"
  list = serv.get_all_best_neighbors_by_gene("eco:b0002")
  list.each do |hit|
    puts [ hit.genes_id1, hit.genes_id2, hit.sw_score ].join("\t")
  end

  puts "### get_reverse_best_neighbors_by_gene('eco:b0002', 1, 5)"
  list = serv.get_reverse_best_neighbors_by_gene("eco:b0002", 1, 5)
  list.each do |hit|
    puts [ hit.genes_id1, hit.genes_id2, hit.sw_score ].join("\t")
  end

  puts "# * get_all_reverse_best_neighbors_by_gene('eco:b0002')"
  list = serv.get_all_reverse_best_neighbors_by_gene("eco:b0002")
  list.each do |hit|
    puts [ hit.genes_id1, hit.genes_id2, hit.sw_score ].join("\t")
  end

  puts "### get_paralogs_by_gene('eco:b0002', 1, 5)"
  list = serv.get_paralogs_by_gene("eco:b0002", 1, 5)
  list.each do |hit|
    puts [ hit.genes_id1, hit.genes_id2, hit.sw_score ].join("\t")
  end

  puts "# * get_all_paralogs_by_gene('eco:b0002')"
  list = serv.get_all_paralogs_by_gene("eco:b0002")
  list.each do |hit|
    puts [ hit.genes_id1, hit.genes_id2, hit.sw_score ].join("\t")
  end

  # The method "get_similarity_between_genes" is deprecated in 2005-02-20.
  #
  #puts "### get_similarity_between_genes('eco:b0002', 'bsu:BG10350')"
  #relation = serv.get_similarity_between_genes("eco:b0002", "bsu:BG10350")
  #puts "        genes_id1 : #{relation.genes_id1}"		# string
  #puts "        genes_id2 : #{relation.genes_id2}"		# string
  #puts "         sw_score : #{relation.sw_score}"		# int
  #puts "        bit_score : #{relation.bit_score}"		# float
  #puts "         identity : #{relation.identity}"		# float
  #puts "          overlap : #{relation.overlap}"		# int
  #puts "  start_position1 : #{relation.start_position1}"	# int
  #puts "    end_position1 : #{relation.end_position1}"		# int
  #puts "  start_position2 : #{relation.start_position2}"	# int
  #puts "    end_position2 : #{relation.end_position2}"		# int
  #puts "   best_flag_1to2 : #{relation.best_flag_1to2}"		# boolean
  #puts "   best_flag_2to1 : #{relation.best_flag_2to1}"		# boolean
  #puts "      definition1 : #{relation.definition1}"		# string
  #puts "      definition2 : #{relation.definition2}"		# string
  #puts "          length1 : #{relation.length1}"		# int
  #puts "          length2 : #{relation.length2}"		# int

  puts "=== MOTIF"

  puts "### get_motifs_by_gene('eco:b0002', 'pfam')"
  list = serv.get_motifs_by_gene("eco:b0002", "pfam")
  list.each do |motif|
    puts motif.motif_id
  end if list

  puts "### get_motifs_by_gene('eco:b0002', 'tfam')"
  list = serv.get_motifs_by_gene("eco:b0002", "tfam")
  list.each do |motif|
    puts motif.motif_id
  end if list

  puts "### get_motifs_by_gene('eco:b0002', 'pspt')"
  list = serv.get_motifs_by_gene("eco:b0002", "pspt")
  list.each do |motif|
    puts motif.motif_id
  end if list

  puts "### get_motifs_by_gene('eco:b0002', 'pspf')"
  list = serv.get_motifs_by_gene("eco:b0002", "pspf")
  list.each do |motif|
    puts motif.motif_id
  end if list

  puts "### get_motifs_by_gene('eco:b0002', 'all')"
  list = serv.get_motifs_by_gene("eco:b0002", "all")
  list.each do |motif|
    puts "# * motif result"
    puts "       motif_id : #{motif.motif_id}"
    puts "     definition : #{motif.definition}"
    puts "       genes_id : #{motif.genes_id}"
    puts " start_position : #{motif.start_position}"
    puts "   end_position : #{motif.end_position}"
    puts "          score : #{motif.score}"
    puts "         evalue : #{motif.evalue}"
  end

  puts "### get_genes_by_motifs(['pf:ACT', 'ps:ASPARTOKINASE'], 1, 5)"
  list = serv.get_genes_by_motifs(["pf:ACT", "ps:ASPARTOKINASE"], 1, 5)
  list.each do |gene|
    puts [ gene.entry_id, gene.definition ].join("\t")
  end

  puts "# * get_all_genes_by_motifs(['pf:ACT', 'ps:ASPARTOKINASE'])"
  list = serv.get_all_genes_by_motifs(["pf:ACT", "ps:ASPARTOKINASE"])
  list.each do |gene|
    puts [ gene.entry_id, gene.definition ].join("\t")
  end

  puts "=== KO, OC, PC"

  puts "### get_ko_by_gene('eco:b0002')"
  list = serv.get_ko_by_gene("eco:b0002")
  list.each do |ko|
    puts ko
  end

  # The method "get_ko_members" is removed in 2005-06-01.
  # 
  #puts "### get_ko_members('ko:K00003')"
  #list = serv.get_ko_members("ko:K00003")
  #list.each do |gene|
  #  puts gene
  #end

  # The method "get_oc_members_by_gene" is removed in 2006-10-04.
  #
  #puts "### get_oc_members_by_gene('eco:b0002', 1, 5)"
  #list = serv.get_oc_members_by_gene("eco:b0002", 1, 5)
  #list.each do |gene|
  #  puts gene
  #end

  # The method "get_all_oc_members_by_gene" can not be used because
  # it internally uses the deprecated "get_oc_members_by_gene" method.
  #
  #puts "# * get_all_oc_members_by_gene('eco:b0002')"
  #list = serv.get_all_oc_members_by_gene("eco:b0002")
  #list.each do |gene|
  #  puts gene
  #end

  # The method "get_pc_members_by_gene" is removed in 2006-10-04.
  #
  #puts "### get_pc_members_by_gene('eco:b0002', 1, 5)"
  #list = serv.get_pc_members_by_gene("eco:b0002", 1, 5)
  #list.each do |gene|
  #  puts gene
  #end

  # The method "get_all_pc_members_by_gene" can not be used because
  # it internally uses the deprecated "get_pc_members_by_gene" method.
  #
  #puts "# * get_all_pc_members_by_gene('eco:b0002')"
  #list = serv.get_all_pc_members_by_gene("eco:b0002")
  #list.each do |gene|
  #  puts gene
  #end

  puts "=== PATHWAY"

  puts "==== coloring pathway"

  puts "### mark_pathway_by_objects('path:eco00260', obj_list)"
  puts "  obj_list = ['eco:b0002', 'cpd:C00263']"
  obj_list = ["eco:b0002", "cpd:C00263"]
  url = serv.mark_pathway_by_objects("path:eco00260", obj_list)
  puts url

  puts "### color_pathway_by_objects('path:eco00053', obj_list, fg_list, bg_list)"
  puts "  obj_list = ['eco:b0207', 'eco:b1300']"
  puts "  fg_list  = ['blue', '#00ff00']"
  puts "  bg_list  = ['#ff0000', 'yellow']"
  obj_list = ["eco:b0207", "eco:b1300"]
  fg_list  = ["blue", "#00ff00"]
  bg_list  = ["#ff0000", "yellow"]
  url = serv.color_pathway_by_objects("path:eco00053", obj_list, fg_list, bg_list)
  puts url

  #puts "# * save_image(#{url})"
  #filename = serv.save_image(url, "test.gif")
  #filename = serv.save_image(url)
  #puts filename

  puts "==== objects on pathway"

  puts "### get_genes_by_pathway('path:map00010')"
  list = serv.get_genes_by_pathway("path:map00010")
  list.each do |gene|
    puts gene
  end

  puts "### get_genes_by_pathway('path:eco00010')"
  list = serv.get_genes_by_pathway("path:eco00010")
  list.each do |gene|
    puts gene
  end

  puts "### get_enzymes_by_pathway('path:map00010')"
  list = serv.get_enzymes_by_pathway("path:map00010")
  list.each do |enzyme|
    puts enzyme
  end

  puts "### get_enzymes_by_pathway('path:eco00010')"
  list = serv.get_enzymes_by_pathway("path:eco00010")
  list.each do |enzyme|
    puts enzyme
  end

  puts "### get_compounds_by_pathway('path:map00010')"
  list = serv.get_compounds_by_pathway("path:map00010")
  list.each do |compound|
    puts compound
  end

  puts "### get_compounds_by_pathway('path:eco00010')"
  list = serv.get_compounds_by_pathway("path:eco00010")
  list.each do |compound|
    puts compound
  end

  puts "### get_reactions_by_pathway('path:map00010')"
  list = serv.get_reactions_by_pathway("path:map00010")
  list.each do |reaction|
    puts reaction
  end

  puts "### get_reactions_by_pathway('path:eco00010')"
  list = serv.get_reactions_by_pathway("path:eco00010")
  list.each do |reaction|
    puts reaction
  end

  puts "==== pathway by objects"

  puts "### get_pathways_by_genes(['eco:b0756', 'eco:b1002'])"
  list = serv.get_pathways_by_genes(["eco:b0756", "eco:b1002"])
  list.each do |path|
    puts path
  end

  puts "### get_pathways_by_enzymes(['ec:5.1.3.3', 'ec:3.1.3.10'])"
  list = serv.get_pathways_by_enzymes(["ec:5.1.3.3", "ec:3.1.3.10"])
  list.each do |path|
    puts path
  end

  puts "### get_pathways_by_compounds(['cpd:C00221', 'cpd:C00267'])"
  list = serv.get_pathways_by_compounds(["cpd:C00221", "cpd:C00267"])
  list.each do |path|
    puts path
  end

  puts "### get_pathways_by_reactions(['rn:R00014', 'rn:R00710'])"
  list = serv.get_pathways_by_reactions(["rn:R00014", "rn:R00710"])
  list.each do |path|
    puts path
  end

  puts "==== relation between objects"

  puts "### get_linked_pathways('path:eco00620')"
  list = serv.get_linked_pathways('path:eco00620')
  list.each do |path|
    puts path
  end

  puts "### get_genes_by_enzyme('ec:1.1.1.1', 'eco')"
  list = serv.get_genes_by_enzyme("ec:1.1.1.1", "eco")
  list.each do |gene|
    puts gene
  end

  puts "### get_enzymes_by_gene('eco:b0002')"
  list = serv.get_enzymes_by_gene("eco:b0002")
  list.each do |enzyme|
    puts enzyme
  end

  puts "### get_enzymes_by_compound('cpd:C00345')"
  list = serv.get_enzymes_by_compound("cpd:C00345")
  list.each do |enzyme|
    puts enzyme
  end

  puts "### get_enzymes_by_reaction('rn:R00100')"
  list = serv.get_enzymes_by_reaction("rn:R00100")
  list.each do |enzyme|
    puts enzyme
  end

  puts "### get_compounds_by_enzyme('ec:2.7.1.12')"
  list = serv.get_compounds_by_enzyme("ec:2.7.1.12")
  list.each do |compound|
    puts compound
  end

  puts "### get_compounds_by_reaction('rn:R00100')"
  list = serv.get_compounds_by_reaction("rn:R00100")
  list.each do |compound|
    puts compound
  end
  
  puts "### get_reactions_by_enzyme('ec:2.7.1.12')"
  list = serv.get_reactions_by_enzyme("ec:2.7.1.12")
  list.each do |reaction|
    puts reaction
  end

  puts "### get_reactions_by_compound('cpd:C00199')"
  list = serv.get_reactions_by_compound("cpd:C00199")
  list.each do |reaction|
    puts reaction
  end
  
  puts "=== GENES"

  puts "### get_genes_by_organism('mge', 1, 5)"
  list = serv.get_genes_by_organism("mge", 1, 5)
  list.each do |gene|
    puts gene
  end

  puts "# * get_all_genes_by_organism('mge')"
  list = serv.get_all_genes_by_organism("mge")
  list.each do |gene|
    puts gene
  end
  
  puts "=== GENOME"

  puts "### get_number_of_genes_by_organism(org)"
  puts serv.get_number_of_genes_by_organism("mge")

#end

