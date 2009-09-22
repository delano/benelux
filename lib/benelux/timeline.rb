
module Benelux
  # 
  # |------+----+--+----+----|
  #        |
  #       0.02  
  class Timeline < Array
    attr_accessor :regions
    
    def initialize(*args)
      @regions = []
      super
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
    #     obj.regions(:do_request) =>
    #         [[:do_request_a, :do_request_z], [:do_request_a, ...]]
    #    
    def regions(*names)
      return @regions if names.empty?
      names = names.flatten.collect { |n| n.to_s }
      @regions.select do |region| 
        names.member? region.name.to_s
      end
    end

    #
    #     obj.ranges(:do_request) =>
    #         [[:do_request_a, :get_body, :do_request_z], [:do_request_a, ...]]
    #
    def ranges(*names)
      return self if names.empty?
      self.regions(*names).collect do |region|
        self.sort.select do |mark|
          mark >= region.from && 
          mark <= region.to &&
          mark.thread_id == region.to.thread_id
        end
      end
    end
    
    def add_mark(name)
      mark = Benelux::Mark.now(name)
      Benelux.thread_timeline << mark
      self << mark
      mark
    end

    def add_mark_open(name)
      add_mark Benelux.name(name, SUFFIX_START)
    end

    def add_mark_close(name)
      add_mark Benelux.name(name, SUFFIX_END)
    end
    
    def add_region(name, from, to)
      region = Benelux::Region.new(name, from, to)
      @regions << region
      Benelux.thread_timeline.regions << region
      region
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