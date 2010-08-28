require 'spec_helper'
require 'smqueue/adapter/mongrel2_adapter'
require 'support/behaviour/adapter'

describe SMQueue::Adapter::Mongrel2Adapter do
  it_should_behave_like "an adapter class"

  describe "instance" do
    let(:adapter_instance) {
      protocol = stub_everything('Protocol')
      SMQueue::Adapter::Mongrel2Adapter.new :protocol => protocol
    }
    it_should_behave_like "an adapter instance"

    it "allows setting the protocol implementation" do
      protocol = stub_everything('Other Protocol Implementation')
      channel_class = SMQueue::Adapter::Mongrel2Adapter::Mongrel2RequestChannel
      channel_class.expects(:new).once.with(:protocol => protocol)
      m2 = SMQueue::Adapter::Mongrel2Adapter.new :protocol => protocol
      m2.channel 'request'

      channel_class = SMQueue::Adapter::Mongrel2Adapter::Mongrel2ResponseChannel
      channel_class.expects(:new).once.with(:protocol => protocol)
      m2 = SMQueue::Adapter::Mongrel2Adapter.new :protocol => protocol
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

    describe "accessing the request channel" do
      let(:channel) { adapter_instance.channel 'request' }
      it_should_behave_like "an adapter channel"

      it "freaks out when you try to put a message" do
        message = "You can't put messages on the request channel"
        lambda { channel.put :foo, :bar }.should raise_exception message
      end
    end

    describe "accessing the response channel" do
      let(:channel) { adapter_instance.channel 'response' }
      it_should_behave_like "an adapter channel"

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