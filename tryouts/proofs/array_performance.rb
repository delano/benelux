
xtryouts "Array speed", :benchmark do
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


tryouts "Array merge speed", :benchmark do
  set :size, 10_000_000
  set :merges, 100_000
  
  drill "Create #{size} element Array" do
    final = []
    size.times { final << 1 }
  end
  
  drill "Merge #{size} element Array" do
    all = []
    msize = size / merges
    merges.times do
      a = []
      msize.times { a << 1 }
      all << a
    end
    final = []
    all.each { |a| final.push *a }
  end
  
end
