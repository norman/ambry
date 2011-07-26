require "rack/contrib"

module Rack
  # Rack::Norman is a middleware that allows you to store a Norman datbase
  # in a cookie.
  # @see Norman::Adapters::Cookie
  class Norman
    def initialize(app, options = {})
      @app     = app
      @norman = ::Norman::Adapters::Cookie.new(options.merge(:sync => true))
    end

    def call(env)
      @norman.data = env["rack.cookies"]["norman_data"]
      @norman.load_database
      status, headers, body = @app.call(env)
      env["rack.cookies"]["norman_data"] = @norman.export_data
      [status, headers, body]
    end
  end
end
