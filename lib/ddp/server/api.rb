module DDP
	module Server
		# Helper class that users can extend to implement an API that can be passed
		# as the RPC API parameter to the RethinkDB DDP protocol
		class API
			def initialize
				setup_rpc
				setup_collections
			end

			def invoke_rpc(method, *params)
				raise 'No such method' unless @rpc_methods.include? method
				send(method, *params)
			end

			def collection_query(name, *params)
				raise 'No such collection' unless @collections.include? name
				wrap_query(send(name, *params))
			end

			# Implementors must override wrap_query. The argument is a query that is to be executed
			# the result should be a proc that yields data values to its block parameter.
			def wrap_query(query)
				raise 'implement wrap query'
			end

			private

			def setup_rpc
				rpc_module = self.class.const_get :RPC
				@rpc_methods = rpc_module.instance_methods.map(&:to_s)
				singleton_class.include rpc_module
			end

			def setup_collections
				collections_module = self.class.const_get :Collections
				@collections = collections_module.instance_methods.map(&:to_s)
				singleton_class.include collections_module
			end
		end
	end
end
