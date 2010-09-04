require 'benelux'

@base = SelectableArray.new
@tags = Selectable::Tags[:a => 1, :b => 2]

class ::TaggedItems
  include Selectable::Object
end
10.times { |i|
  obj = TaggedItems.new 
  obj.add_tags :index => i, :even => (i%2 == 0)
  @base << obj
}


## filter returns a new instance of the same object
ret = @base.filter(:even => true)
ret.class
#=> SelectableArray
  
## filter! makes permanent changes to itself
ret = @base.filter! :even => true
ret.object_id 
#=> @base.object_id

  
## Can equal a Hash with the same keys/values
@tags == {:a => 1, :b => 2}
#=> true

## Implements a comparison operator
@tags.respond_to? :'<=>'
#=> true

## Comparison operator returns 0 for same values
@tags <=> {:a => 1, :b => 2}
#=> 0

## Comparison operator returns 1 when it's a superset of other
@tags <=> {:a => 1}
#=> 1

## Comparison operator returns -1 when it's a subset of other
@tags <=> {:a => 1, :b => 2, :c => 3}
#=> -1

## > returns false when compared to a hash with more key value pairs
@tags > {:a => 1, :b => 2, :c => 3}
#=> false

## > returns true when compared to a hash with fewer key value pairs
@tags > {:b => 2}
#=> true

## < returns true when compared to a hash with more key value pairs
@tags < {:a => 1, :b => 2, :c => 3}
#=> true

## < returns false when compared to a hash with fewer key value pairs
@tags < {:b => 2}
#=> false

## < returns false when compared to a hash with same values
@tags < {:a => 1, :b => 2}
#=> false

## <= returns true when compared to a hash with same values
@tags <= {:b => 2, :a => 1}
#=> true

## < returns false when compared to an array with same values
@tags < [1, 2]
#=> false

## <= returns true when compared to an array with same values
@tags <= [2, 1]
#=> true

