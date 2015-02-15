module DDP
	module Server
		module Protocol
			# Protocol regarding remote procedure calls
			module RPC
				def handle_rpc
					case @message['msg']
					when 'method'
						handle_method
						true
					else
						false
					end
				end

				def handle_method
					raise 'Must be overridden'
				end

				def result(id, result = nil)
					message = { msg: 'result', id: id }
					if result
						if result['error']
							message['error'] = result
						else
							message['result'] = result
						end
					end
					write_message(message)
				end

				def updated(methods)
					write_message msg: 'updated', methods: methods
				end
			end
		end
	end
end
