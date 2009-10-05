

module Selectable
  
  # An example of filtering an Array of tagged objects based
  # on a provided Hash of tags or Array of tag values. +obj+
  # in this case would be an object that includes Taggable.
  #
  #     class Something
  #       def [](tags={})
  #         tags = [tags].flatten unless tags.is_a?(Hash)
  #         self.select do |obj|
  #           obj.tags >= tags
  #         end
  #       end
  #     end
  #
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
    def <=>(b)
      return 0 if self == b
      self.send :"compare_#{b.class}", b
    end
        
    def >(other)  (self <=> other)  > 0 end
    def <(other)  (self <=> other)  < 0 end
    
    def <=(other) (self <=> other) <= 0 end
    def >=(other) (self <=> other) >= 0 end
    
    private
    
    def compare_Hash(b)
      return -1 unless (self.values_at(*b.keys) & b.values).size >= b.size
      1
    end
    alias_method :"compare_Selectable::Tags", :compare_Hash
    
    def compare_Array(b)
      return -1 unless (self.values & b).size >= b.size
      1
    end
    
    def method_missing(meth, *args)
      raise SelectableError, "#{meth}: #{args.first} is not a Hash or Array"
    end
    
    ## NOTE: This is helpful but defensive. Ponder!
    ##def compare_forced_array(b)
    ##  compare_Array([b])
    ##end
    ##alias_method :compare_String, :compare_forced_array
    ##alias_method :compare_Symbol, :compare_forced_array
    ##alias_method :compare_Fixnum, :compare_forced_array
      
  end

end