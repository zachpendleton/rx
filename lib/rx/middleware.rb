require "json"

module Rx
  class Middleware
    DEFAULT_OPTIONS = {
      cache: true,
      authorization: false
    }.freeze

    def initialize(app,
                   liveness:       [Rx::Check::FileSystemCheck.new],
                   readiness:      [Rx::Check::FileSystemCheck.new],
                   deep_critical:  [],
                   deep_secondary: [],
                   options:        {})
      @app = app
      @options = DEFAULT_OPTIONS.merge(options)
      @cache = cache_factory(@options)

      @liveness_checks = liveness
      @readiness_checks = readiness
      @deep_critical_checks = deep_critical
      @deep_secondary_checks = deep_secondary
    end

    def call(env)
      unless health_check_request?(path(env))
        return app.call(env)
      end

      case path(env)
      when "/liveness"
        ok = check_to_component(liveness_checks).map { |x| x[:status] == 200 }.all?
        liveness_response(ok)
      when "/readiness"
        readiness_response(check_to_component(readiness_checks))
      when "/deep"
        if @options[:authorization] && !Rx::Util::HealthCheckAuthorization.new(env, @options[:authorization]).ok?
          deep_response_authorization_failed
        else
          @cache.cache("deep") do
            readiness = check_to_component(readiness_checks)
            critical  = check_to_component(deep_critical_checks)
            secondary = check_to_component(deep_secondary_checks)

            deep_response(readiness, critical, secondary)
          end
        end
      end
    end

    private

    attr_reader :app, :liveness_checks, :readiness_checks, :deep_critical_checks,
                :deep_secondary_checks, :options

    def cache_factory(options)
      unless options[:cache]
        return Rx::Cache::NoOpCache.new
      end

      Rx::Cache::InMemoryCache.new
    end

    def health_check_request?(path)
      %w[/liveness /readiness /deep].include?(path)
    end

    def liveness_response(is_ok)
      [is_ok ? 200 : 503, {}, []]
    end

    def path(env)
      env["PATH_INFO"] || env["REQUEST_PATH"] || env["REQUEST_URI"]
    end

    def readiness_response(components)
      status = components.map { |x| x[:status] == 200 }.all? ? 200 : 503

      [
        status,
        {"content-type" => "application/json"},
        [JSON.dump({status: status, components: components})]
      ]
    end

    def deep_response_authorization_failed
      [
        403,
        {"content-type" => "application/json"},
        [JSON.dump({ message: "authorization failed" })]
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