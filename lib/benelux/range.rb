
module Benelux
  class Range
    attr_accessor :name
    attr_accessor :from
    attr_accessor :to
    attr_accessor :exception
    attr_accessor :tags
    def initialize(name,from,to)
      @name, @from, @to = name, from, to
      @tags = Benelux::Tags.new
    end
    def to_s
      "%s:%.4f" % [name, duration]
    end
    def inspect
      args = [self.class, hexoid, duration, from, to, name, tags]
      "#<%s:%s duration=%0.4f from=%s to=%s name=%s %s>" % args
    end
    def add_tags(tags=Benelux::Tags.new)
      @tags.merge! tags
    end
    alias_method :add_tag, :add_tags
    def track 
      @from.nil? ? :unknown : @from.track
    end
    def thread_id
      @from.nil? ? :unknown : @from.thread_id
    end
    def call_id
      @from.nil? ? :unknown : @from.call_id
    end
    def successful?
      @exception.nil?
    end
    def failed?
      !successful?
    end
    def duration
      to - from
    end
    def <=>(other)
      from <=> other.from
    end
    def <(other)
      from < other
    end
    def >(other)
      from > other
    end
  end
end