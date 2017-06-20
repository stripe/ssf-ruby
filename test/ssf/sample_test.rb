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
      span.finish()

      assert(span.end_timestamp > span.start_timestamp)
      assert_equal(name, 'test_full_client_send(SSFTest::SSFClientTest)')
      assert_equal(span.service, 'test-srv')
    end

    def test_parent_id
      c = SSF::Client.new(host: '127.0.0.1', port: '8128', service: 'test-srv')
      span = c.start_span(operation: 'run test', parent: 10)

      span.finish()

      assert(span.parent_id == 10)
    end

    def test_child_span
      c = SSF::Client.new(host: '127.0.0.1', port: '8128', service: 'test-srv')
      span = c.new_root_span(operation: 'op1', tags: {'tag1' => 'value1'})

      child1 = span.child_span(operation: 'op2', tags: {'tag2' => 'value2'})

      child1.finish()
      span.finish()

      span.tags.each do |key, value|
        if key != 'name'
          assert(child1.tags[key] != nil)
        end
      end

      assert(child1.parent_id == span.id)
      assert(child1.trace_id == span.trace_id)
    end
  end
end
