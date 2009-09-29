module Benelux
  class Mark < Time
    attr_accessor :name
    attr_accessor :track
    attr_accessor :thread_id
    attr_accessor :call_id
    def self.now(n=nil,c=nil,t=nil)
      v = super()
      v.name, v.thread_id = n, Thread.current.object_id.abs
      v.call_id, v.track = c, t
      v.track ||= Thread.current.track if Thread.current.respond_to? :track
      v
    end
    def inspect(reftime=nil)
      val = reftime.nil? ? self : (reftime - self)
      trackstr = track.is_a?(Gibbler::Digest) ? track.short : track
      arg = [self.class, hexoid, to_f, thread_id, call_id, trackstr, name]
      "#<%s:%s at=%f thread_id=%s call_id=%s track=%s name=%s>" % arg
    end
    def to_s(reftime=nil)
      val = reftime.nil? ? self : (reftime - self)
      val.to_f.to_s
    end
    def distance(time)
      self - time
    end
    def ==(other)
      return false unless other.respond_to? :call_id
      self.name == other.name &&
      self.same_call(other) &&
      self.to_f == self.to_f
    end
    def same_timeline?(other)
      self.thread_id == other.thread_id
    end
    def same_call?(other)
      self.thread_id == other.thread_id &&
      self.call_id == other.call_id
    end
  end
end