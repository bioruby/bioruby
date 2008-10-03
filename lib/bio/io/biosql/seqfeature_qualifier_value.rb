
module Bio
  class SQL 
    class SeqfeatureQualifierValue < DummyBase
      set_primary_keys  :seqfeature_id, :term_id, :rank
      set_sequence_name nil
      belongs_to :seqfeature
      belongs_to :term, :class_name => "Term"
      
      def self.find_cluster(query)
        term_note= Term.find_by_name('note')
        find(:all, :conditions =>["value like ? and term_id = ?", "cl:#{query}", term_note])
      end
      def self.find_cluster_info(query)
        term_note= Term.find_by_name('note')
        find(:all, :conditions =>["value like ? and term_id = ?", "cli:#{query}", term_note])
      end
    end		
  end #SQL
end #Bio
