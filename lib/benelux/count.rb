module Benelux
  
  class Count
    include Selectable::Object
    attr_accessor :name
    def initialize(name, count)
      @name, @count = name, count
    end
    def track 
      @tags[:track]
    end
    def inspect
      "#<%s:%s count=%d name=%s %s>" % [self.class, hexoid, self.to_i, name, tags]
    end
    def to_i
      @count.to_i
    end
    def to_s
      @count.to_s
    end
    def ==(other)
      self.class == other.class &&
      self.name == other.name &&
      self.tags == other.tags &&
      @count.to_i == other.to_i
    end

  end
end