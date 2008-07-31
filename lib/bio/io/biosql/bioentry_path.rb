module Bio
    class SQL
			class BioentryPath < DummyBase
				set_primary_key nil
#delete				set_sequence_name nil
				belongs_to :term
				#da sistemare per poter procedere.
				belongs_to :object_bioentry, :class_name=>"Bioentry"
				belongs_to :subject_bioentry, :class_name=>"Bioentry"
			end #BioentryPath
		end #SQL
end #Bio
