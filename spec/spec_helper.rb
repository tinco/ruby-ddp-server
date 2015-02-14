require 'simplecov'
SimpleCov.start

require 'bundler/setup'

def make_sockets
	host = '127.0.0.1'
	port = 10_151

	server = TCPServer.new(host, port)
	client = TCPSocket.new(host, port)
	peer   = server.accept

	[server, client, peer]
end

# def with_socket_pair
# 	server, client, peer = make_sockets

# 	begin
# 		yield client, peer
# 	ensure
# 		server.close rescue nil
# 		client.close rescue nil
# 		peer.close   rescue nil
# 	end
# end

def example_host
	'www.example.com'
end

def example_path
	'/example'
end

def example_url
	"ws://#{example_host}#{example_path}"
end

def handshake_headers
	{
		'Host'                   => example_host,
		'Upgrade'                => 'websocket',
		'Connection'             => 'Upgrade',
		'Sec-WebSocket-Key'      => 'dGhlIHNhbXBsZSBub25jZQ==',
		'Origin'                 => 'http://example.com',
		'Sec-WebSocket-Protocol' => 'chat, superchat',
		'Sec-WebSocket-Version'  => '13'
	}
end

def handshake
	WebSocket::ClientHandshake.new(:get, example_url, handshake_headers)
end

def with_websocket_pair
	with_socket_pair do |client, peer|
		connection = Reel::Connection.new(peer)
		client << handshake.to_data
		request = connection.request

		websocket = request.websocket

		# Discard handshake
		client.readpartial(4096)

		yield client, websocket
	end
end

RSpec.configure do |config|
	config.before(:all) do
		# nothing yet
	end
	config.before(:each) do
		# nothing yet
	end
	config.after(:all) {}
	config.after(:each) {}
end
