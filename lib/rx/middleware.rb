require "json"

module Rx
  class Middleware
    def initialize(app, options = {liveness: [], readiness: []})
      @app = app
      @options = options

      if @options[:liveness].empty?
        @options[:liveness] << Rx::Check::FileSystemCheck.new
      end

      if @options[:readiness].empty?
        @options[:readiness] << Rx::Check::FileSystemCheck.new
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
        components = options[:readiness]
          .map { |x| [x.name, x.check, x.timing, x.last_error] }
          .map { |(name, ok, timing, err)| { name: name, status: ok ? 200 : 503, message: ok ? "ok" : err, response_time_ms: timing } }
        readiness_response(components)
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

    def readiness_response(components)
      status = components.map { |x| x[:status] == 200 }.all? ? 200 : 502

      [
        status,
        {"content-type" => "application/json"},
        [JSON.dump({status: status, components: components})]
      ]
    end
  end
end