#
# = bio/appl/paml/common.rb - Basic wrapper class common to PAML programs
#
# Copyright::  Copyright (C) 2008
#              Michael D. Barton <mail@michaelbarton.me.uk>,
#              Naohisa Goto <ng@bioruby.org>
#
# License::    The Ruby License
#
# == Description
#
# This file contains Bio::PAML::Common, a basic wrapper class for
# running PAML programs.
#
# == References
#
# * http://abacus.gene.ucl.ac.uk/software/paml.html
#

require 'tempfile'
require 'bio/command'
require 'bio/alignment'

module Bio
module PAML

  autoload :Codeml, 'bio/appl/paml/codeml'
  autoload :Baseml, 'bio/appl/paml/baseml'
  autoload :Yn00,   'bio/appl/paml/yn00'
  #--
  # The autoload of Common::Report, Codeml::Report, Codeml::Rates,
  # Baseml::Report, Yn00::Report are described inside the classes.
  #++

  # == Description
  #
  # Bio::PAML::Common is a basic wrapper class for PAML programs. 
  # The class provides methods for generating the necessary configuration 
  # file, and running a program.
  #
  class Common

    autoload :Report, 'bio/appl/paml/common_report'

    # Default parameters. Should be redefined in subclass.
    DEFAULT_PARAMETERS = {}

    # Default program. Should be redifined in subclass.
    DEFAULT_PROGRAM = nil

    # Parameters described in the control file. (Hash)
    # Each key of the hash must be a Symbol object, and each value
    # must be a String object or nil.
    attr_accessor :parameters

    # Preferred order of parameters.
    DEFAULT_PARAMETERS_ORDER = %w( seqfile outfile treefile
      noisy verbose runmode seqtype CodonFreq ndata clock
      aaDist aaRatefile model NSsites icode Mgene
      fix_kappa kappa fix_omega omega fix_alpha alpha Malpha ncatG
      fix_rho rho nparK nhomo getSE RateAncestor
      Small_Diff cleandata fix_blength method ).collect { |x| x.to_sym }

    # Creates a wrapper instance, which will run using the specified
    # binary location or the command in the PATH.
    # If program is specified as nil, DEFAULT_PROGRAM is used.
    # Default parameters are automatically loaded and merged with
    # the specified parameters.
    # ---
    # *Arguments*:
    # * (optional) _program_: path to the program, or command name (String)
    # * (optional) _params_: parameters (Hash)
    def initialize(program = nil, params = {})
      @program = program || self.class::DEFAULT_PROGRAM
      set_default_parameters
      self.parameters.update(params)
    end

    # Runs the program on the parameters in the passed control file.
    # No parameters checks are performed.
    # All internal parameters are ignored and are kept untouched.
    # The output and report attributes are cleared in this method.
    #
    # Warning about PAML's behavior:
    # PAML writes supplemental output files in the current directory
    # with fixed file names which can not be changed with parameters
    # or command-line options, for example, rates, rst, and rub.
    # This behavior may ovarwrite existing files, especially
    # previous supplemental results.
    #
    # ---
    # *Arguments*:
    # * (optional) _control_file_: file name of control file (String)
    # *Returns*:: messages printed to the standard output (String)
    def run(control_file)
      exec_local([ control_file ])
    end


    # Runs the program on the internal parameters with the specified
    # sequence alignment and tree.
    #
    # Note that parameters[:seqfile] and parameters[:outfile]
    # are always modified, and parameters[:treefile] is modified
    # when tree is specified.
    #
    # To prevent overwrite of existing files by PAML, this method
    # automatically creates a temporary directory and the program
    # is run inside the directory. After the end of the program,
    # the temporary directory is automatically removed.
    #
    # ---
    # *Arguments*:
    # * (required) _alignment_: Bio::Alignment object or similar object
    # * (optional) _tree_: Bio::Tree object
    # *Returns*:: Report object
    def query(alignment, tree = nil)
      astr = alignment.output(:phylipnon)
      if tree then
        tstr = [ sprintf("%3d %2d\n", tree.leaves.size, 1), "\n",
                 tree.output(:newick,
                             { :indent => false,
                               :bootstrap_style => :disabled,
                               :branch_length_style => :disabled })
               ].join('')
      else
        tstr = nil
      end
      str = _query_by_string(astr, tstr)
      @report = self.class::Report.new(str)
      @report
    end

    # Runs the program on the internal parameters with the specified
    # sequence alignment data string and tree data string.
    #
    # Note that parameters[:outfile] is always modified, and
    # parameters[:seqfile] and parameters[:treefile] are modified when
    # alignment and tree are specified respectively.
    #
    # It raises RuntimeError if seqfile is not specified in the argument
    # or in the parameter.
    #
    # For other information, see the document of query method.
    # 
    # ---
    # *Arguments*:
    # * (optional) _alignment_: String
    # * (optional) _tree_: String or nil
    # *Returns*:: contents of output file (String)
    def query_by_string(alignment = nil, tree = nil)
      _query_by_string(alignment, tree)
    end

    # (private) implementation of query_by_string().
    def _query_by_string(alignment = nil, tree = nil)
      @parameters ||= {}
      Bio::Command.mktmpdir('paml') do |path|
        #$stderr.puts path.inspect
        filenames = []
        begin
          # preparing outfile
          outfile = Tempfile.new('out', path)
          outfile.close(false)
          outfn = File.basename(outfile.path)
          self.parameters[:outfile] = outfn
          filenames.push outfn
          # preparing seqfile
          if alignment then
            seqfile = Tempfile.new('seq', path)
            seqfile.print alignment
            seqfile.close(false)
            seqfn = File.basename(seqfile.path)
            self.parameters[:seqfile] = seqfn
            filenames.push seqfn
          end
          # preparing treefile
          if tree then
            treefile = Tempfile.new('tree', path)
            treefile.print tree
            treefile.close(false)
            treefn = File.basename(treefile.path)
            self.parameters[:treefile] = treefn
            filenames.push treefn
          end
          # preparing control file
          ctlfile = Tempfile.new('control', path)
          ctlfile.print self.dump_parameters
          ctlfile.close(false)
          ctlfn = File.basename(ctlfile.path)
          filenames.push ctlfn
          # check parameters
          if errors = check_parameters then
            msg = errors.collect { |e| "error in parameter #{e[0]}: #{e[1]}" }
            raise RuntimeError, msg.join("; ")
          end
          # exec command
          stdout = exec_local([ ctlfn ], { :chdir => path })
          # get main output
          outfile.open
          @output = outfile.read
          # get supplemental result files
          @supplemental_outputs = {}
          (Dir.entries(path) - filenames).each do |name|
            next unless /\A\w/ =~ name
            fn = File.join(path, name)
            if File.file?(fn) then
              @supplemental_outputs[name] = File.read(fn)
            end
          end
        ensure
          outfile.close(true) if outfile
          seqfile.close(true) if seqfile
          treefile.close(true) if treefile
          ctlfile.close(true) if ctlfile
        end
      end
      @output
    end
    private :_query_by_string

    # the last result of the program (String)
    attr_reader :output

    # Report object created from the last result
    attr_reader :report

    # the last exit status of the program
    attr_reader :exit_status

    # the last output to the stdout (String)
    attr_reader :data_stdout

    # the last executed command (Array of String)
    attr_reader :command

    # contents of supplemental output files (Hash).
    # Each key is a file name and value is content of the file.
    attr_reader :supplemental_outputs

    # Loads parameters from the specified string.
    # Note that all previous parameters are erased.
    # Returns the parameters as a hash.
    # ---
    # *Arguments*:
    # * (required) _str_: contents of a PAML control file (String)
    # *Returns*:: parameters (Hash)
    def load_parameters(str)
      hash = {}
      str.each_line do |line|
        param, value = parse_parameter(line)
        hash[param] = value if param
      end
      self.parameters = hash
    end

    # Loads system-wide default parameters.
    # Note that all previous parameters are erased.
    # Returns the parameters as a hash.
    # ---
    # *Returns*:: parameters (Hash)
    def set_default_parameters
      self.parameters = self.class::DEFAULT_PARAMETERS.merge(Hash.new)
    end

    # Shows parameters (content of control file) as a string.
    # The string can be used for control file.
    # ---
    # *Returns*:: string representation of the parameters (String)
    def dump_parameters
      keyorder = DEFAULT_PARAMETERS_ORDER
      keys = parameters.keys
      str = ''
      keys.sort do |x, y|
        (keyorder.index(x) || (keyorder.size + keys.index(x))) <=>
          (keyorder.index(y) || (keyorder.size + keys.index(y)))
      end.each do |key|
        value = parameters[key]
        # Note: spaces are required in both side of the "=".
        str.concat "#{key.to_s} = #{value.to_s}\n" if value
      end
      str
    end

    private

    # (private) clear attributes except program and parameters
    def reset
      @command = nil
      @output = nil
      @report = nil
      @exit_status = nil
      @data_stdout = nil
      @supplemental_outputs = nil
    end

    # (private) parses a parameter in a line
    # ---
    # *Arguments*:
    # * (required) _line_: single line string (String)
    # *Returns*:: parameter name (Symbol or nil), value (String or nil)
    def parse_parameter(line)
      # remove comment
      line = line.sub(/\*.*/, '')
      # Note: spaces are required in both side of the "=".
      param, value = line.strip.split(/\s+=\s+/, 2)
      if !param or param.empty? then
        param = nil
      else
        param = param.to_sym
      end
      return param, value
    end

    # (private) Runs the program on the parameters in the passed control file.
    # No parameter check are executed.
    # ---
    # *Arguments*:
    # * (optional) _control_file_: file name of control file (String)
    # *Returns*:: messages printed to the standard output (String)
    def exec_local(arguments, options = {})
      reset
      cmd = [ @program, *arguments ]
      @command = cmd
      stdout = Bio::Command.query_command(cmd, nil, options)
      @exit_status = $?
      @data_stdout = stdout
      stdout
    end

    # (private) Checks parameters.
    # Returns nil if no errors found. Otherwise, returns an Array
    # containing [ parameter, message ] pairs.
    # ---
    # *Arguments*:
    # *Returns*:: nil or Array
    def check_parameters
      errors = []
      param = self.parameters
      if !param[:seqfile] or param[:seqfile].empty? then
        errors.push([ :seqfile, 'seqfile not specified' ]) 
      end
      errors.empty? ? nil : errors
    end

  end #class Common
end #module PAML
end #module Bio
