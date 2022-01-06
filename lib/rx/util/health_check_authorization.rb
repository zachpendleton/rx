module Rx
  module Util
    class HealthCheckAuthorization
      HTTP_HEADER = "HTTP_AUTHORIZATION"

      def initialize(env, authorization)
        @authorization = authorization
        @env = env
      end

      def ok?
        case @authorization
          when NilClass
            true
          when Proc
            @authorization.call(@env)
          when String
            @authorization == @env[HTTP_HEADER]
          else
            raise StandardError.new("Authorization is not configured properly")
        end
      end
    end
  end
end