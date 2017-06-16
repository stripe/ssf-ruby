module Ssf
  class SSFSpan

    attr_accessor :client

    def finish(time: nil)
      unless time
        time = Time.now.to_f * 1_000_000_000
      end
      self.end_timestamp = time.to_i

      name = self.tags['name']
      if name == nil || name == ''
        name = caller_locations(1,1)[0].label
        set_name(name)
      end

      packet = Ssf::SSFSpan.encode(self)

      @client.send_to_socket(packet)
      self
    end

    def child_span(operation: '', tags: {})
      span_id = SecureRandom.random_number(2**32 - 1)
      trace_id = self.trace_id
      start = Time.now.to_f * 1_000_000_000
      service = self.service
      operation = operation
      # puts self.tags
      # keys = (tags.keys & self.tags.keys)
      # tags = Hash[keys.zip(self.tags.values_at(*keys))]
      tags = tags
      parent = self.id

      span = Ssf::SSFSpan.new({
        id: span_id,
        trace_id: trace_id,
        start_timestamp: start,
        service: service,
        operation: operation,
        tags: tags,
        parent_id: parent,
      })
      span.client = self.client
      span
    end

    def set_name(name)
      self.tags['name'] = name
    end
  end
end
