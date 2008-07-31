 module Bio
    class SQL
			class DbxrefQualifierValue < DummyBase
				#think to use composite primary key
			      set_primary_key nil #dbxref_id, term_id, rank
#delete			      set_sequence_name nil
			      belongs_to :dbxref
			      belongs_to :term
			    end		
		end #SQL
end #Bio		

