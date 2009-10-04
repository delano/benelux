
group "Benelux"

library :benelux, 'lib'
tryouts "Calculator" do
  
  dream :class, Benelux::Stats::Calculator
  dream :n, 10
  drill "can keep stats" do
    stat = Benelux::Stats::Calculator.new
    10.times { stat.sample(rand) }
    stat
  end
  
end

tryouts "Stats" do
  set :stat_names, [:execute, :request, :first_byte]
  
  dream stat_names
  drill "knows stats names" do
    stats = Benelux::Stats.new(stat_names)
    stats.names
  end
  
  drill "can keep multiple stats", true do
    stats = Benelux::Stats.new(stat_names)
    stats.execute.sample(rand)
    stats.request.sample(rand*-1)
    stats.execute != stats.request
  end
  
  dream [true, true, true]
  drill "can keep stats with tags" do
    stats = Benelux::Stats.new(stat_names)
    3.times { |i|
      stats.execute.sample(rand, :usecase => '11')
      stats.execute.sample(rand, :usecase => '11', :request => '22')
      stats.execute.sample(rand, :request => '22')
    }
    stash :execute_stats, stats.execute
    [
      stats.execute['11'] == stats.execute[:usecase => '11'],
      stats.execute['22'] == stats.execute[:request => '22'],
      stats.execute['22','11'] == stats.execute[:usecase => '11', :request => '22']
    ]
  end
  
end