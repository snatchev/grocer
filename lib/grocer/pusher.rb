module Grocer

  class Pusher
    def initialize(connection)
      @connection = connection
      @buffer = HistoryBuffer.new(100)
    end

    def push(notification)
      return if notification.nil?

      if @buffer.end_of_buffer?
        @buffer << notification
      end

      @connection.write(notification.to_bytes)

      if @connection.error
        @buffer.rewind_to do |buffered_notification|
          buffered_notification.identifier == @connection.error.identifier
        end
      end

      push(@buffer.next)
    end
  end
end
