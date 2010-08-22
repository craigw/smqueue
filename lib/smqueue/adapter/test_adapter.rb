class SMQueue
  module Adapter
    class TestAdapter
      class TestChannel
        def initialize channel_name; end
        def get; end
        def put; end
        def ack; end
        def close; end
      end

      attr_accessor :channel_class

      def initialize options = nil
        @channel_class = TestChannel
      end

      def channel channel_name
        @channel_class.new channel_name
      end
    end
  end
end
