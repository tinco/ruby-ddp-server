require 'ddp/server'

class APIClass
	def invoke_rpc(method, *args)
		case method
		when 'hello_world' then 'Hello world!'
		else
			raise 'Don\'t know that method'
		end
	end

	def collection_query(name, *args)
		lambda do |&on_update|
			5.times do |i|
				sleep 5
				on_update.({}, id: 1, message: "Message #{name}: #{i}")
			end
		end
	end
end

run DDP::Server::WebSocket.rack(APIClass)