require 'spec_helper'
require 'smqueue/adapter/mongrel2_adapter'
require 'support/behaviour/adapter'

describe SMQueue::Adapter::Mongrel2Adapter do
  it_should_behave_like "an adapter class"

  describe "instance" do
    let(:adapter_instance) {
      driver = stub_everything('Driver')
      SMQueue::Adapter::Mongrel2Adapter.new :driver => driver
    }
    it_should_behave_like "an adapter instance"

    it "uses ZMQDriver as the default driver implementation" do
      default_driver = SMQueue::Adapter::Mongrel2Adapter::ZMQDriver
      m2 = SMQueue::Adapter::Mongrel2Adapter.new

      channel_class = SMQueue::Adapter::Mongrel2Adapter::Mongrel2RequestChannel
      channel_class.expects(:new).once.with(:driver => default_driver)
      m2.channel 'request'

      channel_class = SMQueue::Adapter::Mongrel2Adapter::Mongrel2ResponseChannel
      channel_class.expects(:new).once.with(:driver => default_driver)
      m2.channel 'response'
    end

    # FIXME: I think this tests the implementation too tightly. We
    #        probably don't care what's called, we just want to end up
    #        with a ZMQ socket that's bound to the remote address.
    describe SMQueue::Adapter::Mongrel2Adapter::ZMQDriver do
      before :each  do
        @driver = SMQueue::Adapter::Mongrel2Adapter::ZMQDriver.new
      end

      it "uses a ZMQ::Context as the context" do
        ctx = @driver.send(:context)
        ctx.should be_kind_of(ZMQ::Context)
      end

      it "can provide upstream sockets" do
        @driver.should respond_to(:upstream)
      end

      describe "upstream sockets" do
        it "asks the context for an upstream socket" do
          ctx = ZMQ::Context.new(1)
          @driver.stubs(:context).returns(ctx)
          ctx.expects(:socket).with(ZMQ::UPSTREAM).once.returns(stub_everything('Socket'))
          @driver.upstream("tcp://foo:1234")
        end

        it "connects the upstream socket to the requested address" do
          ctx = ZMQ::Context.new(1)
          @driver.stubs(:context).returns(ctx)
          socket = stub_everything('Socket')
          ctx.expects(:socket).with(ZMQ::UPSTREAM).once.returns(socket)
          socket.expects(:connect).with("tcp://foo:1234").once
          @driver.upstream("tcp://foo:1234")
        end
      end
    end

    it "allows setting the driver implementation" do
      other_driver = stub_everything('Other Driver')

      channel_class = SMQueue::Adapter::Mongrel2Adapter::Mongrel2RequestChannel
      channel_class.expects(:new).once.with(:driver => other_driver)
      m2 = SMQueue::Adapter::Mongrel2Adapter.new :driver => other_driver
      m2.channel 'request'

      channel_class = SMQueue::Adapter::Mongrel2Adapter::Mongrel2ResponseChannel
      channel_class.expects(:new).once.with(:driver => other_driver)
      m2 = SMQueue::Adapter::Mongrel2Adapter.new :driver => other_driver
      m2.channel 'response'
    end

    describe "accessing an invalid channel" do
      it "should freak out with a nice error message" do
        message = "The channel_name must be 'request' or 'response'."
        lambda {
          adapter_instance.channel 'ducks'
        }.should raise_exception message
      end
    end

    describe "request channel" do
      let(:channel) { adapter_instance.channel 'request' }
      it_should_behave_like "an adapter channel"

      it "allows us to check the driver being used" do
        driver = stub_everything('Some Driver')
        channel_class = SMQueue::Adapter::Mongrel2Adapter::Mongrel2RequestChannel
        instance = channel_class.new :driver => driver
        instance.driver.should be(driver)
      end

      it "freaks out when you try to put a message" do
        message = "You can't put messages on the request channel"
        lambda { channel.put :foo, :bar }.should raise_exception message
      end

      describe "getting a message" do
        before :each  do
          @driver = stub_everything('Driver')
          adapter_options = { :driver => @driver, :host => "test.host",
                              :port => 1234 }
          @m2 = SMQueue::Adapter::Mongrel2Adapter.new adapter_options
        end

        it "asks the driver for an upstream socket to the specified host and port on the first message" do
          @driver.expects(:upstream).with("tcp://test.host:1234").once.returns(stub_everything('Upstream Socket'))
          request = @m2.channel 'request'
          request.get
        end

        it "does not request a connection for subsequent messages" do
          @driver.expects(:upstream).with("tcp://test.host:1234").once.returns(stub_everything('Upstream Socket'))
          request = @m2.channel 'request'
          2.times { request.get }
        end

        it "asks for messages from the socket" do
          socket = stub_everything('Upstream Socket')
          socket.expects(:recv_string).with(0).once
          @driver.stubs(:upstream).returns(socket)
          request = @m2.channel 'request'
          request.get
        end

        it "returns messages in [ header, body ] format" do
          socket = stub_everything('Upstream Socket')
          socket.stubs(:recv_string).returns('f0e45140-94eb-012d-a37f-34159e1f5aec 1 /foo/bar 15:{"X-Test":true},9:TEST BODY,')
          @driver.stubs(:upstream).returns(socket)
          request = @m2.channel 'request'
          expected_headers = {
            'sender_id' => 'f0e45140-94eb-012d-a37f-34159e1f5aec',
            'client_id' => 1,
            'path' => '/foo/bar',
            'headers' => {
              'X-Test' => true
            }
          }
          request.get.should == [ expected_headers, 'TEST BODY' ]
        end

        after :each  do
          @m2 = nil
          @driver = nil
        end
      end
    end

    describe "response channel" do
      let(:channel) { adapter_instance.channel 'response' }
      it_should_behave_like "an adapter channel"

      it "allows us to check the driver being used" do
        driver = stub_everything('Some Driver')
        channel_class = SMQueue::Adapter::Mongrel2Adapter::Mongrel2ResponseChannel
        instance = channel_class.new :driver => driver
        instance.driver.should be(driver)
      end

      it "freaks out when you try to get a message" do
        message = "You can't get messages from the response channel"
        lambda { channel.get }.should raise_exception message
      end

      after :each  do
        @channel = nil
      end
    end
  end
end