module SSF
  class LoggingClient < Client

    def connect_to_socket(host, port)
      nil
    end

    def send_to_socket(message)
      puts("would have sent #{message}")
    end
  end
end
