require 'tempfile'
require 'english'

module Bio
end

class Bio::CodeML

  DEFAULT_OPTIONS = {
    # Essential argumemts
    :seqfile             => nil,
    :treefile            => nil,
    # Optional arguments
    :outfile             => Tempfile.new('codeml').path,
    :noisy               => 0,
    :verbose             => 1,
    :runmode             => 0,
    :seqtype             => 2,
    :CodonFreq           => 2,
    :ndata               => 1,
    :clock               => 0,
    :aaDist              => 0,
    :aaRatefile          => 'wag.dat',
    :model               => 3,
    :NSsites             => 0,
    :icode               => 0,
    :Mgene               => 0,
    :fix_kappa           => 0,
    :kappa               => 2,
    :fix_omega           => 0,
    :omega               => 0.4,
    :fix_alpha           => 0,
    :alpha               => 0.5,
    :Malpha              => 0,
    :ncatG               => 8,
    :getSE               => 0,
    :RateAncestor        => 0,
    :Small_Diff          => 0.000005,
    :cleandata           => 1,
    :fix_blength         => 0,
    :method              => 0
  }
  
  attr_accessor :options

  def initialize(codeml_location)
    unless File.exists?(codeml_location)
      raise ArgumentError.new("File does not exist : #{codeml_location}")
    end
    @binary = codeml_location
  end

  def run(config_file = create_config_file)
    load_options_from_file(config_file)
    check_options
    output = %x[ #{@binary} #{config_file} ]

    loglik  = pull_log_likelyhood(output)

    if loglik == nil || ! File.exists?(self.options[:outfile])
      raise RuntimeError.new("Error running codeml\n" + output)
    end

    result = {:log_likelyhood => loglik}
    result[:alpha] = pull_alpha
    result[:rates] = pull_rates

    result
  end
 
  def self.create_config_file(options = Hash.new, location = Tempfile.new('codeml_config').path)
    options = DEFAULT_OPTIONS.merge(options)
    File.open(location,'w') do |file|
      options.each do |key, value|
        file.puts "#{key.to_s} = #{value.to_s}"
      end
    end
    location
  end

  def load_options_from_file(file)
    options = Hash.new
    File.readlines(file).each do |line|
      param, value = line.strip.split(/\s+=\s+/)
      options[param.to_sym] = value
    end
    self.options = options
  end

  def check_options
    raise ArgumentError.new("Sequence file not found") unless File.exists?(self.options[:seqfile])
    raise ArgumentError.new("Tree file not found") unless File.exists?(self.options[:treefile])
  end

  def pull_log_likelyhood(text)
    text[/lnL  = (-?\d+(\.\d+)?)/,1].to_f
  end

  def pull_alpha
    re = /alpha .+ =\s+(-?\d+(\.\d+)?)/
    File.new(self.options[:outfile]).each do |line|
      if re =~ line
        return Regexp.last_match[1].to_f
      end
    end
    # Return nil if not found
    return nil
  end

  def pull_rates
    re = /\s+(\d+)\s+(\d+)\s+([A-Z]+)\s+(\d+\.\d+)\s+(\d)/
    rates = Array.new
    File.new('rates','r').each do |line|
      if re =~ line
        match = Regexp.last_match
        rates[match[1].to_i] = {:freq => match[2].to_i, :data => match[3], :rate => match[4].to_f }
      end
    end
    rates
  end

  def clean_up
    ['rates','lnf','rst','rub','rst1',self.options[:outfile]].each { |file| File.delete(file) if File.exists?(file) }
  end

end
