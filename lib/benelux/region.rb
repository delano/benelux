
module Benelux
  class Region
    attr_accessor :name
    attr_accessor :from
    attr_accessor :to
    def initialize(name,from,to)
      @name, @from, @to = name, from, to
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