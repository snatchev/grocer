module Grocer
  class Buffer < Queue
    def initialize(max_size)
      @max_size = max_size
      super()
    end

    def push(value)
      if self.size >= @max_size
        self.pop
      end
      super(value)
    end

    def pop_until(&block)
      while obj = self.pop
        if block.call(obj) == true
          break
        end
      end
      self
    end

    ##
    # default with the non block option
    def pop(non_block = true)
      begin
        super(non_block)
      rescue ThreadError
        nil
      end
    end
  end
end
