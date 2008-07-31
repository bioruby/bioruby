
module Bio
  class SQL 
    class Seqfeature <DummyBase  
      set_sequence_name "seqfeature_pk_seq"
      belongs_to :bioentry
      belongs_to :type_term, :class_name => "Term", :foreign_key => "type_term_id"
      belongs_to :source_term, :class_name => "Term", :foreign_key =>"source_term_id"
      has_many :seqfeature_dbxrefs
      has_many :dbxrefs
      has_many :seqfeature_qualifier_values, :order=>'rank'
      has_many :locations, :order=>'rank'
      has_many :object_seqfeature_paths, :class_name => "SeqfeaturePath", :foreign_key => "object_seqfeature_id"
      has_many :subject_seqfeature_paths, :class_name => "SeqfeaturePath", :foreign_key => "subject_seqfeature_id"
      has_many :object_seqfeature_relationships, :class_name => "SeqfeatureRelationship", :foreign_key => "object_seqfeature_id"
      has_many :subject_seqfeature_relationships, :class_name => "SeqfeatureRelationship", :foreign_key => "subject_seqfeature_id"
    end		
  end #SQL
end #Bio
