
group "Benelux"

library :benelux, 'lib'
tryouts "Calculator" do
  set :base, Benelux::Stats::Calculator.new
  dream :class, Benelux::Stats::Calculator
  dream :n, 10
  dream :sum, 45
  dream :sumsq, 285
  dream :min, 0
  dream :max, 9
  dream :proc, lambda { |calc| calc.sd.to_i == 3 }
  drill "can keep stats" do
    10.times { |i| base.sample(i) }
    base
  end
  
  dream true
  drill "can add stats" do
    by_sample = Benelux::Stats::Calculator.new
    10.times { |i| by_sample.sample(i) }
    by_sample += base
    by_merge = Benelux::Stats::Calculator.new
    by_merge.merge! base
    by_merge.merge! base
    stash :sample, by_sample
    stash :merge, by_merge
    by_sample == by_merge
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