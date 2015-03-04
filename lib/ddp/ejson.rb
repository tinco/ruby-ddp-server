require 'json'
require 'base64'

module DDP
	# EJSON is a way of embedding more than the built-in JSON types in JSON.
	# It supports all types built into JSON as plain JSON, plus some custom
	# types identified by a key prefixed with '$'.
	class EJSON
		def self.parse(string)
			parsed = JSON.parse string

			deserialize(parsed)
		end

		def self.generate(object)
			JSON.generate as_ejson(object)
		end

		def self.deserialize(object)
			if object.is_a? Hash
				deserialize_hash(object)
			elsif object.is_a? Array
				object.map { |e| deserialize(e) }
			else
				object
			end
		end

		def self.as_ejson(object)
			if object.respond_to? :as_ejson
				object.as_ejson
			elsif object.is_a? Hash
				hash_as_ejson(object)
			elsif object.is_a? Array
				object.map { |i| as_ejson(i) }
			else
				object
			end
		end

		# Hashes can contain keys that need to be escaped
		def self.hash_as_ejson(hash)
			result = hash.map do |k, v|
				if k.is_a?(String) && k[0] == '$'
					['$escape', { k => as_ejson(v) }]
				else
					[k, as_ejson(v)]
				end
			end
			Hash[result]
		end

		def self.deserialize_hash(hash)
			deserialize_operation(hash) || hash.map do |k, v|
				[k, deserialize(v)]
			end.to_h
		end

		def self.deserialize_operation(hash)
			if hash['$escape']
				return deserialize_escape(hash['$escape'])
			elsif hash['$date']
				return Time.at(hash['$date'] / 1000.0)
			elsif hash['$binary']
				return Base64.decode64(hash['$binary'])
			elsif hash['$type']
				return deserialize_type(hash)
			end
			false
		end

		def self.deserialize_escape(hash)
			hash.map do |k, v|
				[k, deserialize(v)]
			end.to_h
		end

		def self.deserialize_type(hash)
			klass = @classes[hash['$type']]
			if klass
				klass.from_ejson(hash['$value'])
			else
				raise UnknownTypeError, "Don't know how to deserialize #{hash['$type']}"
			end
		end

		def self.add_serializable_class(klass)
			@classes ||= {}
			@classes[klass.name] = klass
		end

		def self.rename_serializable_class(klass, name)
			@classes.delete(klass.name)
			@classes[name] = klass
		end

		# Classes can include this module to be picked up by the EJSON parser
		module Serializable
			def self.extended(klass)
				EJSON.add_serializable_class(klass)
			end

			def ejson_type_name(name)
				EJSON.rename_serializable_class(self, name)
			end

			def from_ejson(_object)
				raise InvalidSerializableClassError, "Class #{name} must override from_ejson."
			end
		end

		# Raised when parsing an unknown type
		class UnknownTypeError < StandardError
		end

		# Raised when serializable class does not implement from_ejson
		class InvalidSerializableClassError < StandardError
		end
	end
end

# Builtin EJSON types:
class Time
	def as_ejson
		# milliseconds since epoch
		{ '$date' => (to_f * 1000).to_i }
	end
end
