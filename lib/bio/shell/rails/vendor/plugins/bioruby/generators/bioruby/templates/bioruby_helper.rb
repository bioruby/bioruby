module BiorubyHelper

  HIDE_VARIABLES = [
    "_", "irb", "_erbout",
  ]

  include Bio::Shell

  def project_workdir
    Bio::Shell.cache[:workdir]
  end

  def have_results
    Bio::Shell.cache[:results].number > 0
  end

  def local_variables
    eval("local_variables", Bio::Shell.cache[:binding]) - HIDE_VARIABLES
  end

  def reference_link(class_or_module)
    name = class_or_module.to_s
    case name
    when /Bio::(.+)/
      path = $1.split('::').join('/')
      url = "http://bioruby.org/rdoc/classes/Bio/#{path}.html"
    when /Chem::(.+)/
      path = $1.split('::').join('/')
      url = "http://chemruby.org/rdoc/classes/Chem/#{path}.html"
    else
      path = name.split('::').join('/')
      url = "http://www.ruby-doc.org/core/classes/#{path}.html"
    end
    return "<a href='#{url}'>#{name}</a>"
  end

end
