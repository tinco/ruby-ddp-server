require 'simplecov'
SimpleCov.start

require 'ddp-server'

RSpec.configure do |config|
	config.before(:all) do
		# nothing yet
	end
	config.before(:each) do
		# nothing yet
	end
	config.after(:all) {}
	config.after(:each) {}
end
