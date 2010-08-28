class SMQueue
  module Adapter
    class Mongrel2Adapter
      class Mongrel2Channel
        def initialize(options)
          @protocol = options[:protocol]
        end
        def get; end
        def put headers, body; end
        def close; end
      end

      class Mongrel2RequestChannel < Mongrel2Channel
        def get; end
        def put headers, body
          raise "You can't put messages on the request channel"
        end
      end

      class Mongrel2ResponseChannel < Mongrel2Channel
        def get
          raise "You can't get messages from the response channel"
        end
        def put headers, body; end
      end

      def initialize options = {}
        @protocol = options[:protocol]
      end

      def channel channel_name
        if !%(request response).include? channel_name
          raise "The channel_name must be 'request' or 'response'."
        end
        channel_class_for(channel_name).new :protocol => @protocol
      end

      private
      def channel_class_for channel_name
        const_name = "Mongrel2#{channel_name[0..0].upcase}#{channel_name[1..-1]}Channel"
        self.class.const_get(const_name)
      end
    end
  end
end