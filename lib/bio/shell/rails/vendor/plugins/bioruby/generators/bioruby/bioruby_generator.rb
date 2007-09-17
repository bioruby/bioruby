class BiorubyGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory 'app/controllers'
      m.directory 'app/helpers'
      m.directory 'app/views/bioruby'
      m.directory 'app/views/layouts'
      m.directory 'public/images/bioruby'
      m.directory 'public/stylesheets'
      m.file 'bioruby_controller.rb', 'app/controllers/bioruby_controller.rb'
      m.file 'bioruby_helper.rb',     'app/helpers/bioruby_helper.rb'
      m.file '_methods.rhtml',        'app/views/bioruby/_methods.rhtml'
      m.file '_classes.rhtml',        'app/views/bioruby/_classes.rhtml'
      m.file '_modules.rhtml',        'app/views/bioruby/_modules.rhtml'
      m.file '_log.rhtml',            'app/views/bioruby/_log.rhtml'
      m.file '_variables.rhtml',      'app/views/bioruby/_variables.rhtml'
      m.file 'commands.rhtml',        'app/views/bioruby/commands.rhtml'
      m.file 'history.rhtml',         'app/views/bioruby/history.rhtml'
      m.file 'index.rhtml',           'app/views/bioruby/index.rhtml'
      m.file 'bioruby.rhtml',         'app/views/layouts/bioruby.rhtml'
      m.file 'spinner.gif',           'public/images/bioruby/spinner.gif'
      m.file 'bioruby-gem.png',       'public/images/bioruby/gem.png'
      m.file 'bioruby-link.gif',      'public/images/bioruby/link.gif'
      m.file 'bioruby-bg.gif',        'public/images/bioruby/bg.gif'
      m.file 'bioruby.css',           'public/stylesheets/bioruby.css'
    end
  end
end

