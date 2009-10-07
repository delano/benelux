

require 'threadify'

parallel = 20
runcount = 100_000
baseline = []
testcase = []

def timer(&blk)
  s = Time.now; blk.call; puts ('%.4f' % (Time.now - s).to_f)
end

print "Populate baseline: "
timer do 
  parallel.times do
    seed = "a"
    (runcount).times do
      baseline << seed.succ!.clone
    end
  end
end

print "Start #{parallel} threads: "
threads = []
timer do 
  parallel.times do
    threads << Thread.new do
      seed = "a"
      runcount.times { testcase << seed.succ!.clone }
    end
  end
end

print "Wait for threads: "
timer do
  threads.each { |t| t.join }
end

# Compare baseline to testcase
p [:size,   testcase.size == baseline.size]
p [:sorted, testcase.sort == baseline.sort]

__END__

Module.method_added?