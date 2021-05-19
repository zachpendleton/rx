require "uri"

module Rx
  module Check
    class HttpCheck
      attr_reader :name

      def initialize(url, name = "http")
        @url = URI(url)
        @name = name
      end

      def check
        Result.from(name) do
          http = Net::HTTP.new(url.host, url.port).tap do |x|
            x.read_timeout = 1
            x.use_ssl = url.scheme == "https"
          end

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