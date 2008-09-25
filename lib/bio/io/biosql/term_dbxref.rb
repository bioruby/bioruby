
 module Bio
    class SQL 
			    class TermDbxref < DummyBase
			      set_primary_key nil #term_id, dbxref_id
#delete			      set_sequence_name nil
			      belongs_to :term, :class_name => "Term"
			      belongs_to :dbxref, :class_name => "Dbxref"
			    end		
		end #SQL
end #Bio
