require 'spec_helper'
require 'smqueue/adapter/test_adapter'
require 'support/behaviour/adapter'

describe SMQueue::Adapter::TestAdapter do
  it_should_behave_like "an adapter class"

  describe "instance" do
    let(:adapter_instance) { SMQueue::Adapter::TestAdapter.new }
    it_should_behave_like "an adapter instance"

    it "allows altering the channel class" do
      adapter_instance.should respond_to(:channel_class=)
      channel_class = stub_everything('Test Channel Class')
      adapter_instance.channel_class = channel_class
      adapter_instance.channel_class.should be(channel_class)
    end

    describe "accessing a channel" do
      describe "when a channel_class is set" do
        it "returns an instance of channel_class for the channel name" do
          channel_name = '/test'
          instance = stub_everything('Test Channel Instance')
          klass = stub_everything('Test Channel Class')
          klass.expects(:new).with(channel_name).once.returns(instance)
          adapter_instance.channel_class = klass
          channel = adapter_instance.channel channel_name
          channel.should be(instance)
        end
      end

      describe "when a channel_class is not set" do
        it "should use TestChannel as the channel_class" do
          test_channel = SMQueue::Adapter::TestAdapter::TestChannel
          adapter_instance.channel_class.should be(test_channel)
        end

        it "returns an instance of TestChannel for the channel name" do
          channel_name = '/test2'
          adapter_instance.channel channel_name
        end
      end
    end
  end
end
