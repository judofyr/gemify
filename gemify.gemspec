# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gemify}
  s.version = "0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Magnus Holm"]
  s.date = %q{2010-01-23}
  s.default_executable = %q{gemify}
  s.executables = ["gemify"]
  s.email = %q{judofyr@gmail.com}
  s.files = [".yardopts", "CHANGELOG", "README.md", "bin/gemify", "gemify.gemspec", "lib/gemify.rb", "lib/gemify/base.rb", "lib/gemify/cli.rb", "lib/gemify/manifest.rb", "lib/trollop.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://dojo.rubyforge.org/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{The lightweight gemspec editor}
  s.post_install_message = %q{** Gemify has changed since 0.2, please see http://dojo.rubyforge.org/}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
