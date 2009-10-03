
# = Selectable
#
# <strong>Note: Classes that include Selectable must also
# subclass Array</strong>
#
#     class Something < Array
#       include Selectable
#     end
#
module Selectable
  
  class SelectableError < RuntimeError; end
  class TagsNotInitialized < SelectableError; end
  
  def Selectable.normalize(*tags)
    tags.flatten!
    tags = tags.first if tags.first.kind_of?(Hash) || tags.first.kind_of?(Array)
    tags
  end
  
  # Return the objects that match the given tags. 
  # This process is optimized for speed so there
  # as few conditions as possible. One result of
  # that decision is that it does not gracefully 
  # handle error conditions. For example, if the
  # tags in an object have not been initialized,
  # you will see this error:
  #
  #     undefined method `>=' for nil:NilClass
  #
  def filter(*tags)
    tags = Selectable.normalize tags
    # select returns an Array. We want a Selectable.
    items = self.select { |obj| obj.tags >= tags }
    self.class.new items
  end  
    alias_method :[], :filter unless method_defined? :[]

  def filter!(*tags)
    tags = Selectable.normalize tags
    self.delete_if { |obj|   obj.tags < tags }
  end
  
  # Helper methods for objects with a @tags instance var
  #
  # e.g. 
  #
  #     class Something
  #       include Selectable::Object
  #     end
  #
  module Object
    attr_accessor :tags
    def add_tags(tags)
      init_tags
      @tags.merge! tags
    end
    alias_method :add_tag, :add_tags
    def remove_tags(*tags)
      raise TagsNotInitialized if @tags.nil?
      tags.flatten!
      @tags.delete_if { |n,v| tags.member?(n) }
    end
    alias_method :remove_tag, :remove_tags
    def tag_values(*tags)
      raise TagsNotInitialized if @tags.nil?
      tags.flatten!
      ret = @tags.collect { |n,v| 
        v if tags.empty? || tags.member?(n) 
      }.compact
      ret
    end
    def self.normalize(tags={})
      tags = tags.first if tags.kind_of?(Array) && tags.first.kind_of?(Hash)
      tags = [tags].flatten unless tags.kind_of?(Hash)
      tags
    end
    def init_tags
      @tags ||= Selectable::Tags.new
    end
  end
  
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
      a = self
      return -1 unless (a.values_at(*b.keys) & b.values).size >= b.size
      1
    end
    alias_method :"compare_Selectable::Tags", :compare_Hash
    
    def compare_Array(b)
      return -1 unless (self.values & b).size >= b.size
      1
    end
    
    def method_missing(meth, *args)
      raise SelectableError, "#{args.first} is not a Hash or Array"
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

class SelectableArray < Array
  include Selectable
end
class SelectableHash < Hash
  include Selectable
end
