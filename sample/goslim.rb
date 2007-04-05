#!/usr/bin/env ruby
#
# goslim.rb - making a GO slim histgram
#
#  Usage:
#
#    % goslim.rb -p process.ontology -f function.ontology \
#       -c component.ontology -s goslim_goa.2002 -g gene_association.mgi \
#       -o mgi -r
#    % R < mgi.R
#    % gv mgi.pdf
#
# Copyright::  Copyright (C) 2003
#              Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: goslim.rb,v 1.5 2007/04/05 23:35:42 trevor Exp $
#



SCRIPT_VERSION = '$Id: goslim.rb,v 1.5 2007/04/05 23:35:42 trevor Exp $'

USAGE = "${__FILE__} - GO slim
Usage:
  #{__FILE__} -p process.ontology -f function.ontology \
     -c component.ontolgy -g gene_association.mgi -s goslim_goa.2002 \
     -o goslim.uniqued.out -r

  #{__FILE__} -p process.ontology -f function.ontology \
     -c component.ontolgy -l gene_association.list -s goslim_goa.2002 \
     -o mgi.out -r

  #{__FILE__} -p process.ontology -f function.ontology \
     -c component.ontolgy -g gene_association.mgi -s goslim_goa.2002 >\
     go_goslit.paired.list



Options;
 -p,--process <go/ontology/process.ontology>
 -f,--function <go/ontology/function.ontolgoy>
 -c,--component <go/ontology/component.ontology>
 -g,--ga <go/gene-associations/gene_association.someone>
 -l,--galist <a GO_ID list>
 -s,--goslim <go/GO_slim/goslim_someone>
 -o,--output <file_name> -- output file name.
 -r,--r_script -- Writing a R script in <file_name>.R to plot a barplot.
 -h,--help
 -v,--version

Format:
  GO ID list: /^GO:\d{7}/ for each line

Mitsuteru C. Nakao <n@bioruby.org>
"



require 'getoptlong'
parser = GetoptLong.new
parser.set_options(
		   ['--process',   '-p', GetoptLong::REQUIRED_ARGUMENT],
		   ['--function',  '-f', GetoptLong::REQUIRED_ARGUMENT],
		   ['--component', '-c', GetoptLong::REQUIRED_ARGUMENT],
		   ['--ga',        '-g', GetoptLong::REQUIRED_ARGUMENT],
		   ['--galist',    '-l', GetoptLong::REQUIRED_ARGUMENT],
		   ['--goslim',    '-s', GetoptLong::REQUIRED_ARGUMENT],
		   ['--output',    '-o', GetoptLong::REQUIRED_ARGUMENT],
		   ['--r_script',  '-r', GetoptLong::NO_ARGUMENT],
		   ['--help',      '-h', GetoptLong::NO_ARGUMENT],
		   ['--version',   '-v', GetoptLong::NO_ARGUMENT])

begin
  parser.each_option do |name, arg|
    eval "$OPT_#{name.sub(/^--/, '').gsub(/-/, '_').upcase} = '#{arg}'"
  end
rescue
  exit(1)
end

if $OPT_VERSION
  puts SCRIPT_VERSION
  exit(0)
end

if $OPT_HELP or !($OPT_PROCESS or $OPT_FUNCTION or $OPT_COMPONENT or 
		  ($OPT_GA or $OPT_GALIST))
  puts USAGE
  exit(0)
end




# subroutines

def slim2r(datname)
  tmp = "# usage: % R --vanilla < #{datname}.R
data <- read.delim2('#{datname}')
dat <- data$count
names(dat) <- paste(data$GO.Term, dat)
# set graphc format
pdf('#{datname}.pdf') 
#postscript('#{datname}.ps') 
# outside margins
par(mai = c(1,2.8,1,0.7))
barplot(dat, 
        cex.names = 0.6,  # row names font size
        las = 2,          # set horizontal row names
        horiz = T,        # set horizontal 
        main = 'GO slim', # main title
        # set color schema, proc, blue(3); func, red(2); comp, green(4)
        col = cbind(c(data$aspect == 'process'), 
		    c(data$aspect == 'function'), 
                    c(data$aspect == 'component')) %*% c(4,2,3)) # color
dev.off()
"
end


