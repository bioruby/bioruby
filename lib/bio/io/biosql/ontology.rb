
 module Bio
    class SQL 
		    class Ontology < DummyBase
#delete		    	set_primary_key "ontology_id"
		      set_sequence_name "ontology_pk_seq"
		      has_many :terms, :class_name => "Term"
		      has_many :term_paths, :class_name => "TermPath"
		      has_many :term_relationships, :class_name => "TermRelationship"
		    end		
		end #SQL
end #Bio
