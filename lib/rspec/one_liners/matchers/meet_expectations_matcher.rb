module RSpec
  module OneLiners
    module Matchers
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
      ::RSpec::OneLiners::Matchers::MeetExpectationsMatcher.new(&block)
    end
  end
end