# build GOslim uniqued list
def slim(ontology, slim_ids, tmp, ga, aspect)
  tmp[aspect] = Hash.new(0)
  slim_ids.each {|slim_id|
    term = ontology.goid2term(slim_id)
    if term
      tmp[aspect][term] = 0
    else
      next
    end

    ga.each {|gaid|
      begin 
	res = ontology.bfs_shortest_path(slim_id, gaid)
	tmp[aspect][term] += 1 if res[0]
      rescue NameError 
	$stderr.puts "Warnning: GO:#{slim_id} (#{term}) doesn't exist in the #{aspect}.ontology."
	tmp[aspect].delete(term)
	break
      end
    }
  }
end


# build GO-GOslim uniqued list
def slim2(ontology, slim_ids, tmp, ga, aspect)
  tmp[aspect] = Hash.new
  slim_ids.each {|slim_id|
    term = ontology.goid2term(slim_id)
    if term
      begin
	unless tmp[aspect][term]['GOslim'].index(slim_id)
	  tmp[aspect][term]['GOslim'] << slim_id
	end
      rescue NameError
	tmp[aspect][term] = {'GOslim'=>[slim_id], 'GO'=>[]}
      end
    else
      next
    end

    ga.each {|gaid|
      begin 
	res = ontology.bfs_shortest_path(slim_id, gaid)
	tmp[aspect][term]['GO'] << gaid if res[0]
      rescue NameError

	break
      end
    }
  }
end



#
# main
#

require 'bio/db/go'

aspects = ['process', 'function', 'component']
rootids = {
  'process'   => '0008150', 
  'function'  => '0003674', 
  'component' => '0005575'}

# files open

ios = {}
files = {
  'process'   => $OPT_PROCESS, 
  'function'  => $OPT_FUNCTION, 
  'component' => $OPT_COMPONENT,  
  'ga'   => $OPT_GA,            # gene-association
  'list' => $OPT_GALIST,        # gene-association list
  'slim' => $OPT_GOSLIM}        # GO slim

files.each {|k, file_name|
  next if file_name == nil
  ios[k] = File.open(file_name)
}

if $OPT_OUTPUT
  ios['output']   = File.new($OPT_OUTPUT, "w+")
  ios['r_script'] = File.new("#{$OPT_OUTPUT}.R", "w+")
else
  ios['r_script'] = ios['output'] = $stdout
end


# start

# ontology
ontology = {}
aspects.each {|aspect|
  ontology[aspect] = Bio::GO::Ontology.new(ios[aspect].read)
}


# GO slim
goslim = Bio::GO::Ontology.new(ios['slim'].read)

# assign a aspect to terms in the GO slim.
slim_ids = Hash.new([])
goslim.to_list.map {|ent| ent.node }.flatten.uniq.each {|goid|
  rootids.each {|aspect, rootid|
    begin
      a,b = ontology[aspect].bfs_shortest_path(rootid, goid)
      slim_ids[aspect] << goid
    rescue NameError
      $stderr.puts "Error: (#{rootid}, #{goid})"
    end
  }
}




# gene-associations

ga_ids = []
if $OPT_GA
  ga = Bio::GO::GeneAssociation.parser(ios['ga'].read)
  ga_ids = ga.map {|ent| ent.goid }

elsif $OPT_GALIST
  while line = ios['list'].gets
    if /^GO:(\d{7})/ =~ line
      goid = $1
      ga_ids << goid
    end
  end
else
  puts "Error: -l or -g options"
  exit
end


# count number

count = Hash.new(0)

aspects.each {|aspect|
  slim2(ontology[aspect], slim_ids[aspect], count, ga_ids, aspect)
}




# output

if $OPT_R_SCRIPT and $OPT_OUTPUT
  tmp = [['aspect', 'count', 'GO Term'].join("\t")]
else
  tmp = [['aspect', 'GO ID', 'GOslim Term', 'GOslim ID'].join("\t")]
end

['component','function','process'].each {|aspect|
  count[aspect].sort {|a, b| b[1]['GO'].size <=> a[1]['GO'].size }.each {|term, value|
    next if term == ""

    if $OPT_R_SCRIPT and $OPT_OUTPUT
      tmp << [aspect, value['GO'].size, term].join("\t") 
    else
      value['GO'].each {|goid|
	tmp << [aspect, "GO:#{goid}", term, 
	  value['GOslim'].map {|e| "GO:#{e}" }.join(' ')].join("\t") 
      }
    end
  }
}
ios['output'].puts tmp.join("\n")


if $OPT_R_SCRIPT and $OPT_OUTPUT
  ios['r_script'].puts slim2r($OPT_OUTPUT)
end


#
