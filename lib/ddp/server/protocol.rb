require 'ddp/server/protocol/heartbeat'
require 'ddp/server/protocol/data'
require 'ddp/server/protocol/rpc'

module DDP
	module Server
		# Implementation of the DDP protocol
		# Can be included into any class that has
		# an on_open, a read_message and a write_message method
		module Protocol
			include Heartbeat
			include Data
			include RPC

			DDP_VERSION = '1'

			attr_accessor :session_id

			def new_session_id
				SecureRandom.hex
			end

			def handle_connect
				message = read_message

				if message['msg'] == 'connect' && message['version'] == DDP_VERSION
					handle_session(message)
				else
					write_message('msg' => 'failed', 'version' => DDP_VERSION)
					close
				end
			end

			def handle_session(message)
				@session_id = message['session'] || new_session_id

				write_message('msg' => 'connected', 'session' => session_id)

				handle_established
			end

			def handle_established
				loop do
					@message = read_message

					next if handle_heartbeat
					next if handle_data
					next if handle_rpc
					break
				end

				close
			end
		end
	end
end
