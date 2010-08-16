module Prequel

  # Adapters are responsible for moving objects in and out of the database and
  # for presenting a hash-like interface to the mappers.
  class Adapter
    include Enumerable

    attr_reader :name
    attr_reader :db

    def initialize(options = {})
      @name = options[:name] || Prequel.default_adapter_name
      load_database
      Prequel.register_adapter(self)
    end

    def key_set(mapper)
      KeySet.new(@db[mapper.klass.to_s].keys, mapper)
    end

    def load_database
      @db = {}
    end

    # These are all just noops for this adapter, which uses an in-memory hash
    # and offers no persistence.

    def export_data
      true
    end

    def import_data
      true
    end

    def save_database
      true
    end
  end
end
