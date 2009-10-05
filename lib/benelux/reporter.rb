
module Benelux
  class Reporter
    attr_reader :thread
    attr_reader :thwait
    def initialize(*threads)
      @thwait = ThreadsWait.new
      @abort, @running = false, false
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
        loop do
          break if @abort
          if @thwait.empty?
            sleep 0.1
            running_threads? ? next : break
          end
          Benelux.timeline.merge! @thwait.next_wait.timeline
        end
      end
      @running = false
      @done = true unless aborted?
    end
    def process
    
    end
    def force_update
      Benelux.timeline.merge! Thread.current.timeline
    end
    def wait
      if Thread.current == Thread.main
        @thread.join
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