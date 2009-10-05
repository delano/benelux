

module Benelux
  class Track
    attr_reader :name
    attr_reader :thread_group
    attr_reader :timeline
    def initialize(n,g=nil)
      @name, @thgrp = n, (g || ThreadGroup.new)
      @timeline = Benelux::Timeline.new
    end
    def add_thread(t=Thread.current)
      @thgrp.add t
      t
    end
    def threads
      @thgrp.list
    end
  end
end