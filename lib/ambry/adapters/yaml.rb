require "yaml"

module Ambry
  module Adapters
    # An Adapter that uses YAML for its storage.
    class YAML < File

      def import_data
        ::YAML.load(::File.read(file_path))
      end

      def export_data
        db.to_yaml
      end
    end
  end
end
