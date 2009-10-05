group "Benelux"

library :benelux, 'lib'
tryouts "Reporter" do
  set :reporter, Benelux::Reporter.new
  
  drill "1", true do
    p Benelux
  end
  
  dream :exception, Benelux::BadRecursion
  xdrill "will not report on itself" do
    reporter.add_threads Thread.current
  end
  
  dream :class, ThreadsWait
  dream :empty?, false
  xdrill "can add threads" do
    2.times {
      t = Thread.new do
        3.times { sleep 1; }
      end
      reporter.add_thread t
    }
    reporter.thwait
  end
  
  dream :done?, true
  xdrill "will wait for known threads" do
    stash :done_before, reporter.done?
    reporter.start
    reporter
  end
  
end
