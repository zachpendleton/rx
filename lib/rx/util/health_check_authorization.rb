module Rx
  module Util
    class HealthCheckAuthorization
      def initialize(env, authorization)
        @authorization = authorization
        @env = env
      end

      def ok?
        return custom_authorization(@env, @authorization) if @authorization.is_a?(Proc)

        default_authorization(@authorization)
      end

      private

      def custom_authorization(env, callable)
        callable.call(env)
      end

      def default_authorization(key)
        req_key = api_key(@env, "authorization_token")
        req_key == key
      end

      def api_key(env, name)
        key = "http_#{name}".upcase

        raise StandardError.new("Token is not configured properly") if env["#{key}"].nil?

        env["#{key}"]
      end
    end
  end
end