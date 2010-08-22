require 'spec_helper'

describe SMQueue do
  it "is version 1.0.0" do
    SMQueue::VERSION.should eql('1.0.0')
  end

  describe "being instantiated" do
    describe "with a broker URI" do
      it "looks up the correct adapter" do
        broker = SMQueue.new "test"
        test_adapter = SMQueue::Adapter::TestAdapter
        broker.adapter.should be_instance_of(test_adapter)
      end

      it "passes the options given in the broker uri to the adapter" do
        options = "username:password@example.com:61613"
        SMQueue::Adapter::TestAdapter.expects(:new).once.with(options)
        SMQueue.new "test://#{options}"
      end
    end

    describe "without a broker URI" do
      it "does not set the adapter" do
        SMQueue.new.adapter.should be_nil
      end
    end
  end

  describe "instance" do
    before(:each) do
      @broker = SMQueue.new
    end

    it "provides a way of setting the broker adapter" do
      @broker.should respond_to(:adapter=)
    end

    it "provides a way of getting the broker adapter" do
      @broker.should respond_to(:adapter)
    end

    describe "opening a channel" do
      describe "if no adapter has been set" do
        it "raises an exception with a useful error message" do
          connecting = lambda { @broker.channel "/test" }
          message = "You must select an Adapter before connecting"
          connecting.should raise_exception(message)
        end
      end

      describe "when an adapter has been set" do
        before(:each) do
          @adapter = stub_everything('Test Adapter')
          @broker.adapter = @adapter
        end

        it "asks the adapter for the channel" do
          @adapter.expects(:channel).once.with("/test")
          @broker.channel "/test"
        end

        after(:each) do
          @adapter = nil
        end
      end
    end

    after(:each) do
      @broker = nil
    end
  end
end