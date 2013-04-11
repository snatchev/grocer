require 'spec_helper'
require 'grocer/pusher'

describe Grocer::Pusher do
  let(:connection) { stub_everything }
  let(:error_response) { stub('ErrorResponse') }

  subject { described_class.new(connection) }

  describe '#push' do
    it 'serializes a notification and sends it via the connection' do
      notification = stub(:to_bytes => 'abc123')
      subject.push(notification)

      connection.should have_received(:write).with('abc123')
    end

    it 'should buffer the notification' do
      notification = stub
      expect {
        subject.push(notification)
      }.to change{subject.buffer.size}.by(1)
    end

    it 'should replay the buffered notifications if an error was reported' do
      notification = double
      connection.stub(:error).and_return(stub('ErrorResponse'))
      subject.push(notification)
      subject.should have_received(:replay_buffer)
    end

    it 'should not replay a buffered notification that was reported to have an error' do
      notification = stub(identifier: 1)
      connection.stub(error: notification)
      subject.buffer.enq(notification)
      #call push on the next notification
      subject.push(stub)
      subject.should_not have_received(:push).with(notification)
    end
  end

  describe '#replay_buffer' do
    let(:notification) { stub('Notification') }

    before do
      subject.buffer.enq(notification)
    end

    it 'should push each buffered notification' do
      subject.replay_buffer
      subject.should have_received(:push).with(notification).once
    end

    it 'should not change the buffer' do
      expect {
        subject.replay_buffer
      }.to_not change{subject.buffer}
    end

    it 'should push buffered notifications until the buffer is empty' do
      pending
    end
  end

end
