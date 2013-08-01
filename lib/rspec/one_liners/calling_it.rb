module RSpec
  module OneLiners
    module ExampleGroupClassMethods
      def subject(name=nil, &block)
        # Add extra methods that allow calling the block that was passed, in the
        # example's lexical scope.
        if block
          define_method(:calling_it) do
            lambda { instance_eval(&block) }
          end
          alias_method(:subject_call, :calling_it)
        end

        # Now proceed to do the things subject normally does.
        super()
      end

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

      def calling_it(desc=nil, *args, &block)
        # Create a new example, where the subject is set to the subject block,
        # as opposed to its return value.
        example do
          self.class.class_eval do
            define_method(:subject) do
              if defined?(@_subject_calling_it)
                @_subject_calling_it
              else
                @_subject_calling_it = calling_it
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
      extend ::RSpec::OneLiners::ExampleGroupClassMethods
    end
  end
end
