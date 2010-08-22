shared_examples_for "an adapter class" do
  let(:adapter) { described_class }
end

shared_examples_for "an adapter instance" do
  it "provides access to channels" do
    adapter_instance.should respond_to(:channel)
  end

  describe "accessing a channel" do
    let(:channel) { adapter_instance.channel "/queue/test" }

    it "returns something that responds to get" do
      channel.should respond_to(:get)
    end

    it "returns something that responds to put" do
      channel.should respond_to(:put)
    end

    it "returns something that can be closed" do
      channel.should respond_to(:close)
    end
  end
end