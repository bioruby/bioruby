module BiorubyHelper

  include Bio::Shell

  def project_workdir
    if Bio::Shell.cache[:savedir].match(/\.bioruby$/)
      Bio::Shell.cache[:workdir]
    else
      Bio::Shell.cache[:savedir]
    end
  end

  def have_results
    Bio::Shell.cache[:results].number > 0
  end

  def local_variables
    eval("local_variables", Bio::Shell.cache[:binding]) -
      BiorubyController::HIDE_VARIABLES
  end

  def render_log(page)
    page.insert_html :top, :logs, :partial => "log"
    page.replace_html "variables", :partial => "variables"
    page.hide "methods_#{@number}"
    page.hide "classes_#{@number}"
    page.hide "modules_#{@number}"
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

