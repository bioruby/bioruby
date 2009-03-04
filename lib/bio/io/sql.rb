#module Bio
 # class SQL
  #  #no check is made
   # def self.establish_connection(configurations, env)
    #  #configurations is an hash similar what YAML returns.
     # #{:database=>"biorails_development", :adapter=>"postgresql", :username=>"rails", :password=>nil}
     # configurations.assert_valid_keys('development', 'production','test')
     # configurations[env].assert_valid_keys('hostname','database','adapter','username','password')
     # DummyBase.configurations = configurations
     # DummyBase.establish_connection "#{env}"
    #end


#require 'rubygems'
#require 'composite_primary_keys'
#require 'erb'
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

    require 'bio/io/biosql/biosql'
    autoload :Sequence, 'bio/db/biosql/sequence'

    def self.fetch_id(id)
      Bio::SQL::Bioentry.find(id)
    end

    def self.fetch_accession(accession)
#     Bio::SQL::Bioentry.exists?(:accession => accession) ? Bio::SQL::Sequence.new(:entry=>Bio::SQL::Bioentry.find_by_accession(accession)) : nil
      Bio::SQL::Sequence.new(:entry=>Bio::SQL::Bioentry.find_by_accession(accession.upcase))
    end

    def self.exists_accession(accession)
#      Bio::SQL::Bioentry.find_by_accession(accession.upcase).nil? ? false : true
      !Bio::SQL::Bioentry.find_by_accession(accession.upcase).nil?
    end

    def self.exists_database(name)
#      Bio::SQL::Biodatabase.find_by_name(name).nil? ? false : true
      !Bio::SQL::Biodatabase.first(:name=>name).nil?
    end

    def self.list_entries
      Bio::SQL::Bioentry.all.collect do|entry|
        {:id=>entry.bioentry_id, :accession=>entry.accession}
      end
    end

    def self.list_databases
      Bio::SQL::Biodatabase.all.collect do|entry|
        {:id=>entry.biodatabase_id, :name => entry.name}
      end
    end

    def self.delete_entry_id(id)
      Bio::SQL::Bioentry.delete(id)
    end

    def self.delete_entry_accession(accession)
      Bio::SQL::Bioentry.find_by_accession(accession.upcase).destroy!
    end

  end #biosql

end #Bio
