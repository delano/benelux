
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
  
  require 'selectable/tags'
  require 'selectable/object'
  
  # Returns a Hash or Array
  def Selectable.normalize(*tags)
    tags.flatten!
    tags = tags.first if tags.first.kind_of?(Hash) || tags.first.kind_of?(Array)
    if tags.is_a?(Hash)
      tags = Hash[tags.collect { |n,v| [n, v.to_s] }]
    else
      tags.collect! { |v| v.to_s }
    end
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
  
  def tags
    t = Selectable::Tags.new
    self.each { |o| t.merge o.tags }
    t
  end
  
end

class SelectableArray < Array
  include Selectable
end
class SelectableHash < Hash
  include Selectable
end
