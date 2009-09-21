module Benelux
  class Mark < Time
    attr_accessor :name
    attr_accessor :thread_id
    attr_accessor :call_id
    def self.now(n=nil,c=nil,t=nil)
      v = super()
      v.name, v.call_id, v.thread_id = n, c, t
      v
    end
    def inspect(reftime=nil)
      val = reftime.nil? ? self.to_f : (self.to_f - reftime.to_f)
      args = [self.class, self.hexoid, self.name, val, thread_id, call_id]
      "#<%s:%s name=%s at=%f thread_id=%s call_id=%s>" % args
    end
    def to_s(reftime=nil)
      val = reftime.nil? ? self.to_f : (self.to_f - reftime.to_f)
      val.to_s
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