module Bio
    class SQL
			class BioentryReference < DummyBase
				set_primary_keys :bioentry_id, :reference_id, :rank
				belongs_to :bioentry, :class_name => "Bioentry"
				belongs_to :reference , :class_name => "Reference"
			end		
		end #SQL
end #Bio		

