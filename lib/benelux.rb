require 'attic'
require 'thread'
require 'hexoid'
require 'gibbler'

module Benelux
  NOTSUPPORTED = [Class, Object, Kernel]
  
  require 'benelux/tags'
  require 'benelux/mark'
  require 'benelux/range'
  require 'benelux/stats'
  require 'benelux/timeline'
  require 'benelux/mixins/thread'
  
  @@timed_methods = {}
  @@known_threads = []
  @@timelines = {}
  @@mutex = Mutex.new
  @@debug = true
  
  def Benelux.enable_debug; @@debug = true; end
  def Benelux.disable_debug; @@debug = false; end
  def Benelux.debug?; @@debug; end
  
  class BeneluxError < RuntimeError; end
  class NotSupported < BeneluxError; end
  
  # Returns an Array of method names for the current class that
  # are timed by Benelux. 
  #
  # This is an instance method for objects which have Benelux 
  # modified methods. 
  def benelux_timers
    Benelux.timed_methods[self.class]
  end

  def Benelux.timeline(track=nil)
    if track.nil?
      if Benelux.timelines.empty?
        tl = known_threads.collect { |t| t.timeline}
      else
        tl = Benelux.timelines.values
      end
      Benelux.merge_timelines *tl
    else
      Benelux.timelines[track]
    end
  end
  
  # Must be run in single-threaded mode (after all track threads
  # have finished).
  #
  def Benelux.update_all_track_timelines
    Benelux.timelines.keys.each { |track| Benelux.update_track(track) }
  end
  
  # Must be run from the master thread in the current track. The master
  # thread is either the first thread in a track or the one which creates
  # additional threads for the track. 
  #
  def Benelux.update_track_timeline(track=nil)
    track = Thread.current.track if track.nil?
    threads = Benelux.known_threads.select { |t| t.track == track }
    Benelux.timelines[track] = Benelux.merge_timelines(*threads.collect { |t| t.timeline })
    threads.each { |t| t.timeline.clear }
    Benelux.timelines[track]
  end
  
  # Create a named track. 
  def Benelux.current_track(track)
    Benelux.store_thread_reference
    @@mutex.synchronize do
      # QUESTION: Is it okay for multiple threads to write to
      # different elements in the same hash?
      Benelux.timelines[track] ||= Benelux::Timeline.new
      Benelux.add_thread_tags :track => track
      Thread.current.track = track
    end
  end
  
  # Combine two or more timelines into a new, single Benelux::Timeline.
  #
  def Benelux.merge_timelines(*timelines)
    tl, ranges = Benelux::Timeline.new, []
    timelines.each_with_index do |t, index|
      next if t.empty?
      tl << t
      ranges += t.ranges
    end
    tl = tl.flatten.sort!
    tl.ranges = ranges.sort
    tl
  end
  
  def Benelux.thread_timeline
    Thread.current.timeline ||= Benelux::Timeline.new
    Thread.current.timeline
  end
  
  # Make note of the class which included Benelux. 
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
    klass.module_eval generate_timer_str(meth_alias, meth), __FILE__, 146
  end
  
  def Benelux.add_tally obj, meth
  end
  
  def Benelux.name(*names)
    names.flatten.collect { |n| n.to_s }.join('_')
  end
  
  
  def Benelux.prepare_object obj
    obj.extend Attic  unless obj.kind_of?(Attic)
    unless obj.kind_of?(Benelux)
      obj.attic :timeline
      obj.send :include, Benelux
    end
  end

  # Benelux keeps track of the threads which have timed
  # objects so it can process the timelines after all is
  # said and done. 
  def Benelux.store_thread_reference
    return if Benelux.known_threads.member? Thread.current
    @@mutex.synchronize do
      Thread.current.timeline ||= Benelux::Timeline.new
      Benelux.known_threads << Thread.current
      Benelux.known_threads.uniq!
    end
  end
  
  # Thread tags become the default for any new Mark or Range. 
  def Benelux.add_thread_tags(args=Benelux::Tags.new)
    Benelux.thread_timeline.add_default_tags args
  end
  def Benelux.add_thread_tag(*args) add_thread_tags *args end
  
  def Benelux.remove_thread_tags(*args)
    Benelux.thread_timeline.remove_default_tags *args
  end
  def Benelux.remove_thread_tag(*args) remove_thread_tags *args end
  
  
  def Benelux.inspect
    str = ["Benelux"]
    str << "threads:" << Benelux.known_threads.inspect
    str << "tracks:" << Benelux.timelines.keys.inspect
    str << "timers:" << Benelux.timed_methods.inspect
    str << "timeline:" << Benelux.timeline.inspect
    str.join $/
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
  
  def Benelux.timelines
    @@timelines
  end
  
  # Rename the method +meth+ in the object +obj+ and return
  # the new alias. 
  # 
  # e.g.
  #
  #     Benelux.renamed(SomeClass, :execute) 
  #       # => __benelux_execute_2151884308_2165479316
  # 
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

  # Creates a method definition (for an `eval` that) for a method
  # named +meth+ which times a call to +meth_alias+. 
  def Benelux.generate_timer_str(meth_alias, meth)
    %Q{
    def #{meth}(*args, &block)
      call_id = "" << self.object_id.abs.to_s << args.object_id.abs.to_s
      # We only need to do these things once.
      if self.timeline.nil?
        self.timeline = Benelux::Timeline.new
        Benelux.store_thread_reference
      end
      mark_a = self.timeline.add_mark :'#{meth}_a'
      mark_a.add_tag :call_id => call_id
      tags = mark_a.tags
      ret = #{meth_alias}(*args, &block)
    rescue => ex
      raise ex
    ensure
      mark_z = self.timeline.add_mark :'#{meth}_z'
      mark_z.tags = tags # In case tags were added between these marks
      range = self.timeline.add_range :'#{meth}', mark_a, mark_z
      range.exception = ex if defined?(ex) && !ex.nil?
    end
    }
  end
  
end





