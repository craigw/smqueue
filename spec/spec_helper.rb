require 'bundler'
Bundler.setup
require 'smqueue'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end