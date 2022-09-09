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
module ReadmeExample
  class A
    attr :x

    def initialize(b: nil)
      @x = 0
      @b = b
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
end
```

Note that `query_command_side_effect` does ALL the things. So that is a good
method to try testing elegantly. If we can test that elegantly, we can test
anything elegantly. Right?

With vanilla RSpec, I might test this method like this:

```ruby
describe "ReadmeExample::A, vanilla" do
  let(:a) { ReadmeExample::A.new(b: b) }
  let(:b) { double('b').as_null_object }

  describe '#query_command_side_effect' do
    it "is expected to return 1" do
      expect(a.query_command_side_effect).to eq(1)
    end

    it "is expected to update x" do
      expect { a.query_command_side_effect }.to change(a, :x)
    end

    it "is expected to call command on b" do
      expect(b).to receive(:command).once
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

describe "ReadmeExample::A, subject_call style" do
  let(:a) { ReadmeExample::A.new(b: b) }
  let(:b) { double('b').as_null_object }

  describe '#query_command_side_effect' do
    subject { a.query_command_side_effect }
    it { is_expected.to eq(1) }
    call { is_expected.to change(a, :x) }

    it "is expected to call command on b" do
      expect(b).to receive(:command).once
      subject
    end
  end
end
```

In the above example, `it` is short for the return value of the method under
test, and `call` is a lambda containing the subject, suitable for use with
`change` and `raise_error` and any other matcher that works with lambdas,
already packaged up for you and ready to use.

With this gem, the above example passes:

```
ReadmeExample::A, vanilla
  #query_command_side_effect
    is expected to return 1
    is expected to update x
    is expected to call command on b

ReadmeExample::A, subject_call style
  #query_command_side_effect
    is expected to eq 1
    is expected to change `ReadmeExample::A#x`
    is expected to call command on b

Finished in 0.01393 seconds (files took 0.20693 seconds to load)
6 examples, 0 failures
```

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
