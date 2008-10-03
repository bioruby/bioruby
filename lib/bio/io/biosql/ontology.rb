
 module Bio
    class SQL 
		    class Ontology < DummyBase
		      has_many :terms, :class_name => "Term"
		      has_many :term_paths, :class_name => "TermPath"
		      has_many :term_relationships, :class_name => "TermRelationship"
		    end		
		end #SQL
end #Bio
