module Bio
  class SQL
    class BioentryQualifierValue < DummyBase
      #NOTE: added rank to primary_keys, now it's finished.
      set_primary_keys :bioentry_id, :term_id, :rank
      belongs_to :bioentry, :class_name => "Bioentry"
      belongs_to :term, :class_name => "Term"
    end #BioentryQualifierValue
  end #SQL
end #Bio
