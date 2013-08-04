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

# ----------------------------------------------------------------------

require 'rspec/subject_call'

describe A do
  subject(:a) { A.new(b: b) }
  let(:b) { double('b').as_null_object }

  describe '#query' do
    it 'should return 1' do
      a.query.should == 1
    end
  end

  describe '#command' do
    it 'should call command on b' do
      b.should_receive(:command).once
      a.command
    end
  end

  describe '#query_command' do
    it 'should return 1' do
      a.query_command.should == 1
    end

    it 'should call command on b' do
      b.should_receive(:command).once
      a.query_command
    end
  end

  describe '#query_command_side_effect - vanilla' do
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

  describe '#query_command_side_effect - subject_call with custom doc strings' do
    subject { a.query_command_side_effect }

    it 'should return 1' do
      subject.should == 1
    end

    it 'should call b.command' do
      b.should_receive(:command)
      call_subject
    end

    it 'should increment counter by 1' do
      call { should change(a, :counter).by(1) }
    end
  end

  describe '#query_command_side_effect - subject_call with one liners' do
    subject { a.query_command_side_effect }
    it { should == 1 }
    call { should change(a, :counter).by(1) }
    call { should meet_expectations { b.should_receive(:command) } }
  end

  describe '#query_command_side_effect - subject_call, its style' do
    subject { a }
    its(:query_command_side_effect) { should == 1 }
    calling(:query_command_side_effect) { should change(a, :counter).by(1) }
    calling(:query_command_side_effect) { should meet_expectations { b.should_receive(:command) } }
  end

  describe '#query_command_side_effect - expect syntax' do
    subject { a.query_command_side_effect }

    it 'should return 1' do
      expect(subject).to eq(1)
    end

    it 'should call b.command' do
      expect(call).to meet_expectations { b.should_receive(:command) }
    end

    it 'should increment counter by 1' do
      expect(call).to change(a, :counter).by(1)
    end
  end
end
