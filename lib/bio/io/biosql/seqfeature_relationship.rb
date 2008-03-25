
 module Bio
    class SQL 
			    class SeqfeatureRelationship <DummyBase
			      set_sequence_name "seqfeatue_relationship_pk_seq"
			      belongs_to :term
			      belongs_to :object_seqfeature, :class_name => "Seqfeature"
			      belongs_to :subject_seqfeature, :class_name => "Seqfeature"
			    end		
		end #SQL
end #Bio
