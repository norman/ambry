require "rack/contrib"

module Rack
  class Prequel
    def initialize(app, options = {})
      @app     = app
      @prequel = ::Prequel::Adapters::Cookie.new(options.merge(:sync => true))
    end

    def call(env)
      @prequel.data = env["rack.cookies"]["prequel_data"]
      @prequel.load_database
      status, headers, body = @app.call(env)
      env["rack.cookies"]["prequel_data"] = @prequel.export_data
      [status, headers, body]
    end
  end
end
