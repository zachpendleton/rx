require "json"

module Rx
  class Middleware
    def initialize(app, options = {liveness: []})
      @app = app
      @options = options

      if @options[:liveness].empty?
        @options[:liveness] << Rx::Check::FileSystemCheck.new
      end
    end

    def call(env)
      unless health_check_request?(env)
        return app.call(env)
      end

      case env["REQUEST_PATH"]
      when "/liveness"
        ok = options[:liveness].map(&:check).all?
        liveness_response(ok)
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

    def liveness_response(is_ok)
      [is_ok ? 200 : 503, {}, []]
    end
  end
end