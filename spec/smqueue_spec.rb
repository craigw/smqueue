require 'spec_helper'

describe SMQueue do
  it "is version 1.0.0" do
    SMQueue::VERSION.should eql('1.0.0')
  end
end