
module Benelux
  class Range
    attr_accessor :name
    attr_accessor :from
    attr_accessor :to
    attr_accessor :exception
    def initialize(name,from,to)
      @name, @from, @to = name, from, to
    end
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