module Bio
  class SQL 
    class Location < DummyBase
      #set_sequence_name "location_pk_seq"
      belongs_to :seqfeature
      belongs_to :dbxref
      belongs_to :term
      has_many :location_qualifier_values
      
      def to_s
        if strand==-1
          str="complement("+start_pos.to_s+".."+end_pos.to_s+")"
        else
          str=start_pos.to_s+".."+end_pos.to_s
        end
        return str    
      end 
      
    end
  end #SQL
end #Bio
