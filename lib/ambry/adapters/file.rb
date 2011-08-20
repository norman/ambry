module Ambry
  module Adapters
    # Loads and saves hash database from a Marshal.dump file.
    class File < Adapter

      attr_reader :file_path
      attr :lock

      def initialize(options)
        @file_path = options[:file]
        @lock      = Mutex.new
        super
      end

      def load_database
        @db = import_data
        (!@db || @db.empty?) ? @db = {} : @db.map(&:freeze)
      rescue Errno::ENOENT
        # @TODO warn via logger when file doesn't exist
        @db = {}
      end

      def export_data
        Marshal.dump(db)
      end

      def import_data
        Marshal.load(::File.read(file_path))
      end

      def save_database
        @lock.synchronize do
          ::File.open(file_path, "w") {|f| f.write(export_data)}
        end
      end
    end
  end
end
