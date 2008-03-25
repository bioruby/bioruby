 module Bio
    class SQL 
			class LocationQualifierValue <  DummyBase
			      set_primary_key nil #location_id, term_id
#delete			      set_sequence_name nil
			      belongs_to :location
			      belongs_to :term
			    end		
		end #SQL
end #Bio

