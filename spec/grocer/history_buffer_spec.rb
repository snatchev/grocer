require 'spec_helper'
require 'grocer/history_buffer'

describe Grocer::HistoryBuffer do
  subject { described_class.new(10) }

  before do
    ('a'..'j').each do |c|
      subject << c
    end
  end

  it "should not grow beyond the max size" do
    subject.size.should eq(10)
    subject << 'k'
    subject.size.should eq(10)
  end

  it "should push an element to the end of the buffer" do
    subject.rewind_to do |obj|
      obj == 'a'
    end

    subject << 'k'
    subject.current.should == 'b'
  end

  it "should provide a way to rewind to a specific element" do
    subject.rewind_to do |obj|
      obj == 'd'
    end
    subject.next.should == 'e'
  end

  it "should not affect the buffer if we remind to something non-existant" do
    subject.rewind_to do |obj|
      false
    end

    subject.current.should == 'j'
  end

  it "should not advance past the end of the buffer" do
    subject.current.should == 'j'

    2.times do
      subject.next.should be_nil
      subject.current.should == 'j'
    end
  end
end
