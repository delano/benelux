
module Benelux
  # 
  # |------+----+--+----+----|
  #        |
  #       0.02  
  class Timeline < Array
    attr_accessor :ranges
    
    def initialize(*args)
      @ranges = []
      super
    end
    
    def duration
      self.last - self.first
    end
    
    def each(*args, &blk)
      if args.empty? 
        super(&blk) 
      else 
        self.marks(*args).each(&blk)
      end
    end
    
    #
    #      obj.marks(:execute_a, :execute_z, :do_request_a) => 
    #          [:execute_a, :do_request_a, :do_request_a, :execute_z]
    #
    def marks(*names)
      return self if names.empty?
      names = names.flatten.collect { |n| n.to_s }
      self.select do |mark| 
        names.member? mark.name.to_s
      end
    end

    #
    #     obj.ranges(:do_request) =>
    #         [[:do_request_a, :do_request_z], [:do_request_a, ...]]
    #    
    def ranges(*names)
      return @ranges if names.empty?
      names = names.flatten.collect { |n| n.to_s }
      @ranges.select do |range| 
        names.member? range.name.to_s
      end
    end

    #
    #     obj.ranges(:do_request) =>
    #         [[:do_request_a, :get_body, :do_request_z], [:do_request_a, ...]]
    #
    def regions(*names)
      return self if names.empty?
      self.ranges(*names).collect do |range|
        self.sort.select do |mark|
          ret = mark >= range.from && 
          mark <= range.to &&
          ((!mark.track.nil? && mark.track == range.track) ||
          mark.thread_id == range.to.thread_id)
          ret
        end
      end
    end
    
    def add_mark(name, call_id)
      mark = Benelux::Mark.now(name, call_id)
      Benelux.thread_timeline << mark
      self << mark
      mark
    end
    
    def add_range(name, from, to)
      range = Benelux::Range.new(name, from, to)
      @ranges << range
      Benelux.thread_timeline.ranges << range
      range
    end
    
    def to_line
      marks = self.sort
    end
    
    def to_line2
      marks = self.sort
      str, prev = [], marks.first
      marks.each do |mark|
        str << "%s(%s):%.4f" % [mark.name, mark.thread_id, mark.to_s(prev)]
        prev = mark
      end
      str.join('; ')
    end
    def +(other)
      self << other
      self.flatten
    end
    # Needs to compare thread id and call id. 
    #def <=>(other)
    #end
  end
end