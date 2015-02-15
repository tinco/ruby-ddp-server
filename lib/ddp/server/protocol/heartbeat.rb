module DDP
	module Server
		module Protocol
			# Protocol regarding heartbeat messages
			module Heartbeat
				def handle_heartbeat
					case @message['msg']
					when 'ping'
						write_message msg: 'pong', id: @message['id']
						true
					when 'pong'
						true
					else
						false
					end
				end
			end
		end
	end
end
