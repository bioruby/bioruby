#require 'dm-ar-finders'
#require 'dm-core'
require 'erb'
require 'composite_primary_keys'

module Bio
 class SQL
    class DummyBase < ActiveRecord::Base
      #NOTE: Using postgresql, not setting sequence name, system will discover the name by default.
      #NOTE: this class will not establish the connection automatically
      self.abstract_class = true
      self.pluralize_table_names = false
      #prepend table name to the usual id, avoid to specify primary id for every table
      self.primary_key_prefix_type = :table_name_with_underscore
      #biosql_configurations=YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__),'./config', 'database.yml'))).result)
      #self.configurations=biosql_configurations
      #self.establish_connection "development"
    end #DummyBase

    require 'bio/io/biosql/ar-biosql'
    
  #  #no check is made
  def self.establish_connection(configurations, env)
    #  #configurations is an hash similar what YAML returns.

     #configurations.assert_valid_keys('development', 'production','test')
     #configurations[env].assert_valid_keys('hostname','database','adapter','username','password')
     DummyBase.configurations = configurations
    connection = DummyBase.establish_connection "#{env}"
    #Init of basis terms and ontologies
    Ontology.first(:conditions => ["name = ?", 'Annotation Tags']) || Ontology.create({:name => 'Annotation Tags'})
    Ontology.first(:conditions => ["name = ?", 'SeqFeature Keys']) || Ontology.create({:name => 'SeqFeature Keys'})
    Ontology.first(:conditions => ["name = ?", 'SeqFeature Sources']) ||Ontology.create({:name => 'SeqFeature Sources'})
    Term.first(:conditions => ["name = ?", 'EMBLGenBankSwit']) || Term.create({:name => 'EMBLGenBankSwit', :ontology => Ontology.first(:conditions => ["name = ?", 'SeqFeature Sources'])})
    connection 
  end #establish_connection
  
  end #SQL
end #Bio
