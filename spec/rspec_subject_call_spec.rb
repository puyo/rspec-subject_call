require 'spec_helper'

module RSpecSubjectCallSpec
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
end

# ----------------------------------------------------------------------

require 'rspec/subject_call'

describe RSpecSubjectCallSpec::A do
  subject(:a) { RSpecSubjectCallSpec::A.new(b: b) }
  let(:b) { double('b').as_null_object }

  describe '#query' do
    it 'is expected to return 1' do
      expect(a.query).to eq(1)
    end
  end

  describe '#command' do
    it 'is expected to call command on b' do
      expect(b).to receive(:command).once
      a.command
    end
  end

  describe '#query_command' do
    it 'is expected to return 1' do
      expect(a.query_command).to eq(1)
    end

    it 'is expected to call command on b' do
      expect(b).to receive(:command).once
      a.query_command
    end
  end

  describe '#query_command_side_effect - vanilla' do
    it 'is expected to return 1' do
      expect(a.query_command_side_effect).to eq(1)
    end

    it 'is expected to call command on b' do
      expect(b).to receive(:command).once
      a.query_command_side_effect
    end

    it 'is expected to increment counter' do
      expect { a.query_command_side_effect }.to change(a, :counter).by(1)
    end
  end

  describe '#query_command_side_effect - subject_call with custom doc strings' do
    subject { a.query_command_side_effect }

    it 'is expected to return 1' do
      expect(subject).to eq(1)
    end

    it 'is expected to call b.command' do
      expect(b).to receive(:command).once
      call_subject
    end

    it 'is expected to increment counter by 1' do
      call { is_expected.to change(a, :counter).by(1) }
    end
  end

  describe '#query_command_side_effect - subject_call with one liners' do
    subject { a.query_command_side_effect }
    it { is_expected.to eq(1) }
    call { is_expected.to change(a, :counter).by(1) }
    call { is_expected.to cause(b).to receive(:command).once }
  end

  describe '#query_command_side_effect - expect syntax' do
    subject { a.query_command_side_effect }

    it 'is expected to return 1' do
      expect(subject).to eq(1)
    end

    it 'is expected to call b.command' do
      expect(call).to meet_expectations { expect(b).to receive(:command).once }
    end

    it 'is expected to increment counter by 1' do
      expect(call).to change(a, :counter).by(1)
    end
  end
end
