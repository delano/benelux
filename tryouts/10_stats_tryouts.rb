require 'benelux'

@base = Benelux::Stats::Calculator.new
@stat_names = [:execute, :request, :first_byte]

## "can keep stats"
10.times { |i| @base.sample(i) }
@base.sum
#=> 45

## "can add stats"
by_sample = Benelux::Stats::Calculator.new
10.times { |i| by_sample.sample(i) }
by_sample += @base
by_merge = Benelux::Stats::Calculator.new
by_merge.merge! @base
by_merge.merge! @base
p [:sample, by_sample]
p [:merge, by_merge]
by_sample == by_merge
#=> true


## "knows stats names"
stats = Benelux::Stats.new(@stat_names)
stats.names
#=> @stat_names


## "can keep multiple stats"
stats = Benelux::Stats.new(@stat_names)
stats.execute.sample(rand)
stats.request.sample(rand*-1)
stats.execute != stats.request
#=> true


## "can keep stats with tags"
stats = Benelux::Stats.new(@stat_names)
3.times { |i|
  stats.execute.sample(rand, :usecase => '11')
  stats.execute.sample(rand, :usecase => '11', :request => '22')
  stats.execute.sample(rand, :request => '22')
}
[
  stats.execute['11'] == stats.execute[:usecase => '11'],
  stats.execute['22'] == stats.execute[:request => '22'],
  stats.execute['22','11'] == stats.execute[:usecase => '11', :request => '22']
]
#=> [true, true, true]