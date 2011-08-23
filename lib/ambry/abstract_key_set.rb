module Ambry

  # @abstract
  class AbstractKeySet
    extend Forwardable
    include Enumerable

    attr_accessor  :keys, :mapper
    def_delegators :keys, :empty?, :length, :size
    def_delegators :to_enum, :each

    # Create a new KeySet from an array of keys and a mapper.
    def initialize(keys = nil, mapper = nil)
      @keys = keys || [].freeze
      # Assume that if a frozen array is passed in, it's already been compacted
      # and uniqued in order to improve performance.
      unless @keys.frozen?
        @keys.uniq!
        @keys.compact!
        @keys.freeze
      end
      @mapper = mapper
    end

    def +(key_set)
      self.class.new(keys + key_set.keys, mapper)
    end
    alias | +

    def -(key_set)
      self.class.new((keys - key_set.keys).freeze, mapper)
    end

    def &(key_set)
      self.class.new((keys & key_set.keys).compact.freeze, mapper)
    end

    # With no block, returns an instance for the first key. If a block is given,
    # it returns the first instance yielding a true value.
    def first(&block)
      block_given? ? all.detect(&block) : all.first
    end

    # With no block, returns an instance for the first key. If a block is given,
    # it returns the first instance yielding a true value.
    def last(&block)
      block_given? ? all.reverse.detect(&block) : all.last
    end

    # With no block, returns the number of keys. If a block is given, counts the
    # number of elements yielding a true value.
    def count(&block)
      return keys.count unless block_given?
      proxy = HashProxy.new
      keys.inject(0) do |count, key|
        proxy.with(mapper[key], &block) ? count.succ : count
      end
    end

    def find(id = nil, &block)
      return mapper.get(id) if id
      return self unless block_given?
      proxy = HashProxy.new
      self.class.new(keys.inject([]) do |found, key|
        found << key if proxy.with(mapper[key], &block)
        found
      end, mapper)
    end

    def to_enum
      KeyIterator.new(keys) {|k| @mapper.get(k)}
    end
    alias all to_enum

    def find_by_key(&block)
      return self unless block_given?
      self.class.new(keys.inject([]) do |set, key|
        set << key if yield(key); set
      end, mapper)
    end

    def sort(&block)
      proxies = HashProxySet.new
      self.class.new(@keys.sort do |a, b|
        begin
          yield(*proxies.using(mapper[a], mapper[b]))
        ensure
          proxies.clear
        end
      end, mapper)
    end

    def limit(length)
      self.class.new(@keys.first(length).freeze, mapper)
    end
  end

  class KeyIterator
    include Enumerable

    attr_reader :keys, :callable

    def initialize(keys, &callable)
      @keys     = keys
      @callable = callable
    end

    def reverse
      KeyIterator.new(keys.reverse, &callable)
    end

    def last
      callable.call keys.last
    end

    def each(&block)
      block_given? ? keys.each {|k| yield callable.call(k)} : to_enum
    end
  end
end
