

module Benelux
  
  # Helper methods for objects with a @tags instance var
  #
  # e.g. 
  #
  #     class Something
  #       include Benelux::TagHelpers
  #     end
  #
  module TagHelpers
    attr_accessor :tags
    def add_tags(tags)
      @tags ||= Benelux::Tags.new
      @tags.merge! tags
    end
    alias_method :add_tag, :add_tags
    def remove_tags(*tags)
      tags.flatten!
      @tags ||= Benelux::Tags.new
      @tags.delete_if { |n,v| tags.member?(n) }
    end
    alias_method :remove_tag, :remove_tags
    def tag_values(*tags)
      tags.flatten!
      @tags ||= Benelux::Tags.new
      ret = @tags.collect { |n,v| 
        p [:n, v]
        v if tags.empty? || tags.member?(n) 
      }.compact
      ret
    end
    def self.normalize(tags={})
      tags = tags.first if tags.kind_of?(Array) && tags.first.kind_of?(Hash)
      tags = [tags].flatten unless tags.kind_of?(Hash)
      tags
    end
  end
  
  # An example of filtering an Array of tagged objects based
  # on a provided Hash of tags or Array of tag values. +obj+
  # in this case would be an object that includes TagHelpers.
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
    
    def ==(*other)
      other = Benelux::TagHelpers.normalize other
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
    def <=>(*other)
      other = Benelux::TagHelpers.normalize other
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