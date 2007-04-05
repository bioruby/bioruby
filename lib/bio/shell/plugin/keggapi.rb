#
# = bio/shell/plugin/keggapi.rb - plugin for KEGG API
#
# Copyright::   Copyright (C) 2005
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: keggapi.rb,v 1.12 2007/04/05 23:35:41 trevor Exp $
#

module Bio::Shell

  module Private

    module_function

    def keggapi_definition2tab(list)
      ary = []
      list.each do |entry|
        ary << "#{entry.entry_id}\t#{entry.definition}"
      end
      return ary
    end
  end

  private

  def keggapi(wsdl = nil)
    if wsdl
      @keggapi = Bio::KEGG::API.new(wsdl)
    else
      @keggapi ||= Bio::KEGG::API.new
    end
    return @keggapi
  end

  # DBGET

  def binfo(db = "all")
    result = keggapi.binfo(db)
    puts result
    return result
  end

  def bfind(str)
    result = keggapi.bfind(str)
    return result
  end

  def bget(str)
    result = keggapi.bget(str)
    if block_given?
      yield result
    else
      puts result
      return result
    end
  end

  def btit(str)
    result = keggapi.btit(str)
    puts result
    return result
  end

  def bconv(str)
    result = keggapi.bconv(str)
    puts result
    return result
  end

  # DATABASES

  def keggdbs
    list = keggapi.list_databases
    result = Bio::Shell::Private.keggapi_definition2tab(list).join("\n")
    puts result
    return list.map {|x| x.entry_id}
  end

  def keggorgs
    list = keggapi.list_organisms
    result = Bio::Shell::Private.keggapi_definition2tab(list).sort.join("\n")
    puts result
    return list.map {|x| x.entry_id}
  end

  def keggpathways(org = "map")
    list = keggapi.list_pathways(org)
    result = Bio::Shell::Private.keggapi_definition2tab(list).join("\n")
    puts result
    return list.map {|x| x.entry_id}
  end

  # use KEGG DAS insetad
  def kegggenomeseq(org)
    result = ""
    require 'net/ftp'
    Net::FTP.open("ftp.genome.jp", "anonymous") do |ftp|
      path = "/pub/kegg/genomes/#{org}"
      list = ftp.nlst(path)
      file = list.grep(/.*genome$/).shift
      if file
        open("ftp://ftp.genome.jp/#{file}") do |file|
          result = file.read
        end
      end
    end
    return result
  end

end

=begin

== BioRuby extensions

--- get_all_best_best_neighbors_by_gene(genes_id)
--- get_all_best_neighbors_by_gene(genes_id)
--- get_all_reverse_best_neighbors_by_gene(genes_id)
--- get_all_paralogs_by_gene(genes_id)
--- get_all_genes_by_motifs(motif_id_list)
--- get_all_oc_members_by_gene(genes_id)
--- get_all_pc_members_by_gene(genes_id)
--- get_all_genes_by_organism(org)
--- get_all_linkdb_by_entry(entry_id, db)
--- save_image(url, filename = nil)
--- get_entries(ary = [])
--- get_aaseqs(ary = [])
--- get_naseqs(ary = [])
--- get_definitions(ary = [])

== Original KEGG API methods

--- get_linkdb_by_entry(entry_id, db, start, max_results)
--- get_best_best_neighbors_by_gene(genes_id, start, max_results)
--- get_best_neighbors_by_gene(genes_id, start, max_results)
--- get_reverse_best_neighbors_by_gene(genes_id, start, max_results)
--- get_paralogs_by_gene(genes_id, start, max_results)
--- get_motifs_by_gene(genes_id, db)
--- get_genes_by_motifs(motif_id_list, start, max_results)
--- get_ko_by_gene(genes_id)
--- get_ko_by_ko_class(ko_class_id)
--- get_genes_by_ko_class(ko_class_id, org, start, max_results)
--- get_genes_by_ko(ko_id, org)
--- get_oc_members_by_gene(genes_id, start, max_results)
--- get_pc_members_by_gene(genes_id, start, max_results)
--- mark_pathway_by_objects(pathway_id, object_id_list)
--- color_pathway_by_objects(pathway_id, object_id_list, fg_color_list, bg_color_list)
--- get_html_of_marked_pathway_by_objects(pathway_id, object_id_list)
--- get_html_of_colored_pathway_by_objects(pathway_id, object_id_list, fg_color_list, bg_color_list)
--- get_genes_by_pathway(pathway_id)
--- get_enzymes_by_pathway(pathway_id)
--- get_compounds_by_pathway(pathway_id)
--- get_glycans_by_pathway(pathway_id)
--- get_reactions_by_pathway(pathway_id)
--- get_kos_by_pathway(pathway_id)
--- get_pathways_by_genes(genes_id_list)
--- get_pathways_by_enzymes(enzyme_id_list)
--- get_pathways_by_compounds(compound_id_list)
--- get_pathways_by_glycans(glycan_id_list)
--- get_pathways_by_reactions(reaction_id_list)
--- get_pathways_by_kos(ko_id_list, org)
--- get_linked_pathways(pathway_id)
--- get_genes_by_enzyme(enzyme_id, org)
--- get_enzymes_by_gene(genes_id)
--- get_enzymes_by_compound(compound_id)
--- get_enzymes_by_glycan(glycan_id)
--- get_enzymes_by_reaction(reaction_id)
--- get_compounds_by_enzyme(enzyme_id)
--- get_compounds_by_reaction(reaction_id)
--- get_glycans_by_enzyme(enzyme_id)
--- get_glycans_by_reaction(reaction_id)
--- get_reactions_by_enzyme(enzyme_id)
--- get_reactions_by_compound(compound_id)
--- get_reactions_by_glycan(glycan_id)
--- get_genes_by_organism(org, start, max_results)
--- get_number_of_genes_by_organism(org)
--- convert_mol_to_kcf(mol_text)

=end
