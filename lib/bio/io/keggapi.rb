#
# = bio/io/keggapi.rb - KEGG API access class
#
# Copyright::  Copyright (C) 2003, 2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: keggapi.rb,v 1.15 2007/07/20 21:56:45 k Exp $
#

require 'bio/io/soapwsdl'
require 'uri'
require 'net/http'
require 'bio/command'

module Bio
class KEGG

# == Description
#
# KEGG API is a web service to use KEGG system via SOAP/WSDL.
#
# == References
#
# For more informations on KEGG API, see the following site and read the
# reference manual.
#
# * http://www.genome.jp/kegg/soap/
# * http://www.genome.jp/kegg/soap/doc/keggapi_manual.html
#
# == List of methods
#
# As of KEGG API v5.0
#
# * list_databases
# * list_organisms
# * list_pathways(org)
# * binfo(string)
# * bget(string)
# * bfind(string)
# * btit(string)
# * get_linkdb_by_entry(entry_id, db, start, max_results)
# * get_best_best_neighbors_by_gene(genes_id, start, max_results)
# * get_best_neighbors_by_gene(genes_id, start, max_results)
# * get_reverse_best_neighbors_by_gene(genes_id, start, max_results)
# * get_paralogs_by_gene(genes_id, start, max_results)
# * get_similarity_between_genes(genes_id1, genes_id2)
# * get_motifs_by_gene(genes_id, db)
# * get_genes_by_motifs(motif_id_list, start, max_results)
# * get_ko_by_gene(genes_id)
# * get_ko_members(ko_id)
# * get_oc_members_by_gene(genes_id, start, max_results)
# * get_pc_members_by_gene(genes_id, start, max_results)
# * mark_pathway_by_objects(pathway_id, object_id_list)
# * color_pathway_by_objects(pathway_id, object_id_list, fg_color_list, bg_color_list)
# * get_genes_by_pathway(pathway_id)
# * get_enzymes_by_pathway(pathway_id)
# * get_compounds_by_pathway(pathway_id)
# * get_reactions_by_pathway(pathway_id)
# * get_pathways_by_genes(genes_id_list)
# * get_pathways_by_enzymes(enzyme_id_list)
# * get_pathways_by_compounds(compound_id_list)
# * get_pathways_by_reactions(reaction_id_list)
# * get_linked_pathways(pathway_id)
# * get_genes_by_enzyme(enzyme_id, org)
# * get_enzymes_by_gene(genes_id)
# * get_enzymes_by_compound(compound_id)
# * get_enzymes_by_reaction(reaction_id)
# * get_compounds_by_enzyme(enzyme_id)
# * get_compounds_by_reaction(reaction_id)
# * get_reactions_by_enzyme(enzyme_id)
# * get_reactions_by_compound(compound_id)
# * get_genes_by_organism(org, start, max_results)
# * get_number_of_genes_by_organism(org)                             
#
# == KEGG API methods implemented only in BioRuby
# 
# In BioRuby, returned values are added filter method to pick up
# values in a complex data type as an array.
# 
#   #!/usr/bin/env ruby
# 
#   require 'bio'
# 
#   serv = Bio::KEGG::API.new
#   results = serv.get_best_neighbors_by_gene("eco:b0002", "bsu")
# 
#   # case 0 : without filter
#   results.each do |hit|
#     print hit.genes_id1, "\t", hit.genes_id2, "\t", hit.sw_score, "\n"
#   end
# 
#   # case 1 : select gene names and SW score only
#   fields = [:genes_id1, :genes_id2, :sw_score]
#   results.each do |hit|
#     puts hit.filter(fields).join("\t")
#   end
#   
#   # case 2 : also uses aligned position in each amino acid sequence etc.
#   fields1 = [:genes_id1, :start_position1, :end_position1, :best_flag_1to2]
#   fields2 = [:genes_id2, :start_position2, :end_position2, :best_flag_2to1]
#   results.each do |hit|
#     print "> score: ", hit.sw_score, ", identity: ", hit.identity, "\n"
#     print "1:\t", hit.filter(fields1).join("\t"), "\n"
#     print "2:\t", hit.filter(fields2).join("\t"), "\n"
#   end
# 
# Using filter method will make it easy to change fields to select and
# keep the script clean.
# 
# * Bio::KEGG::API#get_all_neighbors_by_gene(genes_id, org)
# * Bio::KEGG::API#get_all_best_best_neighbors_by_gene(genes_id)
# * Bio::KEGG::API#get_all_best_neighbors_by_gene(genes_id)
# * Bio::KEGG::API#get_all_reverse_best_neighbors_by_gene(genes_id)
# * Bio::KEGG::API#get_all_paralogs_by_gene(genes_id)
# * Bio::KEGG::API#get_all_genes_by_motifs(motif_id_list)
# * Bio::KEGG::API#get_all_oc_members_by_gene(genes_id)
# * Bio::KEGG::API#get_all_pc_members_by_gene(genes_id)
# * Bio::KEGG::API#get_all_genes_by_organism(org)
# 
# These methods are wrapper for the methods without _all_ in its name
# and internally iterate to retrive all the results using start/max_results
# value pairs described above.  For example,
# 
#   #!/usr/bin/env ruby
#   
#   require 'soap/wsdlDriver'
#   
#   wsdl = "http://soap.genome.jp/KEGG.wsdl"
#   serv = SOAP::WSDLDriverFactory.new(wsdl).create_driver
#   serv.generate_explicit_type = true
#   
#   start = 1
#   max_results = 100
#   
#   loop do
#     results = serv.get_best_neighbors_by_gene('eco:b0002', start, max_results)
#     break unless results	# when no more results returned
#     results.each do |hit|
#       print hit.genes_id1, "\t", hit.genes_id2, "\t", hit.sw_score, "\n"
#     end
#     start += max_results
#   end
# 
# can be witten as
# 
#   #!/usr/bin/env ruby
#   
#   require 'bio'
#   
#   serv = Bio::KEGG::API.new
#   
#   results = serv.get_all_best_neighbors_by_gene('eco:b0002')
#   results.each do |hit|
#     print hit.genes_id1, "\t", hit.genes_id2, "\t", hit.sw_score, "\n"
#   end
# 
# 
# * Bio::KEGG::API#save_image(url, filename = nil)
# 
# Some methods of the KEGG API will return a URL of the generated image.
# This method save an image specified by the URL.  The filename can be
# specified by its second argument, otherwise basename of the URL will
# be used.
# 
#   #!/usr/bin/env ruby
#   
#   require 'bio'
#   
#   serv = Bio::KEGG::API.new("http://soap.genome.jp/v3.0/KEGG.wsdl")
#   
#   list = ["eco:b1002", "eco:b2388"]
#   url = serv.mark_pathway_by_objects("path:eco00010", list)
#   
#   # Save with the original filename (eco00010.gif in this case)
#   serv.save_image(url)
# 
#   # or save as "save_image.gif"
#   serv.save_image(url, "save_image.gif")
# 
# * Bio::KEGG::API#get_entries(entry_id_list)
# * Bio::KEGG::API#get_aaseqs(entry_id_list)
# * Bio::KEGG::API#get_naseqs(entry_id_list)
# * Bio::KEGG::API#get_definitions(entry_id_list)
# 
# These methods are for the shortcut and backward compatibility
# (these methods existed in the older version of the KEGG API).
# 
class API < Bio::SOAPWSDL

  SERVER_URI = "http://soap.genome.jp/KEGG.wsdl"

  # Connect to the KEGG API's SOAP server.  A WSDL file will be automatically
  # downloaded and parsed to generate the SOAP client driver.  The default URL
  # for the WSDL is http://soap.genome.jp/KEGG.wsdl but it can be changed by
  # the argument or by wsdl= method.
  def initialize(wsdl = nil)
    @wsdl = wsdl || SERVER_URI
    @log = nil
    @start = 1
    @max_results = 100
    create_driver
  end

  # Returns current value for the 'start' count for the methods having 
  # start/max_results argument pairs or changes the default value for
  # the 'start' count.
  attr_accessor :start

  # Returns current value for the 'max_results' number for the methods having 
  # start/max_results argument pairs or changes the default value for the
  # 'max_results' count. If your request timeouts, try smaller value for
  # the max_results.
  attr_accessor :max_results

  def method_missing(*arg)
    begin
      results = @driver.send(*arg)
    rescue Timeout::Error
      retry
    end
    results = add_filter(results)
    return results
  end


