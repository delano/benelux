
group "Benelux"

library :benelux, 'lib'
tryouts "Stats" do
  
  dream :class, Benelux::StatKeeper
  dream :n, 10
  drill "can keep stats" do
    keeper = Benelux::StatKeeper.new
    10.times { keeper.sample(rand) }
    keeper
  end
  
  dream :class, Benelux::TimerStats
  drill "can keep multiple stats" do
    methods = [:execute, :request, :first_byte]
    stats = Benelux::TimerStats.new(methods)
  end
  
end