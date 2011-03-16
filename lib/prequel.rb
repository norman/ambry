require "forwardable"
require "thread"
require "prequel/adapter"
require "prequel/key_set"
require "prequel/mapper"
require "prequel/model"
require "prequel/hash_proxy"
require "prequel/adapters/file"

module Prequel
  extend self

  @lock = Mutex.new

  # The default adapter name.
  attr_reader   :default_adapter_name
  @default_adapter_name = :main

  # A hash of all instantiated Prequel adapters.
  attr_reader :adapters
  @adapters = {}

  def register_adapter(adapter)
    name = adapter.name.to_sym
    if adapters[name]
      raise PrequelError, "Adapter #{name.inspect} already registered"
    end
    @lock.synchronize do
      adapters[name] = adapter
    end
  end

  # Base error for Prequel.
  class PrequelError < StandardError ; end

  # Raised when a single instance is expected but could not be found.
  class NotFoundError < PrequelError
    def initialize(*args)
      super('Could not find %s with key "%s"' % args)
    end
  end
end
