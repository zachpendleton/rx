module Rx
  module Check
    class ActiveRecordCheck
      attr_reader :name

      def initialize(name = "activerecord")
        @name = name
      end

      def check
        Result.from(name) do
          unless defined?(ActiveRecord::Base)
            raise StandardError.new("Undefined class ActiveRecord::Base")
          end

          ActiveRecord::Base.connection.active?
        end
      end
    end
  end
end