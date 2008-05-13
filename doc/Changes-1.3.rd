= Incompatible and important changes since the BioRuby 1.2.1 release

A lot of changes have been made to the BioRuby after the version 1.2.1
is released.

== Incompatible changes

--- Bio::Features

Bio::Features is obsoleted and changed to an array of Bio::Feature object
with some backward compatibility methods. The backward compatibility methods
will soon be removed in the future.

--- Bio::References

Bio::References is obsoleted and changed to an array of Bio::Reference object
with some backward compatibility methods. The backward compatibility methods
will soon be removed in the future.

--- Bio::BLAST::Default::Report, Bio::BLAST::Default::Report::Hit,
    Bio::BLAST::Default::Report::HSP, Bio::BLAST::WU::Report,
    Bio::BLAST::WU::Report::Hit, Bio::BLAST::WU::Report::HSP

* Iteration#lambda, #kappa, #entropy, #gapped_lambda, #gapped_kappa,
  and #gapped_entropy, and the same methods in the Report class are
  changed to return float or nil instead of string or nil.

