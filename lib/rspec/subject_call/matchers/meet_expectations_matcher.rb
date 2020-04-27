module RSpec
  module SubjectCall
    module Matchers
      # A general purpose matcher that inverts order of operations.
      #
      # e.g.
      #
      #     expect { A.new(b).method_call_with_side_effect }.to meet_expectations { expect(b).to receive(:command) } }
      #
      class MeetExpectationsMatcher
        def initialize(&block)
          @expected_receives = block
        end

        def matches?(subject)
          @expected_receives.call # e.g. expect(x).to receive(:y)
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
