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

  attr_accessor   :default_adapter_name
  @default_adapter_name = :main

  attr_accessor :adapters
  @adapters = {}

  def register_adapter(adapter)
    name = adapter.name.to_sym
    if adapters[name]
      raise PrequelError, "Adapter #{name.inspect} already registered"
    end
    adapters[name] = adapter
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
