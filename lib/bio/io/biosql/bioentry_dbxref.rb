module Bio
		class SQL
			class BioentryDbxref < DummyBase
#delete				set_sequence_name nil
				set_primary_key nil #bioentry_id,dbxref_id
				belongs_to :bioentry, :class_name => "Bioentry"
				belongs_to :dbxref, :class_name => "Dbxref"
			end
    		end #SQL
end #Bio	

