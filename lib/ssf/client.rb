require 'socket'

module SSF
  class Client
    DEFAULT_HOST = '127.0.0.1'.freeze
    DEFAULT_PORT = 8128

    attr_reader :host
    attr_reader :port

    attr_reader :service

    def initialize(host: DEFAULT_HOST, port: DEFAULT_PORT, service: '', max_buffer_size: 50)
      @host = host
      @port = port
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

    def start_span(operation: '', tags: {}, trace_id: nil, parent_id: nil)
      span_id = SecureRandom.random_number(2**32 - 1)
      start = Time.now.to_f * 1_000_000_000
      # the trace_id is set to span_id for root spans
      span = Ssf::SSFSpan.new({
        id: span_id,
        trace_id: span_id,
        start_timestamp: start,
        service: @service,
        operation: operation,
        tags: Ssf::SSFSpan.clean_tags(tags)
        })
      span.client = self
      span.socket = @socket
      if trace_id != nil
        span.trace_id = trace_id
      end
      if parent_id != nil
        span.parent_id = parent_id
      end
      span
    end
  end
end
