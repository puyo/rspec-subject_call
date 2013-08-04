require 'rspec/subject_call/matchers/meet_expectations_matcher'
require 'rspec/subject_call/matchers/return_value_matcher'

module RSpec
  module SubjectCall
    module ExampleGroupClassMethods
      # Define a method +subject+ for use inside examples, and also a method
      # +call+ which returns a lambda containing the subject, suitable for use
      # with matchers that take lambdas.
      #
      # e.g.
      #
      #    subject { obj.my_method }
      #
      #    it { should == some_result }
      #
      #    it 'should change something, should syntax' do
      #       call.should change{something}
      #    end
      #
      #    it 'should change something, expect syntax' do
      #       expect(call).to change{something}
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

      # Allow for syntax similar to +its+:
      #
      #   its(:my_method) { should == 1 }
      #   calling(:my_method) { should change{something} }
      #
      def calling(method_name, &block)
        describe(method_name) do
          let(:__its_subject) do
            method_chain = method_name.to_s.split('.')
            lambda do
              method_chain.inject(subject) do |inner_subject, attr|
                inner_subject.send(attr)
              end
            end
          end

          def should(matcher=nil, message=nil)
            RSpec::Expectations::PositiveExpectationHandler.handle_matcher(__its_subject, matcher, message)
          end

          def should_not(matcher=nil, message=nil)
            RSpec::Expectations::NegativeExpectationHandler.handle_matcher(__its_subject, matcher, message)
          end

          example(&block)
        end
      end

      # Like +it+ but sets the implicit subject to the lambda you supplied when
      # defining the subject, so that you can use it with matchers that take
      # blocks like +change+:
      #
      #   call { should change{something} }
      #
      def call(desc=nil, *args, &block)
        # Create a new example, where the subject is set to the subject block,
        # as opposed to its return value.
        example do
          self.class.class_eval do
            define_method(:subject) do
              if defined?(@_subject_call)
                @_subject_call
              else
                @_subject_call = call
              end
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
