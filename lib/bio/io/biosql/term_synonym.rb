
 module Bio
    class SQL 
			    class TermSynonym < DummyBase
#delete			      set_sequence_name nil
			      set_primary_key nil
			      belongs_to :term, :class_name => "Term"
			    end		
		end #SQL
end #Bio
