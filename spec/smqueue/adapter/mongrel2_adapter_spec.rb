require 'spec_helper'
require 'smqueue/adapter/mongrel2_adapter'
require 'support/behaviour/adapter'

describe SMQueue::Adapter::Mongrel2Adapter do
  it_should_behave_like "an adapter class"

  describe "instance" do
    let(:adapter_instance) { SMQueue::Adapter::Mongrel2Adapter.new }
    it_should_behave_like "an adapter instance"
  end
end