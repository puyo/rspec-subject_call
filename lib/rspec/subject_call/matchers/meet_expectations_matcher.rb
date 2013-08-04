module RSpec
  module SubjectCall
    module Matchers
      # A general purpose matcher that inverts order of operations
      # allowing for one liners involving mock expectations.
      class MeetExpectationsMatcher
        def initialize(&block)
          @should_receives = block
        end

        def matches?(subject)
          @should_receives.call # e.g. x.should_receive(:y)
          subject.call # execute the subject (assumed to be a Proc)
        end

        def description
          'met expectations'
        end
      end
    end
  end

  module Matchers
    def meet_expectations(&block)
      ::RSpec::SubjectCall::Matchers::MeetExpectationsMatcher.new(&block)
    end
  end
end
