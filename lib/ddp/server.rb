require 'ddp/server/version'
require 'celluloid/websocket/rack'
require 'json'
require 'securerandom'

module DDP
	# An implementation of the Meteor DDP protocol
	module Server
		# Rack middleware for running DDP
		class Rack < Celluloid::WebSocket::Rack
			DDP_VERSION = '1'

			attr_accessor :session_id

			def new_session_id
				SecureRandom.hex
			end

			def on_open
				read_connect
			end

			def read_message
				JSON.parse read
			end

			def read_connect
				message = JSON.parse read
				if message['msg'] == 'connect'
					handle_connect(message)
				else
					# let's just ignore that for now
					read_connect
				end
			end

			def handle_connect
				if message['version'] != DDP_VERSION
					write JSON.generate('msg' => 'failed', 'version' => DDP_VERSION)
					close
				else
					@session_id = message['session'] || new_session_id
					write JSON.generate('msg' => 'connected', 'session' => session_id)
					on_established
				end
			end

			def on_established
				message = read_message
				case message['msg']
				when 'ping'
					write('msg' => 'pong', 'id' => message['id'])
					# read entire protocol here
				end
			end
		end
	end
end
