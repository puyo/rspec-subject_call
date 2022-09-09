require 'spec_helper'

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
