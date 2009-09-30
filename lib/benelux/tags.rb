

module Benelux
  class Tags < ::Hash
    
    def to_s
      tagstr = []
      self.each_pair do |n,v|
        tagstr << "%s=%s" % [n,v]
      end
      tagstr.join ' '
    end
    
    def inspect
      to_s
    end
    
    def ==(other)
      if other.is_a?(Array)
        (self.values & other).sort == other.sort
      else
        super(other)
      end
    end
    
    # Comparison between other Hash and Array objects.
    #
    # e.g.
    #
    #     a = {:a => 1, :b => 2}
    #     a > {:a => 1, :b => 2, :c => 3}    # => false
    #     a > {:a => 1}                      # => true
    #     a < {:a => 1, :b => 2, :c => 3}    # => true
    #     a >= [2, 1]                        # => true
    #     a > [2, 1]                         # => false
    #
    def <=>(other)
      return 0 if self == other
      if other.is_a?(Array)
        return -1 unless (self.values & other).size >= other.size
      else
        return -1 unless (self.keys & other.keys).size >= other.keys.size
        other.each_pair { |n,v| 
          return -1 unless self.has_key?(n) && self[n] == v
        }
      end
      1
    end
    
    def >(other)  (self <=> other) > 0  end
    def <(other)  (self <=> other) < 0  end
    
    def <=(other) (self <=> other) <= 0 end
    def >=(other) (self <=> other) >= 0 end
      
  end
end