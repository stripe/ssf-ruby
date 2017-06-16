require 'socket'

module SSF
  class Client

    DEFAULT_HOST = '127.0.0.1'
    DEFAULT_PORT = 8128

    attr_reader :host
    attr_reader :port

    attr_reader :service

    def initialize(host: DEFAULT_HOST, port: DEFAULT_PORT, service: '', max_buffer_size: 50)
      @host, @port = host, port
      @service = service
      @socket = connect_to_socket(host, port)
    end

    def connect_to_socket(host, port)
      socket = UDPSocket.new
      socket.connect(host, port)
      socket
    end

    def send_to_socket(message)
      @socket.send(message, 0)
    end

    def start_span(service: '', operation: '', tags: {})
      span_id = SecureRandom.random_number(2**32 - 1)
      trace_id = span_id
      start = Time.now.to_f * 1_000_000_000
      service = @service
      operation = operation
      tags = tags

      Ssf::SSFSpan.new({
        id: span_id,
        trace_id: trace_id,
        start_timestamp: start,
        service: service,
        operation: operation,
        tags: tags,
      })
    end
  end
end
