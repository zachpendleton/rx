require "json"

module Rx
  class Middleware
    def initialize(app,
                   liveness:       [Rx::Check::FileSystemCheck.new],
                   readiness:      [Rx::Check::FileSystemCheck.new],
                   deep_critical:  [],
                   deep_secondary: [],
                   options:        {})
      @app = app
      @options = options
      @cache = Rx::Cache::InMemoryCache.new

      @liveness_checks = liveness
      @readiness_checks = readiness
      @deep_critical_checks = deep_critical
      @deep_secondary_checks = deep_secondary
    end

    def call(env)
      unless health_check_request?(env)
        return app.call(env)
      end

      case env["REQUEST_PATH"]
      when "/liveness"
        ok = check_to_component(liveness_checks).map { |x| x[:status] == 200 }.all?
        liveness_response(ok)
      when "/readiness"
        readiness_response(check_to_component(readiness_checks))
      when "/deep"
        @cache.cache("deep") do
          readiness = check_to_component(readiness_checks)
          critical  = check_to_component(deep_critical_checks)
          secondary = check_to_component(deep_secondary_checks)

          deep_response(readiness, critical, secondary)
        end
      end
    end

    private

    attr_reader :app, :liveness_checks, :readiness_checks, :deep_critical_checks, :deep_secondary_checks

    def health_check_request?(env)
      %w[/liveness /readiness /deep].include?(env["REQUEST_PATH"])
    end

    def liveness_response(is_ok)
      [is_ok ? 200 : 503, {}, []]
    end

    def readiness_response(components)
      status = components.map { |x| x[:status] == 200 }.all? ? 200 : 503

      [
        status,
        {"content-type" => "application/json"},
        [JSON.dump({status: status, components: components})]
      ]
    end

    def deep_response(readiness, critical, secondary)
      status = (readiness.map { |x| x[:status] == 200 } + critical.map { |x| x[:status] == 200 }).all? ? 200 : 503

      [
        status,
        {"content-type" => "application/json"},
        [JSON.dump(status: status, readiness: readiness, critical: critical, secondary: secondary)]
      ]
    end

    def check_to_component(check)
      Array(check)
        .map { |check| Rx::Concurrent::Future.execute { check.check } }
        .map(&:value)
        .map { |r| { name: r.name, status: r.ok? ? 200 : 503, message: r.ok? ? "ok" : r.error, response_time_ms: r.timing } }
    end
  end
end