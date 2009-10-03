
group "Benelux"

library :benelux, 'lib'
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