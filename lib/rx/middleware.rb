require "json"

module Rx
  class Middleware
    def initialize(app, options = {liveness: [], readiness: [], deep: {critical: [], secondary: []}})
      @app = app
      @options = options
      @cache = Rx::Cache::InMemoryCache.new

      @options[:liveness] ||= []
      if @options[:liveness].empty?
        @options[:liveness] << Rx::Check::FileSystemCheck.new
      end

      @options[:readiness] ||= []
      if @options[:readiness].empty?
        @options[:readiness] << Rx::Check::FileSystemCheck.new
      end

      @options[:deep] ||= {critical: [], secondary: []}
      @options[:deep][:critical] ||= []
      @options[:deep][:secondary] ||= []
    end

    def call(env)
      unless health_check_request?(env)
        return app.call(env)
      end

      case env["REQUEST_PATH"]
      when "/liveness"
        ok = options[:liveness].map(&:check).map(&:ok?).all?
        liveness_response(ok)
      when "/readiness"
        readiness_response(check_to_component(options[:readiness]))
      when "/deep"
        @cache.cache("deep") do
          readiness = check_to_component(options[:readiness])
          critical = check_to_component(options[:deep][:critical])
          secondary = check_to_component(options[:deep][:secondary])

          deep_response(readiness, critical, secondary)
        end
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