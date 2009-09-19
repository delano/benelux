require 'attic'

module Benelux

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
    self.benelux_timeline ||= Benelux::Timeline.new
    self.benelux_timeline << Benelux::Mark.now(name, thread_id, call_id)
  end
  private :benelux_mark
  
  def benelux_open_mark(ref, *names)
    name = Benelux.name *names
    benelux_mark ref, name, :open
  end
  private :benelux_open_mark
  
  def benelux_close_mark(ref, *names)
    name = Benelux.name *names
    benelux_mark ref, name, :close
  end
  private :benelux_close_mark
  
  @@timed_objects = []
  
  def Benelux.timed_objects
    @@timed_objects
  end
  
  def Benelux.name(*names)
    names.flatten.collect { |n| n.to_s }.join('_')
  end
  
  def Benelux.included(obj)
    timed_objects << obj unless timed_objects.member? obj
  end
  
  def Benelux.add_timer obj, meth
    meth_alias = "__benelux_#{meth}_#{Thread.current.object_id.abs}_#{obj.object_id.abs}"
    obj.extend Attic
    obj.send :include, Benelux
    obj.attic :benelux_timeline
    obj.module_eval do
      alias_method meth_alias, meth
    end
    obj.module_eval generate_wrapper_str(meth_alias, meth)
  end
  
  def Benelux.generate_wrapper_str(meth_alias, meth)
    %Q{
    def #{meth}(*args, &block)
      ref = args.object_id.abs 
      benelux_open_mark ref, :'#{meth}'
      ret = #{meth_alias}(*args, &block)
      benelux_close_mark ref, :'#{meth}'
      ret
    end
    }
  end
  
end

module Benelux
  class Mark < Time
    attr_accessor :name
    attr_accessor :thread_id
    attr_accessor :call_id
    def self.now(n=nil,t=nil,c=nil)
      v = super()
      v.name, v.thread_id, v.call_id = n, t, c
      v
    end
    def ==(other)
      return false unless other.respond_to? :call_id
      self.name == other.name &&
      self.thread_id == other.thread_id &&
      self.call_id == other.call_id
    end
    def same_timeline?(other)
      return false unless other.respond_to? :thread_id
      self.thread_id == other.thread_id
    end
    def same_call?(other)
      return false unless other.respond_to? :call_id
      self.thread_id == other.thread_id &&
      self.call_id == other.call_id
    end
  end
  # 
  # |------+----+--+----+----|
  #        |
  #       0.02  
  class Timeline < Array
    #def to_line
    #  marks = self.sort
    #  len = marks.last.to_f - marks.first.to_f
    #end
  end
end