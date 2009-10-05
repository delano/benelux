
tryouts "Array speed", :benchmark do
  set :base, []
  
  drill "Populate array" do
    10_000_000.times { base << 1 }
  end
  
  drill "with <<" do
    a = []
    base.each { |v|
      a << v
    }
    a.flatten!
  end
  
  # SLOOOOOWWWWW (b/c it creates a new Array every iteration)
  xdrill "with +=" do
    a = []
    base.each {|v|
      a += [v]
    }
    a
  end
  
  drill "with select" do
    a = base.select { |v|
      true
    }
    Array.new(a)
  end
  
end
