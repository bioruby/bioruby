#!/usr/bin/env ruby
#
# vs-genes.rb - homology/motif search wrapper
#
#  FASTA/BLAST/Pfam interface for the multiple query in the FASTA format
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  $Id: vs-genes.rb,v 0.1 2001/06/21 08:26:31 katayama Exp $
#

def usage(cpu, ktup, skip, resultdir, verbose)
  print <<-END

  Usage:

    % #{$0} -p PROG -q QUERY -t TARGET [-c #] [-k #] [-s #] [-d DIR] [-v on]

  options
    -p PROG   : (fasta3|ssearch3|tfasta3|fastx3|tfastx3)[3]
                  or
                (blastp|blastn|blastx|tblastn|tblastx)
                  or
                (hmmpfam|hmmpfam_n)
    -q QUERY  : query nucleotide or peptide sequences in the FASTA format
    -t TARGET : target DB (FASTA or BLAST2 formatdb or Pfam format)

  optional arguments
    -c num    : number of CPUs (for the SMP machines, default is #{cpu})
    -k num    : FASTA ktup value (2 for pep, 6 for nuc, default is #{ktup})
    -s num    : skip query (for the resume session, default is #{skip})
    -d DIR    : result output directory (default is "#{resultdir}")
    -v on/off : verbose output of processing if on (default is "#{verbose}")

  END

  exit 1
end


### initialize

def init
  arg = {}

  # default values
  arg['c'] = 1			# num of CPUs
  arg['k'] = 2			# ktup value for FASTA
  arg['s'] = 0			# skip query
  arg['d'] = "./result"		# result directory
  arg['v'] = 'off'		# verbose mode

  # parse options
  ARGV.join(' ').scan(/-(\w) (\S+)/).each do |key, val|
    arg[key] = val
  end

  # check program, query, target or print usage
  unless arg['p'] and arg['q'] and arg['t']
    usage(arg['c'], arg['k'], arg['s'], arg['d'], arg['v'])
  end

  # create result output directory
  unless test(?d, "#{arg['d']}")
    Dir.mkdir("#{arg['d']}", 0755)
  end

  # print status
  if arg['v'] != 'off'
    puts "PROG   : #{arg['p']}"
    puts "  ktup : #{arg['k']}" if arg['p'] =~ /fast/
    puts "QUERY  : #{arg['q']}"
    puts "  skip : #{arg['s']}"
    puts "TARGET : #{arg['t']}"
    puts "RESULT : #{arg['d']}"
  end

  return arg
end


### generate command line

def cmd_line(arg, orf)
  # program with default command line options	# query -> target DB
  opt = {
    # FASTA : "-b n" for best n scores, "-d n" for best n alignment
    'fasta3'	=> "fasta3    -Q -H -m 6",	# pep -> pep or nuc -> nuc
    'ssearch3'	=> "ssearch3  -Q -H -m 6",	# pep -> pep or nuc -> nuc
    'tfasta3'	=> "tfasta3   -Q -H -m 6",	# pep -> nuc 
    'fastx3'	=> "fastx3    -Q -H -m 6",	# nuc -> pep 
    'tfastx3'	=> "tfastx3   -Q -H -m 6",	# pep -> nuc (with frameshifts)
					
    'fasta33'	=> "fasta33   -Q -H -m 6",	# pep -> pep or nuc -> nuc
    'ssearch33'	=> "ssearch33 -Q -H -m 6",	# pep -> pep or nuc -> nuc
    'tfasta33'	=> "tfasta33  -Q -H -m 6",	# pep -> nuc 
    'fastx33'	=> "fastx33   -Q -H -m 6",	# nuc -> pep 
    'tfastx33'	=> "tfastx33  -Q -H -m 6",	# pep -> nuc (with frameshifts)

    # BLAST : outputs XML
    'blastp'	=> "blastall -m 7 -p blastp  -d",	# pep -> pep 
    'blastn'	=> "blastall -m 7 -p blastn  -d",	# nuc -> nuc 
    'blastx'	=> "blastall -m 7 -p blastx  -d",	# nuc -> pep 
    'tblastn'	=> "blastall -m 7 -p tblastn -d",	# pep -> nuc 
    'tblastx'	=> "blastall -m 7 -p tblastx -d",	# nuc -> nuc (by trans)

    # Pfam : "-A n" for best n alignment, "-E n" for E value cutoff etc.
    'hmmpfam'	=> "hmmpfam",			# pep -> Pfam DB
    'hmmpfam_n'	=> "hmmpfam -n",		# nuc -> Pfam DB
  }

  # arguments used in the command line
  cpu    = arg['c'].to_i
  ktup   = arg['k']
  target = arg['t']
  query  = arg['d'] + "/query." + orf
  result = arg['d'] + "/" + orf

  prog   = opt[arg['p']]

  if cpu > 1					# use multiple CPUs
    case arg['p']
    when /(fast|ssearch)/
      prog += " -T #{cpu}"
      prog.sub!(' ', '_t ')			# rename program with "_t"
    when /pfam/
      prog += " --cpu #{cpu}"
    end
  end

  # generate complete command line to execute
  case arg['p']
  when /fast/
    command  = "#{prog} #{query} #{target} #{ktup} > #{result}"
  when /ssearch/
    command  = "#{prog} #{query} #{target} > #{result}"
  when /blast/
    command  = "#{prog} #{target} -i #{query} > #{result}"
  when /pfam/
    command  = "#{prog} #{target} #{query} > #{result}"
  end

  return command
end


### main

begin
  arg = init
  count = 0

  open(arg['q'], "r") do |f|
    while seq = f.gets("\n>")
      count += 1

      # skip (-s option)
      next unless count > arg['s'].to_i

      # clean up
      seq.sub!(/^>?[ \t]*/, '')	# delete '>' and SPACEs or TABs at the head
      seq.sub!(/>$/, '')	# delete '>' at the tail (separator)

      # get ORF name
      if seq[/^$/]		# no definition (e.g. ">\nSEQ>" or ">\n>")
	next			#  -> useless for the multiple query
      else
	orf = seq[/^\S+/]	# the first word in the definition line
      end

      # KEGG uses ">DB:ENTRY" format in the definition line
      if orf =~ /:/
	db,orf = orf.split(/:/)
      end

      # add time if the same ORF name was already used
      if test(?f, "#{arg['d']}/#{orf}")
	orf = "#{orf}.#{Time.now.to_f.to_s}"
      end

      # create temporal file of the query
      open("#{arg['d']}/query.#{orf}", "w+") do |tmp|
	tmp.print(">#{seq}")
      end

      command = cmd_line(arg, orf)

      # print status
      if arg['v'] != 'off'
	puts "#{count} : #{orf} ..."
	puts "  #{command}"
      end

      # execute
      system("#{command}")

      # remove temporal file
      File.delete("#{arg['d']}/query.#{orf}")
    end
  end
end

