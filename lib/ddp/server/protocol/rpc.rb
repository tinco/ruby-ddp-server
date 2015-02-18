module DDP
	module Server
		module Protocol
			# Protocol regarding remote procedure calls
			module RPC
				NO_RESULT = Object.new

				def handle_rpc
					case @message['msg']
					when 'method'
						handle_method(@message['id'], @message['method'], @message['params'])
						true
					else
						false
					end
				end

				def handle_method(id, method, params)
					raise 'Must be overridden'
				end

				def send_result(id, result = NO_RESULT)
					message = { msg: 'result', id: id }
					message['result'] = result unless result == NO_RESULT
					write_message(message)
				end

				def send_error_result(id, error)
					message = { msg: 'result', id: id }
					message['error'] = { 
						error: error.class.name,
						reason: error.message,
						details: "Backtrace: \n#{error.backtrace.join("\n")}"
					}
					write_message(message)
				end

				def send_updated(methods)
					write_message msg: 'updated', methods: methods
				end
			end
		end
	end
end
