require 'pry'
module Ssf
  class SSFSpan
    def finish(time: nil)
      unless time
        time = Time.now.to_f * 1_000_000_000
      end
      self.end_timestamp = time.to_i
    end
  end
end
