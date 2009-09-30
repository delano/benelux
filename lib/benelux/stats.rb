
module Benelux
  class Stats
    attr_reader :names
    def initialize(*methods)
      @names = methods.flatten
      @names.each { |meth| add_keeper(meth) }
    end
    def add_keeper(meth)
      self.class.send :attr_reader, meth
      instance_variable_set("@#{meth}", Benelux::Stats::Group.new(meth))
    end
    
    class Group < Array
      attr_reader :name
      def initialize(name)
        @name = name
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
      
      def [](*tags)
        tags = Benelux::TagHelpers.normalize tags
        self.select { |c| c.tags >= tags }
      end
      

    end
    
    # Based on Mongrel::Stats, Copyright (c) 2005 Zed A. Shaw
    class Calculator < Array
      include Benelux::TagHelpers
      
      attr_reader :sum, :sumsq, :n, :min, :max

      def initialize
        reset
      end
  
      def +(obj)
        raise
      end
  
      # Resets the internal counters so you can start sampling again.
      def reset
        self.clear
        @n, @sum, @sumsq = 0.0, 0.0, 0.0
        @last_time = 0.0
        @min, @max = 0.0, 0.0
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
        out.puts "#{msg}: #{self.inspect}"
      end

      # Returns a common display (used by dump)
      def inspect
        v = [mean, @n, @sum, @sumsq, sd, @min, @max]
        t = %q'N=%0.4f SUM=%0.4f SUMSQ=%0.4f SD=%0.4f MIN=%0.4f MAX=%0.4f"'
        ('"%0.4f: ' << t) % v
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