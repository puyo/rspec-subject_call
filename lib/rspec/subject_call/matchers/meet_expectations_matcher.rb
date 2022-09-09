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
          @expectation = @expected_receives.call # e.g. { expect(x).to receive(:y) }
        end

        def matches?(subject)
          subject.call # execute the subject (assumed to be a Proc)
        end

        def description
          "cause #{@expectation.orig_object} to #{@expectation.description_for("receive")}"
        end
      end

      class AffectMatcher
        def initialize(other_subject, &block)
          @other_subject = other_subject
          @expected_receives = block
          @expectation = @expected_receives.call # e.g. { expect(x).to receive(:y) }
        end

        def matches?(subject)
          subject.call # execute the subject (assumed to be a Proc)
        end

        def description
          require 'pry'; binding.pry
          "cause #{@expectation.orig_object} to #{@expectation.description_for("receive")}"
        end
      end

      class CauseMatcher
        def initialize(other_subject, expectation)
          @other_subject = other_subject
          @expectation = expectation # receive(:y)
        end

        def matches?(subject)
          @expectation.matches?(@other_subject)
          if subject.is_a?(Proc)
            subject.call
          else
            warn "cause expects the subject to be a proc"
          end
        end

        def description
          "cause #{@other_subject.inspect} to #{@expectation.description}"
        end
      end

      class CauseExpectation < RSpec::Expectations::ExpectationTarget
        def to(matcher, message=nil, &block)
          @matcher = matcher
          @message = message
          @not = false
          super
          self
        end

        def not_to(matcher, message=nil, &block)
          @matcher = matcher
          @message = message
          @not = true
          super
          self
        end
        alias to_not not_to

        def matches?(subject)
          p 'matches?'
          @matcher.matches?(target)
          if subject.is_a?(Proc)
            subject.call
          else
            warn "cause expects the subject to be a proc"
          end
        end

        def description
          "HI"
        end
      end
    end
  end

  module Matchers
    def meet_expectations(&block)
      ::RSpec::SubjectCall::Matchers::MeetExpectationsMatcher.new(&block)
    end

    def affect(subject, &block)
      ::RSpec::SubjectCall::Matchers::AffectMatcher.new(subject, &block)
    end

    # def cause(subject, to:)
    #   ::RSpec::SubjectCall::Matchers::CauseMatcher.new(subject, to)
    # end

    def cause(subject)
      ::RSpec::SubjectCall::Matchers::CauseExpectation.new(subject)
    end
  end
end
