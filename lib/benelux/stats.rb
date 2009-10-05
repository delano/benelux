
module Benelux
  class Stats < Hash
    def initialize(*groups)
      groups.each { |n| add_group(n) }
    end
    def add_group(n,v=Calculator.new)
      self.store(n, v)
    end
    def method_missing(meth, *args)
      return self.group(meth) if self.group?(meth)
      super  
    end
    alias_method :group?, :has_key?
    alias_method :group, :fetch
    alias_method :groups, :keys
    def sample(name, s, tags={})
      self.send(name).sample(s, tags)
    end
    def +(other)
      if !other.is_a?(Benelux::Stats)
        raise TypeError, "can't convert #{other.class} into Stats" 
      end
      other.names.each do |name|
        add_group name
        a = self.group(name) 
        a += other.group(name)
        a
      end
      self
    end
    
    
    # Based on Mongrel::Stats, Copyright (c) 2005 Zed A. Shaw
    class Calculator < Array
      include Selectable::Object
      
      attr_reader :sum, :sumsq, :n, :min, :max

      def initialize
        reset
      end
  
      def +(other)
        super(other)
        self.recalculate
        self
      end
  
      # Resets the internal counters so you can start sampling again.
      def reset
        self.clear
        @n, @sum, @sumsq = 0.0, 0.0, 0.0
        @last_time = 0.0
        @min, @max = 0.0, 0.0
      end
      
      def samples(*args)
        args.flatten.each { |s| sample(s) }
      end
      
      # Adds a sampling to the calculations.
      def sample(s)
        self << s
        update s
      end
  
      def update(s)
        @sum += s
        @sumsq += s * s
        if @n == 0
          @min = @max = s
        else
          @min = s if @min > s
          @max = s if @max < s
        end
        @n+=1
      end
  
      # Dump this Stats object with an optional additional message.
      def dump(msg = "", out=STDERR)
        out.puts "#{msg}: #{self.report}"
      end

      # Returns a common display (used by dump)
      def report
        v = [mean, @n, @sum, @sumsq, sd, @min, @max]
        t = %q'%8d(N) %10.4f(SUM) %8.4f(SUMSQ) %8.4f(SD) %8.4f(MIN) %8.4f(MAX)'
        ('%0.4f: ' << t) % v
      end
      
      def inspect
        v = [ mean, @n, @sum, @sumsq, sd, @min, @max, tags]
        "%.4f: n=%.4f sum=%.4f sumsq=%.4f sd=%.4f min=%.4f max=%.4f %s" % v
      end
      
      def to_s; mean.to_s; end
      def to_f; mean.to_f; end
      def to_i; mean.to_i; end
  
      # Calculates and returns the mean for the data passed so far.
      def mean; return 0.0 unless @n > 0; @sum / @n; end

      # Calculates the standard deviation of the data so far.
      def sd
        return 0.0 if @n <= 1
        # (sqrt( ((s).sumsq - ( (s).sum * (s).sum / (s).n)) / ((s).n-1) ))
        begin
          return Math.sqrt( (@sumsq - ( @sum * @sum / @n)) / (@n-1) )
        rescue Errno::EDOM
          return 0.0
        end
      end
  
      def recalculate
        samples = self.clone
        reset
        samples.each { |s| sample(s) }
      end
  
    end
    
    
  end
end


__END__

class Group < Array
  include Selectable
  
  attr_accessor :name
  
  def +(other)
#        p [name, other.filter('2bf1f5ebc7572115df6ea53294fe0b67037a5190', '7d43d6adcb01a18c218f05531412b35865c703ba').size]
    other.each do |newcalc|
      #calcs = self.select { |calc| calc.tags == newcalc.tags }
      self << newcalc
      # This should only ever contain one b/c we should
      # not have several calculators with the same tags. 
      #calcs.each do |calc|
      #  calc += newcalc
      #end
    end
    p [name, self.size]
    #p [name, self, other]
    self
  end
  
  def sample(s, tags={})
    raise BeneluxError, "tags must be a Hash" unless tags.kind_of?(Hash)
    calcs = self.select { |c| c.tags == tags }
    if calcs.empty?
      (c = Calculator.new).add_tags tags
      self << c
      calcs = [c]
    end
    calcs.each { |c| c.sample(s) }
    nil
  end
  
  def tag_values(tag)
    vals = self.collect { |calc| calc.tags[tag] }
    Array.new vals.uniq
  end
  
  def tags()    merge.tags   end
  def mean()    merge.mean   end
  def min()     merge.min    end
  def max()     merge.max    end
  def sum()     merge.sum    end
  def sd()      merge.sd     end
  def n()       merge.n      end
  
  def merge(*tags)
    tags = Selectable.normalize tags
    mc = Calculator.new
    mc.init_tags!
    all = tags.empty? ? self : self.filter(tags)
    all.each { |calc| 
      mc.samples calc
      mc.add_tags_quick calc.tags
    }
    mc
  end
  
  def filter(*tags)
    (f = super).name = @name
    f
  end
  alias_method :[], :filter
  
end