
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
    Sleeper.new.respond_to? :timeline
  end
  
  dream :class, SelectableArray
  dream :size, 1
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
  
  dream :class, SelectableArray
  drill "A Benelux object has a timed_methods method" do
    s = Sleeper.new
    s.do_something
    s.timed_methods
  end

end

tryouts "Counters" do
  setup do
    class ::Sleeper
      def   do_something()  sleep rand/3 end
      def another_method(t) t*2          end 
    end
  end
  drill "Add timers to existing objects", true do
    Benelux.add_counter Sleeper, :another_method do |args,ret|
      ret
    end
    Sleeper.new.respond_to? :timeline
  end
  dream :kind_of?, Benelux::MethodPacker
  drill "Can get specific packed method" do
    Benelux.packed_method Sleeper, :another_method
  end
  
  dream :class, Benelux::Count
  dream :name, :another_method
  dream :to_i, 2000
  drill "Run counter" do
    a = Sleeper.new
    a.another_method(1000)
    pm = Benelux.packed_method Sleeper, :another_method
    Benelux.thread_timeline.counts.first
  end
end

xtryouts "Not supported" do
  
  dream :exception, Benelux::NotSupported
  drill "Class is not supported" do
    Benelux.add_timer Class, :new
  end
  
end