#
# = bio/io/keggapi.rb - KEGG API access class
#
# Copyright::  Copyright (C) 2003, 2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
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
    response = http.get(path)
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

