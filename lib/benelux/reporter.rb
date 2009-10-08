
module Benelux
  class Reporter
    attr_reader :thread
    attr_reader :thwait
    @@mutex = Mutex.new
    def initialize(*threads)
      @thwait = ThreadsWait.new
      @abort, @running = false, false
      @tmerge = Benelux::Stats::Calculator.new
      add_threads *threads
      @tbd = []
      @thread = create_reporting_thread
    end
    def create_reporting_thread(priority=-3)
      t = Thread.new do
        5.times {  # Give the app 1 second to generate threads
          break if @start && !@thwait.empty?
          sleep 0.2
        }
        
        run_loop
      end
      t.priority = priority
      t
    end
    def add_threads(*threads)
      threads.each do |thread|
        raise BadRecursion, "Cannot report on self" if thread == @thread
        next if thread == Thread.main
        @thwait.join_nowait thread
      end
      @start = true
    end
    alias_method :add_thread, :add_threads
    def running_threads?
      # Any status that is not nil or false is running
      !@thwait.threads.select { |t| t.status }.empty?
    end

    def run_loop
      loop do
        break if @abort
        process(@tbd)
        if @thwait.empty?
          sleep 0.001 # prevent mad thrashing. 
          # If there are no threads running we can stop 
          # because there are none waiting in the queue. 
          running_threads? ? next : break
        end
        t = @thwait.next_wait
        @tbd << t.timeline
      end
    end
    def process(tbd)
      return if tbd.empty?
      (start = Time.now)
      Benelux.timeline.merge! *tbd
      (endt = Time.now)
      dur = (endt - start).to_f
      #p [:processed, tbd.size, dur]
      tbd.clear
      @tmerge.sample dur
    end
    # We don't add the main thread to the wait group
    # so we need to manually force processing for
    # that thread.
    def force_update
      @abort = false
      @tbd << Thread.current.timeline
      run_loop
    end
    # Call this once the active threads have stopped. It
    # increases the priority of the processing thread, 
    # waits for it to finish and then calls force_update
    # to get the main threads stats into the timeline. 
    def wait
      if @thread && Thread.current == Thread.main
        @abort = true
        @thread.priority = 0
        @thread.join if @thread.status
        force_update
      else
        msg = "Not main thread. Skipping call to wait from #{caller[0]}"
        Benelux.ld msg
      end
    end
    def stop() @abort = true end
    def done?()     @done  end
    def aborted?()  @abort end
    def running?()  @running end
  end
end