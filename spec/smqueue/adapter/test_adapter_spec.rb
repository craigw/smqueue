require 'spec_helper'
require 'smqueue/adapter/test_adapter'
require 'support/behaviour/adapter'

describe SMQueue::Adapter::TestAdapter do
  it_should_behave_like "an adapter"
end
