module Ambry

  # Adapters are responsible for persisting the database. This base adapter
  # offers no persistence, all IO operations are just stubs. Adapters must also
  # present the full database as a Hash to the mapper, and provide a `key`
  # method that returns an  array with all the keys for the specified model
  # class.
  class Adapter

    attr_reader :name
    attr_reader :db
    attr_accessor :read_only

    # @option options [String] :name The adapter name. Defaults to {#Ambry.default_adapter_name}.
    def initialize(options = {})
      @name      = options[:name] || Ambry.default_adapter_name
      @read_only = false
      load_database
      Ambry.register_adapter(self)
    end

    # Get a hash of all the data for the specified model class.
    # @param klass [#to_s] The model class whose data to return.
    def db_for(klass)
      @db[klass.to_s] ||= {}
    end

    # Loads the database. For this adapter, that means simply creating a new
    # hash.
    def load_database
      @db = {}
    end

    # These are all just noops for this adapter, which uses an in-memory hash
    # and offers no persistence.

    # Inheriting adapters can overload this method to export the data to a
    # String.
    def export_data
      true
    end

    # Inheriting adapters can overload this method to load the data from some
    # kind of storage.
    def import_data
      true
    end

    # Is the adapter read only? If so, attempts to write data will raise an
    # AmbryError.
    def read_only?
      @read_only
    end

    # Inheriting adapters can overload this method to persist the data to some
    # kind of storage.
    def save_database
      raise AmbryError if read_only?
      true
    end
  end
end
