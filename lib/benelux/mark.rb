module Benelux
  class Mark < Time
    attr_accessor :name
    attr_accessor :thread_id
    def self.now(n=nil)
      v = super()
      v.name, v.thread_id = n, Thread.current.object_id.abs
      v
    end
    def inspect(reftime=nil)
      val = reftime.nil? ? self : (reftime - self)
      arg = [self.class, self.hexoid, self.name, self.to_f, thread_id]
      "#<%s:%s name=%s at=%f thread_id=%s>" % arg
    end
    def to_s(reftime=nil)
      val = reftime.nil? ? self : (reftime - self)
      val.to_f.to_s
    end
    def ==(other)
      return false unless other.respond_to? :call_id
      self.name == other.name &&
      self.thread_id == other.thread_id &&
      self.call_id == other.call_id &&
      self.to_f == self.to_f
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
end