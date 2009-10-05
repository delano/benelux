
module Benelux
  class Reporter
    attr_reader :thread
    attr_reader :thwait
    def initialize(*threads)
      add_threads *threads
      @thwait = ThreadsWait.new
      @done, @abort = false, false
    end
    def add_threads(*threads)
      threads.each do |thread|
        raise BadRecursion, "Cannot report on self" if thread == Thread.current
        @thwait.join_nowait thread
      end
    end
    alias_method :add_thread, :add_threads
    def start
      @thread = Thread.new do
        while (!@thwait.empty?) && @thwait.next_wait
          break if @abort
          sleep 1
        end
      end
      @thwait.join unless @thwait.empty?
      @done = true unless aborted?
    end
    def wait
      @thwait.join unless @thwait.empty?
    end
    def stop() @abort = true end
    def done?()     @done  end
    def aborted?()  @abort end
  end
end