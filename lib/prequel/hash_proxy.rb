# Wrapper around hash instances that allows values to be accessed as symbols,
# strings or method invocations. It behaves similary to OpenStruct, with the
# fundamental difference being that you instantiate *one* HashProxy instance
# and reassign its Hash during a loop in order to avoid creating garbage.
module Prequel
  class HashProxy
    attr :hash

    def method_missing(symbol, *args, &block)
      hash[symbol] or begin
        raise NoMethodError unless hash.has_key?(symbol)
      end
    end

    def [](value)
      hash[value.to_sym] or hash[value.to_s]
    end

    def clear
      @hash = nil
    end

    def using(hash)
      @hash = hash
      self
    end

    def with(hash, &block)
      yield using hash ensure clear
    end
  end
end