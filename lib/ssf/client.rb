# frozen_string_literal: true
require 'socket'

module SSF
  class Client
    DEFAULT_HOST = '127.0.0.1'.freeze
    DEFAULT_PORT = 8128

    attr_reader :host
    attr_reader :port

    attr_reader :service
    attr_reader :socket

    def initialize(host: DEFAULT_HOST, port: DEFAULT_PORT, service: nil, max_buffer_size: 50)
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

    def send_to_socket(span)
      message = Ssf::SSFSpan.encode(span)

      begin
        # Despite UDP being connectionless, some implementations — including
        # ruby — will throw an exception if there's nothing listening. We will
        # rescue it to avoid any problems for our client.
        @socket.send(message, 0)
        true
      rescue StandardError
        false
      end
    end

    def start_span(name: '', tags: {}, parent: nil, indicator: false, override_service: nil)
      tags = Ssf::SSFSpan.clean_tags(tags)
      if parent
        start_span_from_context(
          name: name,
          tags: Hash[parent.tags].merge!(tags),
          trace_id: parent.trace_id,
          parent_id: parent.id,
          indicator: indicator,
          clean_tags: false,
          override_service: override_service
        )
      else
        start_span_from_context(
          name: name,
          tags: tags,
          indicator: indicator,
          clean_tags: false,
          override_service: override_service
        )
      end
    end

    def start_span_from_context(name: '', tags: {}, trace_id: nil, parent_id: nil, indicator: false, clean_tags: true, override_service: nil)
      span_service = override_service || @service
      unless span_service
        raise ArgumentError.new("You must either pass service to start_span_from_context or when you initialize the client")
      end

      span_id = SecureRandom.random_number(2**32 - 1)
      start = Time.now.to_f * 1_000_000_000
      # the trace_id is set to span_id for root spans
      span = Ssf::SSFSpan.new({
        id: span_id,
        trace_id: span_id,
        indicator: indicator,
        start_timestamp: start,
        service: span_service,
        name: name,
        tags: clean_tags ? Ssf::SSFSpan.clean_tags(tags) : tags,
      })
      span.client = self
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
