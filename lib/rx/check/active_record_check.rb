module Rx
  module Check
    class ActiveRecordCheck
      attr_reader :name

      def initialize(name = "activerecord")
        @name = name
      end

      def check
        Result.from(name) do
          unless activerecord_defined?
            raise StandardError.new("Undefined class ActiveRecord::Base")
          end

          ActiveRecord::Base.connection.connect! unless ActiveRecord::Base.connection.active?
          ActiveRecord::Base.connection.active?
        end
      end

      private

      def activerecord_defined?
        defined?(ActiveRecord::Base)
      end
    end
  end
end
