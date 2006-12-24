module ShellHelper

  include Bio::Shell

  def evaluate_script(script)
    @local_variables = eval("local_variables", Bio::Shell.cache[:binding]) - ["_erbout"]

    # write out to history
    begin
      Bio::Shell.cache[:histfile].puts "#{Time.now}\t#{script.strip.inspect}"
      eval(script, Bio::Shell.cache[:binding])
    rescue
      $!
    end
  end

  def method_link()
  end

  def reference_link(class_name)
    case class_name
    when /Bio::(.+)/
      "http://bioruby.org/rdoc/classes/Bio/#{$1.split('::').join('/')}.html"
    when /Chem::(.+)/
      "http://chemruby.org/rdoc/classes/Chem/#{$1.split('::').join('/')}.html"
    else
      "http://www.ruby-doc.org/core/classes/#{class_name.split('::').join('/')}.html"
    end
  end

end
