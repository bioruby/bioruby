module Bio
		class SQL
			class Biodatabase < DummyBase
				has_many :bioentries, :class_name =>"Bioentry", :foreign_key => "biodatabase_id"
				validates_uniqueness_of :name
			end
		end #SQL
end #Bio	


if __FILE__ == $0
  require 'rubygems'
  require 'composite_primary_keys'
  require 'bio'
  require 'pp'
  
  #  pp connection = Bio::SQL.establish_connection('bio/io/biosql/config/database.yml','development')
  pp connection = Bio::SQL.establish_connection({'test'=>{'database'=>"bio_test", 'adapter'=>"postgresql", 'username'=>"rails", 'password'=>nil}},'test')
  #pp YAML::load(ERB.new(IO.read('bio/io/biosql/config/database.yml')).result)
  if true
    pp Bio::SQL.list_entries

    puts "### GenBank"
    if ARGV.size > 0
	gb = Bio::GenBank.new(ARGF.read)
    else
	require 'bio/io/fetch'
	gb = Bio::GenBank.new(Bio::Fetch.query('gb', 'AJ224122'))
    end

   	biosequence = gb.to_biosequence
	db=Bio::SQL::Biodatabase.new(:biodatabase_id=>3,:name=>"JEFF", :authority=>"ME", :description=>"YOU")
	db.save!
	
	#sqlseq = Bio::SQL::Sequence.new(:biosequence=>biosequence,:biodatabase_id=>db.id)

	#    bioseq = Bio::SQL.fetch_accession('AJ224122')   
	#    pp bioseq
	#    pp bioseq.entry_id    
    #TODO create a test only for tables not sequence here
#    pp bioseq.molecule_type
    #pp  bioseq.molecule_type.class
    #bioseq.molecule_type_update('dna', 1)
    pp Bio::SQL::Taxon.find(8121).taxon_names
    
	    #sqlseq.to_biosequence
	
	#sqlseq.delete
  end
  #pp  bioseq.molecule_type
  #term = Bio::SQL::Term.find_by_name('mol_type')
  #pp term
  #pp bioseq.entry.bioentry_qualifier_values.create(:term=>term, :rank=>2, :value=>'pippo')
  #pp bioseq.entry.bioentry_qualifier_values.inspect
  #pp bioseq.entry.bioentry_qualifier_values.find_all_by_term_id(26)
  #pp primo.class
  #  pp primo.value='dna'
  #  pp primo.save
  #pp bioseq.molecule_type= 'prova'
  
  #Bio::SQL::BioentryQualifierValue.delete(delete.bioentry_id,delete.term_id,delete.rank)
  
  
end
