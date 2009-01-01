# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{merb_resourceful}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Leal"]
  s.date = %q{2009-01-01}
  s.description = %q{merb_resourceful lends a little magic to common resource actions.}
  s.email = %q{dgleal@gmail.com}
  s.extra_rdoc_files = ["README.textile", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README.textile", "Rakefile", "TODO", "lib/merb_resourceful", "lib/merb_resourceful/controller.rb", "lib/merb_resourceful/orms", "lib/merb_resourceful/orms/datamapper_resource.rb", "lib/merb_resourceful/builder.rb", "lib/merb_resourceful.rb", "spec/merb_resourceful", "spec/merb_resourceful/datamapper_resourceful_controller_spec.rb", "spec/merb_resourceful/resourceful_controller_spec.rb", "spec/merb_resourceful/log", "spec/merb_resourceful/log/merb_test.log", "spec/merb_resourceful/log/merb.main.pid", "spec/spec_helper.rb", "spec/views", "spec/views/create.html.erb", "spec/views/edit.html.erb", "spec/views/new.html.erb", "spec/views/layout.another.html.erb", "spec/views/update.html.erb", "spec/views/show.html.erb", "spec/views/index.html.erb", "spec/config", "spec/config/init.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/david/merb_resourceful}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{merb}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{merb_resourceful lends a little magic to common resource actions.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<merb>, ["~> 1.0"])
    else
      s.add_dependency(%q<merb>, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<merb>, ["~> 1.0"])
  end
end
