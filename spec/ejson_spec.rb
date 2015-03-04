require 'spec_helper'
require 'ddp/ejson'
require 'json'
require 'base64'

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

			it 'parses an escaped ejson' do
				example = { '$escape' => { '$date' => 'a' } }
				ejson = JSON.generate(example)
				expect(EJSON.parse(ejson)).to eq('$date' => 'a')
			end

			it 'parses a date ejson' do
				time = Time.now
				ms_since_epoch = (time.to_f * 1000).to_i
				example = { 'date' => { '$date' => ms_since_epoch } }
				ejson = JSON.generate(example)
				expect(EJSON.parse(ejson)['date'].to_s).to eq(time.to_s)
			end

			it 'parses a binary ejson' do
				example = { '$binary' => Base64.encode64('Hello World') }
				ejson = JSON.generate(example)
				expect(EJSON.parse(ejson)).to eq('Hello World')
			end

			it 'parses custom types' do
				# Test class
				class A
					extend EJSON::Serializable

					ejson_type_name 'A'

					def as_ejson
						{ '$type' => 'A', '$value' => '1234' }
					end

					def self.from_ejson(object)
						object.to_i
					end
				end

				ejson = EJSON.generate(A.new)
				expect(EJSON.parse(ejson)).to eq(1234)
			end

			it 'raises an exception when parsing an unknown type' do
				ejson = JSON.generate('$type' => 'B', '$value' => '1234')
				expect do
					EJSON.parse(ejson)
				end.to raise_error(EJSON::UnknownTypeError)
			end

			it 'raises an exception when a serializable class does not override from_ejson' do
				expect do
					# Test class
					class C
						extend EJSON::Serializable
					end

					C.from_ejson(false)
				end.to raise_error(EJSON::InvalidSerializableClassError)
			end
		end
	end
end
