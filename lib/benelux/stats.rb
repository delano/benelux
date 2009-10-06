
module Benelux
  class Stats
    attr_reader :names
    
    def initialize(*names)
      @names = []
      add_groups names
    end
    def group(name)
      @names.member?(name) ? self.send(name) : create_zero_group(name)
    end
    def create_zero_group(name)
      g = Benelux::Stats::Group.new
      g.name = name
      g.sample(0)
      g
    end
    # Each group
    def each(&blk)
      @names.each { |name| blk.call(group(name)) }
    end
    # Each group name, group
    def each_pair(&blk)
      @names.each { |name| blk.call(name, group(name)) }
    end
    def add_groups(*args)
      args.flatten.each do |meth|
        next if has_group? meth
        @names << meth
        self.class.send :attr_reader, meth
        (g = Benelux::Stats::Group.new).name = meth
        instance_variable_set("@#{meth}", g)
      end
    end
    def sample(name, s, tags={})
      self.send(name).sample(s, tags)
    end
    alias_method :add_group, :add_groups
    def has_group?(name)
      @names.member? name
    end
    def +(other)
      if !other.is_a?(Benelux::Stats)
        raise TypeError, "can't convert #{other.class} into Stats" 
      end
      other.names.each do |name|
        add_group name
        a = self.send(name) 
        a += other.send(name)
        a
      end
      self
    end
    
    class Group < Array
      include Selectable
      
      attr_accessor :name
      
      def +(other)
        unless @name == other.name
          raise BeneluxError, "Cannot add #{other.name} to #{@name}"
        end
        other.each do |newcalc|
          # Merge calculator with a like calculator in another group.
          calcs = self.select { |calc| calc.tags == newcalc.tags }
          # This should only ever contain one b/c we should
          # not have several calculators with the same tags. 
          calcs.each do |calc|
            calc += newcalc
          end
          self << newcalc
        end
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
    
    # Based on Mongrel::Stats, Copyright (c) 2005 Zed A. Shaw
    class Calculator < Array
      include Selectable::Object
      
      attr_reader :sum, :sumsq, :n, :min, :max

      def initialize
        reset
      end
  
      def +(other)
        self.push *other
        self.recalculate
        self
      end
  
      # Resets the internal counters so you can start sampling again.
      def reset
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
        reset
        self.each { |s| update(s) }
        self
      end
  
    end
    
    
  end
end