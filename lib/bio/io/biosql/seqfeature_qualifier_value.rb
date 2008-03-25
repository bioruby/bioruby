
module Bio
  class SQL 
    class SeqfeatureQualifierValue < DummyBase
      set_primary_keys :seqfeature_id, :term_id, :rank
      set_sequence_name nil
      belongs_to :seqfeature
      belongs_to :term
    end		
  end #SQL
end #Bio
