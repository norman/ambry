require "prequel/adapter"
require "prequel/key_set"
require "prequel/mapper"
require "prequel/model"
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

  # Raised by adapters
  class AdapterError < PrequelError ; end

  # Raised when trying to access data from the wrong class.
  class BadClassError < PrequelError ; end

  # Raised when a single instance is expected but could not be found.
  class NotFoundError < PrequelError
    def initialize(*args)
      if args.size == 1
        super('Could not find %s' % args)
      else
        super('Could not find %s with key "%s"' % args)
      end
    end
  end

  # Raised when attempting to instantiate a model instance with an empty hash.
  class EmptyDataError < PrequelError ; end
end
