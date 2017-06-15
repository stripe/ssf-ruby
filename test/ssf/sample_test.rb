require 'test/unit'
require 'ssf'

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
  end
end
