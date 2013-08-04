require 'rspec/matchers/pretty'
require 'rspec/matchers/built_in'

module RSpec
  module SubjectCall
    module Matchers
      class ReturnValueMatcher < RSpec::Matchers::BuiltIn::Eq
        def matches?(subject)
          @actual = subject.call
        end

        def description
          "return #{expected.inspect}"
        end
      end
    end
  end

  module Matchers
    def return_value(expected)
      ::RSpec::SubjectCall::Matchers::ReturnValueMatcher.new(expected)
    end
  end
end
