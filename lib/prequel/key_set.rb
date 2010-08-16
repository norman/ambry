require "forwardable"

module Prequel
  class KeySet
    include Enumerable
    extend Forwardable

    attr_accessor :keys, :mapper
    def_delegators :keys, :<<, :size
    def_delegator :mapper, :klass

    def initialize(keys = nil, mapper = nil)
      @keys   = keys || []
      @mapper = mapper
    end

    def method_missing(symbol, *args, &block)
      if klass.respond_to?(symbol)
        self.class.new(keys & klass.send(symbol, *args, &block).keys, @mapper)
      else
        raise NoMethodError.new("undefined method `%s' for %s:%s" % [symbol, self.to_s, self.class.to_s])
      end
    end

    def count(&block)
      block_given? ? super : size
    end

    def each(&block)
      keys.each {|key| yield @mapper[key]}
    end

    def find(&block)
      return self unless block_given?
      keys.inject(self.class.new([], @mapper)) do |set, key|
        set << key if yield(@mapper[key]); set
      end
    end

    def find_by_key(&block)
      return self unless block_given?
      keys.inject(self.class.new([], @mapper)) do |set, key|
        set << key if yield(key); set
      end
    end
  end
end
