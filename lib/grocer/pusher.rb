module Grocer

  class Pusher
    def initialize(connection)
      @connection = connection
      @buffer = HistoryBuffer.new(100)
    end

    def push(notification)
      return 0 if notification.nil?

      if @buffer.end_of_buffer?
        @buffer << notification
      end

      bytes = @connection.write(notification.to_bytes)

      if @connection.error
        rewind_buffer_to_identifier(@connection.error.identifier)
      end

      #re-send anything that remains on the buffer ahead of us
      bytes += push(@buffer.next)
    end

    private
      def rewind_buffer_to_identifier(identifier)
        @buffer.rewind_to do |buffered_notification|
          buffered_notification.identifier == identifier
        end
      end

  end
end
