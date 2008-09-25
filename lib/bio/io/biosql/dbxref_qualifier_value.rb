 module Bio
    class SQL
			class DbxrefQualifierValue < DummyBase
				#think to use composite primary key
			      set_primary_key nil #dbxref_id, term_id, rank
#delete			      set_sequence_name nil
			      belongs_to :dbxref, :class_name => "Dbxref"
			      belongs_to :term, :class_name => "Term"
			    end		
		end #SQL
end #Bio		

