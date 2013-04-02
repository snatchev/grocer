require 'spec_helper'
require 'grocer/ring_buffer'

describe Grocer::RingBuffer do
  subject { described_class.new(10) }

  it "should not grow beyond the max size" do
    11.times do
      subject.push("hello")
    end
    subject.size.should eq(10)
  end

  it "should provide backward access to the prev element" do
  end

  it "should provide forward access to the next element"

  it "should push an element to the end of the buffer"

  it "should provide a way to rewind to a specific element" do
    ('a'..'j').each do |c|
      subject << c
    end

    subject.rewind_to do |obj|
      obj == 'd'
    end
    subject.next.should == 'e'
  end

  it "should not affect the buffer if we remind to something non-existant" do
    ('a'..'j').each do |c|
      subject << c
    end

    subject.rewind_to do |obj|
      false
    end

    subject.current.should == 'j'
  end

  it "should not advance past the end of the buffer"




end
