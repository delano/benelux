require 'attic'
require 'thread'


module Benelux
  NOTSUPPORTED = [Class, Object, Kernel]
  require 'benelux/timeline'
  require 'benelux/mark'
  require 'benelux/mixins/thread'
  
  @@timed_objects = {}
  @@timeline = Benelux::Timeline.new
  
  class BeneluxError < RuntimeError; end
  class NotSupported < BeneluxError; end
  
  def benelux_timers
    Benelux.timed_objects[self.class]
  end
  
  def Benelux.supported?(klass)
    !NOTSUPPORTED.member?(klass)
  end
  
  def Benelux.timed_objects
    @@timed_objects
  end
  
  def Benelux.timeline
    @@timeline
  end
  
  def Benelux.thread_timeline
    Thread.current.benelux
  end
  
  def Benelux.update_timeline mark
    Thread.current.benelux ||= Benelux::Timeline.new
    Thread.current.benelux << mark
    Benelux.timeline << mark
    mark
  end
  
  def Benelux.included(obj)
    timed_objects[obj] = [] unless timed_objects.has_key? obj
  end
  
  def Benelux.add_timer obj, meth
    raise NotSupported, obj unless Benelux.supported? obj
    prepare_object obj
    meth_alias = rename_method obj, meth
    timed_objects[obj] << meth
    obj.module_eval generate_timer_str(meth_alias, meth)
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
      obj.attic :benelux
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
      self.benelux ||= Benelux::Timeline.new
      ref = args.object_id.abs 
      self.benelux.mark_open ref, :'#{meth}'
      ret = #{meth_alias}(*args, &block)
      self.benelux.mark_close ref, :'#{meth}'
      ret
    end
    }
  end
  
end


