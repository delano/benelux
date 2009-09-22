
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
    Sleeper.new.respond_to? :benelux
  end
  
  dream :class, Hash
  dream { Hash[ Sleeper => [:do_something] ] }
  drill "Benelux keeps track of timed objects" do
    Benelux.timed_objects
  end
  
  dream [:do_something]
  drill "A Benelux object has a benelux_timers method" do
    Sleeper.new.benelux_timers
  end
  
  dream :class, Benelux::Timeline
  dream :size, 10 # 5 * 2 = 10 (marks are stored for the method start and end)
  drill "Creates a timeline" do
    sleeper = Sleeper.new
    5.times { sleeper.do_something }
    sleeper.timeline
  end
  
  dream :size, 4
  drill "Timelines are stored per object" do
    sleeper = Sleeper.new
    Thread.new do
      2.times { sleeper.do_something }
    end.join
    sleeper.timeline
  end
  
  dream :class, Benelux::Timeline
  dream :size, 10
  drill "Creates a timeline for the thread" do
    Benelux.thread_timeline
  end
  
  dream :class, Benelux::Timeline
  dream :size, 14
  drill "Creates a global timeline" do
    Benelux.timeline
  end
  
end


tryouts "Not supported" do
  
  dream :exception, Benelux::NotSupported
  drill "Class is not supported" do
    Benelux.add_timer Class, :new
  end
  
end