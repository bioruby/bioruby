module Bio
  class SQL 
    class Location < DummyBase
      #set_sequence_name "location_pk_seq"
      belongs_to :seqfeature, :class_name => "Seqfeature"
      belongs_to :dbxref, :class_name => "Dbxref"
      belongs_to :term, :class_name => "Term"
      has_many :location_qualifier_values, :class_name => "LocationQualifierValue"
      
      def to_s
        if strand==-1
          str="complement("+start_pos.to_s+".."+end_pos.to_s+")"
        else
          str=start_pos.to_s+".."+end_pos.to_s
        end
        return str    
      end
      
      def sequence
        seq=""
        unless self.seqfeature.bioentry.biosequence.seq.nil?
          seq=Bio::Sequence::NA.new(self.seqfeature.bioentry.biosequence.seq[start_pos-1..end_pos-1])
          seq.reverse_complement! if strand==-1
        end
        return seq        
      end
      
      
      
    end
  end #SQL
end #Bio
