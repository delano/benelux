require 'attic'
require 'thread'
require 'hexoid'

module Benelux
  NOTSUPPORTED = [Class, Object, Kernel]
  
  require 'benelux/mark'
  require 'benelux/range'
  require 'benelux/stats'
  require 'benelux/timeline'
  require 'benelux/mixins/thread'
  
  @@timed_methods = {}
  @@known_threads = []
  @@mutex = Mutex.new
  
  class BeneluxError < RuntimeError; end
  class NotSupported < BeneluxError; end
  
  def self.inspect
    str = ["Benelux"]
    str << "threads:" << Benelux.known_threads.inspect
    str << "timers:" << Benelux.timed_methods.inspect
    str << "timeline:" << Benelux.timeline.inspect
    str.join $/
  end
  
  def benelux_timers
    Benelux.timed_methods[self.class]
  end
  
  def Benelux.supported?(klass)
    !NOTSUPPORTED.member?(klass)
  end
  
  def Benelux.timed_methods
    @@timed_methods
  end
  
  def Benelux.known_threads
    @@known_threads
  end
  
  def Benelux.timeline(track=nil)
    timeline = Benelux::Timeline.new
    ranges = []
    Benelux.known_threads.each do |t| 
      next if !track.nil? && t.track != track
      timeline << t.timeline
      ranges += t.timeline.ranges
    end
    timeline = timeline.flatten.sort
    timeline.ranges = ranges.sort
    timeline
  end
  
  def Benelux.thread_timeline(thread_id=nil)
    Thread.current.timeline ||= Benelux::Timeline.new
    Thread.current.timeline
  end
  
  
  def Benelux.included(klass)
    timed_methods[klass] = [] unless timed_methods.has_key? klass
  end
  
  def Benelux.timed_method? klass, meth
    !timed_methods[klass].nil? && timed_methods[klass].member?(meth)
  end
  
  def Benelux.add_timer klass, meth
    raise NotSupported, klass unless Benelux.supported? klass
    raise AlreadyTimed, klass if Benelux.timed_method? klass, meth
    prepare_object klass
    meth_alias = rename_method klass, meth
    timed_methods[klass] << meth
    klass.module_eval generate_timer_str(meth_alias, meth), __FILE__, 119
  end
  
  def Benelux.add_tally obj, meth
  end
  
  def Benelux.name(*names)
    names.flatten.collect { |n| n.to_s }.join('_')
  end
  
  private
  def Benelux.prepare_object obj
    obj.extend Attic  unless obj.kind_of?(Attic)
    unless obj.kind_of?(Benelux)
      obj.attic :timeline
      obj.send :include, Benelux
    end
  end
  
  def Benelux.rename_method(obj, meth)
    ## NOTE: This is commented out so we can include  
    ## Benelux definitions before all classes are loaded. 
    ##unless obj.respond_to? meth
    ##  raise NoMethodError, "undefined method `#{meth}' for #{obj}:Class"
    ##end
    thread_id, call_id = Thread.current.object_id.abs, obj.object_id.abs
    meth_alias = "__benelux_#{meth}_#{thread_id}_#{call_id}"
    obj.module_eval do
      alias_method meth_alias, meth
    end
    meth_alias
  end
  
  def Benelux.store_thread_reference
    return if Benelux.known_threads.member? Thread.current
    @@mutex.synchronize do
      Benelux.known_threads << Thread.current
      Benelux.known_threads.uniq!
    end
  end
  
  def Benelux.current_track(track)
    Benelux.store_thread_reference
    Thread.current.track = track
  end
  
  def Benelux.generate_timer_str(meth_alias, meth)
    %Q{
    def #{meth}(*args, &block)
      call_id = "" << self.object_id.abs.to_s << args.object_id.abs.to_s
      # We only need to do these things once.
      if self.timeline.nil?
        self.timeline = Benelux::Timeline.new
        Benelux.store_thread_reference
      end
      begin
        mark_a = self.timeline.add_mark :'#{meth}_a', call_id
        ret = #{meth_alias}(*args, &block)
      rescue => ex
        raise ex
      ensure
        mark_z = self.timeline.add_mark :'#{meth}_z', call_id
        region = self.timeline.add_range :'#{meth}', mark_a, mark_z
        region.exception = ex if defined?(ex) && !ex.nil?
      end
      ret
    end
    }
  end
  
end





