require 'spec_helper'

describe SMQueue do
  it "is version 0.4.0-development" do
    SMQueue::VERSION.should eql('0.4.0-development')
  end
end