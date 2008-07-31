
 module Bio
    class SQL 
			    class TermDbxref < DummyBase
			      set_primary_key nil #term_id, dbxref_id
#delete			      set_sequence_name nil
			      belongs_to :term
			      belongs_to :dbxref
			    end		
		end #SQL
end #Bio
