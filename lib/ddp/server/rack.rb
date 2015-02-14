require 'ddp/server/version'
require 'ddp/server/protocol'
require 'celluloid/websocket/rack'
require 'json'
require 'securerandom'

module DDP
	module Server
		# Rack middleware for running DDP
		class Rack < Celluloid::WebSocket::Rack
			include DDP::Server::Protocol

			def on_open
				handle_connect
			end

			def read_message
				JSON.parse read
			end

			def write_message(message)
				write JSON.generate(message)
			end
		end
	end
end
