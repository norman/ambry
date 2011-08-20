require "active_support"
require "active_support/message_verifier"
require "zlib"

module Ambry
  module Adapters

    # Ambry's cookie adapter allows you to store a Ambry database inside
    # a zipped and signed string suitable for setting as a cookie. This can be
    # useful for modelling things like basic shopping carts or form wizards.
    # Keep in mind the data is signed, so it can't be tampered with. However,
    # the data is not *encrypted*, so somebody that wanted to could unzip and
    # load the cookie data to see what's inside. So don't send this data
    # client-side if it's at all sensitive.
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
          raise(AmbryError, "Data is %s bytes, cannot exceed %s" % [length, Cookie.max_data_length])
        end
        cookie
      end

      def import_data
        (!data || data.empty?) ? {} : Marshal.load(Zlib::Inflate.inflate(verifier.verify(data)))
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
