require File.expand_path('lib/rspec/subject_call/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name                      = 'rspec-subject_call'
  s.version                   = RSpec::SubjectCall::VERSION
  s.platform                  = Gem::Platform::RUBY
  s.authors                   = [ 'Gregory McIntyre' ]
  s.email                     = [ 'greg@gregorymcintyre.com' ]
  s.homepage                  = 'http://github.com/puyo/rspec-one_liners'
  s.description               = 'Enable reuse of the subject for use with expect..to..change and my_double.should_receive'
  s.summary                   = "rspec-subject_call-#{s.version}"
  s.required_rubygems_version = '> 1.3.6'

  s.files = `git ls-files`.split($\)
  s.executables = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
