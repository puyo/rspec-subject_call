module RSpec
  module OneLiners
    module ExampleGroupClassMethods
      # Define a method +subject+ for use inside examples, and also a
      # method +calling_it+ which returns a lambda containing the subject,
      # suitable for use with matchers that take lambdas.
      #
      # e.g.
      #
      #    subject { obj.my_method }
      #
      #    it { should == some_result }
      #
      #    it 'should change something, should syntax' do
      #       calling_it.should change{something}
      #    end
      #
      #    it 'should change something, expect syntax' do
      #       expect(calling_it).to change{something}
      #    end
      #
      def subject(name=nil, &block)
        # Add extra methods that allow calling the block that was passed, in
        # the example's lexical scope.
        if block
          define_method(:calling_it) do
            lambda { instance_eval(&block) }
          end
          alias_method(:subject_call, :calling_it)
        end

        # Now proceed to do the things subject normally does.
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
      #   calling_it { should change{something} }
      #
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
