module Prequel

  # Adapters are responsible for persisting the database. This base adapter
  # offers no persistence, all IO operations are just stubs. Adapters must also
  # present the full database as a Hash to the mapper by providing a key_set
  # method that returns an instance of Prequel::Key set with all keys.
  class Adapter

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
