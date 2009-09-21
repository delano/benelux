group "Benelux Concept Proofs"

xtryouts "Time benchmarks", :benchmark do
  set :runcount, 100000
  
  drill "Create Array", 1 do
    @@timers = []
  end
  
  drill "Time.now overhead", 5 do
    runcount.times { Time.now.to_f }
  end
  
  drill "[] << Time.now overhead", 5 do
    runcount.times { @@timers << Time.now.to_f }
  end
  
end

require 'date'
tryouts "Time proofs", :api do
  set :runcount, 100000
  
  drill "All calls to Time.now.to_f are unique (will fail)", 0 do
    timers = []
    runcount.times { timers << Time.now.to_f; sleep 0.00000001 }
    timers.size - timers.uniq.size
  end
  
end