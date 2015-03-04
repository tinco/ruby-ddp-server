require 'spec_helper'
require 'ddp/ejson'
require 'json'

# Tests in DDP Module
module DDP
	describe EJSON do
		describe 'generate' do
			it 'generates normal json for simple structures' do
				[
					{ 'a' => 'b' },
					['a'],
					{ 'a' => [1] }
				].each do |example|
					expect(EJSON.generate(example)).to eq(JSON.generate(example))
				end
			end

			it 'escapes keys that start with a dollar sign' do
				example = { '$bla' => 'value' }
				ejson = EJSON.generate(example)
				expect(JSON.parse(ejson)['$escape']).to eq('$bla' => 'value')
			end

			it 'generates a special type for dates' do
				time = Time.now
				ms_since_epoch = (time.to_f * 1000).to_i
				ejson = EJSON.generate('date' => time)
				expect(JSON.parse(ejson)['date']).to eq('$date' => ms_since_epoch)
			end
		end

		describe 'parse' do
			it 'parses generic json' do
				[
					{ 'a' => 'b' },
					['a'],
					{ 'a' => [1] }
				].each do |example|
					json = JSON.generate(example)
					expect(EJSON.parse(json)).to eq(example)
				end
			end

			it 'parses a date ejson' do
				time = Time.now
				ms_since_epoch = (time.to_f * 1000).to_i
				example = { 'date' => { '$date' => ms_since_epoch } }
				ejson = JSON.generate(example)
				expect(EJSON.parse(ejson)['date'].to_s).to eq(time.to_s)
			end
		end
	end
end
