require 'ddp/server/version'
require 'ddp/server/protocol'
require 'celluloid/websocket/rack'
require 'ddp/ejson'
require 'securerandom'

module DDP
	module Server
		# Server on top of a Celluloid::WebSocket
		class WebSocket < Celluloid::WebSocket
			include DDP::Server::Protocol

			attr_accessor :api, :subscriptions

			def initialize(api_class, config)
				@api = api_class.new(config)
				@subscriptions = {}
			end

			def on_open
				handle_connect
			end

			def read_message
				EJSON.parse read
			end

			def write_message(message)
				write EJSON.generate(message)
			end
		end
	end
end
