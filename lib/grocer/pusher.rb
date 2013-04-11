module Grocer
  class Pusher
    class Buffer < Queue
      def initialize(max_size)
        @max_size = max_size
        super()
      end

      def enq(value)
        if self.length >= @max_size
          self.deq
        end
        super
      end

      def shift_until(&block)
        while obj = self.shift
          if block.call(obj) == true
            break
          end
        end
        self
      end
    end

    attr_reader :buffer

    def initialize(connection)
      @connection = connection
      @buffer = Buffer.new(100)
    end

    def push(notification)
      @buffer.enq(notification)
      @connection.write(notification.to_bytes)

      if @connection.error
        @buffer.shift_until do |n|
          n.identifier == @connection.error.identifier
        end
        replay_buffer
      end
    end

    def replay_buffer
      while notification = @buffer.deq
        self.push(notification)
      end
    end
  end
end
