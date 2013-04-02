module Grocer
  class Pusher
    def initialize(connection)
      @connection = connection
      @buffer = RingBuffer.new(10)
    end

    def push(notification)
      @connection.write(notification.to_bytes)
    end
  end
end
