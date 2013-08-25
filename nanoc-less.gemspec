# encoding: utf-8

$LOAD_PATH.unshift(File.expand_path('../lib/', __FILE__))
require 'nanoc/less/version'

Gem::Specification.new do |s|
  s.name        = 'nanoc-less'
  s.version     = Nanoc::Less::VERSION
  s.homepage    = 'http://nanoc.ws/'
  s.summary     = 'Less support for nanoc'
  s.description = 'Provides a :less filter for nanoc'

  s.author  = 'Denis Defreyne'
  s.email   = 'denis.defreyne@stoneship.org'
  s.license = 'MIT'

  s.required_ruby_version = '>= 1.9.3'

  s.files              = Dir['[A-Z]*'] +
                         Dir['{lib,test}/**/*'] +
                         [ 'nanoc-less.gemspec' ]
  s.require_paths      = [ 'lib' ]

  s.rdoc_options     = [ '--main', 'README.md' ]
  s.extra_rdoc_files = [ 'LICENSE', 'README.md', 'NEWS.md' ]

  s.add_runtime_dependency('nanoc-core')
  s.add_runtime_dependency('less')
  s.add_runtime_dependency('therubyracer')
  s.add_development_dependency('bundler')
end
