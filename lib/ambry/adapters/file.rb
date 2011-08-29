module Ambry
  module Adapters
    # Loads and saves hash database from a Marshal.dump file.
    class File < Adapter

      attr_reader :file_path
      attr :lock

      def initialize(options)
        @file_path = options[:file]
        @read_only  = !! options[:read_only]
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
        data = ::File.open(file_path, "rb") { |f| f.read }
        Marshal.load(data)
      end

      def save_database
        super
        @lock.synchronize do
          ::File.open(file_path, "wb") {|f| f.write(export_data)}
        end
      end
    end
  end
end
