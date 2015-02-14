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
					raise 'Not Implemented'
				end
			end
		end
	end
end
