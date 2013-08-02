# RSpec One Liners

This gem permits succinct one liner syntax in situations that currently require more than one line of code.
It's for impatient people who use RSpec and like saving keystrokes.

## The Situation

There are different types of methods I sometimes need to test.

A **query** performs a calculation and returns a value.

A **command** changes state or otherwise has some lasting effect.

A method may also have a number of **side effects** which you *may* wish to
make assertions about, such as caching or keeping counts.

Let's not go into whether these methods are well designed. Let's just assume
that we want to test them conveniently.

Here is a class that has all these things:

```ruby
class A
  attr_reader :counter

  def initialize(args = {})
    @b = args[:b]
    @counter = 0
  end

  def query
    1
  end

  def command
    @b.command
  end

  def query_command
    @b.command
    1
  end

  def query_command_side_effect
    @b.command
    @counter += 1
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

  describe '#query_command_side_effect - vanilla best practice' do
    it 'should return 1' do
      a.query_command_side_effect.should == 1
    end

    it 'should call command on b' do
      b.should_receive(:command).once
      a.query_command_side_effect
    end

    it 'should increment counter' do
      expect { a.query_command_side_effect }.to change(a, :counter).by(1)
    end
  end
end
```

But I feel as though this is more typing that I would like. I feel like this
could be DRYed up. For example, `a.query_command_side_effect` is repeated three
times.

## The Better Situation

This is how I would like to test this tricky method:

```ruby
describe A do
  let(:a) { A.new(b: b) }
  let(:b) { double('b').as_null_object }

  describe '#query_command_side_effect' do
    subject { a.query_command_side_effect }
    it { should == 1 }
    calling_it { should change(a, :counter).by(1) }
    calling_it { should meet_expectations { b.should_receive(:command) } }
  end
end
```

In the above example, `it` is short for the return value of the method under
test, and `calling_it` is a lambda containing the subject, suitable for use
with `change`, already packaged up for you and ready to use.

With this gem, the above example passes.

## WARNING

This gem is currently beta. There is a decent chance that its
prototypical implementation that messes with RSpec internals will mess
something up or cause hard to diagnose issues. On the other hand, it may just
be crazy enough to work.

## More Examples

```ruby
class Array
  def sum
    inject(:+)
  end
end

describe Array do
  describe '#sum' do
    subject { call }

    def call
      array.sum
    end

    context 'with the array [1,2,3]' do
      let(:array) { [1,2,3] }
      it { should == 6 }
    end

    context 'with the array [1,2,nil], calling it' do
      let(:array) { [1,2,nil] }
      subject { method(:call) }
      it { should raise_error }
    end
  end
end

require 'calling_it'

describe Array do
  describe '#sum' do
    subject { array.sum }

    context 'with the array [1,2,3]' do
      let(:array) { [1,2,3] }
      it { should == 6 }
    end

    context 'with the array [1,2,nil]' do
      let(:array) { [1,2,nil] }
      calling_it { should raise_error(TypeError) }
    end
  end
end
```

```ruby
describe Array do
  describe '#pop' do
    subject { call }

    def call
      array.pop
    end

    context 'with the array [1,2,3]' do
      let(:array) { [1,2,3] }
      it { should == 3 }

      context 'calling it' do
        subject { method(:call) }
        it { should change(array, :size).by(-1) }
      end
    end
  end
end

require 'calling_it'

describe Array do
  describe '#pop' do
    subject { array.pop }

    context 'with the array [1,2,3]' do
      let(:array) { [1,2,3] }
      it { should == 3 }
      calling_it { should change(array, :size).by(-1) }
    end
  end
end
```
```
