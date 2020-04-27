require File.expand_path('lib/rspec/subject_call/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name                      = 'rspec-subject_call'
  s.version                   = RSpec::SubjectCall::VERSION
  s.platform                  = Gem::Platform::RUBY
  s.license                   = 'MIT'
  s.authors                   = [ 'Gregory McIntyre' ]
  s.email                     = [ 'greg@gregorymcintyre.com' ]
  s.homepage                  = 'http://github.com/puyo/rspec-subject_call'
  s.description               = 'Use the rspec subject more conveniently'
  s.summary                   = "rspec-subject_call-#{s.version}"

  s.files = `git ls-files`.split($\)
  s.executables = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
