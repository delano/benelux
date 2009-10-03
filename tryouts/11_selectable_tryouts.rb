
group "Benelux"

library :benelux, 'lib'
tryouts "Selectable" do
  set :base, SelectableArray.new
  
  setup do
    class ::TaggedItems
      include Selectable::Object
    end
    10.times { |i|
      obj = TaggedItems.new 
      obj.add_tags :index => i, :even => (i%2 == 0)
      base << obj
    }
  end
  
  dream :class, SelectableArray
  dream :size, 5
  drill "filter returns a new instance of the same object" do
    base[:even => true]
  end
  
  drill "[] and filter are the same", true do
    base[:even => false] == base.filter[:even => false]
  end
  
  dream :class, SelectableArray
  dream :object_id, base.object_id
  dream :size, 5
  drill "filter! makes permanent changes to itself" do
    base.filter! :even => true
  end
  
end


tryouts "Tags" do
  set :base, Selectable::Tags[:a => 1, :b => 2]
  
  drill "Can equal a Hash with the same keys/values", true do
    base == {:a => 1, :b => 2}
  end
  
  drill "Implements a comparison operator", true do
    base.respond_to? :'<=>'
  end
  
  drill "Comparison operator returns 0 for same values", 0 do
    base <=> {:a => 1, :b => 2}
  end
  
  drill "Comparison operator returns 1 when it's a superset of other", 1 do
    base <=> {:a => 1}
  end

  drill "Comparison operator returns -1 when it's a subset of other", -1 do
    base <=> {:a => 1, :b => 2, :c => 3}
  end
  
  drill "> returns false when compared to a hash with more key value pairs", false do
    base > {:a => 1, :b => 2, :c => 3}
  end
  
  drill "> returns true when compared to a hash with fewer key value pairs", true do
    base > {:b => 2}
  end
  
  drill "< returns true when compared to a hash with more key value pairs", true do
    base < {:a => 1, :b => 2, :c => 3}
  end
  
  drill "< returns false when compared to a hash with fewer key value pairs", false do
    base < {:b => 2}
  end
  
  drill "< returns false when compared to a hash with same values", false do
    base < {:a => 1, :b => 2}
  end

  drill "<= returns true when compared to a hash with same values", true do
    base <= {:b => 2, :a => 1}
  end
  
  drill "< returns false when compared to an array with same values", false do
    base < [1, 2]
  end
  
  drill "<= returns true when compared to an array with same values", true do
    base <= [2, 1]
  end
  
end


