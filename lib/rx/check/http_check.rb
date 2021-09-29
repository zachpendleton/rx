require "uri"

module Rx
  module Check
    class HttpCheck
      attr_reader :name, :timeout

      def initialize(url, name = "http", timeout: 1)
        @url = URI(url)
        @name = name
        @timeout = timeout
      end

      def check
        Result.from(name) do
          http = Net::HTTP.new(url.host, url.port)
          http.read_timeout = timeout
          http.use_ssl = url.scheme == "https"

          response = http.request(Net::HTTP::Get.new(path))
          response.code == "200"
        end
      end

      private

      attr_reader :url

      def path
        path = url.path == "" ? "/" : url.path
        path = "#{path}?#{url.query}" if url.query
        path = "#{path}##{url.fragment}" if url.fragment

        path
      end
    end
  end
end