require 'attic'

module Benelux
  extend self
  
  class Mark < Time
    attr_accessor :name
    def self.now(name=nil)
      v = super()
      v.name = name
      v
    end
  end
  
  @@timed_objects = []
  def add_timer obj, meth
    meth_alias = "__benelux_#{meth}_#{Thread.current.object_id.abs}_#{obj.object_id.abs}"
    obj.extend Attic
    obj.attic :benelux_timeline
    obj.module_eval do
      alias_method meth_alias, meth
    end
    obj.module_eval benelux_methods_str(meth_alias, meth)
    timed_objects << obj
  end
  
  def timed_objects
    @@timed_objects
  end
  
  def name(*names)
    names.flatten.collect { |n| n.to_s }.join('_')
  end
  
  private
  
  def benelux_methods_str(meth_alias, meth)
    %Q{
    unless respond_to?(:__benelux_mark)
      
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
    end
    def #{meth}(*args, &block)  
      benelux_mark(:'#{meth}', :start)
      ret = #{meth_alias}(*args, &block)
      benelux_mark(:'#{meth}', :end)
      ret
    end
    }
  end
  
end

