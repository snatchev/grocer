require 'forwardable'

module Grocer
  class RingBuffer
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
      if @current_index == (@array.size - 1)
        @current_index += 1
      end

      @array << obj
    end
    alias :push :<<

    def rewind_to(&block)
      @current_index.downto(0) do |index|
        obj = @array[index]
        if block.call(obj) == true
          @current_index = index
          return obj
        end
      end

      current
    end

    def next
      @current_index += 1
      current
    end

    def current
      @array[@current_index]
    end

  end
end
