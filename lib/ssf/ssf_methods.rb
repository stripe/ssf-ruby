require 'socket'

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

      @client.send_to_socket(self)
    end

    def child_span(operation: '', tags: {})
      puts "WARN: this method is deprecated."
      span_id = SecureRandom.random_number(2**32 - 1)
      trace_id = self.trace_id
      start = Time.now.to_f * 1_000_000_000
      service = self.service
      operation = operation
      new_tags = {}
      self.tags.each do |key, value|
        if key != 'name'
          new_tags[key] = value
        end
      end

      new_tags = Ssf::SSFSpan.clean_tags(tags.merge(new_tags))

      parent = self.id

      span = Ssf::SSFSpan.new({
        id: span_id,
        trace_id: trace_id,
        start_timestamp: start,
        service: service,
        operation: operation,
        tags: new_tags,
        parent_id: parent
      })
      span.client = self.client
      span
    end

    def set_name(name)
      self.tags['name'] = name
    end

    def set_tag(name, value)
      if name.nil?
        return
      end
      self.tags[name.to_s] = value.to_s
    end

    def set_tags(tags)
      if tags.is_a?(Hash)
        tags.map do |k, v|
          self.set_tag(k, v)
        end
      end
    end

    def self.clean_tags(tags)
      tmp = {}
      tags.map do |k, v|
        if v && k != 'name'
          tmp[k.to_s] = v.to_s
        end
      end
      tmp
    end
  end
end