# def get_all_neighbors_by_gene(genes_id, org)
#   get_all(:get_neighbors_by_gene, genes_id, org)
# end

  def get_all_best_best_neighbors_by_gene(genes_id)
    get_all(:get_best_best_neighbors_by_gene, genes_id)
  end

  def get_all_best_neighbors_by_gene(genes_id)
    get_all(:get_best_neighbors_by_gene, genes_id)
  end

  def get_all_reverse_best_neighbors_by_gene(genes_id)
    get_all(:get_reverse_best_neighbors_by_gene, genes_id)
  end

  def get_all_paralogs_by_gene(genes_id)
    get_all(:get_paralogs_by_gene, genes_id)
  end

  def get_all_genes_by_motifs(motif_id_list)
    get_all(:get_genes_by_motifs, motif_id_list)
  end

  def get_all_oc_members_by_gene(genes_id)
    get_all(:get_oc_members_by_gene, genes_id)
  end

  def get_all_pc_members_by_gene(genes_id)
    get_all(:get_pc_members_by_gene, genes_id)
  end

  def get_all_genes_by_organism(org)
    get_all(:get_genes_by_organism, org)
  end

  def get_all_linkdb_by_entry(entry_id, db)
    get_all(:get_linkdb_by_entry, entry_id, db)
  end


  def save_image(url, filename = nil)
    schema, user, host, port, reg, path, = URI.split(url)
    filename ||= File.basename(path)

    http = Bio::Command.new_http(host, port)
    response, = http.get(path)
    File.open(filename, "w+") do |f|
      f.print response.body
    end
    return filename
  end


  def get_entries(ary = [])
    result = ''
    step = [@max_results, 50].min
    0.step(ary.length, step) do |i|
      str = ary[i, step].join(" ")
      if entry = @driver.send(:bget, str)
        result << entry.to_s
      end
    end
    return result
  end

  def get_aaseqs(ary = [])
    result = ''
    step = [@max_results, 50].min
    0.step(ary.length, step) do |i|
      str = "-f -n a " + ary[i, step].join(" ")
      if entry = @driver.send(:bget, str)
        result << entry.to_s
      end
    end
    return result
  end

  def get_naseqs(ary = [])
    result = ''
    step = [@max_results, 50].min
    0.step(ary.length, step) do |i|
      str = "-f -n n " + ary[i, step].join(" ")
      if entry = @driver.send(:bget, str)
        result << entry.to_s
      end
    end
    return result
  end

  def get_definitions(ary = [])
    result = ''
    step = [@max_results, 50].min
    0.step(ary.length, step) do |i|
      str = ary[i, step].join(" ")
      if entry = @driver.send(:btit, str)
        result << entry.to_s
      end
    end
    return result
  end


  private

  def add_filter(results)
    if results.is_a?(Array)
      results.each do |result|
	next if result.is_a?(Fixnum)
        def result.filter(fields)
          fields.collect { |field| self.send(field) }
        end
      end
    end
    return results
  end

  def get_all(method, *args)
    args << @start
    args << @max_results

    ary = []
    loop do
      results = @driver.send(method, *args)
      break unless results
      break if results.empty?
      results = add_filter(results)
      ary << results
      args[-2] += @max_results  # next start count
    end
    return ary.flatten
  end

