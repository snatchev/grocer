require 'spec_helper'
require 'grocer/pusher'

describe Grocer::Pusher do
  let(:connection) { stub_everything }

  subject { described_class.new(connection) }

  describe '#push' do
    it 'serializes a notification and sends it via the connection' do
      notification = stub(:to_bytes => 'abc123')
      subject.push(notification)

      connection.should have_received(:write).with('abc123')
    end

    it "should buffer the notification on push" do
      notification = stub
      subject.push(notification)
      subject.buffer.current.should == notification
    end

    it "should not buffer a notification if we are retrying from the buffer" do
    end

    it "should push notifications that occured after an error was detected" do
    end

  end
end
