module Bio
		class SQL
			class BioentryDbxref < DummyBase
#delete				set_sequence_name nil
				set_primary_key nil #bioentry_id,dbxref_id
				belongs_to :bioentry
				belongs_to :dbxref
			end
    		end #SQL
end #Bio	

