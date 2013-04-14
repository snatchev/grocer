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
      notification = mock("Notification") do
        stubs(:to_bytes => 'abc123')
      end

      expect {
        subject.push(notification)
      }.to change{subject.buffer.size}.by(1)
    end

    it 'should replay the buffered notifications if an error was reported' do
      notification = mock("Notification") do
        stubs(:to_bytes => 'abc123')
        stubs(:identifier)
      end
      error_response = mock('ErrorResponse') do
        stubs(:identifier)
      end
      connection.stubs(:error).returns(error_response)
      subject.stubs(:replay_buffer)
      subject.push(notification)
      subject.should have_received(:replay_buffer)
    end

    it 'should not replay a buffered notification that was reported to have an error' do
      bad_notification = mock("BadNotification") do
        stubs(:to_bytes => 'abc123')
        stubs(:identifier => 1)
      end
      good_notification = mock("GoodNotification") do
        stubs(:to_bytes => 'abc123')
        stubs(:identifier => 2)
      end
      connection.stubs(:error).returns(bad_notification, nil)
      subject.buffer.enq(bad_notification)
      subject.push(good_notification)
      subject.should have_received(:push).with(bad_notification).never
    end
  end

  describe '#replay_buffer' do
    let(:notification) do
      mock('Notification') do
        stubs(:to_bytes => 'abc123')
      end
    end

    before do
      subject.buffer.enq(notification)
    end

    it 'should push each buffered notification' do
      subject.replay_buffer
      connection.should have_received(:write).with(notification.to_bytes)
    end

    it 'should not change the buffer' do
      expect {
        subject.replay_buffer
      }.to_not change{subject.buffer.size}
    end
  end

end
