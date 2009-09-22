
module Benelux
  class Region
    attr_accessor :name
    attr_accessor :from
    attr_accessor :to
    attr_accessor :exception
    def initialize(name,from,to)
      @name, @from, @to = name, from, to
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