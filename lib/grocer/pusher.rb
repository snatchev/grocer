module Grocer

  class Pusher
    def initialize(connection)
      @connection = connection
    end

    def push(notification)
      bytes = @connection.write(notification.to_bytes)
      if bytes == 0
        puts @connection.error
      end
    end
  end
end
