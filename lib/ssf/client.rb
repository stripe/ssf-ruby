require 'socket'

module SSF
  class Client

    DEFAULT_HOST = '127.0.0.1'
    DEFAULT_PORT = 8200

    attr_reader :host
    attr_reader :port

    def initialize(host = DEFAULT_HOST, port = DEFAULT_PORT, opts = {}, max_buffer_size=50)
      self.host, self.port = host, port
      @socket = connect_to_socket(host, port)
    end

    def connect_to_socket(host, port)
      socket = UDPSocket.new
      socket.connect(host, port)
      socket
    end

    def send_to_socket(message)
      @socket.send(message)
    end
  end
end
