class SMQueue
  module Adapter
    class Mongrel2Adapter
      class ZMQDriver
        def initialize
          if !defined?(ZMQ)
            require 'ffi'
            require 'ffi-rzmq'
          end
        end

        def upstream uri
          socket = context.socket(ZMQ::UPSTREAM)
          socket.connect uri
          socket
        end

        private
        def context
          @context ||= default_context
        end

        def default_context
          ZMQ::Context.new(1)
        end
      end

      class Mongrel2Channel
        attr_reader :driver
        def initialize options
          @driver = options[:driver]
          @host = options[:host]
          @port = options[:port]
        end
        def get; end
        def put headers, body; end
        def close; end

        protected
        def socket
          @socket ||= @driver.upstream("tcp://#{@host}:#{@port}")
        end
      end

      class Mongrel2RequestChannel < Mongrel2Channel
        def get
          raw_message = socket.recv_string(0)
          return unless raw_message
          sender_id, client_id, path, request = *raw_message.split(/ /, 4)
          header_length, headers_and_body = *request.split(/:/, 2)
          request_headers = json_parser.parse(headers_and_body[0,header_length.to_i])
          body_part = headers_and_body[(header_length.to_i + 1)..-1]
          body_length, body_content = *body_part.split(/:/, 2)
          body = body_content[0,body_length.to_i]
          message_headers = {
            'sender_id' => sender_id,
            'client_id' => client_id.to_i,
            'path' => path,
            'headers' => request_headers
          }
          [ message_headers, body ]
        end

        def put headers, body
          raise "You can't put messages on the request channel"
        end

        private
        def json_parser
          if !defined?(JSON)
            require 'yajl/json_gem'
          end
          JSON
        end
      end

      class Mongrel2ResponseChannel < Mongrel2Channel
        def get
          raise "You can't get messages from the response channel"
        end

        def put headers, body; end
      end

      def initialize options = {}
        @options = options
        @options[:driver] ||= default_driver
      end

      def channel channel_name
        if !%(request response).include? channel_name
          raise "The channel_name must be 'request' or 'response'."
        end
        channel_class_for(channel_name).new @options
      end

      private
      def default_driver
        ZMQDriver
      end

      def channel_class_for channel_name
        const_name = "Mongrel2#{channel_name[0..0].upcase}#{channel_name[1..-1]}Channel"
        self.class.const_get(const_name)
      end
    end
  end
end