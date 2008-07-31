
 module Bio
    class SQL 
			    class TermPath < DummyBase
			      set_sequence_name "term_path_pk_seq"
			      belongs_to :ontology
			      belongs_to :subject_term, :class_name => "Term"
			      belongs_to :object_term, :class_name => "Term"
			      belongs_to :predicate_term, :class_name => "Term"
			    end		
		end #SQL
end #Bio
