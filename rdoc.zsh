#!/usr/bin/env zsh

#DIAGRAM='--diagram'
WEBCVS='http://cvs.open-bio.org/cgi-bin/viewcvs/viewcvs.cgi'

rdoc ${DIAGRAM} --op rdoc --inline-source \
  --webcvs "${WEBCVS}/bioruby/\%s?cvsroot=bioruby" \
  bin/*(.) lib/**/*.rb [A-Z]*(.) doc/*rd etc/bioinformatics/*(.)
