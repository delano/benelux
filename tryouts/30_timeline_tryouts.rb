

__END__
# OLD (0.3):

group "Benelux"

library :benelux, 'lib'
tryouts "Timelines" do
  set :tl, Benelux::Timeline.new
  
  setup do
    class ::Sleeper
      def   do_something()  sleep rand/3 end
      def another_method(t) t*2          end 
    end
  end
  
  drill "Can set thread track", :track1 do
    Benelux.current_track :track1
#    Thread.current.track
  end
  
  drill "Add timers to existing objects", true do
    Benelux.add_timer Sleeper, :do_something
    Sleeper.new.respond_to? :timeline
  end
  
  dream :class, Benelux::Timeline
  dream :size, 3
  drill "create timeline with marks" do
    tl.add_default_tags :a => :frog
    tl.add_mark(:one)
    tl.add_default_tags :b => :rest
    tl.add_mark(:two)
    tl.add_default_tags :c => :tilt
    tl.add_mark(:three)
    tl.marks
  end
  
  dream :size, 2
  drill "select marks based on tags" do
    tl[:frog][:b => :rest]
  end

  dream :class, Benelux::Timeline
  dream :size, 10 # 5 * 2 = 10
  drill "Creates a timeline for the thread" do
    sleeper = Sleeper.new
    5.times { sleeper.do_something }
    Benelux.thread_timeline
  end
  
  dream :class, Benelux::Timeline
  dream :size, 10
  drill "Creates a global timeline" do
    Benelux.update_all_track_timelines
    Benelux.timeline
  end
end