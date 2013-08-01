require File.expand_path('lib/rspec/one_liners/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name                      = 'rspec-one_liners'
  s.version                   = RSpec::OneLiners::VERSION
  s.platform                  = Gem::Platform::RUBY
  s.authors                   = [ 'Gregory McIntyre' ]
  s.email                     = [ 'greg@gregorymcintyre.com' ]
  s.homepage                  = 'http://github.com/puyo/rspec-one_liners'
  s.description               = 'One liner expect..to..change syntax, one liner my_double.should_receive syntax'
  s.summary                   = "rspec-one_liners-#{s.version}"
  s.required_rubygems_version = '> 1.3.6'

  s.files = `git ls-files`.split($\)
  s.executables = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
