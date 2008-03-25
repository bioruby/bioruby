 module Bio
    class SQL
			class Comment < DummyBase
#delete				set_primary_key "comment_id"
			      set_sequence_name "comment_pk_seq"
			      belongs_to :bioentry
			end
		end #SQL
end #Bio		   
