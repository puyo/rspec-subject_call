require 'rspec/subject_call/matchers/meet_expectations_matcher'

module RSpec
  module SubjectCall
    module ExampleGroupClassMethods
      # Define a method +subject+ for use inside example groups which provides
      # a +call+ method for examples in this group which returns a lambda
      # containing the subject, suitable for use with matchers that take
      # lambdas, such as +change+.
      #
      # e.g.
      #
      #    subject { obj.my_method }
      #
      #    it { is_expected.to eq(some_result) }
      #
      #    it 'is expected to change something' do
      #       expect(call).to change { something }
      #    end
      #
      def subject(name=nil, &block)
        if block
          define_method(:call_subject) do
            instance_eval(&block)
          end
          define_method(:call) do
            lambda { call_subject }
          end
        end

        # Do the things subject normally does.
        super(name, &block)
      end

      # Like +it+ but sets the implicit subject to the lambda you supplied when
      # defining the subject, so that you can use it with matchers that take
      # blocks like +change+:
      #
      #   call { is_expected.to change { something } }
      #
      def call(desc=nil, *args, &block)
        # Create a new example, where the subject is set to the subject block,
        # as opposed to its return value.
        example do
          self.class.class_eval do
            define_method(:subject) do
              call # calls define_method(:call) inside def subject above
            end
          end
          instance_eval(&block)
        end
      end
    end
  end
end

module RSpec
  module Core
    class ExampleGroup
      extend ::RSpec::SubjectCall::ExampleGroupClassMethods
    end
  end
end
