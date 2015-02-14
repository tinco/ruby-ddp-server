module DDP
	module Server
		module Protocol
			# Protocol regarding handling data subscriptions
			module Data
				def handle_data
					case @message['msg']
					when 'sub'
						handle_sub
						true
					when 'unsub'
						handle_unsub
						true
					else
						false
					end
				end

				def handle_sub
					raise 'Not Implemented'
				end

				def handle_unsub
					raise 'Not Implemented'
				end
			end
		end
	end
end
