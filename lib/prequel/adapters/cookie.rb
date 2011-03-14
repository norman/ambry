require "active_support"
require "active_support/message_verifier"
require "zlib"

module Prequel
  module Adapters
    class Cookie < Adapter

      attr :verifier
      attr_accessor :data

      MAX_DATA_LENGTH = 4096

      def self.max_data_length
        MAX_DATA_LENGTH
      end

      def initialize(options)
        @data     = options[:data]
        @verifier = ActiveSupport::MessageVerifier.new(options[:secret])
        super
      end

      def export_data
        cookie = verifier.generate(Zlib::Deflate.deflate(Marshal.dump(db)))
        length = cookie.bytesize
        if length > Cookie.max_data_length
          raise(PrequelError, "Data is %s bytes, cannot exceed %s" % [length, Cookie.max_data_length])
        end
        cookie
      end

      def import_data
        data.blank? ? {} : Marshal.load(Zlib::Inflate.inflate(verifier.verify(data)))
      end

      def load_database
        @db = import_data
        @db.map(&:freeze)
      end

      def save_database
        @data = export_data
      end
    end
  end
end