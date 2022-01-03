module Rx
  module Util
    class HealthCheckAuthorization
      def initialize(env, authorization)
        @authorization = authorization
        @env = env
      end

      def ok?
        return costum_authorization(@authorization) if @authorization.is_a?(Proc)

        default_authorization(@authorization)
      end

      private

      def default_authorization(key)
        req_key = api_key(@env, "Authorization")
        req_key == key
      end

      def costum_authorization(callable)
        callable.call
      end

      def api_key(env, name)
        key = "http_#{name}".upcase
        sth = env["#{key}"]
        env["#{key}"] unless env["#{key}"].nil?
      end
    end
  end
end