
module Bio
  class SQL 
    class Seqfeature <DummyBase  
      set_sequence_name "seqfeature_pk_seq"
      belongs_to :bioentry
      #, :class_name => "Bioentry"
      belongs_to :type_term, :class_name => "Term", :foreign_key => "type_term_id"
      belongs_to :source_term, :class_name => "Term", :foreign_key =>"source_term_id"
      has_many :seqfeature_dbxrefs, :class_name => "SeqfeatureDbxref", :foreign_key => "seqfeature_id"
      has_many :seqfeature_qualifier_values, :order=>'rank', :foreign_key => "seqfeature_id"
      #, :class_name => "SeqfeatureQualifierValue"
      has_many :locations, :class_name => "Location", :order=>'rank'
      has_many :object_seqfeature_paths, :class_name => "SeqfeaturePath", :foreign_key => "object_seqfeature_id"
      has_many :subject_seqfeature_paths, :class_name => "SeqfeaturePath", :foreign_key => "subject_seqfeature_id"
      has_many :object_seqfeature_relationships, :class_name => "SeqfeatureRelationship", :foreign_key => "object_seqfeature_id"
      has_many :subject_seqfeature_relationships, :class_name => "SeqfeatureRelationship", :foreign_key => "subject_seqfeature_id"

      #get the subsequence described by the locations objects
      def sequence
        return self.locations.inject(Bio::Sequence::NA.new("")){|seq, location| seq<<location.sequence}
    end
    
      #translate the subsequences represented by the feature and its locations
      #not considering the qualifiers 
      #Return a Bio::Sequence::AA object
      def translate(*args)
        self.sequence.translate(*args)
      end
      end		
    end #SQL
  end #Bio
