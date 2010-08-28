class SMQueue
  module Adapter
    class Mongrel2Adapter
      class Mongrel2Channel
        def get; end
        def put headers, body; end
        def close; end
      end

      def initialize options = {}
      end

      def channel channel_name
        Mongrel2Channel.new
      end
    end
  end
end