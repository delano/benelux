require 'attic'
require 'thread'
require 'hexoid'

module Benelux
  NOTSUPPORTED = [Class, Object, Kernel]
  SUFFIX_START = :a.freeze
  SUFFIX_END   = :z.freeze
  
  require 'benelux/timeline'
  require 'benelux/mark'
  require 'benelux/region'
  require 'benelux/mixins/thread'
  
  @@timed_methods = {}
  @@thread_timelines = []
  @@timeline = Benelux::Timeline.new
  @@mutex = Mutex.new
  
  class BeneluxError < RuntimeError; end
  class NotSupported < BeneluxError; end
  
  def benelux_timers
    Benelux.timed_methods[self.class]
  end
  
  def Benelux.supported?(klass)
    !NOTSUPPORTED.member?(klass)
  end
  
  def Benelux.store_thread_reference
    return if Benelux.thread_timelines.member? Thread.current
    @@mutex.synchronize do
      Benelux.thread_timelines << Thread.current
    end
  end
  
  def Benelux.timed_methods
    @@timed_methods
  end
  
  def Benelux.thread_timelines
    @@thread_timelines
  end
  
  def Benelux.timeline
    @@timeline = Benelux.generate_timeline #if @@timeline.empty?
    @@timeline
  end
  
  def Benelux.generate_timeline
    @@mutex.synchronize do
      timeline = Benelux::Timeline.new
      regions = []
      Benelux.thread_timelines.each do |t| 
        timeline << t.timeline
        regions += t.timeline.regions
      end
      timeline = timeline.flatten.sort
      timeline.regions = regions.sort
      timeline
    end
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
    klass.module_eval generate_timer_str(meth_alias, meth)
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
  
  def Benelux.generate_timer_str(meth_alias, meth)
    %Q{
    def #{meth}(*args, &block)
      # We only need to do these things once.
      if self.timeline.nil?
        self.timeline = Benelux::Timeline.new
        Benelux.store_thread_reference
      end
      mark_a = self.timeline.add_mark_open :'#{meth}'
      ret = #{meth_alias}(*args, &block)
      mark_z = self.timeline.add_mark_close :'#{meth}'
      self.timeline.add_region :'#{meth}', mark_a, mark_z
      ret
    end
    }
  end
  
end


