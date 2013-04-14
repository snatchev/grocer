module Grocer
  class Pusher

    attr_reader :buffer

    def initialize(connection)
      @connection = connection
      @buffer = Buffer.new(100)
    end

    def push(notification)
      @buffer.push(notification)
      @connection.write(notification.to_bytes)

      error = @connection.error
      if error
        @buffer.pop_until do |n|
          n.identifier == error.identifier
        end
        self.replay_buffer
      end
    end

    def replay_buffer
      replay_buffer = Buffer.new(100)
      while !@buffer.empty?
        replay_buffer.push(@buffer.pop)
      end

      while !replay_buffer.empty?
        self.push(replay_buffer.pop)
      end
    end
  end
end
