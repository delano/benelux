require 'attic'

module Benelux

  def benelux_at(*names)
    name = Benelux.name *names
    self.benelux_timeline.select do |mark| 
      mark.name.to_s == name.to_s
    end
  end
  
  def benelux_between(*names)
    nameA, nameB = *names.collect { |n| Benelux.name n }
    timeA, timeB = benelux_at(nameA), benelux_at(nameB)
    timeB.first.to_f - timeA.first.to_f
  end
  
  def benelux_mark(*names)
    name = Benelux.name *names
    self.benelux_timeline ||= []
    self.benelux_timeline << Benelux::Mark.now(name)
  end
  private :benelux_mark
  
  @@timed_objects = []
  
  def Benelux.timed_objects
    @@timed_objects
  end
  
  def Benelux.name(*names)
    names.flatten.collect { |n| n.to_s }.join('_')
  end
  
  def Benelux.add_timer obj, meth
    meth_alias = "__benelux_#{meth}_#{Thread.current.object_id.abs}_#{obj.object_id.abs}"
    obj.extend Attic
    obj.attic :benelux_timeline
    obj.send :include, Benelux
    obj.module_eval do
      alias_method meth_alias, meth
    end
    obj.module_eval generate_wrapper_str(meth_alias, meth)
    timed_objects << obj unless timed_objects.member? obj
  end
  
  def Benelux.generate_wrapper_str(meth_alias, meth)
    %Q{
    def #{meth}(*args, &block)  
      benelux_mark(:'#{meth}', :start)
      ret = #{meth_alias}(*args, &block)
      benelux_mark(:'#{meth}', :end)
      ret
    end
    }
  end
  
end

module Benelux
  class Mark < Time
    attr_accessor :name
    def self.now(name=nil)
      v = super()
      v.name = name
      v
    end
  end
end