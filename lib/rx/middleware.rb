require "json"

module Rx
  class Middleware
    def initialize(app, options = {})
      @app = app
      @options = {}
    end

    def call(env)
      unless health_check_request?(env)
        return app.call(env)
      end

      case env["REQUEST_PATH"]
      when "/liveness"
        liveness_response
      when "/readiness"
        # TODO
      when "/deep"
        # TODO
      end
    end

    private

    attr_reader :app, :options

    def health_check_request?(env)
      %w[/liveness /readiness /deep].include?(env["REQUEST_PATH"])
    end

    def liveness_response
      [200, {}, []]
    end
  end
end