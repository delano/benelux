require 'profiler'
group "Benelux"

library :benelux, 'lib'

tryouts "Basics" do
  
  setup do
    class ::Sleeper
      def do_something() sleep rand/3 end
    end
  end
  
  drill "Add timers to existing objects", true do
    Benelux.add_timer Sleeper, :do_something
    Sleeper.new.respond_to? :timeline
  end
  
  dream :class, Array
  #dream { Hash[ Sleeper => [Benelux::MethodTimer.new(Sleeper, :do_something)] ] }
  drill "Benelux keeps track of packed objects" do
    Benelux.packed_methods
  end
  
  dream [:do_something]
  xdrill "A Benelux object has a benelux_timers method" do
    Sleeper.new.benelux_timers
  end
  
  dream :class, Benelux::Timeline
  dream :size, 10 # 5 * 2 = 10 (marks are stored for the method start and end)
  xdrill "Creates a timeline" do
    sleeper = Sleeper.new
    5.times { sleeper.do_something }
    sleeper.timeline
  end
  
  dream :size, 4
  xdrill "Timelines are stored per object" do
    sleeper = Sleeper.new
    Thread.new do
      2.times { sleeper.do_something }
    end.join
    sleeper.timeline
  end
  
  dream :class, Benelux::Timeline
  dream :size, 10
  xdrill "Creates a timeline for the thread" do
    Benelux.thread_timeline
  end
  
  dream :class, Benelux::Timeline
  dream :size, 14
  xdrill "Creates a global timeline" do
    Benelux.timeline
  end
  
end


tryouts "Not supported" do
  
  dream :exception, Benelux::NotSupported
  drill "Class is not supported" do
    Benelux.add_timer Class, :new
  end
  
end