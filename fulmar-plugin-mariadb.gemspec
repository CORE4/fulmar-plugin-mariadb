# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fulmar/plugin/mariadb/version'

Gem::Specification.new do |spec|
  spec.name          = 'fulmar-plugin-mariadb'
  spec.version       = Fulmar::Plugin::MariaDB::VERSION
  spec.authors       = ['Gerrit Visscher']
  spec.email         = ['g.visscher@core4.de']

  spec.summary       = 'MariaDB database plugin for fulmar'
  spec.description   = 'This gems add database handling'
  spec.homepage      = 'https://github.com/CORE4/fulmar-plugin-mariadb'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/}) || %w(.editorconfig).include?(f)
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'fulmar', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
end
