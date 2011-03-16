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

    # Get a hash of all the data for the specified model class.
    # @param klass [#to_s] The model class whose data to return.
    def db_for(klass)
      @db[klass.to_s] ||= {}
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
