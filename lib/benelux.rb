require 'attic'
require 'thread'


module Benelux
  require 'benelux/timeline'
  require 'benelux/mark'
  require 'benelux/mixins/thread'
  
  @@timed_objects = []
  @@timeline = Benelux::Timeline.new
  
  def benelux_at(*names)
    name = Benelux.name *names
    self.benelux_timeline.select do |mark| 
      mark.name.to_s == name.to_s
    end
  end
  
  def benelux_between(*names)
    name_s, name_e = *names.collect { |n| Benelux.name n }
    time_s, time_e = benelux_at(name_s), benelux_at(name_e)
    time_e.first.to_f - time_s.first.to_f
  end
  
  def benelux_duration(*names)
    name = Benelux.name *names
    name_s, name_e = "#{name}_start", "#{name}_end"
    benelux_between(name_s, name_e)
  end
  
  def benelux_mark(call_id, *names)
    name = Benelux.name *names
    thread_id = Thread.current.object_id.abs
    mark = Benelux::Mark.now(name, thread_id, call_id)
    Benelux.update_timeline mark
    (self.benelux_timeline ||= Benelux::Timeline.new) << mark
  end
  private :benelux_mark
  
  def benelux_mark_open(ref, *names)
    name = Benelux.name *names
    benelux_mark ref, name, :'aa'
  end
  private :benelux_mark_open
  
  def benelux_mark_close(ref, *names)
    name = Benelux.name *names
    benelux_mark ref, name, :'zz'
  end
  private :benelux_mark_close
  
  
  def Benelux.timed_objects
    @@timed_objects
  end
  
  def Benelux.timeline
    @@timeline
  end
  
  def Benelux.thread_timeline
    Thread.current.benelux_timeline
  end
  
  def Benelux.update_timeline mark
    Thread.current.benelux_timeline ||= Benelux::Timeline.new
    Thread.current.benelux_timeline << mark
    Benelux.timeline << mark
    mark
  end
  
  def Benelux.included(obj)
    timed_objects << obj unless timed_objects.member? obj
  end
  
  def Benelux.add_timer obj, meth
    prepare_object obj
    meth_alias = rename_method obj, meth
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
      obj.attic :benelux_timeline
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
      ref = args.object_id.abs 
      benelux_mark_open ref, :'#{meth}'
      ret = #{meth_alias}(*args, &block)
      benelux_mark_close ref, :'#{meth}'
      ret
    end
    }
  end
  
end


