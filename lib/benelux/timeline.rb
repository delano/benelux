
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
    
    ##def between(*names)
    ##  name_s, name_e = *names.collect { |n| Benelux.name n }
    ##  time_s, time_e = at(name_s), at(name_e)
    ##  time_e.first.to_f - time_s.first.to_f
    ##end
    ##def duration(*names)
    ##  name = Benelux.name *names
    ##  name_s, name_e = "#{name}_a", "#{name}_z"
    ##  between(name_s, name_e)
    ##end
    
    #
    #     obj.region(:do_request_a, :do_request_z) =>
    #         [[:do_request_a, :get_body, :do_request_z], [:do_request_a, ...]]
    #
    ##def regions(from, to)
    ##  pairs = marks(from).zip marks(to)
    ##  pairs.collect do |pair|
    ##    idx_a, idx_z = self.index(pair[0]), self.index(pair[1])
    ##    range = self.values_at idx_a..idx_z
    ##    range.select do |mark|
    ##      mark.thread_id
    ##    end
    ##  end
    ##end
    
    #
    #      obj.marks(:execute_a, :execute_z, :do_request_a) => 
    #          [:execute_a, :do_request_a, :do_request_a, :execute_z]
    #
    def marks(*names)
      names = names.flatten.collect { |n| n.to_s }
      self.select do |mark| 
        names.member? mark.name.to_s
      end
    end
    
    def duration(name)
      name_s = Benelux.name name, SUFFIX_START 
      name_e = Benelux.name name, SUFFIX_END
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