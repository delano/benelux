
group "Benelux"

library :benelux, 'lib'



tryouts "Essentials" do
  
  setup do
    class ::Sleeper
      def   do_something()  sleep rand/3 end
      def another_method(t) t*2          end 
    end
  end
  
  drill "Add timers to existing objects", true do
    Benelux.add_timer Sleeper, :do_something
    Benelux.add_counter Sleeper, :another_method
    Sleeper.new.respond_to? :timeline
  end
  
  dream :class, SelectableArray
  dream :size, 2
  dream :proc, lambda { |obj|
    pm = obj.first
    pm.class == Benelux::MethodTimer && 
    pm.meth == :do_something &&
    pm.klass == Sleeper
  }
  drill "Keeps a list of modified methods" do
    Benelux.packed_methods
  end
  
  drill "Knows what a timer has been defined", true do
    Benelux.timed_method? :Sleeper, :do_something
  end
  
  drill "Knows what a timer has not been defined", false do
    Benelux.timed_method? :Sleeper, :no_such_method
  end
  
  dream [1,1]
  drill "Knows there's one timer and one counter" do
    [Benelux.timed_methods.size, Benelux.counted_methods.size]
  end
  
  dream :class, SelectableArray
  xdrill "A Benelux object has a timed_methods method" do
    Sleeper.new.timed_methods
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