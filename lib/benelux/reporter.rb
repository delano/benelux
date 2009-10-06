
module Benelux
  class Reporter
    attr_reader :thread
    attr_reader :thwait
    def initialize(*threads)
      @thwait = ThreadsWait.new
      @abort, @running = false, false
      @tmerge = Benelux::Stats::Calculator.new
      add_threads *threads
      start
    end
    def add_threads(*threads)
      threads.each do |thread|
        #raise BadRecursion, "Cannot report on self" if thread == Thread.current
        next if thread == Thread.main
        @thwait.join_nowait thread
      end
    end
    alias_method :add_thread, :add_threads
    def running_threads?
      !@thwait.threads.select { |t| t.status }.empty?
    end
    
    def start
      return if running?
      @running = true
      @thread = Thread.new do
        sleep 1   # Give the app time to generate threads
        tbd = []
        loop do
          break if @abort
          process(tbd) if tbd.size > 1
          if @thwait.empty?
            tbd.empty? ? sleep(0.1) : process(tbd)
            running_threads? ? next : break
          end
          tbd << @thwait.next_wait.timeline
        end
      end
      @running = false
      @done = true unless aborted?
    end
    def process(tbd)
      return if tbd.empty?
      start = Time.now
      Benelux.timeline.merge! *tbd
      dur = (Time.now - start).to_f
      Benelux.ld [:processed, tbd.size, dur]
      tbd.clear
      @tmerge.sample dur
    end
    # We don't add the main thread to the wait group
    # so we need to manually force processing for
    # that thread. The reason: we 
    def force_update
      process [Thread.current.timeline]
    end
    def wait
      if Thread.current == Thread.main
        @thread.join
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