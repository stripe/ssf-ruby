module SSF
  class LocalBufferingClient < Client

    attr_reader :buffer

    def initialize(service: '')
      @buffer = []
      @service = service
    end

    def send_to_socket(message)
      @buffer << message
    end

    def reset
      @buffer.clear
    end
  end
end
