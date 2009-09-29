module Benelux
  class Mark < Time
    attr_accessor :name
    attr_accessor :tags
    def self.now(n=nil)
      v = super()
      v.tags = {}
      v.name = n 
      v
    end
    def track 
      @tags[:track]
    end
    def add_tags(tags={})
      @tags.merge! tags
    end
    alias_method :add_tag, :add_tags
    def inspect(reftime=nil)
      val = reftime.nil? ? self : (reftime - self)
      tagstr = ""
      @tags.each_pair do |n,v|
        v = v.is_a?(Gibbler::Digest) ? v.short : v
        tagstr << " %s=%s" % [n,v]
      end
      "#<%s:%s at=%f name=%s%s>" % [self.class, hexoid, to_f, name, tagstr]
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