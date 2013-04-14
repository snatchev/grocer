require 'spec_helper'
require 'grocer/buffer'

describe Grocer::Buffer do
  describe "#push" do
    subject { described_class.new(1) }
    it "should not keep more than max_size elements" do
      subject.push(1)
      expect(subject.size).to eq(1)
      subject.push(2)
      expect(subject.size).to eq(1)
    end
  end

  describe "#pop" do
    subject { described_class.new(1) }
    it "should not block if the queue is empty" do
      expect(subject.pop).to be_nil
    end
  end

  describe "#pop_until" do
    subject { described_class.new(3) }
    before do
      3.times { |i|
        subject.push(i)
      }
    end

    it "should inclusively remove elements from the front until the condition is true" do
      subject.pop_until {|i| i == 0 }
      expect(subject.length).to eq(2)
    end

    it "should remove all elements if the condition is not met" do
      subject.pop_until {|i| i == 'a' }
      expect(subject.length).to eq(0)
    end
  end

end
