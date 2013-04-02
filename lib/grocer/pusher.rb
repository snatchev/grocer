module Grocer

  class Pusher
    def initialize(connection)
      @connection = connection
      @buffer = RingBuffer.new(10)
    end

    def push(notification)
      @buffer << notification
      bytes = @connection.write(notification.to_bytes)
      if bytes == 0
        puts @connection.error
      end
    end
  end
end
