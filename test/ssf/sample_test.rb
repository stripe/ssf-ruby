require 'test/unit'
require 'ssf/sample_pb.rb'

module SSFTest
  class ChargeTest < Test::Unit::TestCase

    def test_create_ssf
      print("asdasdfasd")
      s = Ssf::SSFSample.new({
        id: 123456,
      })
      assert(s.id == 123456, "id doesn't match")
    end
  end
end
