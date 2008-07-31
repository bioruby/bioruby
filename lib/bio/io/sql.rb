
require 'rubygems'
require 'erb'
require 'composite_primary_keys'
# BiosqlPlug

=begin
Ok Hilmar gives to me some clarification
1) "EMBL/GenBank/SwissProt" name in term table, is only a convention assuming data loaded by genbank embl ans swissprot formats.
   If your features come from others ways for example blast or alignment ... whatever.. the user as to take care about the source. 


=end
=begin
TODO:
1) source_term_id => surce_term and check before if the source term is present or not and the level, the root should always be something "EMBL/GenBank/SwissProt" or contestualized.
2) Into DummyBase class delete connection there and use Bio::ArSQL.establish_connection which reads info from a yml file. 
3) Chk Locations in Biofeatures ArSQL
=end
module Bio
  class SQL	
    #no check is made
    def self.establish_connection(configurations, env)
      #configurations is an hash similar what YAML returns.
      #{:database=>"biorails_development", :adapter=>"postgresql", :username=>"rails", :password=>nil}
      configurations.assert_valid_keys('development', 'production','test')
      configurations[env].assert_valid_keys('hostname','database','adapter','username','password')
      DummyBase.configurations = configurations
      DummyBase.establish_connection "#{env}"
    end
    
    def self.fetch_id(id)
      Bio::SQL::Bioentry.find(id)
    end
    
    def self.fetch_accession(accession)
      accession = accession.upcase
      Bio::SQL::Bioentry.exists?(:accession => accession) ? Bio::SQL::Sequence.new(:entry=>Bio::SQL::Bioentry.find_by_accession(accession)) : nil			
    end
    
    def self.exists_accession(accession)
      Bio::SQL::Bioentry.find_by_accession(accession.upcase).nil? ? false : true
    end
    
    def self.exists_database(name)
      Bio::SQL::Biodatabase.find_by_name(name).nil? ? false : true
    end
    
    def self.list_entries
      Bio::SQL::Bioentry.find(:all).collect{|entry|
        {:id=>entry.bioentry_id, :accession=>entry.accession}
      }
    end
    
    def self.list_databases
      Bio::SQL::Biodatabase.find(:all).collect{|entry|
        {:id=>entry.biodatabase_id, :name => entry.name}
      }
    end
    
    def self.delete_entry_id(id)
      Bioentry.delete(id)
    end
    
    def self.delete_entry_accession(accession)
      Bioentry.delete(Bioentry.find_by_accession(accession))
    end
    
    
    class DummyBase <  ActiveRecord::Base
      #NOTE: Using postgresql, not setting sequence name, system will discover the name by default.
      #NOTE: this class will not establish the connection automatically
      self.abstract_class = true			
      self.pluralize_table_names = false
      #prepend table name to the usual id, avoid to specify primary id for every table
      self.primary_key_prefix_type = :table_name_with_underscore
      #biosql_configurations=YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__),'../config', 'database.yml'))).result)
      #self.configurations=biosql_configurations
      #self.establish_connection "development"
    end #DummyBase
    
    autoload :Biodatabase, 'bio/io/biosql/biodatabase'
    autoload :Bioentry, 'bio/io/biosql/bioentry'
    autoload :BioentryDbxref, 'bio/io/biosql/bioentry_dbxref'
    autoload :BioentryPath, 'bio/io/biosql/bioentry_path'
    autoload :BioentryQualifierValue, 'bio/io/biosql/bioentry_qualifier_value'
    autoload :BioentryReference, 'bio/io/biosql/bioentry_reference'
    autoload :BioentryRelationship, 'bio/io/biosql/bioentry_relationship'
    autoload :Biosequence, 'bio/io/biosql/biosequence'
    autoload :Comment, 'bio/io/biosql/comment'
    autoload :Dbxref, 'bio/io/biosql/dbxref'
    autoload :DbxrefQualifierValue, 'bio/io/biosql/dbxref_qualifier_value'
    autoload :Location, 'bio/io/biosql/location'
    autoload :LocationQualifierValue, 'bio/io/biosql/location_qualifier_value'
    autoload :Ontology, 'bio/io/biosql/ontology'
    autoload :Reference, 'bio/io/biosql/reference'
    autoload :Seqfeature, 'bio/io/biosql/seqfeature'
    autoload :SeqfeatureDbxref, 'bio/io/biosql/seqfeature_dbxref'
    autoload :SeqfeaturePath, 'bio/io/biosql/seqfeature_path'
    autoload :SeqfeatureQualifierValue, 'bio/io/biosql/seqfeature_qualifier_value'
    autoload :SeqfeatureRelationship, 'bio/io/biosql/seqfeature_relationship'
    autoload :Taxon, 'bio/io/biosql/taxon'
    autoload :TaxonName, 'bio/io/biosql/taxon_name'
    autoload :Term, 'bio/io/biosql/term'
    autoload :TermDbxref, 'bio/io/biosql/term_dbxref'
    autoload :TermPath, 'bio/io/biosql/term_path'
    autoload :TermRelationship, 'bio/io/biosql/term_relationship'
    autoload :TermRelationshipTerm, 'bio/io/biosql/term_relationship_term'
    autoload :Sequence, 'bio/db/biosql/sequence'
  end #biosql
  
end #Bio

if __FILE__ == $0
  require 'rubygems'
  require 'composite_primary_keys'
  require 'bio'
  require 'pp'
  
  #  pp connection = Bio::SQL.establish_connection('bio/io/biosql/config/database.yml','development')
  pp connection = Bio::SQL.establish_connection({'development'=>{'database'=>"biorails_development", 'adapter'=>"postgresql", 'username'=>"rails", 'password'=>nil}},'development')
  #pp YAML::load(ERB.new(IO.read('bio/io/biosql/config/database.yml')).result)
  pp Bio::SQL.list_entries
  if nil
    pp Bio::SQL.list_entries
    bioseq = Bio::SQL.fetch_accession('AJ224122')   
    pp bioseq
    pp bioseq.entry_id    
    #TODO create a test only for tables not sequence here
    pp bioseq.molecule_type
    #pp  bioseq.molecule_type.class
    #bioseq.molecule_type_update('dna', 1)
    pp Bio::SQL::Taxon.find(8121).taxon_names
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
