require 'forwardable'

module Grocer
  class HistoryBuffer
    extend Forwardable
    def_delegators :@array, :size

    attr_reader :max_size, :current

    def initialize(max_size)
      @max_size = max_size
      @array = Array.new()
      @current_index = -1
    end

    def <<(obj)
      if @array.size >= @max_size
        @array.shift
      end

      @array << obj
    end
    alias :push :<<

    def rewind_to(&block)
      @current_index.downto(-@max_size) do |index|
        obj = @array[index]
        if block.call(obj) == true
          @current_index = index
          return obj
        end
      end

      current
    end

    def play(&block)
      while self.next
        block.call(current)
      end
    end

    def next
      @current_index += 1

      if @current_index >= 0
        @current_index = -1
        return nil
      end
      current
    end

    def end_of_buffer?
      @current_index == -1
    end

    def current
      @array[@current_index]
    end
  end
end
