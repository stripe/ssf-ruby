module Ssf
  class SSFSpan

    attr_accessor :client

    def finish(time: nil)
      unless time
        time = Time.now.to_f * 1_000_000_000
      end
      self.end_timestamp = time.to_i

      packet = Ssf::SSFSpan.encode(self)

      @client.send_to_socket(packet)
      self
    end
  end
end
