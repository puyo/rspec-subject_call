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
