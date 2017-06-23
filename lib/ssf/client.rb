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

    def new_root_span(operation: '', tags: {})
      span_id = SecureRandom.random_number(2**32 - 1)
      trace_id = span_id
      start = Time.now.to_f * 1_000_000_000
      service = @service
      operation = operation
      tags = tags

      span = Ssf::SSFSpan.new({
        id: span_id,
        trace_id: trace_id,
        start_timestamp: start,
        service: service,
        operation: operation,
        tags: tags,
      })
      span.client = self
      span
    end

    def start_span(operation: '', tags: {}, parent: -1)
      span_id = SecureRandom.random_number(2**32 - 1)
      trace_id = span_id
      start = Time.now.to_f * 1_000_000_000
      service = @service
      operation = operation
      tags = tags

      span = Ssf::SSFSpan.new({
        id: span_id,
        trace_id: trace_id,
        start_timestamp: start,
        service: service,
        operation: operation,
        tags: tags,
      })
      span.client = self
      if parent != -1
        span.parent_id = parent
      end
      span
    end

    def span_from_context(operation: '', tags: {}, trace_id: -1, parent_id: -1)
      span_id = SecureRandom.random_number(2**32 - 1)
      trace_id = trace_id
      start = Time.now.to_f * 1_000_000_000
      service = @service
      operation = operation
      tags = tags

      tags = Ssf::SSFSpan.clean_tags(tags)

      span = Ssf::SSFSpan.new({
        id: span_id,
        trace_id: trace_id,
        start_timestamp: start,
        service: service,
        operation: operation,
        tags: tags,
        parent_id: parent_id,
      })
      span.client = self
      span
    end
  end
end
