require 'spec_helper'
require 'smqueue/adapter/mongrel2_adapter'
require 'support/behaviour/adapter'

describe SMQueue::Adapter::Mongrel2Adapter do
  it_should_behave_like "an adapter class"

  describe "instance" do
    let(:adapter_instance) { SMQueue::Adapter::Mongrel2Adapter.new }
    it_should_behave_like "an adapter instance"

    describe "accessing an invalid channel" do
      before(:each) do
        protocol = stub_everything('Protocol')
        channel_class = SMQueue::Adapter::Mongrel2Adapter::Mongrel2RequestChannel
        channel_class.stubs(:new).returns(:protocol => protocol)
        @m2 = SMQueue::Adapter::Mongrel2Adapter.new
      end

      it "should freak out with a nice error message" do
        message = "The channel_name must be 'request' or 'response'."
        lambda { @m2.channel 'ducks' }.should raise_exception message
      end
    end

    describe "accessing the request channel" do
      let(:channel) {
        protocol = stub_everything('Protocol')
        channel_class = SMQueue::Adapter::Mongrel2Adapter::Mongrel2RequestChannel
        instance = channel_class.new(:protocol => protocol)
        channel_class.stubs(:new).returns(instance)
        m2 = SMQueue::Adapter::Mongrel2Adapter.new
        m2.channel 'request'
      }
      it_should_behave_like "an adapter channel"

      it "allows setting the protocol implementation" do
        protocol = stub_everything('Other Protocol Implementation')
        channel_class = SMQueue::Adapter::Mongrel2Adapter::Mongrel2RequestChannel
        channel_class.expects(:new).once.with(:protocol => protocol)
        m2 = SMQueue::Adapter::Mongrel2Adapter.new :protocol => protocol
        m2.channel 'request'
      end

      it "freaks out when you try to put a message" do
        message = "You can't put messages on the request channel"
        lambda { channel.put :foo, :bar }.should raise_exception message
      end
    end

    describe "accessing the response channel" do
      let(:channel) {
        protocol = stub_everything('Protocol')
        channel_class = SMQueue::Adapter::Mongrel2Adapter::Mongrel2ResponseChannel
        instance = channel_class.new(:protocol => protocol)
        channel_class.stubs(:new).returns(instance)
        m2 = SMQueue::Adapter::Mongrel2Adapter.new
        m2.channel 'response'
      }
      it_should_behave_like "an adapter channel"

      it "allows setting the protocol implementation" do
        protocol = stub_everything('Other Protocol Implementation')
        channel_class = SMQueue::Adapter::Mongrel2Adapter::Mongrel2ResponseChannel
        channel_class.expects(:new).once.with(:protocol => protocol)
        m2 = SMQueue::Adapter::Mongrel2Adapter.new :protocol => protocol
        m2.channel 'response'
      end

      it "freaks out when you try to get a message" do
        message = "You can't get messages from the response channel"
        lambda { channel.get }.should raise_exception message
      end

      after(:each) do
        @channel = nil
      end
    end
  end
end