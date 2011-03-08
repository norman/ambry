module Prequel

  class KeySet
    include Enumerable
    extend Forwardable

    attr_accessor :keys, :mapper
    def_delegators :keys, :empty?, :size
    def_delegator :mapper, :klass

    def initialize(keys = nil, mapper = nil)
      @keys   = (keys || []).uniq.compact.freeze
      @mapper = mapper
    end

    def method_missing(symbol, *args, &block)
      if klass.respond_to?(symbol )
        self.class.new(keys & klass.send(symbol, *args, &block).keys, @mapper)
      else
        raise NoMethodError.new("undefined method `%s' for %s:%s" % [symbol, self.to_s, self.class.to_s])
      end
    end

    [:+, :&, :-, :|].each do |symbol|
      define_method symbol do |key_set|
        self.class.new(keys.send(symbol, key_set.keys), @mapper)
      end
    end

    def count(&block)
      block_given? ? super : size
    end

    # Iterate over the mapper's raw attribute Hash associated with each key.
    def each(&block)
      keys.each {|key| yield @mapper[key]}
    end

    # Iterate over keys. This is the fastest way to iterate, but offers the
    # least flexibility.
    def each_key(&block)
      keys.each {|key| yield key}
    end

    # Iterate over model instances associated with each key. This is the slowest
    # way to iterate, but allows for the most flexible searching.
    def each_instance(&block)
      keys.each {|key| yield @mapper.get(key)}
    end

    def find(&block)
      return self unless block_given?
      proxy = HashProxy.new(klass)
      found_keys = []
      keys.each do |key|
        found_keys << key if proxy.with(@mapper[key], &block)
      end
      klass.key_set(found_keys)
    end
    alias all find

    def find_by_key(&block)
      return self unless block_given?
      self.class.new(keys.inject([]) do |set, key|
        set << key if yield(key); set
      end, @mapper)
    end

    def first(&block)
      klass.from_hash super
    end

    def instances
      keys.map {|k| @mapper.get(k)}
    end

    def sort(&block)
      proxy1 = HashProxy.new
      proxy2 = HashProxy.new
      self.class.new(@keys.sort do |a, b|
        begin
          yield(proxy1.using(@mapper[a]), proxy2.using(@mapper[b]))
        ensure
          proxy1.clear
          proxy2.clear
        end
      end, @mapper)
    end

    def limit(length)
      self.class.new(@keys.slice(0,length), mapper)
    end
  end
end
