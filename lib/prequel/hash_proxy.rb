# Wrapper around hash instances that allows values to be accessed as symbols,
# strings or method invocations. It behaves similary to OpenStruct, with the
# fundamental difference being that you instantiate *one* HashProxy instance
# and reassign its Hash during a loop in order to avoid creating garbage.
module Prequel
  class HashProxy
    attr :hash

    # Allows accessing a hash attribute as a method.
    def method_missing(symbol, *args, &block)
      hash[symbol] or begin
        raise NoMethodError unless hash.has_key?(symbol)
      end
    end

    # Allows accessing a hash attribute as hash key, either a string or symbol.
    def [](value)
      hash[value.to_sym] or hash[value.to_s]
    end

    # Remove the hash.
    def clear
      @hash = nil
    end

    # Use the hash and return self.
    def using(hash)
      @hash = hash
      self
    end

    # Set the hash to use while calling the block. When the block ends, the
    # hash is unset.
    def with(hash, &block)
      yield using hash ensure clear
    end
  end
end