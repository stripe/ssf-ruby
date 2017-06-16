require 'test/unit'
require 'ssf'
require 'securerandom'

module SSFTest
  class SSFClientTest < Test::Unit::TestCase

    def test_create_ssf
      s = Ssf::SSFSpan.new({
        id: 123456,
      })
      assert(s.id == 123456, "id doesn't match")
    end

    def test_encode_ssf
      s = Ssf::SSFSpan.new({
        id: 123456,
      })

      message = Ssf::SSFSpan.encode(s)

      s2 = Ssf::SSFSpan.decode(message)

      assert(s.id == s2.id)
    end

    def test_client_send
      s = Ssf::SSFSpan.new({
        id: 123456,
      })

      c = SSF::Client.new(host: '127.0.01', port: '8128')
      c.send_to_socket(Ssf::SSFSpan.encode(s))
    end

    def test_full_client_send
      c = SSF::Client.new(host: '127.0.01', port: '8128', service: 'test-srv')
      span = c.start_span(operation: 'run test')
      span.finish

      assert(span.end_timestamp > span.start_timestamp)
      assert(span.service == 'test-srv')
    end
  end
end
