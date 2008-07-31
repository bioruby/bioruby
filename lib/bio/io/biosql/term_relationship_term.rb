
 module Bio
    class SQL 
			    class TermRelationshipTerm < DummyBase
#delete			      set_sequence_name nil
			      set_primary_key :term_relationship_id
			      belongs_to :term_relationship
			      belongs_to :term
			    end		
		end #SQL
end #Bio
