# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# Note: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rsspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separetly)
#  * 'just' rspec: 'rspec'
guard :rspec, cmd: 'bundle exec rspec -c' do
	watch(/^spec\/.+_spec\.rb$/) { 'spec' }
	watch(/^lib\/.+\.rb$/) { 'spec' }
	watch('spec/spec_helper.rb') { 'spec' }
end

guard :rubocop do
	watch(/.+\.rb$/)
	watch(/(?:.+\/)?\.rubocop\.yml$/) { |m| File.dirname(m[0]) }
end

guard 'cucumber' do
	watch(/^features\/.+\.feature$/)
	watch(%r{^features\/support\/.+$})          { 'features' }

	watch(%r{^features/step_definitions/(.+)_steps\.rb$}) do |m|
		Dir[File.join("**/#{m[1]}.feature")][0] || 'features'
	end
end