end # API

end # KEGG
end # Bio


if __FILE__ == $0

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

  puts "### get_neighbors_by_gene('eco:b0002', 'all', 1, 5)"
  list = serv.get_neighbors_by_gene("eco:b0002", "all", 1, 5)
  list.each do |hit|
    puts [ hit.genes_id1, hit.genes_id2, hit.sw_score ].join("\t")
  end

  puts "# * get_all_neighbors_by_gene('eco:b0002', 'bsu')"
  list = serv.get_all_neighbors_by_gene("eco:b0002", "bsu")
  list.each do |hit|
    puts [ hit.genes_id1, hit.genes_id2, hit.sw_score ].join("\t")
  end

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

  puts "### get_similarity_between_genes('eco:b0002', 'bsu:BG10350')"
  relation = serv.get_similarity_between_genes("eco:b0002", "bsu:BG10350")
  puts "        genes_id1 : #{relation.genes_id1}"		# string
  puts "        genes_id2 : #{relation.genes_id2}"		# string
  puts "         sw_score : #{relation.sw_score}"		# int
  puts "        bit_score : #{relation.bit_score}"		# float
  puts "         identity : #{relation.identity}"		# float
  puts "          overlap : #{relation.overlap}"		# int
  puts "  start_position1 : #{relation.start_position1}"	# int
  puts "    end_position1 : #{relation.end_position1}"		# int
  puts "  start_position2 : #{relation.start_position2}"	# int
  puts "    end_position2 : #{relation.end_position2}"		# int
  puts "   best_flag_1to2 : #{relation.best_flag_1to2}"		# boolean
  puts "   best_flag_2to1 : #{relation.best_flag_2to1}"		# boolean
  puts "      definition1 : #{relation.definition1}"		# string
  puts "      definition2 : #{relation.definition2}"		# string
  puts "          length1 : #{relation.length1}"		# int
  puts "          length2 : #{relation.length2}"		# int

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

  puts "### get_ko_members('ko:K00003')"
  list = serv.get_ko_members("ko:K00003")
  list.each do |gene|
    puts gene
  end

  puts "### get_oc_members_by_gene('eco:b0002', 1, 5)"
  list = serv.get_oc_members_by_gene("eco:b0002", 1, 5)
  list.each do |gene|
    puts gene
  end

  puts "# * get_all_oc_members_by_gene('eco:b0002')"
  list = serv.get_all_oc_members_by_gene("eco:b0002")
  list.each do |gene|
    puts gene
  end

  puts "### get_pc_members_by_gene('eco:b0002', 1, 5)"
  list = serv.get_pc_members_by_gene("eco:b0002", 1, 5)
  list.each do |gene|
    puts gene
  end

  puts "# * get_all_pc_members_by_gene('eco:b0002')"
  list = serv.get_all_pc_members_by_gene("eco:b0002")
  list.each do |gene|
    puts gene
  end

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

end

