
group "Benelux"

library :benelux, 'lib'
tryouts "Timelines" do
  set :tl, Benelux::Timeline.new
  
  dream :class, Benelux::Timeline
  dream :size, 3
  drill "create timeline with marks" do
    tl.add_default_tags :a => :frog
    tl.add_mark(:one) and sleep rand
    tl.add_default_tags :b => :rest
    tl.add_mark(:two) and sleep rand
    tl.add_default_tags :c => :tilt
    tl.add_mark(:three) and sleep rand
    tl.marks
  end
  
  dream :size, 2
  drill "select marks based on tags" do
    tl[:frog][:b => :rest]
  end

  dream :class, Benelux::Timeline
  dream :size, 10 # 5 * 2 = 10
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
  dream :size, 13
  drill "Creates a timeline for the thread" do
    Benelux.thread_timeline
  end
  
  dream :class, Benelux::Timeline
  dream :size, 17
  drill "Creates a global timeline" do
    Benelux.timeline
  end
end