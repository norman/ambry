require "rack/contrib"

module Rack
  # Rack::Ambry is a middleware that allows you to store a Ambry datbase
  # in a cookie.
  # @see Ambry::Adapters::Cookie
  class Ambry
    def initialize(app, options = {})
      @app         = app
      options      = options.call if options.respond_to? :call
      @cookie_name = options.delete(:cookie_name) || "ambry_data"
      @ambry = ::Ambry::Adapters::Cookie.new(options.merge(:sync => true))
    end

    def call(env)
      @ambry.data = env["rack.cookies"][@cookie_name]
      @ambry.load_database
      status, headers, body = @app.call(env)
      env["rack.cookies"][@cookie_name] = @ambry.export_data
      [status, headers, body]
    end
  end
end
