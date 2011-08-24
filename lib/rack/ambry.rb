require "rack/contrib"

module Rack
  # Rack::Ambry is a middleware that allows you to store a Ambry datbase
  # in a cookie.
  # @see Ambry::Adapters::Cookie
  class Ambry
    def initialize(app, options = {})
      @app     = app
      @ambry = ::Ambry::Adapters::Cookie.new(options.merge(:sync => true))
    end

    def call(env)
      @ambry.data = env["rack.cookies"]["ambry_data"]
      @ambry.load_database
      status, headers, body = @app.call(env)
      env["rack.cookies"]["ambry_data"] = @ambry.export_data
      [status, headers, body]
    end
  end
end
