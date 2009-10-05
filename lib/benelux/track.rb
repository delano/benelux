

module Benelux
  class Track
    attr_reader :name
    attr_reader :thread_group
    attr_reader :timeline
    def initialize(n)
      @name, @thread_group = n, ThreadGroup.new
      @timeline = Benelux::Timeline.new
    end
    def add_thread(t=Thread.current)
      @thread_group.add t
    end
  end
end