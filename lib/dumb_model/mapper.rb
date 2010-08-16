module DumbModel
  class Mapper

    attr_reader :file_path
    attr_reader :db

    def method_missing(symbol, *args, &block)
      db.__send__(symbol, *args, &block)
    end

    def initialize(file_path)
      @file_path = file_path
      load_database
    end

    def count(klass, &block)
      db.select do|key, value|
        key_class = key.to_s.split(":")[0]
        if block_given?
          yield(key, value) &&  key_class == klass
        else
          key_class == klass
        end
      end.size
    end

    def put(instance)
      key = "%s:%s" % [instance.class.to_s, instance.to_param]
      db[key] = instance.to_hash
    end

    def load_database
      File.open(file_path, "r") do |file|
        @db = Marshal.load(file.read)
      end
    rescue Errno::ENOENT
      @db = {}
    end

    def save_database
      File.open(file_path, "w") do |file|
        file.write(Marshal.dump(db))
      end
    end
  end
end