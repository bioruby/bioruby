
 module Bio
    class SQL 
		    class Ontology < DummyBase
#delete		    	set_primary_key "ontology_id"
		      set_sequence_name "ontology_pk_seq"
		      has_many :terms
		      has_many :term_paths
		      has_many :term_relationships
		    end		
		end #SQL
end #Bio
