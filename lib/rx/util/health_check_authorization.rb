module Rx
  module Util
    class HealthCheckAuthorization
      def initialize(env, authorization)
        @authorization = authorization
        @env = env
      end

      def ok?
        return costum_authorization(@env, @authorization) if @authorization.is_a?(Proc)

        default_authorization(@authorization)
      end

      private

      def costum_authorization(env, callable)
        callable.call(env)
      end

      def default_authorization(key)
        req_key = api_key(@env, "authorization_token")
        req_key == key
      end

      def api_key(env, name)
        key = "http_#{name}".upcase
        env["#{key}"] unless env["#{key}"].nil?
      end
    end
  end
end