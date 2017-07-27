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

    def test_set_tag
      s = Ssf::SSFSpan.new({
        id: 123456,
      })
      s.set_tag('foo', 'bar')
      assert_equal(s.tags['foo'], 'bar')
    end

    def test_set_tags
      s = Ssf::SSFSpan.new({
        id: 123456,
      })
      s.set_tag('foo', 'bar')

      s.set_tags({
        'foo' => 'gorch',
        'fart' => 'eww',
      })
      assert_equal(s.tags['foo'], 'gorch')
      assert_equal(s.tags['fart'], 'eww')
    end

    def test_set_tags_with_symbols
      s = Ssf::SSFSpan.new({
        id: 123456,
      })
      # Make sure we stringify everything.
      assert_nothing_raised do
        s.set_tag(:foo, 'bar')
        assert_equal(s.tags['foo'], 'bar')
        s.set_tag('foo', :bar)
        assert_equal(s.tags['foo'], 'bar')
        s.set_tags({ foo: 'bar' })
        assert_equal(s.tags['foo'], 'bar')
        s.set_tags({ 'foo' => :bar })
        assert_equal(s.tags['foo'], 'bar')
      end
    end

    def test_set_tag_with_nils
      s = Ssf::SSFSpan.new({
        id: 123456,
      })
      # We need to ensure that if someone accidentally passes a nill we
      # don't blow up!
      assert_nothing_raised do
        s.set_tag(nil, nil)
        s.set_tags(nil)
      end

    end

    def test_client_send
      s = Ssf::SSFSpan.new({
        id: 123456,
      })

      c = SSF::LoggingClient.new(host: '127.0.01', port: '8128')
      c.send_to_socket(Ssf::SSFSpan.encode(s))
    end

    def test_full_client_send
      c = SSF::LoggingClient.new(host: '127.0.01', port: '8128', service: 'test-srv')
      span = c.start_span(operation: 'run test')
      span.finish

      assert(span.end_timestamp > span.start_timestamp)
      assert_equal(name, 'test_full_client_send(SSFTest::SSFClientTest)')
      assert_equal(span.service, 'test-srv')
    end

    def test_child_span
      c = SSF::LoggingClient.new(host: '127.0.0.1', port: '8128', service: 'test-srv')
      span = c.start_span(operation: 'op1', tags: {'tag1' => 'value1'})

      child1 = c.start_span(operation: 'op2', tags: {'tag2' => 'value2'}, parent: span)

      child1.finish
      span.finish

      span.tags.each do |key, value|
        if key != 'name'
          assert(child1.tags[key], "expected to find non-nil value for #{key}")
        end
      end

      assert(child1.parent_id == span.id)
      assert(child1.trace_id == span.trace_id)
    end

    def test_from_context
      c = SSF::LoggingClient.new(host: '127.0.0.1', port: '8128', service: 'test-srv')
      span = c.start_span_from_context(operation: 'op1',
                                tags: { 'tag1' => 'value1' },
                                trace_id: 5,
                                parent_id: 10)

      assert(span.trace_id == 5)
      assert(span.parent_id == 10)
    end


    def test_start_span_context_tags_nonstrings
      # we should be able to handle passing in keys and values for
      # 'tags' that are not strings without throwing an exception
      c = SSF::LoggingClient.new(host: '127.0.0.1', port: '8128', service: 'test-srv')

      tags = {
        :foo => :bar,
        'something' => nil,
        'a_number' => 5,
      }

      span = c.start_span(operation: 'op1',
                                tags: tags)

      assert_equal(span.tags['foo'], 'bar')
      assert_equal(span.tags['something'], nil)
      assert_equal(span.tags['a_number'], '5')
    end

    def test_child_span_tags_nonstrings
      # we should be able to handle passing in keys and values for
      # 'tags' that are not strings without throwing an exception
      c = SSF::LoggingClient.new(host: '127.0.0.1', port: '8128', service: 'test-srv')

      tags = {
        :foo => :bar,
        'something' => nil,
        'a_number' => 5,
      }

      span = c.start_span(operation: 'op1', tags: tags)
      span = c.start_span(operation: 'op2', tags: tags, parent: span)

      assert_equal(span.tags["foo"], "bar")
      assert_equal(span.tags["something"], nil)
      assert_equal(span.tags["a_number"], "5")
    end
  end
end
