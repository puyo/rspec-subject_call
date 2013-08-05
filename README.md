# RSpec Subject Call

This gem permits succinct one liner syntax in situations that currently require
more than one line of code. It's for impatient people who use RSpec and like
saving keystrokes.

## The Situation

There are different types of methods I sometimes need to test. [[1]]

A **query** performs a calculation and returns a value, like `sum`.

A **command** does one thing. Often it changes one piece of state.
e.g. `x=` or `print_document`.

A method may also have a number of **side effects** which you *may* wish to
make assertions about, such as caching, keeping counts or raising exceptions.

To illustrate, here is a class that has all these types of methods.

```ruby
class A
  attr :x

  def initialize(args = {})
    @b = args[:b]
    @x = 0
  end

  def query
    1
  end

  def command
    @x = 1
  end

  def query_command
    @x = 1
    1
  end

  def query_command_side_effect
    @b.command
    @x = 1
    1
  end
end

class B
  def command
  end
end
```

Note that `query_command_side_effect` does ALL the things. So that is a good
method to try testing elegantly. If we can test that elegantly, we can test
anything elegantly. Right?

With vanilla RSpec, I might test this method like this:

```ruby
describe A do
  let(:a) { A.new(b: b) }
  let(:b) { double('b').as_null_object }

  describe '#query_command_side_effect' do
    it 'should return 1' do
      a.query_command_side_effect.should == 1
    end

    it 'should update x' do
      expect { a.query_command_side_effect }.to change(a, :x)
    end

    it 'should call command on b' do
      b.should_receive(:command).once
      a.query_command_side_effect
    end
  end
end
```

But I feel as though this is more typing that I would like and could be DRYed
up. For example, `a.query_command_side_effect` is repeated three times.

## The Subject Call Solution

This is how I would like to test this tricky method:

```ruby
require 'rspec/subject_call'

describe A do
  let(:a) { A.new(b: b) }
  let(:b) { double('b').as_null_object }

  describe '#query_command_side_effect' do
    subject { a.query_command_side_effect }
    it { should == 1 }
    call { should change(a, :x) }
    call { should meet_expectations { b.should_receive(:command) } }
  end
end
```

In the above example, `it` is short for the return value of the method under
test, and `call` is a lambda containing the subject, suitable for use with
`change` and `raise_error` and any other matcher that works with lambdas,
already packaged up for you and ready to use.

With this gem, the above example passes.

## Installation

```
gem install rspec-subject_call
```

If you prefer, copy and paste this into your `Gemfile` and run `bundle`:

```
gem 'rspec-subject_call'
```

Later that day, ensure this line is included somehow before your spec:

```
require 'rspec/subject_call'
```

Now you can use your new powers for good or for awesome.


[1]: http://en.wikipedia.org/wiki/Command%E2%80%93query_separation "Command-Query Separation"
