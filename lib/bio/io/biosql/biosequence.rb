module Bio
    class SQL
			class Biosequence < DummyBase
				set_primary_key "bioentry_id"
#delete				set_sequence_name "biosequence_pk_seq"
				belongs_to :bioentry
			end
		end #SQL
end #Bio		   
