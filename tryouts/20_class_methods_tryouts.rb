
group "Benelux"

library :benelux, 'lib'



xtryouts "Essentials" do
  
  setup do
    class ::Sleeper
      def   do_something()  sleep rand/3 end
      def another_method(t) t*2          end 
    end
  end
  
  drill "Add timers to existing objects", true do
    Benelux.add_timer Sleeper, :do_something
    Benelux.add_counter Sleeper, :another_method do 
      p 1
    end
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
  drill "A Benelux object has a timed_methods method" do
    Sleeper.new.timed_methods
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
    Benelux.add_timer Sleeper, :do_something
    Benelux.add_counter Sleeper, :another_method do |*args|
      args.first
    end
    Sleeper.new.respond_to? :timeline
  end
  dream :kind_of?, Benelux::MethodPacker
  drill "Can get specific packed method" do
    Benelux.packed_method Sleeper, :another_method
  end
  
  drill "Run counter", true do
    a = Sleeper.new
    a.another_method(1000)
    pm = Benelux.packed_method Sleeper, :another_method
    pm.counter
  end
end

xtryouts "Not supported" do
  
  dream :exception, Benelux::NotSupported
  drill "Class is not supported" do
    Benelux.add_timer Class, :new
  end
  
end