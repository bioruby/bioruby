module Bio
    class SQL
			class BioentryReference < DummyBase
				set_primary_key :bioentry_reference_id
				belongs_to :bioentry
				belongs_to :reference 
			end		
		end #SQL
end #Bio		

