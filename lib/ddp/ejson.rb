require 'json'

module DDP
	# EJSON is a way of embedding more than the built-in JSON types in JSON.
	# It supports all types built into JSON as plain JSON, plus some custom
	# types identified by a key prefixed with '$'.
	class EJSON
		def self.parse(string)
			JSON.parse string
		end

		def self.generate(object)
			JSON.generate as_ejson(object)
		end

		def as_ejson(object)
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
	end
end

# Builtin EJSON types:
class Time
	def as_ejson
		# milliseconds since epoch
		{ '$date' => (to_f * 1000).to_i }
	end
end
