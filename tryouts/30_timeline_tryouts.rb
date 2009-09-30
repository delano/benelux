
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

end