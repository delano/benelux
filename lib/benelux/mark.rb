module Benelux
  class Mark < Time
    attr_accessor :name
    attr_accessor :tags
    def self.now(n=nil)
      v = super()
      v.tags = Benelux::Tags.new
      v.name = n 
      v
    end
    def track 
      @tags[:track]
    end
    def add_tags(tags=Benelux::Tags.new)
      @tags.merge! tags
    end
    alias_method :add_tag, :add_tags
    def inspect(reftime=nil)
      val = reftime.nil? ? self : (reftime - self)
      "#<%s:%s at=%f name=%s %s>" % [self.class, hexoid, to_f, name, tags]
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
      self.tags == other.tags &&
      self.to_f == self.to_f
    end
  end
end