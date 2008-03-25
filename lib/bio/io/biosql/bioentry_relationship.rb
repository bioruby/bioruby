module Bio
    class SQL
			class BioentryRelationship < DummyBase
#delete				set_primary_key "bioentry_relationship_id"
				set_sequence_name "bieontry_relationship_pk_seq"
				belongs_to :object_bioentry, :class_name => "Bioentry"
				belongs_to :subject_bioentry, :class_name => "Bioentry"
			end
		end #SQL
end #Bio		    
